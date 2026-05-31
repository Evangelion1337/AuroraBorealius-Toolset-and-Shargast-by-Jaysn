use std::collections::HashMap;
use nwn_gamemodel::Area;

#[derive(Debug, Clone, Copy, bytemuck::Pod, bytemuck::Zeroable)]
#[repr(C)]
pub struct Vertex {
    pub position: [f32; 3],
    pub normal: [f32; 3],
    pub uv: [f32; 2],
    pub color: [f32; 4],
}

#[derive(Debug, Clone)]
pub struct MeshData {
    pub vertices: Vec<Vertex>,
    pub indices: Vec<u32>,
}

#[derive(Debug, Clone)]
pub struct ModelGroup {
    pub model_name: Option<String>,
    pub texture_name: Option<String>,
    pub data: MeshData,
}

#[derive(Debug, Clone, Copy, bytemuck::Pod, bytemuck::Zeroable)]
#[repr(C)]
pub struct InstanceData {
    pub row0: [f32; 4],
    pub row1: [f32; 4],
    pub row2: [f32; 4],
    pub row3: [f32; 4],
}

pub struct ModelCache {
    pub cache: HashMap<String, Vec<nwn_tileset::ModelMesh>>,
}

impl ModelCache {
    pub fn new() -> Self {
        Self { cache: HashMap::new() }
    }

    pub fn get_or_load(&mut self, name: &str) -> Option<&Vec<nwn_tileset::ModelMesh>> {
        if self.cache.contains_key(name) {
            return self.cache.get(name);
        }
        match nwn_tileset::load_model_meshes(name) {
            Ok(Some(meshes)) => {
                self.cache.insert(name.to_string(), meshes);
                self.cache.get(name)
            }
            _ => None,
        }
    }

    /// Retain only the model names in `keep`, evicting the rest to free memory.
    pub fn retain(&mut self, keep: &std::collections::HashSet<String>) {
        self.cache.retain(|k, _| keep.contains(k));
    }
}

pub fn tile_instance_transform(col: usize, row: usize, height: f32, orientation: u8) -> InstanceData {
    let tile_w = 10.0;
    let half = tile_w / 2.0;
    let angle_deg = match orientation { 1 => 90, 2 => 180, 3 => 270, _ => 0 };
    let rad = (angle_deg as f32).to_radians();
    let (s, c) = rad.sin_cos();
    let tx = col as f32 * tile_w;
    let tz = -(row as f32) * tile_w;
    InstanceData {
        row0: [c, 0.0, -s, 0.0],
        row1: [0.0, 1.0, 0.0, 0.0],
        row2: [s, 0.0, c, 0.0],
        row3: [tx + half, height, tz - half, 1.0],
    }
}

fn fallback_instance_transform(col: usize, row: usize, height: f32) -> InstanceData {
    let tile_w = 10.0;
    let tx = col as f32 * tile_w;
    let tz = -(row as f32) * tile_w;
    InstanceData {
        row0: [1.0, 0.0, 0.0, 0.0],
        row1: [0.0, 1.0, 0.0, 0.0],
        row2: [0.0, 0.0, 1.0, 0.0],
        row3: [tx, height, tz, 1.0],
    }
}

pub struct InstancedTiles {
    pub models: Vec<ModelGroup>,
    pub instance_data: Vec<Vec<InstanceData>>,
    /// Maps (col, row) -> Vec<(group_idx, instance_idx)> for fast single-tile updates.
    pub tile_instance_map: std::collections::HashMap<(usize, usize), Vec<(usize, usize)>>,
}

pub fn build_instanced_tiles(area: &Area, model_cache: &mut ModelCache) -> InstancedTiles {
    let cols = area.width.max(1) as usize;
    let rows = area.height.max(1) as usize;
    if cols == 0 || rows == 0 {
        return InstancedTiles { models: Vec::new(), instance_data: Vec::new(), tile_instance_map: std::collections::HashMap::new() };
    }

    // Phase 1: collect unique model names
    let mut unique_models: Vec<String> = Vec::new();
    let mut seen: std::collections::HashSet<String> = std::collections::HashSet::new();
    for (i, _) in area.tiles.iter().enumerate() {
        if i >= cols * rows { break; }
        if let Some(Some(name)) = area.tile_models.get(i) {
            if !name.is_empty() && seen.insert(name.clone()) {
                unique_models.push(name.clone());
            }
        }
    }

    // Phase 2: load all models in parallel
    use rayon::prelude::*;
    let loaded: Vec<_> = unique_models.par_iter()
        .map(|name| {
            let meshes = nwn_tileset::load_model_meshes(name).ok().flatten();
            (name.clone(), meshes)
        })
        .collect();
    for (name, meshes) in loaded {
        if let Some(m) = meshes {
            model_cache.cache.entry(name).or_insert(m);
        }
    }

    // Maps (model_name, texture_group_index) -> group index
    let mut group_map: HashMap<(String, usize), usize> = HashMap::new();
    let mut models: Vec<ModelGroup> = Vec::new();
    let mut instance_data: Vec<Vec<InstanceData>> = Vec::new();
    let mut fallback_instances: Vec<InstanceData> = Vec::new();

    // Phase 3: build instances
    let mut tile_instance_map: std::collections::HashMap<(usize, usize), Vec<(usize, usize)>> = std::collections::HashMap::new();
    for (i, tile) in area.tiles.iter().enumerate() {
        if i >= cols * rows { break; }
        let col = i % cols;
        let row = i / cols;
        let model_name = area.tile_models.get(i).and_then(|m| m.as_deref()).unwrap_or("");
        let height = tile.height as f32 * 4.0;

        if let Some(meshes) = model_cache.get_or_load(model_name) {
            if meshes.is_empty() { continue; }
            let all_empty = meshes.iter().all(|m| m.indices.is_empty());
            if all_empty { continue; }

            let mut entries = Vec::new();
            for (mi, mesh) in meshes.iter().enumerate() {
                if mesh.indices.is_empty() { continue; }
                let gidx = if let Some(&idx) = group_map.get(&(model_name.to_string(), mi)) {
                    idx
                } else {
                    let idx = models.len();
                    group_map.insert((model_name.to_string(), mi), idx);
                    let vertices: Vec<Vertex> = mesh.positions.iter().enumerate().map(|(i, p)| {
                        let n = mesh.normals.get(i).copied().unwrap_or([0.0, 1.0, 0.0]);
                        let u = mesh.uvs.get(i).copied().unwrap_or([0.0, 0.0]);
                        let c = mesh.colors.get(i).copied().unwrap_or([1.0, 1.0, 1.0, 1.0]);
                        Vertex { position: *p, normal: n, uv: u, color: c }
                    }).collect();
                    let mut indices = mesh.indices.clone();
                    let vcount = vertices.len() as u32;
                    for idx in &mut indices {
                        if *idx >= vcount {
                            eprintln!("WARN: index {} >= vertex count {}", idx, vcount);
                            *idx = (*idx).min(vcount - 1);
                        }
                    }
                    models.push(ModelGroup {
                        model_name: Some(model_name.to_string()),
                        texture_name: mesh.texture_name.clone(),
                        data: MeshData { vertices, indices },
                    });
                    instance_data.push(Vec::new());
                    idx
                };
                let inst_idx = instance_data[gidx].len();
                instance_data[gidx].push(tile_instance_transform(col, row, height, tile.orientation as u8));
                entries.push((gidx, inst_idx));
            }
            tile_instance_map.insert((col, row), entries);
        } else {
            fallback_instances.push(fallback_instance_transform(col, row, height));
        }
    }

    if !fallback_instances.is_empty() {
        let verts = [
            [0.0, 0.0, 0.0, 0.0, 0.0],
            [10.0, 0.0, 0.0, 1.0, 0.0],
            [10.0, 0.0, -10.0, 1.0, 1.0],
            [0.0, 0.0, -10.0, 0.0, 1.0],
        ];
        let vertices: Vec<Vertex> = verts.iter().map(|v| Vertex {
            position: [v[0], v[1], v[2]],
            normal: [0.0, 1.0, 0.0],
            uv: [v[3], v[4]],
            color: [1.0, 1.0, 1.0, 1.0],
        }).collect();
        let indices = vec![0u32, 1, 2, 0, 2, 3];

        let thick = 0.3;
        let deep = [
            [0.0, -thick, 0.0, 0.0, 0.0],
            [10.0, -thick, 0.0, 1.0, 0.0],
            [10.0, -thick, -10.0, 1.0, 1.0],
            [0.0, -thick, -10.0, 0.0, 1.0],
        ];
        let side_normals = [[0.0, 0.0, 1.0], [1.0, 0.0, 0.0], [0.0, 0.0, -1.0], [-1.0, 0.0, 0.0]];
        let side_quads = [(0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)];
        let all_verts = [verts, deep].concat();
        let mut box_vertices = vertices;
        let mut box_indices = indices;
        for (qi, &(a, b, c, d)) in side_quads.iter().enumerate() {
            let bv = box_vertices.len() as u32;
            for &idx in &[a, b, c, d] {
                box_vertices.push(Vertex {
                    position: [all_verts[idx][0], all_verts[idx][1], all_verts[idx][2]],
                    normal: side_normals[qi],
                    uv: [all_verts[idx][3], all_verts[idx][4]],
                    color: [0.7, 0.7, 0.7, 1.0],
                });
            }
            box_indices.extend_from_slice(&[bv, bv + 1, bv + 2, bv, bv + 2, bv + 3]);
        }

        models.push(ModelGroup {
            model_name: None,
            texture_name: None,
            data: MeshData { vertices: box_vertices, indices: box_indices },
        });
        instance_data.push(fallback_instances);
    }
    InstancedTiles { models, instance_data, tile_instance_map }
}

/// Build 3D model instances for placeables, doors, and creatures that have
/// a resolved `model_name`. Uses the same model caching as tiles.
pub fn build_object_models(area: &Area, model_cache: &mut ModelCache, filter: &VisibilityFilter) -> InstancedTiles {
    // Pre-load unique object models in parallel
    {
        let mut unique = Vec::new();
        let mut seen = std::collections::HashSet::new();
        if filter.show_placeables {
            for p in &area.placeables {
                if let Some(ref name) = p.model_name {
                    if !name.is_empty() && seen.insert(name.clone()) {
                        unique.push(name.clone());
                    }
                }
            }
        }
        if filter.show_doors {
            for d in &area.doors {
                if let Some(ref name) = d.model_name {
                    if !name.is_empty() && seen.insert(name.clone()) {
                        unique.push(name.clone());
                    }
                }
            }
        }
        if filter.show_creatures {
            for c in &area.creatures {
                if let Some(ref name) = c.model_name {
                    if !name.is_empty() && seen.insert(name.clone()) {
                        unique.push(name.clone());
                    }
                }
            }
        }
        use rayon::prelude::*;
        let loaded: Vec<_> = unique.par_iter()
            .map(|name| {
                let meshes = nwn_tileset::load_model_meshes(name).ok().flatten();
                (name.clone(), meshes)
            })
            .collect();
        for (name, meshes) in loaded {
            if let Some(m) = meshes {
                model_cache.cache.entry(name).or_insert(m);
            }
        }
    }

    let mut group_map: HashMap<(String, usize), usize> = HashMap::new();
    let mut models: Vec<ModelGroup> = Vec::new();
    let mut instance_data: Vec<Vec<InstanceData>> = Vec::new();

    let mut add_object_instances = |model_name: &str, x: f32, y: f32, z: f32, bearing: f32,
                                     models: &mut Vec<ModelGroup>,
                                     instance_data: &mut Vec<Vec<InstanceData>>,
                                     group_map: &mut HashMap<(String, usize), usize>| {
        let meshes = match model_cache.get_or_load(model_name) {
            Some(ms) if !ms.is_empty() => ms,
            _other => {
                return;
            }
        };
        let all_empty = meshes.iter().all(|m| m.indices.is_empty());
        if all_empty { return; }

        let (rx, ry, rz) = nwn_to_renderer(x, y, z);
        let (s, c) = bearing.sin_cos();

        for (mi, mesh) in meshes.iter().enumerate() {
            if mesh.indices.is_empty() { continue; }
            let gidx = if let Some(&idx) = group_map.get(&(model_name.to_string(), mi)) {
                idx
            } else {
                let idx = models.len();
                group_map.insert((model_name.to_string(), mi), idx);
                let vertices: Vec<Vertex> = mesh.positions.iter().enumerate().map(|(i, p)| {
                    let n = mesh.normals.get(i).copied().unwrap_or([0.0, 1.0, 0.0]);
                    let u = mesh.uvs.get(i).copied().unwrap_or([0.0, 0.0]);
                    let c = mesh.colors.get(i).copied().unwrap_or([1.0, 1.0, 1.0, 1.0]);
                    Vertex { position: *p, normal: n, uv: u, color: c }
                }).collect();
                let mut indices = mesh.indices.clone();
                let vcount = vertices.len() as u32;
                for idx in &mut indices {
                    if *idx >= vcount {
                        eprintln!("WARN: index {} >= vertex count {}", idx, vcount);
                        *idx = (*idx).min(vcount - 1);
                    }
                }
                models.push(ModelGroup {
                    model_name: Some(model_name.to_string()),
                    texture_name: mesh.texture_name.clone(),
                    data: MeshData { vertices, indices },
                });
                instance_data.push(Vec::new());
                idx
            };
            instance_data[gidx].push(InstanceData {
                row0: [c, 0.0, -s, 0.0],
                row1: [0.0, 1.0, 0.0, 0.0],
                row2: [s, 0.0, c, 0.0],
                row3: [rx, ry, rz, 1.0],
            });
        }
    };

    if filter.show_placeables {
        for p in &area.placeables {
            if let Some(ref name) = p.model_name {
                add_object_instances(name, p.x, p.y, p.z, p.bearing, &mut models, &mut instance_data, &mut group_map);
            }
        }
    }
    if filter.show_doors {
        for d in &area.doors {
            if let Some(ref name) = d.model_name {
                add_object_instances(name, d.x, d.y, d.z, d.bearing, &mut models, &mut instance_data, &mut group_map);
            }
        }
    }
    if filter.show_creatures {
        for c in &area.creatures {
            if let Some(ref name) = c.model_name {
                add_object_instances(name, c.x, c.y, c.z, c.bearing, &mut models, &mut instance_data, &mut group_map);
            }
        }
    }

    InstancedTiles { models, instance_data, tile_instance_map: std::collections::HashMap::new() }
}

/// Maps (obj_type_str, obj_idx) -> list of (group_idx, instance_idx) pairs in the returned instance_data.
pub fn build_object_instance_map(area: &Area, obj_inst: &InstancedTiles, model_cache: &ModelCache, filter: &VisibilityFilter) -> HashMap<(String, usize), Vec<(usize, usize)>> {
    let mut map: HashMap<(String, usize), Vec<(usize, usize)>> = HashMap::new();
    let mut group_counts = vec![0usize; obj_inst.instance_data.len()];
    // Reconstruct group_map: (model_name, mesh_idx) → group_idx, in first-encounter order
    let mut group_map: HashMap<(String, usize), usize> = HashMap::new();
    // Track how many groups have been "seen" to match models.len() ordering
    let mut next_group = 0usize;

    let add_mapping = |model_name: &str, obj_type: &str, obj_idx: usize,
                           group_map: &mut HashMap<(String, usize), usize>,
                           next_group: &mut usize,
                           group_counts: &mut Vec<usize>,
                           map: &mut HashMap<(String, usize), Vec<(usize, usize)>>,
                           model_cache: &ModelCache| {
        let meshes = match model_cache.cache.get(model_name) {
            Some(ms) => ms,
            None => return,
        };
        let mut entries = Vec::new();
        for (mi, mesh) in meshes.iter().enumerate() {
            if mesh.indices.is_empty() { continue; }
            if !group_map.contains_key(&(model_name.to_string(), mi)) {
                group_map.insert((model_name.to_string(), mi), *next_group);
                *next_group += 1;
            }
            let gidx = group_map[&(model_name.to_string(), mi)];
            if group_counts[gidx] < obj_inst.instance_data[gidx].len() {
                entries.push((gidx, group_counts[gidx]));
                group_counts[gidx] += 1;
            }
        }
        if !entries.is_empty() {
            map.insert((obj_type.to_string(), obj_idx), entries);
        }
    };

    if filter.show_placeables {
        for (i, p) in area.placeables.iter().enumerate() {
            if let Some(ref name) = p.model_name {
                add_mapping(name, "placeable", i, &mut group_map, &mut next_group, &mut group_counts, &mut map, model_cache);
            }
        }
    }
    if filter.show_doors {
        for (i, d) in area.doors.iter().enumerate() {
            if let Some(ref name) = d.model_name {
                add_mapping(name, "door", i, &mut group_map, &mut next_group, &mut group_counts, &mut map, model_cache);
            }
        }
    }
    if filter.show_creatures {
        for (i, c) in area.creatures.iter().enumerate() {
            if let Some(ref name) = c.model_name {
                add_mapping(name, "creature", i, &mut group_map, &mut next_group, &mut group_counts, &mut map, model_cache);
            }
        }
    }

    map
}

pub fn build_tile_mesh(area: &Area) -> MeshData {
    if area.width <= 0 || area.height <= 0 || area.tiles.is_empty() {
        return MeshData { vertices: Vec::new(), indices: Vec::new() };
    }
    let tile_w = 10.0;
    let tile_h = 10.0;
    let mut vertices = Vec::new();
    let mut indices = Vec::new();
    let cols = area.width as usize;
    let rows = area.height as usize;

    for (i, tile) in area.tiles.iter().enumerate() {
        let row = i / cols;
        let col = i % cols;
        if row >= rows { break; }
        let tx = col as f32 * tile_w;
        let ty = -(row as f32) * tile_h;
        let height = tile.height as f32 * 4.0;

        let base_index = vertices.len() as u32;
        let verts: [[f32; 5]; 4] = [
            [tx,       height, ty, 0.0, 0.0],
            [tx+tile_w, height, ty, 1.0, 0.0],
            [tx+tile_w, height, ty-tile_h, 1.0, 1.0],
            [tx,       height, ty-tile_h, 0.0, 1.0],
        ];
        for &v in &verts {
            vertices.push(Vertex {
                position: [v[0], v[1], v[2]],
                normal: [0.0, 1.0, 0.0],
                uv: [v[3], v[4]],
                color: [1.0, 1.0, 1.0, 1.0],
            });
        }
        indices.extend_from_slice(&[
            base_index, base_index + 1, base_index + 2,
            base_index, base_index + 2, base_index + 3,
        ]);

        let thick = 0.3;
        let low = height - thick;
        let deep: [[f32; 5]; 4] = [
            [tx,       low, ty, 0.0, 0.0],
            [tx+tile_w, low, ty, 1.0, 0.0],
            [tx+tile_w, low, ty-tile_h, 1.0, 1.0],
            [tx,       low, ty-tile_h, 0.0, 1.0],
        ];
        let side_quads = [(0, 1, 5, 4), (1, 2, 6, 5), (2, 3, 7, 6), (3, 0, 4, 7)];
        let side_normals = [[0.0, 0.0, 1.0], [1.0, 0.0, 0.0], [0.0, 0.0, -1.0], [-1.0, 0.0, 0.0]];
        let all_verts = [verts, deep].concat();
        for (qi, &(a, b, c, d)) in side_quads.iter().enumerate() {
            let base = vertices.len() as u32;
            for &idx in &[a, b, c, d] {
                vertices.push(Vertex {
                    position: [all_verts[idx][0], all_verts[idx][1], all_verts[idx][2]],
                    normal: side_normals[qi],
                    uv: [all_verts[idx][3], all_verts[idx][4]],
                    color: [0.7, 0.7, 0.7, 1.0],
                });
            }
            indices.extend_from_slice(&[
                base, base + 1, base + 2,
                base, base + 2, base + 3,
            ]);
        }
    }

    MeshData { vertices, indices }
}

#[derive(Debug, Clone, Copy)]
pub enum ObjectType {
    Creature,
    Door,
    Placeable,
    Trigger,
    Waypoint,
    Encounter,
    SoundEmitter,
    Light,
}

#[derive(Debug, Clone, Copy)]
pub struct MarkerInfo {
    pub obj_type: ObjectType,
    pub index: usize,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub aabb_min: [f32; 3],
    pub aabb_max: [f32; 3],
}

fn aabb_from_vertex_range(vertices: &[Vertex], range_start: usize) -> ([f32; 3], [f32; 3]) {
    let mut min = [f32::MAX; 3];
    let mut max = [f32::MIN; 3];
    for v in &vertices[range_start..] {
        min[0] = min[0].min(v.position[0]);
        min[1] = min[1].min(v.position[1]);
        min[2] = min[2].min(v.position[2]);
        max[0] = max[0].max(v.position[0]);
        max[1] = max[1].max(v.position[1]);
        max[2] = max[2].max(v.position[2]);
    }
    let padding = 0.15;
    (
        [min[0] - padding, min[1] - padding, min[2] - padding],
        [max[0] + padding, max[1] + padding, max[2] + padding],
    )
}

fn compute_model_world_aabb(model_cache: &ModelCache, model_name: &str, x: f32, y: f32, z: f32, bearing: f32) -> Option<([f32; 3], [f32; 3])> {
    let meshes = model_cache.cache.get(model_name)?;
    if meshes.is_empty() { return None; }
    let mut min = [f32::MAX, f32::MAX, f32::MAX];
    let mut max = [f32::MIN, f32::MIN, f32::MIN];
    for mesh in meshes {
        for p in &mesh.positions {
            min[0] = min[0].min(p[0]);
            min[1] = min[1].min(p[1]);
            min[2] = min[2].min(p[2]);
            max[0] = max[0].max(p[0]);
            max[1] = max[1].max(p[1]);
            max[2] = max[2].max(p[2]);
        }
    }
    if min[0] == f32::MAX { return None; }
    let (rx, ry, rz) = nwn_to_renderer(x, y, z);
    let (s, c) = bearing.sin_cos();
    let corners = [
        [min[0], min[1], min[2]], [max[0], min[1], min[2]],
        [min[0], max[1], min[2]], [max[0], max[1], min[2]],
        [min[0], min[1], max[2]], [max[0], min[1], max[2]],
        [min[0], max[1], max[2]], [max[0], max[1], max[2]],
    ];
    let mut w_min = [f32::MAX; 3];
    let mut w_max = [f32::MIN; 3];
    for &[lx, ly, lz] in &corners {
        let wx = c * lx - s * lz + rx;
        let wy = ly + ry;
        let wz = s * lx + c * lz + rz;
        w_min[0] = w_min[0].min(wx);
        w_min[1] = w_min[1].min(wy);
        w_min[2] = w_min[2].min(wz);
        w_max[0] = w_max[0].max(wx);
        w_max[1] = w_max[1].max(wy);
        w_max[2] = w_max[2].max(wz);
    }
    Some((w_min, w_max))
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct VisibilityFilter {
    pub show_tiles: bool,
    pub show_creatures: bool,
    pub show_doors: bool,
    pub show_placeables: bool,
    pub show_triggers: bool,
    pub show_waypoints: bool,
    pub show_encounters: bool,
    pub show_sound_emitters: bool,
    pub show_lights: bool,
}

impl Default for VisibilityFilter {
    fn default() -> Self {
        Self {
            show_tiles: true,
            show_creatures: true,
            show_doors: true,
            show_placeables: true,
            show_triggers: true,
            show_waypoints: true,
            show_encounters: true,
            show_sound_emitters: true,
            show_lights: true,
        }
    }
}

pub struct MarkersResult {
    pub mesh: MeshData,
    pub markers: Vec<MarkerInfo>,
}

/// Returns the game-icon resref to display as a billboard sprite for each object type.
/// Returns `None` when no suitable icon exists (geometry-only marker).
pub fn object_type_icon(obj_type: ObjectType) -> Option<&'static str> {
    match obj_type {
        ObjectType::Waypoint => Some("po_hu_f_01_h"),
        ObjectType::Door => Some("do_hide"),
        ObjectType::Creature => None,
        ObjectType::Placeable => None,
        ObjectType::Trigger => None,
        ObjectType::Encounter => None,
        ObjectType::SoundEmitter => None,
        ObjectType::Light => None,
    }
}

pub fn build_object_markers(area: &Area, filter: VisibilityFilter, model_cache: &ModelCache) -> MarkersResult {
    let mut vertices = Vec::new();
    let mut indices = Vec::new();
    let mut markers = Vec::new();

    if filter.show_creatures {
        for (i, c) in area.creatures.iter().enumerate() {
            let oz = c.z + 0.3;
            let (aabb_min, aabb_max) = c.model_name.as_ref()
                .and_then(|n| compute_model_world_aabb(model_cache, n, c.x, c.y, oz, c.bearing))
                .unwrap_or_else(|| {
                    let start = vertices.len();
                    add_creature_marker(&mut vertices, &mut indices, c.x, c.y, oz, c.bearing, [1.0, 0.3, 0.3, 1.0]);
                    aabb_from_vertex_range(&vertices, start)
                });
            markers.push(MarkerInfo { obj_type: ObjectType::Creature, index: i, x: c.x, y: c.y, z: oz, aabb_min, aabb_max });
        }
    }
    if filter.show_doors {
        for (i, d) in area.doors.iter().enumerate() {
            let (aabb_min, aabb_max) = d.model_name.as_ref()
                .and_then(|n| compute_model_world_aabb(model_cache, n, d.x, d.y, d.z, d.bearing))
                .unwrap_or_else(|| {
                    let start = vertices.len();
                    add_door_marker(&mut vertices, &mut indices, d.x, d.y, d.z, d.bearing, [1.0, 0.8, 0.0, 1.0]);
                    aabb_from_vertex_range(&vertices, start)
                });
            markers.push(MarkerInfo { obj_type: ObjectType::Door, index: i, x: d.x, y: d.y, z: d.z, aabb_min, aabb_max });
        }
    }
    if filter.show_placeables {
        for (i, p) in area.placeables.iter().enumerate() {
            let oz = p.z + 0.3;
            let (aabb_min, aabb_max) = p.model_name.as_ref()
                .and_then(|n| compute_model_world_aabb(model_cache, n, p.x, p.y, oz, p.bearing))
                .unwrap_or_else(|| {
                    let start = vertices.len();
                    add_placeable_marker(&mut vertices, &mut indices, p.x, p.y, oz, p.bearing, [0.2, 0.4, 1.0, 1.0]);
                    aabb_from_vertex_range(&vertices, start)
                });
            markers.push(MarkerInfo { obj_type: ObjectType::Placeable, index: i, x: p.x, y: p.y, z: oz, aabb_min, aabb_max });
        }
    }
    if filter.show_triggers {
        for (i, t) in area.triggers.iter().enumerate() {
            let start = vertices.len();
            add_trigger_marker(&mut vertices, &mut indices, t.x, t.y, t.z, [0.8, 0.2, 0.8, 0.3]);
            let (aabb_min, aabb_max) = aabb_from_vertex_range(&vertices, start);
            markers.push(MarkerInfo { obj_type: ObjectType::Trigger, index: i, x: t.x, y: t.y, z: t.z, aabb_min, aabb_max });
        }
    }
    if filter.show_waypoints {
        for (i, w) in area.waypoints.iter().enumerate() {
            let start = vertices.len();
            add_waypoint_marker(&mut vertices, &mut indices, w.x, w.y, w.z, [0.2, 1.0, 0.2, 1.0]);
            let (aabb_min, aabb_max) = aabb_from_vertex_range(&vertices, start);
            markers.push(MarkerInfo { obj_type: ObjectType::Waypoint, index: i, x: w.x, y: w.y, z: w.z, aabb_min, aabb_max });
        }
    }
    if filter.show_encounters {
        for (i, e) in area.encounters.iter().enumerate() {
            let start = vertices.len();
            add_encounter_marker(&mut vertices, &mut indices, e.x, e.y, e.z, [1.0, 0.5, 0.0, 0.8]);
            let (aabb_min, aabb_max) = aabb_from_vertex_range(&vertices, start);
            markers.push(MarkerInfo { obj_type: ObjectType::Encounter, index: i, x: e.x, y: e.y, z: e.z, aabb_min, aabb_max });
        }
    }
    if filter.show_sound_emitters {
        for (i, s) in area.sound_emitters.iter().enumerate() {
            let start = vertices.len();
            add_sound_emitter_marker(&mut vertices, &mut indices, s.x, s.y, s.z, [0.2, 0.8, 1.0, 0.8]);
            let (aabb_min, aabb_max) = aabb_from_vertex_range(&vertices, start);
            markers.push(MarkerInfo { obj_type: ObjectType::SoundEmitter, index: i, x: s.x, y: s.y, z: s.z, aabb_min, aabb_max });
        }
    }
    if filter.show_lights {
        for (i, l) in area.lights.iter().enumerate() {
            let start = vertices.len();
            let light_color: [f32; 4] = [
                l.color[0] as f32 / 255.0,
                l.color[1] as f32 / 255.0,
                l.color[2] as f32 / 255.0,
                l.color[3] as f32 / 255.0,
            ];
            add_light_marker(&mut vertices, &mut indices, l.x, l.y, l.z, light_color);
            let (aabb_min, aabb_max) = aabb_from_vertex_range(&vertices, start);
            markers.push(MarkerInfo { obj_type: ObjectType::Light, index: i, x: l.x, y: l.y, z: l.z, aabb_min, aabb_max });
        }
    }

    MarkersResult {
        mesh: MeshData { vertices, indices },
        markers,
    }
}

pub fn build_area_floor(area: &Area) -> MeshData {
    let tile_w = 10.0;
    let cols = area.width.max(1) as usize;
    let rows = area.height.max(1) as usize;

    let mut vertices = Vec::new();
    let mut indices = Vec::new();

    // Overlay checkerboard at tile height with transparency
    for row in 0..rows {
        for col in 0..cols {
            let tx = col as f32 * tile_w;
            let tz = -(row as f32) * tile_w;
            let base = vertices.len() as u32;
            let shade = if (row + col) % 2 == 0 { 0.25 } else { 0.20 };
            for &(dx, dz, u, v) in &[
                (0.0, 0.0, 0.0, 0.0),
                (tile_w, 0.0, 1.0, 0.0),
                (tile_w, -tile_w, 1.0, 1.0),
                (0.0, -tile_w, 0.0, 1.0),
            ] {
                vertices.push(Vertex {
                    position: [tx + dx, 0.0, tz + dz],
                    normal: [0.0, 1.0, 0.0],
                    uv: [u, v],
                    color: [shade, shade * 1.2, shade * 1.5, 0.3],
                });
            }
            indices.extend_from_slice(&[base, base + 2, base + 1, base, base + 3, base + 2]);
        }
    }

    // Grid lines at tile boundaries
    for row in 0..=rows {
        let tz = -(row as f32) * tile_w;
        let base = vertices.len() as u32;
        for col in 0..cols {
            let tx = col as f32 * tile_w;
            for &(dx, dz) in &[(0.0, 0.0), (tile_w, 0.0), (tile_w, -0.05), (0.0, -0.05)] {
                vertices.push(Vertex {
                    position: [tx + dx, 0.0, tz + dz],
                    normal: [0.0, 1.0, 0.0],
                    uv: [0.0, 0.0],
                    color: [0.3, 0.4, 0.6, 0.5],
                });
            }
            indices.extend_from_slice(&[base, base + 2, base + 1, base, base + 3, base + 2]);
        }
    }

    for col in 0..=cols {
        let tx = col as f32 * tile_w;
        let base = vertices.len() as u32;
        for row in 0..rows {
            let tz = -(row as f32) * tile_w;
            for &(dx, dz) in &[(0.0, 0.0), (0.0, -tile_w), (-0.05, -tile_w), (-0.05, 0.0)] {
                vertices.push(Vertex {
                    position: [tx + dx, 0.0, tz + dz],
                    normal: [0.0, 1.0, 0.0],
                    uv: [0.0, 0.0],
                    color: [0.3, 0.4, 0.6, 0.5],
                });
            }
            indices.extend_from_slice(&[base, base + 2, base + 1, base, base + 3, base + 2]);
        }
    }

    MeshData { vertices, indices }
}

pub fn build_paint_overlay(area: &Area) -> MeshData {
    build_paint_overlay_inner(area, 0, false, [40, 80, 200, 160])
}

pub fn build_paint_overlay_ex(area: &Area, water_level: i32, show_water: bool, water_color: [u8; 4]) -> MeshData {
    build_paint_overlay_inner(area, water_level, show_water, water_color)
}

fn build_paint_overlay_inner(area: &Area, water_level: i32, show_water: bool, water_color: [u8; 4]) -> MeshData {
    let cols = area.width.max(1) as usize;
    let rows = area.height.max(1) as usize;
    let tile_w = 10.0;
    let tint_map: std::collections::HashMap<usize, [f32; 4]> = area.tile_tints.iter().map(|&(ti, c)| {
        (ti, [c[0] as f32 / 255.0, c[1] as f32 / 255.0, c[2] as f32 / 255.0, c[3] as f32 / 255.0])
    }).collect();
    let mut vertices = Vec::new();
    let mut indices = Vec::new();
    let mut base_idx: u32 = 0;
    for ti in 0..(cols * rows) {
        if let Some(&tint) = tint_map.get(&ti) {
            if tint[3] <= 0.0 { continue; }
            let col = ti % cols;
            let row = ti / cols;
            let h = area.tiles.get(ti).map(|t| t.height).unwrap_or(0);
            let height = h as f32 * 4.0 + 0.05; // slight offset above tile
            let x0 = col as f32 * tile_w;
            let z0 = -(row as f32) * tile_w;
            let x1 = x0 + tile_w;
            let z1 = z0 - tile_w;
            vertices.extend_from_slice(&[
                Vertex { position: [x0, height, z0], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color: tint },
                Vertex { position: [x1, height, z0], normal: [0.0, 1.0, 0.0], uv: [1.0, 0.0], color: tint },
                Vertex { position: [x1, height, z1], normal: [0.0, 1.0, 0.0], uv: [1.0, 1.0], color: tint },
                Vertex { position: [x0, height, z1], normal: [0.0, 1.0, 0.0], uv: [0.0, 1.0], color: tint },
            ]);
            indices.extend_from_slice(&[base_idx, base_idx + 1, base_idx + 2, base_idx, base_idx + 2, base_idx + 3]);
            base_idx += 4;
        }
    }
    // Water level overlay
    if show_water && water_level > 0 {
        let water_color = [water_color[0] as f32 / 255.0, water_color[1] as f32 / 255.0, water_color[2] as f32 / 255.0, water_color[3] as f32 / 255.0];
        let water_height = water_level as f32 * 4.0;
        for ti in 0..(cols * rows) {
            let col = ti % cols;
            let row = ti / cols;
            let x0 = col as f32 * tile_w;
            let z0 = -(row as f32) * tile_w;
            let x1 = x0 + tile_w;
            let z1 = z0 - tile_w;
            vertices.extend_from_slice(&[
                Vertex { position: [x0, water_height, z0], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color: water_color },
                Vertex { position: [x1, water_height, z0], normal: [0.0, 1.0, 0.0], uv: [1.0, 0.0], color: water_color },
                Vertex { position: [x1, water_height, z1], normal: [0.0, 1.0, 0.0], uv: [1.0, 1.0], color: water_color },
                Vertex { position: [x0, water_height, z1], normal: [0.0, 1.0, 0.0], uv: [0.0, 1.0], color: water_color },
            ]);
            indices.extend_from_slice(&[base_idx, base_idx + 1, base_idx + 2, base_idx, base_idx + 2, base_idx + 3]);
            base_idx += 4;
        }
    }
    MeshData { vertices, indices }
}

/// Map a physical edge direction to the tile-local wall edge, accounting for tile orientation.
/// physical_edge: 0=right(+x), 1=bottom(-z), 2=left(-x), 3=top(+z)
fn physical_to_local_edge(physical_edge: u8, tile_orientation: u8) -> u8 {
    (physical_edge + 4 - (tile_orientation & 3)) % 4
}

pub fn build_walkmesh(area: &Area) -> MeshData {
    let cols = area.width.max(1) as usize;
    let rows = area.height.max(1) as usize;
    let tile_w = 10.0;
    let mut vertices = Vec::new();
    let mut indices = Vec::new();

    // Build a lookup for walkmesh walls: tile_index -> [right, bottom] bools
    let mut wall_set = std::collections::HashSet::new();
    for &(ti, edge) in &area.walkmesh_walls {
        wall_set.insert((ti, edge));
    }

    // Pre-collect orientations for all tiles
    let orientations: Vec<u8> = area.tiles.iter().map(|t| t.orientation as u8 & 3).collect();

    for (i, tile) in area.tiles.iter().enumerate() {
        if i >= cols * rows { break; }
        let row = i / cols;
        let col = i % cols;
        let tx = col as f32 * tile_w;
        let tz = -(row as f32) * tile_w;
        let height = tile.height as f32 * 4.0;

        let walk_color = if tile.walkable {
            [0.0, 0.6, 0.0, 0.25]
        } else {
            [0.6, 0.0, 0.0, 0.35]
        };

        let base = vertices.len() as u32;
        for &(dx, dz) in &[(0.0, 0.0), (tile_w, 0.0), (tile_w, -tile_w), (0.0, -tile_w)] {
            vertices.push(Vertex {
                position: [tx + dx, height + 0.05, tz + dz],
                normal: [0.0, 1.0, 0.0],
                uv: [0.0, 0.0],
                color: walk_color,
            });
        }
        indices.extend_from_slice(&[base, base + 2, base + 1, base, base + 3, base + 2]);
    }

    // Edge walls between tiles at different heights
    for row in 0..rows {
        for col in 0..cols {
            let i = row * cols + col;
            if i >= area.tiles.len() { break; }
            let h = area.tiles[i].height as f32 * 4.0;
            let oi = orientations.get(i).copied().unwrap_or(0);
            let tx = col as f32 * tile_w;
            let tz = -(row as f32) * tile_w;

            // Check right neighbor (physical edge 0)
            if col + 1 < cols {
                let ri = row * cols + col + 1;
                if ri < area.tiles.len() {
                    let rh = area.tiles[ri].height as f32 * 4.0;
                    let ori = orientations.get(ri).copied().unwrap_or(0);
                    let has_wall = wall_set.contains(&(i, physical_to_local_edge(0, oi))) ||
                                   wall_set.contains(&(ri, physical_to_local_edge(2, ori)));
                    if (rh - h).abs() > 0.01 || has_wall {
                        let wall_color = if has_wall { [0.8, 0.3, 0.0, 0.6] } else { [0.0, 0.4, 0.0, 0.3] };
                        let base = vertices.len() as u32;
                        vertices.push(Vertex { position: [tx + tile_w, h, tz], normal: [1.0, 0.0, 0.0], uv: [0.0, 0.0], color: wall_color });
                        vertices.push(Vertex { position: [tx + tile_w, rh, tz], normal: [1.0, 0.0, 0.0], uv: [0.0, 0.0], color: wall_color });
                        vertices.push(Vertex { position: [tx + tile_w, rh, tz - tile_w], normal: [1.0, 0.0, 0.0], uv: [0.0, 0.0], color: wall_color });
                        vertices.push(Vertex { position: [tx + tile_w, h, tz - tile_w], normal: [1.0, 0.0, 0.0], uv: [0.0, 0.0], color: wall_color });
                        indices.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
                    }
                }
            }
            // Check bottom neighbor (physical edge 1)
            if row + 1 < rows {
                let bi = (row + 1) * cols + col;
                if bi < area.tiles.len() {
                    let bh = area.tiles[bi].height as f32 * 4.0;
                    let obi = orientations.get(bi).copied().unwrap_or(0);
                    let has_wall = wall_set.contains(&(i, physical_to_local_edge(1, oi))) ||
                                   wall_set.contains(&(bi, physical_to_local_edge(3, obi)));
                    if (bh - h).abs() > 0.01 || has_wall {
                        let wall_color = if has_wall { [0.8, 0.3, 0.0, 0.6] } else { [0.0, 0.4, 0.0, 0.3] };
                        let base = vertices.len() as u32;
                        vertices.push(Vertex { position: [tx, h, tz - tile_w], normal: [0.0, 0.0, -1.0], uv: [0.0, 0.0], color: wall_color });
                        vertices.push(Vertex { position: [tx, bh, tz - tile_w], normal: [0.0, 0.0, -1.0], uv: [0.0, 0.0], color: wall_color });
                        vertices.push(Vertex { position: [tx + tile_w, bh, tz - tile_w], normal: [0.0, 0.0, -1.0], uv: [0.0, 0.0], color: wall_color });
                        vertices.push(Vertex { position: [tx + tile_w, h, tz - tile_w], normal: [0.0, 0.0, -1.0], uv: [0.0, 0.0], color: wall_color });
                        indices.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
                    }
                }
            }
        }
    }

    MeshData { vertices, indices }
}

pub fn build_walkmesh_edges(area: &Area) -> (Vec<f32>, Vec<u32>) {
    let cols = area.width.max(1) as usize;
    let rows = area.height.max(1) as usize;
    let tile_w = 10.0;
    let mut verts: Vec<f32> = Vec::new();
    let mut indices: Vec<u32> = Vec::new();

    let mut wall_set = std::collections::HashSet::new();
    for &(ti, edge) in &area.walkmesh_walls {
        wall_set.insert((ti, edge));
    }

    // Pre-collect orientations
    let orientations: Vec<u8> = area.tiles.iter().map(|t| t.orientation as u8 & 3).collect();

    for (i, tile) in area.tiles.iter().enumerate() {
        if i >= cols * rows { break; }
        let row = i / cols;
        let col = i % cols;
        let tx = col as f32 * tile_w;
        let tz = -(row as f32) * tile_w;
        let h = tile.height as f32 * 4.0;

        let color = if tile.walkable { [0.0, 1.0, 0.0, 0.6] } else { [1.0, 0.0, 0.0, 0.7] };
        // Tile quad perimeter: 4 corners -> 4 edges
        let corners: [[f32; 3]; 4] = [
            [tx, h + 0.05, tz],
            [tx + tile_w, h + 0.05, tz],
            [tx + tile_w, h + 0.05, tz - tile_w],
            [tx, h + 0.05, tz - tile_w],
        ];
        let line_edges: [(usize, usize); 4] = [(0,1), (1,2), (2,3), (3,0)];
        let base = verts.len() as u32 / 7;
        for &(a, b) in &line_edges {
            for &ci in &[a, b] {
                verts.push(corners[ci][0]);
                verts.push(corners[ci][1]);
                verts.push(corners[ci][2]);
                verts.push(color[0]);
                verts.push(color[1]);
                verts.push(color[2]);
                verts.push(color[3]);
            }
            indices.push(base + (a as u32 * 2));
            indices.push(base + (a as u32 * 2 + 1));
        }
    }

    // Edge walls between tiles at different heights
    for row in 0..rows {
        for col in 0..cols {
            let i = row * cols + col;
            if i >= area.tiles.len() { break; }
            let h = area.tiles[i].height as f32 * 4.0;
            let oi = orientations.get(i).copied().unwrap_or(0);
            let tx = col as f32 * tile_w;
            let tz = -(row as f32) * tile_w;

            // Right neighbor (physical edge 0)
            if col + 1 < cols {
                let ri = row * cols + col + 1;
                if ri < area.tiles.len() {
                    let rh = area.tiles[ri].height as f32 * 4.0;
                    let ori = orientations.get(ri).copied().unwrap_or(0);
                    let has_wall = wall_set.contains(&(i, physical_to_local_edge(0, oi))) ||
                                   wall_set.contains(&(ri, physical_to_local_edge(2, ori)));
                    if (rh - h).abs() > 0.01 || has_wall {
                        let wall_color = if has_wall { [0.8, 0.3, 0.0, 0.8] } else { [0.0, 0.6, 0.0, 0.5] };
                        let base = verts.len() as u32 / 7;
                        let pts: [[f32; 3]; 4] = [
                            [tx + tile_w, h, tz],
                            [tx + tile_w, rh, tz],
                            [tx + tile_w, rh, tz - tile_w],
                            [tx + tile_w, h, tz - tile_w],
                        ];
                        let wall_edges: [(usize, usize); 4] = [(0,1), (1,2), (2,3), (3,0)];
                        for &(a, b) in &wall_edges {
                            for &ci in &[a, b] {
                                verts.push(pts[ci][0]); verts.push(pts[ci][1]); verts.push(pts[ci][2]);
                                verts.push(wall_color[0]); verts.push(wall_color[1]); verts.push(wall_color[2]); verts.push(wall_color[3]);
                            }
                            indices.push(base + (a as u32 * 2));
                            indices.push(base + (a as u32 * 2 + 1));
                        }
                    }
                }
            }
            // Bottom neighbor (physical edge 1)
            if row + 1 < rows {
                let bi = (row + 1) * cols + col;
                if bi < area.tiles.len() {
                    let bh = area.tiles[bi].height as f32 * 4.0;
                    let obi = orientations.get(bi).copied().unwrap_or(0);
                    let has_wall = wall_set.contains(&(i, physical_to_local_edge(1, oi))) ||
                                   wall_set.contains(&(bi, physical_to_local_edge(3, obi)));
                    if (bh - h).abs() > 0.01 || has_wall {
                        let wall_color = if has_wall { [0.8, 0.3, 0.0, 0.8] } else { [0.0, 0.6, 0.0, 0.5] };
                        let base = verts.len() as u32 / 7;
                        let pts: [[f32; 3]; 4] = [
                            [tx, h, tz - tile_w],
                            [tx, bh, tz - tile_w],
                            [tx + tile_w, bh, tz - tile_w],
                            [tx + tile_w, h, tz - tile_w],
                        ];
                        let wall_edges: [(usize, usize); 4] = [(0,1), (1,2), (2,3), (3,0)];
                        for &(a, b) in &wall_edges {
                            for &ci in &[a, b] {
                                verts.push(pts[ci][0]); verts.push(pts[ci][1]); verts.push(pts[ci][2]);
                                verts.push(wall_color[0]); verts.push(wall_color[1]); verts.push(wall_color[2]); verts.push(wall_color[3]);
                            }
                            indices.push(base + (a as u32 * 2));
                            indices.push(base + (a as u32 * 2 + 1));
                        }
                    }
                }
            }
        }
    }

    (verts, indices)
}

/// Add a box with 6 faces (24 verts, 36 indices)
fn add_box_marker(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    cx: f32, cy: f32, cz: f32, sx: f32, sy: f32, sz: f32, color: [f32; 4],
    transform: impl Fn(f32, f32, f32) -> (f32, f32, f32))
{
    if !cx.is_finite() || !cy.is_finite() || !cz.is_finite() { return; }
    let (rx, ry, rz) = transform(cx, cy, cz);
    let faces: [([f32; 3], [f32; 3], [f32; 3], [f32; 3], [f32; 3]); 6] = [
        ([-sx, -sy,  sz], [ sx, -sy,  sz], [ sx,  sy,  sz], [-sx,  sy,  sz], [ 0.0,  0.0,  1.0]),
        ([ sx, -sy, -sz], [-sx, -sy, -sz], [-sx,  sy, -sz], [ sx,  sy, -sz], [ 0.0,  0.0, -1.0]),
        ([ sx, -sy,  sz], [ sx, -sy, -sz], [ sx,  sy, -sz], [ sx,  sy,  sz], [ 1.0,  0.0,  0.0]),
        ([-sx, -sy, -sz], [-sx, -sy,  sz], [-sx,  sy,  sz], [-sx,  sy, -sz], [-1.0,  0.0,  0.0]),
        ([-sx,  sy,  sz], [ sx,  sy,  sz], [ sx,  sy, -sz], [-sx,  sy, -sz], [ 0.0,  1.0,  0.0]),
        ([-sx, -sy, -sz], [ sx, -sy, -sz], [ sx, -sy,  sz], [-sx, -sy,  sz], [ 0.0, -1.0,  0.0]),
    ];
    for (a, b, c, d, n) in &faces {
        let vi = vertices.len() as u32;
        for pt in [a, b, c, d] {
            vertices.push(Vertex {
                position: [rx + pt[0], ry + pt[1], rz + pt[2]],
                normal: *n,
                uv: [0.0, 0.0],
                color,
            });
        }
        indices.extend_from_slice(&[vi, vi + 1, vi + 2, vi, vi + 2, vi + 3]);
    }
}

/// Rotated box around renderer Y (NWN Z) by bearing. Uses same face definitions
/// as add_box_marker, but each corner + normal is rotated by bearing around Y axis.
fn add_rotated_box(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    nwn_cx: f32, nwn_cy: f32, nwn_cz: f32,
    sx: f32, sy: f32, sz: f32,
    bearing: f32, color: [f32; 4])
{
    if !nwn_cx.is_finite() || !nwn_cy.is_finite() || !nwn_cz.is_finite() { return; }
    let (rx, ry, rz) = nwn_to_renderer(nwn_cx, nwn_cy, nwn_cz);
    let (sin_b, cos_b) = bearing.sin_cos();
    let faces: [([f32; 3], [f32; 3], [f32; 3], [f32; 3], [f32; 3]); 6] = [
        ([-sx, -sy,  sz], [ sx, -sy,  sz], [ sx,  sy,  sz], [-sx,  sy,  sz], [ 0.0,  0.0,  1.0]),
        ([ sx, -sy, -sz], [-sx, -sy, -sz], [-sx,  sy, -sz], [ sx,  sy, -sz], [ 0.0,  0.0, -1.0]),
        ([ sx, -sy,  sz], [ sx, -sy, -sz], [ sx,  sy, -sz], [ sx,  sy,  sz], [ 1.0,  0.0,  0.0]),
        ([-sx, -sy, -sz], [-sx, -sy,  sz], [-sx,  sy,  sz], [-sx,  sy, -sz], [-1.0,  0.0,  0.0]),
        ([-sx,  sy,  sz], [ sx,  sy,  sz], [ sx,  sy, -sz], [-sx,  sy, -sz], [ 0.0,  1.0,  0.0]),
        ([-sx, -sy, -sz], [ sx, -sy, -sz], [ sx, -sy,  sz], [-sx, -sy,  sz], [ 0.0, -1.0,  0.0]),
    ];
    for (a, b, d0, d1, n) in &faces {
        let vi = vertices.len() as u32;
        for pt in [a, b, d0, d1] {
            let lx = pt[0] * cos_b + pt[2] * sin_b;
            let ly = pt[1];
            let lz = -pt[0] * sin_b + pt[2] * cos_b;
            vertices.push(Vertex {
                position: [rx + lx, ry + ly, rz + lz],
                normal: [n[0] * cos_b + n[2] * sin_b, n[1], -n[0] * sin_b + n[2] * cos_b],
                uv: [0.0, 0.0],
                color,
            });
        }
        indices.extend_from_slice(&[vi, vi + 1, vi + 2, vi, vi + 2, vi + 3]);
    }
}

pub(crate) fn nwn_to_renderer(x: f32, y: f32, z: f32) -> (f32, f32, f32) {
    (x, z, -y)
}

fn add_creature_marker(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    x: f32, y: f32, z: f32, bearing: f32, color: [f32; 4])
{
    add_rotated_box(vertices, indices, x, y, z, 0.35, 0.6, 0.3, bearing, color);
    add_rotated_box(vertices, indices, x, y, z + 0.45, 0.2, 0.2, 0.2, bearing, color);
    add_rotated_box(vertices, indices, x, y, z, 0.45, 0.06, 0.45, bearing, color);
}

fn add_door_marker(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    x: f32, y: f32, z: f32, bearing: f32, color: [f32; 4])
{
    let (s, c) = bearing.sin_cos();
    add_rotated_box(vertices, indices, x, y, z, 0.4, 1.0, 0.08, bearing, color);
    let lx = x - 0.45 * c;
    let ly = y - 0.45 * s;
    add_rotated_box(vertices, indices, lx, ly, z, 0.06, 1.1, 0.10, bearing, color);
    let rx = x + 0.45 * c;
    let ry = y + 0.45 * s;
    add_rotated_box(vertices, indices, rx, ry, z, 0.06, 1.1, 0.10, bearing, color);
}

fn add_placeable_marker(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    x: f32, y: f32, z: f32, bearing: f32, color: [f32; 4])
{
    add_rotated_box(vertices, indices, x, y, z, 0.3, 0.35, 0.25, bearing, color);
}

fn add_wireframe_circle(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    x: f32, y: f32, z: f32, outer_r: f32, inner_r: f32, color: [f32; 4], n: u32)
{
    let (rx, ry, rz) = nwn_to_renderer(x, y, z);
    let base = vertices.len() as u32;
    for i in 0..n {
        let angle = (i as f32 / n as f32) * std::f32::consts::TAU;
        let (cos_a, sin_a) = (angle.cos(), angle.sin());
        vertices.push(Vertex { position: [rx + cos_a * inner_r, ry, rz + sin_a * inner_r], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color });
        vertices.push(Vertex { position: [rx + cos_a * outer_r, ry, rz + sin_a * outer_r], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color });
    }
    for i in 0..n {
        let a = base + i * 2;
        let b = base + i * 2 + 1;
        let next_a = base + ((i + 1) % n) * 2;
        let next_b = base + ((i + 1) % n) * 2 + 1;
        indices.extend_from_slice(&[a, next_a, b]);
        indices.extend_from_slice(&[b, next_a, next_b]);
    }
}

fn add_trigger_marker(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    x: f32, y: f32, z: f32, color: [f32; 4])
{
    add_wireframe_circle(vertices, indices, x, y, z + 0.1, 1.0, 0.85, color, 24);
}

fn add_waypoint_marker(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    x: f32, y: f32, z: f32, color: [f32; 4])
{
    add_wireframe_circle(vertices, indices, x, y, z + 0.3, 0.4, 0.3, color, 16);
    // Small upward stem
    let (rx, ry, rz) = nwn_to_renderer(x, y, z + 0.3);
    let stem_base = vertices.len() as u32;
    let h = 0.5;
    vertices.push(Vertex { position: [rx, ry, rz], normal: [0.0, 0.0, 1.0], uv: [0.0, 0.0], color });
    vertices.push(Vertex { position: [rx, ry + h, rz], normal: [0.0, 0.0, 1.0], uv: [0.0, 0.0], color });
    vertices.push(Vertex { position: [rx, ry + h + 0.15, rz], normal: [0.0, 0.0, 1.0], uv: [0.0, 0.0], color });
    // Stem line is just a thin quad per pair
    for i in 0..2 {
        let a = stem_base + i;
        let na = stem_base + i + 1;
        // Very thin "line" as two degenerate triangles
        indices.extend_from_slice(&[a, na, na]);
    }
}

fn add_encounter_marker(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    x: f32, y: f32, z: f32, color: [f32; 4])
{
    add_wireframe_circle(vertices, indices, x, y, z + 0.15, 0.7, 0.6, color, 20);
    // Arrow pointing up (triangle)
    let (rx, ry, rz) = nwn_to_renderer(x, y, z + 0.15);
    let arr_base = vertices.len() as u32;
    vertices.push(Vertex { position: [rx, ry + 1.0, rz], normal: [0.0, 0.0, 1.0], uv: [0.0, 0.0], color });
    vertices.push(Vertex { position: [rx - 0.15, ry + 0.5, rz - 0.1], normal: [0.0, 0.0, 1.0], uv: [0.0, 0.0], color });
    vertices.push(Vertex { position: [rx + 0.15, ry + 0.5, rz - 0.1], normal: [0.0, 0.0, 1.0], uv: [0.0, 0.0], color });
    indices.extend_from_slice(&[arr_base, arr_base + 1, arr_base + 2]);
}

fn add_sound_emitter_marker(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    x: f32, y: f32, z: f32, color: [f32; 4])
{
    // Circle with sound ring arcs
    let (rx, ry, rz) = nwn_to_renderer(x, y, z + 0.3);
    let r = 0.4;
    let base = vertices.len() as u32;
    let n = 12;
    // Center
    vertices.push(Vertex { position: [rx, ry, rz], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color });
    // Outer ring
    for i in 0..n {
        let angle = (i as f32 / n as f32) * std::f32::consts::TAU;
        let cx = rx + angle.cos() * r;
        let cz = rz + angle.sin() * r;
        vertices.push(Vertex { position: [cx, ry, cz], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color });
    }
    let c = base;
    for i in 0..n {
        let next = (i + 1) % n;
        let vi = base + 1 + i as u32;
        let v_next = base + 1 + next as u32;
        indices.extend_from_slice(&[c, v_next, vi]);
    }
    // Sound wave arcs
    for wave in 0..3 {
        let arc_r = r + 0.15 + wave as f32 * 0.15;
        let arc_n = 8;
        let start_angle = -0.8 + wave as f32 * 0.3;
        let end_angle = 0.8 + wave as f32 * 0.3;
        let abase = vertices.len() as u32;
        for i in 0..=arc_n {
            let t = i as f32 / arc_n as f32;
            let angle = start_angle + (end_angle - start_angle) * t;
            let cx = rx + angle.cos() * arc_r;
            let cz = rz + angle.sin() * arc_r;
            vertices.push(Vertex { position: [cx, ry, cz], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color });
        }
        for i in 0..arc_n {
            indices.extend_from_slice(&[abase + i as u32, abase + i as u32 + 1]);
        }
    }
}

fn add_light_marker(vertices: &mut Vec<Vertex>, indices: &mut Vec<u32>,
    x: f32, y: f32, z: f32, color: [f32; 4])
{
    let (rx, ry, rz) = nwn_to_renderer(x, y, z);
    let r = 0.3;
    let n = 8;
    let base = vertices.len() as u32;
    vertices.push(Vertex { position: [rx, ry, rz], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color });
    for i in 0..n {
        let angle = (i as f32 / n as f32) * std::f32::consts::TAU;
        let cx = rx + angle.cos() * r;
        let cz = rz + angle.sin() * r;
        vertices.push(Vertex { position: [cx, ry, cz], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color });
    }
    let c = base;
    for i in 0..n {
        let vi = base + 1 + i as u32;
        let v_next = base + 1 + ((i + 1) % n) as u32;
        indices.extend_from_slice(&[c, v_next, vi]);
    }
    // Starburst rays
    for ray in 0..4 {
        let ra = ray as f32 * std::f32::consts::FRAC_PI_2;
        let ra_x = rx + ra.cos() * (r + 0.2);
        let ra_z = rz + ra.sin() * (r + 0.2);
        let ray_base = vertices.len() as u32;
        vertices.push(Vertex { position: [rx, ry, rz], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color });
        vertices.push(Vertex { position: [ra_x, ry, ra_z], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color });
        indices.extend_from_slice(&[ray_base, ray_base + 1]);
    }
}
