#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

use std::collections::HashMap;
use std::io::{Cursor, Read, Seek, SeekFrom};
use std::path::Path;
use std::sync::Mutex;
use nwn_erf::ErfFile;
use nwnrs_types::resman::{ResContainer, ResRef};

pub type Result<T> = std::result::Result<T, TilesetError>;

#[derive(Debug, thiserror::Error)]
pub enum TilesetError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Parse error: {0}")]
    Parse(String),
    #[error("ERF error: {0}")]
    Erf(#[from] nwn_erf::ErfError),
    #[error("Tileset not found: {0}")]
    NotFound(String),
}

#[derive(Debug, Clone)]
pub struct Tileset {
    pub name: String,
    pub tiles: HashMap<u32, TileDef>,
}

#[derive(Debug, Clone)]
pub struct TileDef {
    pub id: u32,
    pub model_name: String,
}

impl Tileset {
    pub fn from_bytes(name: &str, data: &[u8]) -> Result<Self> {
        let text = std::str::from_utf8(data)
            .map_err(|e| TilesetError::Parse(format!("invalid UTF-8 in .set: {e}")))?;
        let set_file = nwnrs_types::set::parse_set(text)
            .map_err(|e| TilesetError::Parse(e.to_string()))?;

        let mut tiles = HashMap::new();
        for tile in set_file.tiles.values() {
            if let Some(ref model) = tile.model {
                tiles.insert(tile.id, TileDef {
                    id: tile.id,
                    model_name: model.to_lowercase(),
                });
            }
        }

        Ok(Self {
            name: name.to_lowercase(),
            tiles,
        })
    }

    pub fn tile_model(&self, tile_id: u32) -> Option<&str> {
        self.tiles.get(&tile_id).map(|t| t.model_name.as_str())
    }
}

pub fn game_data_dir() -> Option<std::path::PathBuf> {
    let home = std::env::var("HOME").ok()?;
    let data_dir = Path::new(&home)
        .join(".local/share/Steam/steamapps/common/Neverwinter Nights/data");
    if data_dir.is_dir() { Some(data_dir) } else { None }
}

/// Global cache for game data (KEY/BIF) resources — avoids re-reading on disk misses.
/// Key is format `"{resref_lower}:{restype}"`, caches the raw bytes once loaded.
/// Clears entirely when total cached bytes exceed the limit (~256 MB).
struct BoundedGameDataCache {
    map: HashMap<String, Option<Vec<u8>>>,
    total_bytes: usize,
    max_bytes: usize,
}

impl BoundedGameDataCache {
    fn new(max_bytes: usize) -> Self {
        Self { map: HashMap::new(), total_bytes: 0, max_bytes }
    }

    fn get(&self, key: &str) -> Option<&Option<Vec<u8>>> {
        self.map.get(key)
    }

    fn insert(&mut self, key: String, value: Option<Vec<u8>>) {
        let size = value.as_ref().map(|v| v.len()).unwrap_or(0);
        // If the key already exists, subtract its old size first
        if let Some(old_val) = self.map.get(&key) {
            if let Some(v) = old_val {
                self.total_bytes = self.total_bytes.saturating_sub(v.len());
            }
        }
        // Clear entire cache if adding this would exceed the limit
        if self.total_bytes + size > self.max_bytes {
            self.map.clear();
            self.total_bytes = 0;
        }
        self.total_bytes += size;
        self.map.insert(key, value);
    }
}

static GAME_DATA_CACHE: std::sync::OnceLock<Mutex<BoundedGameDataCache>> =
    std::sync::OnceLock::new();

const GAME_DATA_CACHE_MAX_BYTES: usize = 256 * 1024 * 1024; // 256 MB

fn game_data_cache() -> &'static Mutex<BoundedGameDataCache> {
    GAME_DATA_CACHE.get_or_init(|| Mutex::new(BoundedGameDataCache::new(GAME_DATA_CACHE_MAX_BYTES)))
}

fn cache_key(resref: &ResRef) -> String {
    format!("{}:{}", resref.res_ref().to_lowercase(), resref.res_type().0)
}

pub fn load_resource_from_key(resref: &nwnrs_types::resman::ResRef, data_dir: &Path) -> Result<Option<Vec<u8>>> {
    let ck = cache_key(resref);
    // Check cache first
    {
        let cache = game_data_cache().lock().unwrap();
        if let Some(cached) = cache.get(&ck) {
            return Ok(cached.clone());
        }
    }
    // Load from disk (may block on I/O)
    let result = load_resource_from_key_uncached(resref, data_dir);
    // Cache result (even None to avoid repeated misses)
    if let Ok(ref data) = result {
        let mut cache = game_data_cache().lock().unwrap();
        cache.insert(ck, data.clone());
    }
    result
}

fn load_resource_from_key_uncached(resref: &nwnrs_types::resman::ResRef, data_dir: &Path) -> Result<Option<Vec<u8>>> {
    let key_names = &["nwn_base.key", "nwn_retail.key", "nwn_expn.key", "nwn_x1.key", "nwn_x2.key", "nwnx1.key", "nwnx2.key"];
    for key_name in key_names {
        let key_path = data_dir.join(key_name);
        if !key_path.exists() { continue; }
        if let Ok(key_table) = nwnrs_types::key::read_key_table_from_file(&key_path) {
            if key_table.contains(resref) {
                if let Ok(res) = key_table.demand(resref) {
                    if let Ok(data) = res.read_all(nwnrs_types::resman::CachePolicy::Bypass) {
                        return Ok(Some(data));
                    }
                }
            }
        }
    }
    Ok(None)
}

pub fn find_tileset_in_game_data(name: &str) -> Result<Option<Tileset>> {
    let data_dir = match game_data_dir() {
        Some(d) => d,
        None => return Ok(None),
    };
    let set_lower = name.to_lowercase();
    let set_resref = match nwnrs_types::resman::ResRef::new(set_lower, nwnrs_types::resman::ResType(2013)) {
        Ok(rr) => rr,
        Err(_) => return Ok(None),
    };
    match load_resource_from_key(&set_resref, &data_dir)? {
        Some(data) => {
            match Tileset::from_bytes(name, &data) {
                Ok(ts) => Ok(Some(ts)),
                Err(e) => {
                    eprintln!("Warning: failed to parse tileset '{}' from game data: {}", name, e);
                    Ok(None)
                }
            }
        }
        None => Ok(None),
    }
}

#[derive(Clone)]
pub struct ModelMesh {
    pub positions: Vec<[f32; 3]>,
    pub normals: Vec<[f32; 3]>,
    pub indices: Vec<u32>,
    pub uvs: Vec<[f32; 2]>,
    pub colors: Vec<[f32; 4]>,
    pub texture_name: Option<String>,
    pub name: String,
}

pub fn load_model_mesh(model_name: &str) -> Result<Option<ModelMesh>> {
    let meshes = load_model_meshes(model_name)?;
    match meshes {
        Some(mut ms) if !ms.is_empty() => {
            // Merge all texture groups into a single mesh (keep first texture name)
            let first = ms.swap_remove(0);
            if ms.is_empty() {
                Ok(Some(first))
            } else {
                let mut pos = first.positions;
                let mut norms = first.normals;
                let mut u = first.uvs;
                let mut c = first.colors;
                let mut idx = first.indices;
                let tex_name = first.texture_name;
                for m in ms {
                    let base = pos.len() as u32;
                    pos.extend(m.positions);
                    norms.extend(m.normals);
                    u.extend(m.uvs);
                    c.extend(m.colors);
                    for i in m.indices {
                        idx.push(base + i);
                    }
                }
                Ok(Some(ModelMesh { positions: pos, normals: norms, indices: idx, uvs: u, colors: c, texture_name: tex_name, name: model_name.to_string() }))
            }
        }
        _ => Ok(None),
    }
}

/// Load a model and return one `ModelMesh` per unique texture name.
/// This correctly handles NWN tile models that have different textures
/// for floor, walls, furniture, etc.
pub fn load_model_meshes(model_name: &str) -> Result<Option<Vec<ModelMesh>>> {
    let data_dir = match game_data_dir() {
        Some(d) => d,
        None => return Ok(None),
    };

    let name_lower = model_name.to_lowercase();

    let data = {
        let mut result = None;
        for restype in &[2002, 2001] {
            if let Ok(rr) = nwnrs_types::resman::ResRef::new(
                name_lower.clone(),
                nwnrs_types::resman::ResType(*restype),
            ) {
                if let Some(d) = load_resource_from_key(&rr, &data_dir)? {
                    result = Some(d);
                    break;
                }
            }
        }
        match result {
            Some(d) => d,
            None => return Ok(None),
        }
    };

    load_model_meshes_from_data(model_name, &data)
}

/// Search hak files (one at a time) for a model mesh. Opens only one hak at a time.
pub fn load_model_meshes_from_haks(
    model_name: &str,
    mod_dir: &Path,
    hak_names: &[String],
) -> Option<Vec<ModelMesh>> {
    let name_lower = model_name.to_lowercase();
    let home = std::env::var("HOME").ok();
    for hak_name in hak_names {
        let paths = [
            mod_dir.join(format!("{}.hak", hak_name)),
            mod_dir.join("hak").join(format!("{}.hak", hak_name)),
        ];
        for p in &paths {
            if let Ok(erf) = ErfFile::open(p) {
                for &restype in &[2002u16, 2001u16] {
                    if let Some(data) = erf.get(&name_lower, restype) {
                        if let Ok(Some(meshes)) = load_model_meshes_from_data(model_name, &data) {
                            return Some(meshes);
                        }
                    }
                }
                break;
            }
        }
        if let Some(ref home) = home {
            let p = Path::new(home).join("Documents/Neverwinter Nights/hak").join(format!("{}.hak", hak_name));
            if p.exists() {
                if let Ok(erf) = ErfFile::open(&p) {
                    for &restype in &[2002u16, 2001u16] {
                        if let Some(data) = erf.get(&name_lower, restype) {
                            if let Ok(Some(meshes)) = load_model_meshes_from_data(model_name, &data) {
                                return Some(meshes);
                            }
                        }
                    }
                }
            }
        }
    }
    None
}

pub fn load_model_meshes_from_data(model_name: &str, data: &[u8]) -> Result<Option<Vec<ModelMesh>>> {
    let scene = match nwnrs_types::mdl::parse_scene_model_auto(data) {
        Ok(s) => s,
        Err(e) => return Err(TilesetError::Parse(format!("Scene parse error for '{model_name}': {e}"))),
    };
    let mut baked = match nwnrs_types::mdl::bake_scene_pose(&scene) {
        Ok(s) => s,
        Err(e) => return Err(TilesetError::Parse(format!("Bake error for '{model_name}': {e}"))),
    };

    // Apply node world transforms
    {
        let mut world = vec![[[0.0f32; 4]; 4]; baked.nodes.len()];
        for (i, node) in baked.nodes.iter().enumerate() {
            let local = nwn_transform_to_mat4(&node.local_transform);
            world[i] = match node.parent {
                Some(p) => mat4_mul(&world[p], &local),
                None => local,
            };
        }
        for mesh in &mut baked.meshes {
            let m = world[mesh.source_node];
            if mat4_is_identity(&m) { continue; }
            for prim in &mut mesh.primitives {
                for pos in &mut prim.positions {
                    *pos = mat4_transform(&m, pos);
                }
                for n in &mut prim.normals {
                    *n = mat4_transform_vector(&m, n);
                }
            }
        }
    }

    // Group geometry by texture name
    struct TexGroup {
        positions: Vec<[f32; 3]>,
        normals: Vec<[f32; 3]>,
        uvs: Vec<[f32; 2]>,
        colors: Vec<[f32; 4]>,
        indices: Vec<u32>,
        texture_name: Option<String>,
    }

    let mut groups: Vec<TexGroup> = Vec::new();

    // Detect tile models by name convention: <tileset>_<id> (e.g. "tcn01_a02_01").
    // Tile model vertex-colored primitives (no texture) are always collision/helper
    // geometry and should be skipped — only textured primitives are visual surfaces.
    let is_tile_model = model_name.len() > 5
        && model_name.as_bytes().get(5) == Some(&b'_')
        && model_name.as_bytes()[0] == b't';

    // First pass: check if any primitive in this model has a texture reference.
    // If at least one does, then None-textured primitives are truly vertex-colored.
    // If none do, they may be creature models whose texture name was filtered out
    // by normalize_texture_name (e.g. c_basilisk texture0 = "c_basilisk" matching a node name).
    let any_textured = baked.meshes.iter().flat_map(|m| &m.primitives).any(|prim| {
        prim.texture_names.first().is_some()
            || prim.material.and_then(|mi| baked.materials.get(mi))
                .is_some_and(|mat| !mat.textures.is_empty())
    });

    for mesh in &baked.meshes {
        // Skip AABB walkmesh/collision geometry
        if let Some(node) = baked.nodes.get(mesh.source_node) {
            use nwnrs_types::mdl::NodeKind;
            if let NodeKind::Aabb = node.kind {
                continue;
            }
        }
        for prim in &mesh.primitives {
            // Determine texture name for this primitive
            let tex_name = prim.texture_names.first().cloned().or_else(|| {
                prim.material.and_then(|mi| {
                    baked.materials.get(mi)
                        .and_then(|mat| mat.textures.first().map(|t| t.name.clone()))
                })
            });
            // NWN convention: "None" means vertex colors only, no texture
            let mut tex_name = tex_name.filter(|n| n.to_ascii_lowercase() != "none");
            if tex_name.is_none() && !any_textured {
                // Model-name-as-texture fallback for creature models (e.g. c_basilisk
                // whose texture "c_basilisk" was dropped by normalize_texture_name).
                // Skip for tile models (which won't have a matching texture).
                if !is_tile_model {
                    tex_name = Some(model_name.to_string());
                }
            }
            let has_texture = tex_name.is_some();

            // Tile model vertex-colored primitives are collision/helper geometry,
            // never visual surfaces. Skip them entirely.
            if is_tile_model && !has_texture {
                continue;
            }

            // Find or create group for this texture
            let gidx = groups.iter().position(|g| g.texture_name == tex_name);
            let gidx = gidx.unwrap_or_else(|| {
                groups.push(TexGroup {
                    positions: Vec::new(),
                    normals: Vec::new(),
                    uvs: Vec::new(),
                    colors: Vec::new(),
                    indices: Vec::new(),
                    texture_name: tex_name,
                });
                groups.len() - 1
            });
            let group = &mut groups[gidx];

            // Load UV set (flip V: OpenGL bottom-left -> wgpu top-left)
            let prim_uvs: Vec<[f32; 2]> = if let Some(uv_set) = prim.uv_sets.first() {
                uv_set.coordinates.iter()
                    .map(|uv| [uv[0], 1.0 - uv[1]])
                    .collect()
            } else {
                vec![[0.0, 0.0]; prim.positions.len()]
            };
            let use_planar = prim_uvs.len() == prim.positions.len() && uvs_are_unreasonable(&prim_uvs);
            let planar_uvs = if use_planar && !prim.positions.is_empty() {
                let min_x = prim.positions.iter().map(|p| p[0]).fold(f32::MAX, f32::min);
                let max_x = prim.positions.iter().map(|p| p[0]).fold(f32::MIN, f32::max);
                let min_z = prim.positions.iter().map(|p| p[2]).fold(f32::MAX, f32::min);
                let max_z = prim.positions.iter().map(|p| p[2]).fold(f32::MIN, f32::max);
                let range_x = (max_x - min_x).max(0.001);
                let range_z = (max_z - min_z).max(0.001);
                prim.positions.iter().map(|p| {
                    [1.0 - (p[0] - min_x) / range_x, 1.0 - (p[2] - min_z) / range_z]
                }).collect::<Vec<_>>()
            } else {
                Vec::new()
            };

            for face in &prim.faces {
                for j in 0..3 {
                    let vi = face.vertex_indices[j] as usize;
                    let uvi = face.uv_indices[j] as usize;

                    let pos = if vi < prim.positions.len() { &prim.positions[vi] } else { &prim.positions[0] };
                    let p = [pos[0], pos[2], -pos[1]];
                    group.positions.push(p);

                    if vi < prim.normals.len() {
                        let n = &prim.normals[vi];
                        group.normals.push([n[0], n[2], -n[1]]);
                    } else {
                        group.normals.push([0.0, 1.0, 0.0]);
                    }

                    let uv = if use_planar {
                        if uvi < planar_uvs.len() { planar_uvs[uvi] } else { [0.0, 0.0] }
                    } else {
                        if uvi < prim_uvs.len() { prim_uvs[uvi] } else { [0.0, 0.0] }
                    };
                    group.uvs.push(uv);

                    let default_color = if has_texture {
                        [1.0, 1.0, 1.0, 1.0]
                    } else if let Some(mi) = prim.material {
                        if let Some(mat) = baked.materials.get(mi) {
                            // Use material diffuse * 0.5 for vertex-colored primitives.
                            // The shader applies (ambient + diffuse + point_lights) ≈ 1.166x,
                            // which over-brightens white vertex colors. Halving the diffuse
                            // compensates so that final color approximates NWN's ambient-only look.
                            [(mat.diffuse[0] * 0.5).min(1.0).max(0.0), (mat.diffuse[1] * 0.5).min(1.0).max(0.0), (mat.diffuse[2] * 0.5).min(1.0).max(0.0), mat.alpha.min(1.0).max(0.0)]
                        } else {
                            [0.35, 0.35, 0.35, 1.0]
                        }
                    } else {
                        [0.35, 0.35, 0.35, 1.0]
                    };
                    // For vertex-colored primitives, skip prim.color_rows — they store meaningless
                    // [1,1,1,1] defaults. Use the material color directly instead.
                    let color = if has_texture && vi < prim.color_rows.len() && prim.color_rows[vi].len() >= 4 {
                        let c = &prim.color_rows[vi];
                        [c[0].min(1.0).max(0.0), c[1].min(1.0).max(0.0), c[2].min(1.0).max(0.0), c[3].min(1.0).max(0.0)]
                    } else {
                        default_color
                    };
                    group.colors.push(color);

                    group.indices.push(group.positions.len() as u32 - 1);
                }
            }
        }
    }

    // Convert groups to ModelMesh with auto-generated normals
    let result: Vec<ModelMesh> = groups.into_iter().filter(|g| !g.positions.is_empty()).map(|g| {
        let normals = compute_normals(&g.positions, &g.indices);
        ModelMesh {
            positions: g.positions,
            normals,
            indices: g.indices,
            uvs: g.uvs,
            colors: g.colors,
            texture_name: g.texture_name,
            name: model_name.to_string(),
        }
    }).collect();

    if result.is_empty() {
        Ok(None)
    } else {
        Ok(Some(result))
    }
}

fn uvs_are_unreasonable(uvs: &[[f32; 2]]) -> bool {
    if uvs.is_empty() { return true; }
    let u_min = uvs.iter().map(|u| u[0]).fold(f32::MAX, f32::min);
    let u_max = uvs.iter().map(|u| u[0]).fold(f32::MIN, f32::max);
    let v_min = uvs.iter().map(|u| u[1]).fold(f32::MAX, f32::min);
    let v_max = uvs.iter().map(|u| u[1]).fold(f32::MIN, f32::max);
    let u_range = (u_max - u_min).abs();
    let v_range = (v_max - v_min).abs();
    u_range > 10.0 || v_range > 10.0 || u_max.abs() > 100.0 || v_max.abs() > 100.0
}

#[allow(dead_code)]
fn compute_planar_uvs(positions: &[[f32; 3]]) -> Vec<[f32; 2]> {
    let min_x = positions.iter().map(|p| p[0]).fold(f32::MAX, f32::min);
    let max_x = positions.iter().map(|p| p[0]).fold(f32::MIN, f32::max);
    let min_z = positions.iter().map(|p| p[2]).fold(f32::MAX, f32::min);
    let max_z = positions.iter().map(|p| p[2]).fold(f32::MIN, f32::max);
    let range_x = (max_x - min_x).max(0.001);
    let range_z = (max_z - min_z).max(0.001);
    positions.iter().map(|p| {
        [(p[0] - min_x) / range_x, (p[2] - min_z) / range_z]
    }).collect()
}

fn compute_normals(positions: &[[f32; 3]], indices: &[u32]) -> Vec<[f32; 3]> {
    let mut normals = vec![[0.0f32; 3]; positions.len()];
    for tri in indices.chunks(3) {
        if tri.len() < 3 { continue; }
        let a = positions[tri[0] as usize];
        let b = positions[tri[1] as usize];
        let c = positions[tri[2] as usize];
        let u = [b[0] - a[0], b[1] - a[1], b[2] - a[2]];
        let v = [c[0] - a[0], c[1] - a[1], c[2] - a[2]];
        let nx = u[1] * v[2] - u[2] * v[1];
        let ny = u[2] * v[0] - u[0] * v[2];
        let nz = u[0] * v[1] - u[1] * v[0];
        let len = (nx * nx + ny * ny + nz * nz).sqrt();
        if len > 0.0 {
            for vi in tri.iter().take(3) {
                normals[*vi as usize][0] += nx / len;
                normals[*vi as usize][1] += ny / len;
                normals[*vi as usize][2] += nz / len;
            }
        }
    }
    for n in &mut normals {
        let len = (n[0] * n[0] + n[1] * n[1] + n[2] * n[2]).sqrt();
        if len > 0.0 {
            n[0] /= len; n[1] /= len; n[2] /= len;
        }
    }
    normals
}

pub struct TextureData {
    pub width: u32,
    pub height: u32,
    pub rgba: Vec<u8>,
}

/// Decode a BMP buffer into RGBA pixels.
/// Handles 24-bit (BGR) and 32-bit (BGRA) uncompressed BMP.
fn decode_bmp_rgba(data: &[u8]) -> Option<TextureData> {
    if data.len() < 54 { return None; }
    let file_size = u32::from_le_bytes([data[2], data[3], data[4], data[5]]);
    if data.len() < file_size as usize { return None; }
    let pixel_offset = u32::from_le_bytes([data[10], data[11], data[12], data[13]]) as usize;
    let width = u32::from_le_bytes([data[18], data[19], data[20], data[21]]);
    let height = u32::from_le_bytes([data[22], data[23], data[24], data[25]]);
    let bpp = u16::from_le_bytes([data[28], data[29]]);
    let compression = u32::from_le_bytes([data[30], data[31], data[32], data[33]]);
    if width == 0 || height == 0 { return None; }
    if compression != 0 { return None; } // only uncompressed
    if bpp != 24 && bpp != 32 { return None; }

    let row_size = ((width * bpp as u32 + 31) / 32) * 4;
    let mut rgba = Vec::with_capacity((width * height * 4) as usize);
    // BMP rows are stored bottom-up
    for y in (0..height).rev() {
        let row_start = pixel_offset + (y as usize) * row_size as usize;
        for x in 0..width {
            let px = row_start + (x as usize) * (bpp as usize / 8);
            if bpp == 24 {
                rgba.push(data[px + 2]);  // R
                rgba.push(data[px + 1]);  // G
                rgba.push(data[px]);      // B
                rgba.push(255);           // A
            } else {
                rgba.push(data[px + 2]);  // R
                rgba.push(data[px + 1]);  // G
                rgba.push(data[px]);      // B
                rgba.push(data[px + 3]);  // A
            }
        }
    }
    Some(TextureData { width, height, rgba })
}

/// Decode raw texture bytes for a given resource type into RGBA.
pub fn decode_texture_data(res_type: u16, data: &[u8]) -> Option<TextureData> {
    match res_type {
        8 => {
            if let Ok(dds) = nwnrs_types::dds::DdsTexture::read_from_texture_bytes(data) {
                if let Ok(rgba) = dds.decode_mip_rgba8(0) {
                    return Some(TextureData { width: dds.width, height: dds.height, rgba });
                }
            }
        }
        3 => {
            if let Ok(tga) = nwnrs_types::tga::read_tga(&mut Cursor::new(data)) {
                if let Ok(rgba) = tga.decode_rgba8() {
                    return Some(TextureData { width: tga.width as u32, height: tga.height as u32, rgba });
                }
            }
        }
        1 => {
            if let Some(tex) = decode_bmp_rgba(data) {
                return Some(tex);
            }
        }
        6 => {
            if let Ok(plt) = nwnrs_types::plt::PltTexture::read_from_texture_bytes(data) {
                if let Ok(rgba) = plt.render_rgba8(&nwnrs_types::plt::PltRenderSpec::default()) {
                    return Some(TextureData { width: plt.width, height: plt.height, rgba });
                }
            }
        }
        _ => {}
    }
    None
}

/// Load a texture by normalizing the name and trying all supported resource types.
fn load_texture_by_name(name: &str, lookup: &dyn Fn(&nwnrs_types::resman::ResRef) -> Option<Vec<u8>>) -> Option<TextureData> {
    let name_lower = name.to_lowercase()
        .replace(".dds", "").replace(".tga", "").replace(".bmp", "")
        .replace(" ", "_").replace("-", "_");

    for res_type in &[8u16, 3u16, 1u16, 6u16] {
        let resref = nwnrs_types::resman::ResRef::new(name_lower.clone(), nwnrs_types::resman::ResType(*res_type)).ok()?;
        if let Some(data) = lookup(&resref) {
            if let Some(tex) = decode_texture_data(*res_type, &data) {
                return Some(tex);
            }
        }
    }
    None
}

/// Search all standard hak directories for a given resource.
#[allow(dead_code)]
fn load_resource_from_haks(resref: &nwnrs_types::resman::ResRef) -> Option<Vec<u8>> {
    let home = std::env::var("HOME").ok()?;
    let hak_dirs = [
        Path::new(&home).join("Documents/Neverwinter Nights/hak"),
        Path::new(&home).join("Documents/Neverwinter Nights/development"),
        Path::new(&home).join(".local/share/Steam/steamapps/common/Neverwinter Nights/hak"),
    ];
    for dir in &hak_dirs {
        if !dir.is_dir() { continue; }
        if let Ok(entries) = std::fs::read_dir(dir) {
            for entry in entries.flatten() {
                let path = entry.path();
                if path.extension().and_then(|e| e.to_str()) != Some("hak") { continue; }
                if let Ok(erf) = nwn_erf::ErfFile::open(&path) {
                    let name_lower = resref.res_ref().to_lowercase();
                    if let Some(data) = erf.get(&name_lower, resref.res_type().0) {
                        return Some(data);
                    }
                }
            }
        }
    }
    None
}

pub fn load_texture_data(texture_name: &str) -> Result<Option<TextureData>> {
    let data_dir = match game_data_dir() {
        Some(d) => d,
        None => return Ok(None),
    };

    Ok(load_texture_by_name(texture_name, &|resref| {
        load_resource_from_key(resref, &data_dir).ok()?
    }))
}

/// Like `load_texture_data` but also searches the given ERF files (module + haks) first.
pub fn load_texture_data_from_sources(
    texture_name: &str,
    erfs: &[&nwn_erf::ErfFile],
) -> Result<Option<TextureData>> {
    // Search ERFs first
    for erf in erfs {
        if let Some(data) = load_texture_from_erf(texture_name, erf) {
            return Ok(Some(data));
        }
    }
    // Fall back to game data
    load_texture_data(texture_name)
}

fn load_texture_from_erf(texture_name: &str, erf: &nwn_erf::ErfFile) -> Option<TextureData> {
    let name = texture_name.to_lowercase()
        .replace(".dds", "").replace(".tga", "").replace(".bmp", "")
        .replace(" ", "_").replace("-", "_");

    for &res_type in &[8u16, 3u16, 1u16, 6u16] {
        if let Some(data) = erf.get(&name, res_type) {
            if let Some(tex) = decode_texture_data(res_type, &data) {
                return Some(tex);
            }
        }
    }
    None
}

/// Search haks one at a time for texture data.
pub fn load_texture_data_from_haks(texture_name: &str, mod_dir: &Path, hak_names: &[String]) -> Result<Option<TextureData>> {
    let name = texture_name.to_lowercase()
        .replace(".dds", "").replace(".tga", "").replace(".bmp", "")
        .replace(" ", "_").replace("-", "_");
    let home = std::env::var("HOME").ok();
    for hak_name in hak_names {
        let paths = [
            mod_dir.join(format!("{}.hak", hak_name)),
            mod_dir.join("hak").join(format!("{}.hak", hak_name)),
        ];
        for p in &paths {
            if let Ok(erf) = ErfFile::open(p) {
                if let Some(tex) = load_texture_from_erf(&name, &erf) {
                    return Ok(Some(tex));
                }
                break;
            }
        }
        if let Some(ref home) = home {
            let p = Path::new(home).join("Documents/Neverwinter Nights/hak").join(format!("{}.hak", hak_name));
            if p.exists() {
                if let Ok(erf) = ErfFile::open(&p) {
                    if let Some(tex) = load_texture_from_erf(&name, &erf) {
                        return Ok(Some(tex));
                    }
                }
            }
        }
    }
    Ok(None)
}

/// Read only the header + key entries of an ERF file and extract a single resource.
/// Avoids loading the entire file into memory (unlike ErfFile::open).
fn extract_resource_from_erf(path: &Path, resref: &str, restype: u16) -> Result<Option<Vec<u8>>> {
    let mut file = match std::fs::File::open(path) {
        Ok(f) => f,
        Err(_) => return Ok(None),
    };
    let file_len = match file.metadata().map(|m| m.len()) {
        Ok(l) => l,
        Err(_) => return Ok(None),
    };
    if file_len < 160 { return Ok(None); }

    let mut header = [0u8; 160];
    if file.read_exact(&mut header).is_err() { return Ok(None); }

    let version = std::str::from_utf8(&header[4..8]).unwrap_or("V0.0");
    let has_long = version >= "V1.1";
    let keys_count = u32::from_le_bytes(header[16..20].try_into().unwrap()) as usize;
    let keys_offset = u32::from_le_bytes(header[24..28].try_into().unwrap()) as u64;
    let resources_offset = u32::from_le_bytes(header[28..32].try_into().unwrap()) as u64;
    if keys_count == 0 || keys_offset > file_len || resources_offset > file_len {
        return Ok(None);
    }

    let key_entry_size: u64 = if has_long { 40 } else { 24 };
    let name_len: usize = if has_long { 32 } else { 16 };
    let key_bytes = (keys_count as u64).saturating_mul(key_entry_size).min(10_000_000);
    if file.seek(SeekFrom::Start(keys_offset)).is_err() { return Ok(None); }
    let mut key_buf = vec![0u8; key_bytes as usize];
    if file.read_exact(&mut key_buf).is_err() { return Ok(None); }

    let resref_lower = resref.to_lowercase();
    for i in 0..keys_count {
        let off = i as u64 * key_entry_size;
        if (off + key_entry_size) as usize > key_buf.len() { break; }
        let off = off as usize;
        let n_end = key_buf[off..off + name_len].iter().position(|&b| b == 0).unwrap_or(name_len);
        let n = std::str::from_utf8(&key_buf[off..off + n_end]).unwrap_or("").to_lowercase();
        if n != resref_lower { continue; }
        let rt_off = off + name_len + 4;
        let rt = u16::from_le_bytes(key_buf[rt_off..rt_off + 2].try_into().unwrap());
        if rt != restype { continue; }
        // Found — read resource entry (offset + size)
        if file.seek(SeekFrom::Start(resources_offset + (i as u64) * 8)).is_err() {
            return Ok(None);
        }
        let mut entry = [0u8; 8];
        if file.read_exact(&mut entry).is_err() { return Ok(None); }
        let data_off = u32::from_le_bytes(entry[0..4].try_into().unwrap()) as u64;
        let data_sz = u32::from_le_bytes(entry[4..8].try_into().unwrap()) as usize;
        if data_sz > 10_000_000 || data_off + data_sz as u64 > file_len { return Ok(None); }
        if file.seek(SeekFrom::Start(data_off)).is_err() { return Ok(None); }
        let mut data = vec![0u8; data_sz];
        if file.read_exact(&mut data).is_err() { return Ok(None); }
        return Ok(Some(data));
    }
    Ok(None)
}

pub fn find_and_load_tileset(name: &str, module_path: &Path, haks: &[String]) -> Result<Option<Tileset>> {
    let mod_dir = module_path.parent().unwrap_or(Path::new("."));
    let set_lower = name.to_lowercase();
    let set_type = nwn_lib_rs::erf::ResourceType::Set as u16;

    fn try_parse(name: &str, data: &[u8]) -> Result<Option<Tileset>> {
        match Tileset::from_bytes(name, data) {
            Ok(ts) => Ok(Some(ts)),
            Err(e) => {
                eprintln!("Warning: failed to parse tileset '{}': {}", name, e);
                Ok(None)
            }
        }
    }

    // First try the module itself
    if let Ok(data) = extract_resource_from_erf(module_path, &set_lower, set_type) {
        if let Some(d) = data {
            if let Some(ts) = try_parse(name, &d)? {
                return Ok(Some(ts));
            }
        }
    }

    // Try haks in module dir
    for hak_name in haks {
        let paths = [
            mod_dir.join(format!("{}.hak", hak_name)),
            mod_dir.join("hak").join(format!("{}.hak", hak_name)),
        ];
        for p in &paths {
            if let Ok(data) = extract_resource_from_erf(p, &set_lower, set_type) {
                if let Some(d) = data {
                    if let Some(ts) = try_parse(name, &d)? {
                        return Ok(Some(ts));
                    }
                }
            }
        }
    }

    // Also check ~/Documents/Neverwinter Nights/hak/
    if let Ok(home) = std::env::var("HOME") {
        let hak_dir = Path::new(&home).join("Documents/Neverwinter Nights/hak");
        if hak_dir.is_dir() {
            for hak_name in haks {
                let hak_path = hak_dir.join(format!("{}.hak", hak_name));
                if let Ok(data) = extract_resource_from_erf(&hak_path, &set_lower, set_type) {
                    if let Some(d) = data {
                        if let Some(ts) = try_parse(name, &d)? {
                            return Ok(Some(ts));
                        }
                    }
                }
            }
        }
    }

    // Finally, try NWN game data (KEY/BIF files)
    match find_tileset_in_game_data(name) {
        Ok(ts) => Ok(ts),
        Err(e) => {
            eprintln!("Warning: game data tileset lookup failed for '{}': {}", name, e);
            Ok(None)
        }
    }
}

/// Build a 4x4 column-major matrix from an NWN node transform (Z-up, axis-angle rotation).
fn nwn_transform_to_mat4(t: &nwnrs_types::mdl::NwnTransform) -> [[f32; 4]; 4] {
    let t_mat: [[f32; 4]; 4] = [
        [1.0, 0.0, 0.0, 0.0],
        [0.0, 1.0, 0.0, 0.0],
        [0.0, 0.0, 1.0, 0.0],
        [t.translation[0], t.translation[1], t.translation[2], 1.0],
    ];
    let r_mat = if t.rotation_axis_angle[3].abs() <= f32::EPSILON {
        IDENTITY_MAT4
    } else {
        let [ax, ay, az] = [t.rotation_axis_angle[0], t.rotation_axis_angle[1], t.rotation_axis_angle[2]];
        let len = (ax*ax + ay*ay + az*az).sqrt();
        if len <= f32::EPSILON {
            IDENTITY_MAT4
        } else {
            let (x, y, z) = (ax / len, ay / len, az / len);
            let (c, s) = (t.rotation_axis_angle[3].cos(), t.rotation_axis_angle[3].sin());
            let omc = 1.0 - c;
            [
                [c + x*x*omc, y*x*omc + z*s, z*x*omc - y*s, 0.0],
                [x*y*omc - z*s, c + y*y*omc, z*y*omc + x*s, 0.0],
                [x*z*omc + y*s, y*z*omc - x*s, c + z*z*omc, 0.0],
                [0.0, 0.0, 0.0, 1.0],
            ]
        }
    };
    let s_mat: [[f32; 4]; 4] = [
        [t.scale[0], 0.0, 0.0, 0.0],
        [0.0, t.scale[1], 0.0, 0.0],
        [0.0, 0.0, t.scale[2], 0.0],
        [0.0, 0.0, 0.0, 1.0],
    ];
    mat4_mul(&mat4_mul(&t_mat, &r_mat), &s_mat)
}

const IDENTITY_MAT4: [[f32; 4]; 4] = [
    [1.0, 0.0, 0.0, 0.0],
    [0.0, 1.0, 0.0, 0.0],
    [0.0, 0.0, 1.0, 0.0],
    [0.0, 0.0, 0.0, 1.0],
];

/// Column-major 4x4 matrix multiply: a * b.
/// Each matrix is stored as [col0, col1, col2, col3] where col[i][j] = row j of column i.
fn mat4_mul(a: &[[f32; 4]; 4], b: &[[f32; 4]; 4]) -> [[f32; 4]; 4] {
    let mut r = [[0.0f32; 4]; 4];
    for col in 0..4 {
        for row in 0..4 {
            for k in 0..4 {
                r[col][row] += a[k][row] * b[col][k];
            }
        }
    }
    r
}

/// Transform a 3D point by a 4x4 column-major matrix (treats w=1).
fn mat4_transform(m: &[[f32; 4]; 4], p: &[f32; 3]) -> [f32; 3] {
    [
        m[0][0]*p[0] + m[1][0]*p[1] + m[2][0]*p[2] + m[3][0],
        m[0][1]*p[0] + m[1][1]*p[1] + m[2][1]*p[2] + m[3][1],
        m[0][2]*p[0] + m[1][2]*p[1] + m[2][2]*p[2] + m[3][2],
    ]
}

/// Transform a 3D vector by a 4x4 column-major matrix (treats w=0, no translation).
fn mat4_transform_vector(m: &[[f32; 4]; 4], v: &[f32; 3]) -> [f32; 3] {
    [
        m[0][0]*v[0] + m[1][0]*v[1] + m[2][0]*v[2],
        m[0][1]*v[0] + m[1][1]*v[1] + m[2][1]*v[2],
        m[0][2]*v[0] + m[1][2]*v[1] + m[2][2]*v[2],
    ]
}

fn mat4_is_identity(m: &[[f32; 4]; 4]) -> bool {
    m[0][0] == 1.0 && m[0][1] == 0.0 && m[0][2] == 0.0 && m[0][3] == 0.0 &&
    m[1][0] == 0.0 && m[1][1] == 1.0 && m[1][2] == 0.0 && m[1][3] == 0.0 &&
    m[2][0] == 0.0 && m[2][1] == 0.0 && m[2][2] == 1.0 && m[2][3] == 0.0 &&
    m[3][0] == 0.0 && m[3][1] == 0.0 && m[3][2] == 0.0 && m[3][3] == 1.0
}

/// Load a 2DA file from game data (KEY/BIF) and look up the model name
/// for a given row index. For `placeables.2da` and `door.2da`, the column
/// is `ModelName`. For `appearance.2da`, the column is the 3rd column (index 2).
pub fn parse_2da_value(text: &str, row: i32, column_label: &str) -> Option<String> {
    let mut lines = text.lines();
    let _header = lines.next();
    let mut headers: Vec<&str> = Vec::new();
    // First non-empty non-comment line after header: could be column names or directly data
    let mut first_meta = None;
    for line in &mut lines {
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') || trimmed.starts_with("//") { continue; }
        headers = trimmed.split(|c| c == '\t' || c == ' ').filter(|s| !s.is_empty()).collect();
        first_meta = Some(trimmed);
        break;
    }
    let col_idx = headers.iter().position(|h| h.eq_ignore_ascii_case(column_label))?;

    // Determine if the "header" line is actually a data row (starts with a digit).
    // If so, there are no column headers and data rows don't have a leading row-number column.
    let is_data_line = first_meta.map_or(false, |l| l.starts_with(|c: char| c.is_ascii_digit()));

    let target = format!("{}", row);
    for line in lines {
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') || trimmed.starts_with("//") { continue; }
        let parts: Vec<&str> = trimmed.split(|c| c == '\t' || c == ' ').filter(|s| !s.is_empty()).collect();
        if parts.is_empty() { continue; }
        if parts[0] == target {
            // If the "header" was actually a data row, parts already include the row-number column,
            // so col_idx is the correct index. Otherwise, data rows have one extra leading column.
            let idx = if is_data_line { col_idx } else { col_idx + 1 };
            let val = parts.get(idx).filter(|s| !s.is_empty() && **s != "****");
            return val.map(|s| s.to_string());
        }
    }
    None
}

/// Parse all rows from a 2DA text and collect values from a given column.
/// Deduplicates by row number to prefer earlier rows (from higher-priority haks).
fn parse_2da_all_rows(text: &str, column_label: &str, results: &mut Vec<(String, String)>, seen: &mut std::collections::HashSet<String>) {
    let mut lines = text.lines();
    let _header = lines.next();
    let mut headers: Vec<&str> = Vec::new();
    let mut first_meta = None;
    for line in &mut lines {
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') || trimmed.starts_with("//") { continue; }
        headers = trimmed.split(|c| c == '\t' || c == ' ').filter(|s| !s.is_empty()).collect();
        first_meta = Some(trimmed);
        break;
    }
    let col_idx = match headers.iter().position(|h| h.eq_ignore_ascii_case(column_label)) {
        Some(i) => i,
        None => return,
    };
    let is_data_line = first_meta.map_or(false, |l| l.starts_with(|c: char| c.is_ascii_digit()));

    for line in lines {
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with('#') || trimmed.starts_with("//") { continue; }
        let parts: Vec<&str> = trimmed.split(|c| c == '\t' || c == ' ').filter(|s| !s.is_empty()).collect();
        if parts.is_empty() { continue; }
        let row_label = parts[0];
        // Skip duplicate row numbers (first one wins = highest priority)
        if !seen.insert(row_label.to_string()) { continue; }
        let idx = if is_data_line { col_idx } else { col_idx + 1 };
        if let Some(val) = parts.get(idx).filter(|s| !s.is_empty() && **s != "****") {
            results.push((row_label.to_string(), val.to_string()));
        }
    }
}

/// Lightweight hak resource index — reads only ERF header + key list (not full file data).
pub struct HakIndex {
    /// Maps resource key (resref_lower, restype) → ordered list of hak names (first = highest priority)
    lookup: HashMap<(String, u16), Vec<String>>,
    /// Known search paths for finding hak files
    paths: Vec<std::path::PathBuf>,
}

impl HakIndex {
    pub fn new(mod_dir: &Path, hak_names: &[String]) -> Self {
        let home = std::env::var("HOME").ok();
        // Build list of possible hak paths, mod dir first (highest priority)
        let mut paths = Vec::new();
        paths.push(mod_dir.to_path_buf());
        paths.push(mod_dir.join("hak"));
        if let Some(ref home) = home {
            paths.push(Path::new(home).join("Documents/Neverwinter Nights/hak"));
        }
        let mod_hak_dir = mod_dir.join("hak");

        let mut lookup = HashMap::new();
        for hak_name in hak_names {
            // Search mod dir first (highest priority)
            let search_paths = [
                mod_dir.join(format!("{}.hak", hak_name)),
                mod_hak_dir.join(format!("{}.hak", hak_name)),
            ];
            for p in &search_paths {
                if Self::index_hak(p, hak_name, &mut lookup) {
                    break;
                }
            }
            // Fall back to home dir
            if !lookup.iter().any(|((_, _), v)| v.iter().any(|n| n == hak_name)) {
                if let Some(ref base) = paths.last() {
                    let home_path = base.join(format!("{}.hak", hak_name));
                    Self::index_hak(&home_path, hak_name, &mut lookup);
                }
            }
        }
        Self { lookup, paths }
    }

    /// Read only the header + key list of a hak file to build the resource index.
    fn index_hak(path: &Path, hak_name: &str, lookup: &mut HashMap<(String, u16), Vec<String>>) -> bool {
        let Ok(mut file) = std::fs::File::open(path) else { return false };
        let Ok(len) = file.metadata().map(|m| m.len()) else { return false };
        if len < 160 { return false; }

        // Read the full 160-byte ERF header
        let mut header = [0u8; 160];
        if file.read_exact(&mut header).is_err() { return false; }

        // Parse header according to nwn-lib-rs format:
        //   0-3: FileType
        //   4-7: FileVersion
        //  8-11: localizedstrings_count
        // 12-15: localizedstrings_size
        // 16-19: keys_count
        // 20-23: localizedstrings_offset
        // 24-27: keys_offset
        // 28-31: resources_offset
        // 32-35: build_year
        // 36-39: build_day
        // 40-43: description_strref
        // 44-159: padding
        let version_bytes = &header[4..8];
        let version = std::str::from_utf8(version_bytes).unwrap_or("V0.0");
        let has_long = version >= "V1.1";

        let keys_count = u32::from_le_bytes(header[16..20].try_into().unwrap());
        let keys_offset = u32::from_le_bytes(header[24..28].try_into().unwrap()) as u64;

        if keys_offset > len || keys_count == 0 { return false; }

        // Key entries: V1.0 = 24 bytes, V1.1+ = 40 bytes
        let key_entry_size: u64 = if has_long { 40 } else { 24 };
        let max_key_bytes = (keys_count as u64).saturating_mul(key_entry_size).min(10_000_000);
        if file.seek(SeekFrom::Start(keys_offset)).is_err() { return false; }
        let mut key_buf = vec![0u8; max_key_bytes as usize];
        if file.read_exact(&mut key_buf).is_err() { return false; }

        for i in 0..keys_count as usize {
            let off = (i as u64) * key_entry_size;
            if off as usize + key_entry_size as usize > key_buf.len() { break; }
            let off = off as usize;
            // ResRef is 16 bytes (V1.0) or 32 bytes (V1.1), null-padded
            let name_len: usize = if has_long { 32 } else { 16 };
            let name_bytes = &key_buf[off..off + name_len];
            let name_end = name_bytes.iter().position(|&b| b == 0).unwrap_or(name_len);
            let name = std::str::from_utf8(&name_bytes[..name_end]).unwrap_or("").to_lowercase();
            if name.is_empty() { continue; }
            // Resource type is at offset 16+4=20 for V1.0 or 32+4=36 for V1.1
            let restype_off = off + name_len + 4;
            let restype = u16::from_le_bytes(key_buf[restype_off..restype_off+2].try_into().unwrap());
            lookup.entry((name, restype)).or_insert_with(Vec::new).push(hak_name.to_string());
        }
        true
    }

    /// Returns all hak names that contain the given resource, in priority order.
    pub fn find_haks(&self, resref: &str, restype: u16) -> Option<&[String]> {
        self.lookup.get(&(resref.to_lowercase(), restype)).map(|v| v.as_slice())
    }

    /// Returns all unique (resref, restype) pairs known to the hak index.
    pub fn all_resources(&self) -> Vec<(String, u16)> {
        let mut v: Vec<(String, u16)> = self.lookup.keys().map(|(r, t)| (r.clone(), *t)).collect();
        v.sort_by(|a, b| a.0.cmp(&b.0).then(a.1.cmp(&b.1)));
        v
    }

    /// Try to load a resource from a specific hak file, searching all known paths.
    pub fn load_from_hak(&self, hak_name: &str, resref: &str, restype: u16, mod_dir: &Path) -> Option<Vec<u8>> {
        let paths = [
            mod_dir.join(format!("{}.hak", hak_name)),
            mod_dir.join("hak").join(format!("{}.hak", hak_name)),
        ];
        for p in &paths {
            if let Ok(erf) = ErfFile::open(p) {
                if let Some(data) = erf.get(resref, restype) {
                    return Some(data);
                }
            }
        }
        for base in &self.paths {
            let p = base.join(format!("{}.hak", hak_name));
            if let Ok(erf) = ErfFile::open(&p) {
                if let Some(data) = erf.get(resref, restype) {
                    return Some(data);
                }
            }
        }
        None
    }

    /// Get a resource from the known hak paths. Tries all haks with the resource (highest priority first).
    pub fn get_resource(&self, resref: &str, restype: u16, mod_dir: &Path) -> Option<Vec<u8>> {
        let hak_names = self.find_haks(resref, restype)?;
        for hak_name in hak_names {
            if let Some(data) = self.load_from_hak(hak_name, resref, restype, mod_dir) {
                return Some(data);
            }
        }
        None
    }

    pub fn get_resource_from_path(&self, resref: &str, restype: u16, mod_dir: &Path) -> Option<Vec<u8>> {
        self.get_resource(resref, restype, mod_dir)
    }

    /// Search all haks for a 2DA value. Tries each hak's 2DA data in priority order,
    /// returning the first match. Useful when multiple haks have the same 2DA with different rows.
    pub fn parse_2da_across_haks(&self, two_da_name: &str, row: i32, column: &str, mod_dir: &Path) -> Option<String> {
        let hak_names = self.find_haks(two_da_name, 2017)?;
        for hak_name in hak_names {
            if let Some(data) = self.load_from_hak(hak_name, two_da_name, 2017, mod_dir) {
                if let Ok(text) = std::str::from_utf8(&data) {
                    if let Some(val) = parse_2da_value(text, row, column) {
                        return Some(val);
                    }
                }
            }
        }
        None
    }

    /// Parse a column from a 2DA across all haks, returning all (row_label, column_value) pairs.
    /// Merges data from all haks (later haks don't overwrite earlier).
    pub fn list_2da_column(&self, two_da_name: &str, column: &str, mod_dir: &Path) -> Vec<(String, String)> {
        let mut results = Vec::new();
        let mut seen = std::collections::HashSet::new();
        let hak_names = match self.find_haks(two_da_name, 2017) {
            Some(n) => n,
            None => return results,
        };
        for hak_name in hak_names {
            if let Some(data) = self.load_from_hak(hak_name, two_da_name, 2017, mod_dir) {
                if let Ok(text) = std::str::from_utf8(&data) {
                    parse_2da_all_rows(text, column, &mut results, &mut seen);
                }
            }
        }
        results
    }

    /// Search all haks for a creature model name via the complex multi-column lookup.
    pub fn find_creature_across_haks(&self, row: i32, mod_dir: &Path) -> Option<String> {
        let hak_names = self.find_haks("appearance", 2017)?;
        for hak_name in hak_names {
            if let Some(data) = self.load_from_hak(hak_name, "appearance", 2017, mod_dir) {
                if let Ok(text) = std::str::from_utf8(&data) {
                    if let Some(name) = lookup_creature_model_from_text(text, row) {
                        return Some(name);
                    }
                }
            }
        }
        None
    }
}

pub fn lookup_model_name_from_2da(
    two_da_name: &str,
    row: i32,
    column_label: &str,
    erfs: &[&ErfFile],
) -> Option<String> {
    for erf in erfs {
        if let Some(data) = erf.get(&two_da_name.to_lowercase(), 2017) {
            if let Ok(text) = std::str::from_utf8(&data) {
                if let Some(name) = parse_2da_value(text, row, column_label) {
                    return Some(name);
                }
            }
        }
    }
    let data_dir = game_data_dir()?;
    let resref = nwnrs_types::resman::ResRef::new(
        two_da_name.to_lowercase(),
        nwnrs_types::resman::ResType(2017),
    ).ok()?;
    let data = load_resource_from_key(&resref, &data_dir).ok()??;
    let text = std::str::from_utf8(&data).ok()?;
    parse_2da_value(text, row, column_label)
}

pub fn lookup_placeable_model(appearance: i32, erfs: &[&ErfFile]) -> Option<String> {
    lookup_model_name_from_2da("placeables", appearance, "ModelName", erfs)
}

pub fn lookup_door_model(
    appearance: i32,
    generic_type: Option<i32>,
    erfs: &[&ErfFile],
) -> Option<String> {
    if appearance > 0 {
        lookup_model_name_from_2da("doortypes", appearance, "ModelName", erfs)
    } else if appearance == 0 {
        lookup_model_name_from_2da("genericdoors", generic_type?, "ModelName", erfs)
    } else {
        None
    }
}

pub fn lookup_creature_model(appearance: i32, erfs: &[&ErfFile]) -> Option<String> {
    for col in &["ModelName", "model", "MODELTYPE", "BODY_MODEL", "BodyModel", "Model"] {
        if let Some(name) = lookup_model_name_from_2da("appearance", appearance, col, erfs) {
            return Some(name);
        }
    }
    let race = lookup_model_name_from_2da("appearance", appearance, "RACE", erfs)?;
    let modeltype = lookup_model_name_from_2da("appearance", appearance, "MODELTYPE", erfs)?;
    let prefix = match race.as_str() {
        "0" | "1" | "2" | "3" => "NWH",
        "4" | "5" | "6" => "NWL",
        _ => "NWH",
    };
    Some(format!("{}_{}", prefix, modeltype))
}

/// Like `lookup_creature_model` but parses from raw 2DA text instead of ERF/game data.
pub fn lookup_creature_model_from_text(text: &str, row: i32) -> Option<String> {
    for col in &["ModelName", "model", "MODELTYPE", "BODY_MODEL", "BodyModel", "Model"] {
        if let Some(name) = parse_2da_value(text, row, col) {
            return Some(name);
        }
    }
    let race = parse_2da_value(text, row, "RACE")?;
    let modeltype = parse_2da_value(text, row, "MODELTYPE")?;
    let prefix = match race.as_str() {
        "0" | "1" | "2" | "3" => "NWH",
        "4" | "5" | "6" => "NWL",
        _ => "NWH",
    };
    Some(format!("{}_{}", prefix, modeltype))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn setup() -> Vec<String> {
        let ts = find_tileset_in_game_data("tin01").unwrap().unwrap();
        let mut names: Vec<String> = ts.tiles.values().map(|t| t.model_name.clone()).collect();
        names.sort();
        names.dedup();
        names
    }

    #[test]
    fn test_uvs_match_positions() {
        for name in setup().iter().take(15) {
            if let Ok(Some(mesh)) = load_model_mesh(name) {
                assert_eq!(mesh.uvs.len(), mesh.positions.len(),
                    "UV count mismatch for {name}");
                let u_min = mesh.uvs.iter().map(|u| u[0]).fold(f32::MAX, f32::min);
                let u_max = mesh.uvs.iter().map(|u| u[0]).fold(f32::MIN, f32::max);
                let v_min = mesh.uvs.iter().map(|u| u[1]).fold(f32::MAX, f32::min);
                let v_max = mesh.uvs.iter().map(|u| u[1]).fold(f32::MIN, f32::max);
                let sample: Vec<[f32;2]> = mesh.uvs.iter().take(5).copied().collect();
                println!("{name}: UV ranges U[{u_min:.3}..{u_max:.3}] V[{v_min:.3}..{v_max:.3}] samples={sample:?}");
            }
        }
    }

    #[test]
    fn test_texture_name_present() {
        let found = setup().iter().take(15).any(|name| {
            load_model_mesh(name).ok().flatten().and_then(|m| m.texture_name).is_some()
        });
        assert!(found, "Expected at least one model to have a texture name");
    }

    #[test]
    fn test_tga_texture_loads() {
        for name in setup().iter().take(10) {
            if let Ok(Some(mesh)) = load_model_mesh(name) {
                if let Some(ref tn) = mesh.texture_name {
                    if let Ok(Some(data)) = load_texture_data(tn) {
                        assert!(data.width > 0 && data.height > 0, "Zero-size texture: {tn}");
                        assert!(!data.rgba.is_empty(), "Empty texture data: {tn}");
                        return;
                    }
                }
            }
        }
        panic!("No loadable texture found in first 10 models");
    }
}
