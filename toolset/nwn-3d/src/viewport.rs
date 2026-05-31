use std::path::Path;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Arc, Mutex};

use egui_wgpu::{CallbackTrait, CallbackResources, ScreenDescriptor};
use egui::epaint::PaintCallbackInfo;
use wgpu::util::DeviceExt;

use crate::camera::{OrbitCamera, mat4_mul};
use crate::pipeline;

/// Maximum number of point lights that can be uploaded to the GPU
pub const MAX_POINT_LIGHTS: u32 = 32;

/// GPU-uploadable point light data (2 × vec4<f32>, 32 bytes, matches WGSL PointLight)
#[repr(C)]
#[derive(Copy, Clone, Debug, bytemuck::Pod, bytemuck::Zeroable)]
pub struct PointLightData {
    pub position_radius: [f32; 4], // x,y,z in renderer space, w = radius
    pub color_pad: [f32; 4],       // r,g,b normalized, w unused
}

/// Combined size of the uniform buffer in bytes:
///   144 bytes for existing fields (view_proj+ambient+fog+camera+diffuse)
///   + 32 * 32 bytes for up to 32 point lights
const UNIFORM_BUF_SIZE: u64 = 144 + MAX_POINT_LIGHTS as u64 * 32;
use crate::tile_renderer::{self, MarkerInfo};

struct TextureSlot {
    texture: wgpu::Texture,
    view: wgpu::TextureView,
    sampler: wgpu::Sampler,
    bind_group: Option<wgpu::BindGroup>,
    pending: Option<(u32, u32, Vec<u8>)>,
}

struct GroupResources {
    vertex_buf: wgpu::Buffer,
    index_buf: wgpu::Buffer,
    num_indices: u32,
    instance_buf: wgpu::Buffer,
    num_instances: u32,
    texture_slot: usize,
}

struct SpriteInfo {
    x: f32, y: f32, z: f32,
}

struct SpriteBatch {
    texture_slot: usize,
    start_instance: u32,
    num_instances: u32,
}

pub struct ViewportState {
    pub camera: OrbitCamera,
    pub area_version: u64,
    pub area_resref: String,
    pub markers: Vec<MarkerInfo>,
    pub tile_count: usize,
    pub color_format: wgpu::TextureFormat,
    marker_idx_count: u32,
    pub draw_calls: usize,
    pub group_count: usize,
    marker_vertex_buf: Option<wgpu::Buffer>,
    marker_index_buf: Option<wgpu::Buffer>,

    walkmesh_idx_count: u32,
    walkmesh_vertex_buf: Option<wgpu::Buffer>,
    walkmesh_index_buf: Option<wgpu::Buffer>,
    show_walkmesh: bool,
    walkmesh_edge_vbuf: Option<wgpu::Buffer>,
    walkmesh_edge_ibuf: Option<wgpu::Buffer>,
    walkmesh_edge_count: u32,
    show_walkmesh_edges: bool,
    paint_idx_count: u32,
    paint_vertex_buf: Option<wgpu::Buffer>,
    paint_index_buf: Option<wgpu::Buffer>,
    show_paint: bool,
    water_idx_count: u32,
    water_vertex_buf: Option<wgpu::Buffer>,
    water_index_buf: Option<wgpu::Buffer>,
    pub clear_color: wgpu::Color,
    pub water_level: i32,
    pub show_water: bool,
    pub water_color: [u8; 4],
    show_tiles: bool,
    uniform_buf: wgpu::Buffer,
    uniform_bind_group: wgpu::BindGroup,
    uniform_bind_group_layout: wgpu::BindGroupLayout,
    texture_bind_group_layout: wgpu::BindGroupLayout,
    groups: Vec<GroupResources>,
    texture_slots: Vec<TextureSlot>,
    default_instance_buf: wgpu::Buffer,
    pipeline: wgpu::RenderPipeline,
    tile_pipeline: wgpu::RenderPipeline,
    marker_pipeline: wgpu::RenderPipeline,
    walkmesh_pipeline: wgpu::RenderPipeline,
    viewport_size: (u32, u32),
    color_tex: [Option<wgpu::Texture>; 2],
    color_view: [Option<wgpu::TextureView>; 2],
    depth_tex: [Option<wgpu::Texture>; 2],
    depth_view: [Option<wgpu::TextureView>; 2],
    blit_pipeline: wgpu::RenderPipeline,
    blit_bind_group_layout: wgpu::BindGroupLayout,
    blit_bind_group: [Option<wgpu::BindGroup>; 2],
    blit_sampler: wgpu::Sampler,
    frame_index: usize,

    highlight_vbuf: Option<wgpu::Buffer>,
    highlight_ibuf: Option<wgpu::Buffer>,
    highlight_count: u32,
    tile_hl_vbuf: Option<wgpu::Buffer>,
    tile_hl_ibuf: Option<wgpu::Buffer>,
    tile_hl_count: u32,
    highlight_pipeline: wgpu::RenderPipeline,
    cached_highlight: (Vec<[f32; 3]>, f32),
    cached_tile_highlight: Option<(Option<usize>, usize, usize, f32)>,

    floor_pipeline: wgpu::RenderPipeline,
    floor_vertex_buf: Option<wgpu::Buffer>,
    floor_index_buf: Option<wgpu::Buffer>,
    floor_idx_count: u32,
    show_grid: bool,
    lighting_enabled: bool,
    show_fog: bool,
    fog_color: [f32; 4],
    fog_amount_norm: f32,
    fog_clip_dist: f32,
    ambient_color: [f32; 3],
    diffuse_color: [f32; 3],

    // Sprite / billboard icons
    sprites: Vec<SpriteInfo>,
    sprite_batches: Vec<SpriteBatch>,
    sprite_quad_vbuf: wgpu::Buffer,
    sprite_quad_ibuf: wgpu::Buffer,
    sprite_instance_buf: wgpu::Buffer,
    show_sprites: bool,

    // CPU-side instance data for fast drag updates
    instance_data: Vec<Vec<tile_renderer::InstanceData>>,
    tile_group_count: usize,
    tile_instance_map: std::collections::HashMap<(usize, usize), Vec<(usize, usize)>>,
    object_instance_map: std::collections::HashMap<(String, usize), Vec<(usize, usize)>>,

    /// Point lights uploaded to the GPU each frame
    lights: Vec<PointLightData>,

    /// Cache last camera right/up to skip sprite updates when camera hasn't moved
    last_camera_right_up: Option<([f32; 3], [f32; 3])>,
    sprite_instance_dirty: bool,
}

fn load_texture(name: &str, module_erf: Option<&nwn_erf::ErfFile>, hak_index: Option<&nwn_tileset::HakIndex>, mod_path: Option<&Path>, _hak_names: &[String]) -> Option<(u32, u32, Vec<u8>)> {
    // Try module ERF first
    if let Some(erf) = module_erf {
        if let Some(data) = nwn_tileset::load_texture_data_from_sources(name, &[erf]).ok().flatten() {
            return Some((data.width, data.height, data.rgba));
        }
    }
    // Try specific hak via HakIndex (fast, no full file reads)
    if let (Some(idx), Some(dir)) = (hak_index, mod_path) {
        for &restype in &[8u16, 3u16, 1u16, 6u16] {
            if let Some(data) = idx.get_resource_from_path(name, restype, dir) {
                if let Some(tex) = nwn_tileset::decode_texture_data(restype, &data) {
                    return Some((tex.width, tex.height, tex.rgba));
                }
            }
        }
    }
    // Fall back to game data
    match nwn_tileset::load_texture_data(name) {
        Ok(Some(data)) => {
            Some((data.width, data.height, data.rgba))
        }
        Ok(None) => {
            None
        }
        Err(e) => {
            eprintln!("ERROR: Failed to load texture '{name}': {e}");
            None
        }
    }
}

impl ViewportState {
    pub fn new(
        device: &wgpu::Device,
        config: &wgpu::SurfaceConfiguration,
        area: &nwn_gamemodel::Area,
        area_version: u64,
        visibility_filter: tile_renderer::VisibilityFilter,
        existing_camera: Option<OrbitCamera>,
        module_erf: Option<&nwn_erf::ErfFile>,
        mod_path: Option<&std::path::Path>,
        hak_names: &[String],
        existing_cache: Option<&mut tile_renderer::ModelCache>,
        max_texture_bytes: u64,
        persist: ViewportPersist,
    ) -> Self {

        let camera = existing_camera.unwrap_or_else(|| OrbitCamera::new(area.width as f32, area.height as f32));
        let show_tiles = visibility_filter.show_tiles;
        let show_walkmesh = persist.show_walkmesh;

        // Build HakIndex for efficient texture search (only opens the relevant hak, not all haks)
        let hak_index = mod_path.and_then(|p| {
            if !hak_names.is_empty() {
                Some(nwn_tileset::HakIndex::new(p, hak_names))
            } else {
                None
            }
        });

        // Collect unique model names from area for parallel loading
        let unique_models: Vec<String> = {
            let cols_p = area.width.max(1) as usize;
            let rows_p = area.height.max(1) as usize;
            let mut seen = std::collections::HashSet::new();
            let mut names = Vec::new();
            for (i, _) in area.tiles.iter().enumerate() {
                if i >= cols_p * rows_p { break; }
                if let Some(Some(name)) = area.tile_models.get(i) {
                    if !name.is_empty() && seen.insert(name.clone()) {
                        names.push(name.clone());
                    }
                }
            }
            // Also collect object model names
            for p in &area.placeables {
                if let Some(ref name) = p.model_name {
                    if !name.is_empty() && seen.insert(name.clone()) {
                        names.push(name.clone());
                    }
                }
            }
            for d in &area.doors {
                if let Some(ref name) = d.model_name {
                    if !name.is_empty() && seen.insert(name.clone()) {
                        names.push(name.clone());
                    }
                }
            }
            for c in &area.creatures {
                if let Some(ref name) = c.model_name {
                    if !name.is_empty() && seen.insert(name.clone()) {
                        names.push(name.clone());
                    }
                }
            }
            names
        };

        // Use existing cache or create fresh one
        let mut local_cache = tile_renderer::ModelCache::new();
        let model_cache: &mut tile_renderer::ModelCache = if let Some(c) = existing_cache {
            c
        } else {
            &mut local_cache
        };

        // Only load models not already in the cache
        let already_cached: std::collections::HashSet<&str> = model_cache.cache.keys().map(|s| s.as_str()).collect();
        let to_load: Vec<&String> = unique_models.iter().filter(|n| !already_cached.contains(n.as_str())).collect();

        if !to_load.is_empty() {
            use rayon::prelude::*;
            let results: Vec<_> = to_load.par_iter()
                .map(|name| {
                    let mut loaded = nwn_tileset::load_model_meshes(name).ok().flatten();
                    if loaded.is_none() {
                        if let Some(erf) = module_erf {
                            for restype in &[2002u16, 2001] {
                                if let Some(data) = erf.get(name, *restype) {
                                    if let Ok(meshes) = nwn_tileset::load_model_meshes_from_data(name, &data) {
                                        loaded = meshes;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    if loaded.is_none() {
                        if let (Some(dir), hak_list) = (mod_path, hak_names) {
                            if !hak_list.is_empty() {
                                loaded = nwn_tileset::load_model_meshes_from_haks(name, dir, hak_list);
                            }
                        }
                    }
                    if loaded.is_none() {
                        eprintln!("  model '{}' NOT FOUND", name);
                    }
                    ((*name).clone(), loaded)
                })
                .collect();
            for (name, meshes) in results {
                if let Some(m) = meshes {
                    model_cache.cache.entry(name.to_string()).or_insert(m);
                }
            }
        }

        let mut instanced = tile_renderer::build_instanced_tiles(area, model_cache);
        let tile_group_count = instanced.models.len();
        let obj_instanced = tile_renderer::build_object_models(area, model_cache, &visibility_filter);
        let object_instance_map = tile_renderer::build_object_instance_map(area, &obj_instanced, model_cache, &visibility_filter);
        let obj_models = obj_instanced.models;
        let obj_instance_data = obj_instanced.instance_data;
        // Merge object models into instanced
        instanced.models.extend(obj_models);
        instanced.instance_data.extend(obj_instance_data);

        let markers_result = tile_renderer::build_object_markers(area, visibility_filter, &model_cache);
        let marker_data = markers_result.mesh;
        let tile_count: usize = instanced.instance_data.iter().map(|v| v.len()).sum();
        let draw_calls = instanced.instance_data.iter().filter(|v| !v.is_empty()).count() + 1;
        let group_count = instanced.instance_data.len();

        // --- Sprite / billboard icon setup ---
        let sprite_icon_names: Vec<Option<&str>> = markers_result.markers.iter()
            .map(|m| tile_renderer::object_type_icon(m.obj_type))
            .collect();
        // Deduplicate icon names, preserving order
        let mut sprite_icon_set: Vec<&str> = Vec::new();
        for icon in sprite_icon_names.iter().flatten() {
            if !sprite_icon_set.contains(icon) {
                sprite_icon_set.push(icon);
            }
        }
        // Load icon textures from game data
        let sprite_icon_slot: std::collections::HashMap<&str, usize> = sprite_icon_set.iter().enumerate()
            .map(|(i, name)| (*name, i))
            .collect();
        let sprite_icon_tex_data: Vec<Option<(u32, u32, Vec<u8>)>> = sprite_icon_set.iter()
            .map(|name| match nwn_tileset::load_texture_data(name) {
                Ok(Some(d)) => Some((d.width, d.height, d.rgba)),
                _ => None,
            })
            .collect();
        // Build sprite info list + batches
        let mut sprites: Vec<SpriteInfo> = Vec::new();
        let mut sprite_batches: Vec<SpriteBatch> = Vec::new();
        {
            // Group sprite indices by icon
            let mut by_icon: std::collections::HashMap<&str, Vec<usize>> = std::collections::HashMap::new();
            for (mi, icon) in sprite_icon_names.iter().enumerate() {
                if let Some(name) = icon {
                    let idx = sprites.len();
                    let m = &markers_result.markers[mi];
                    sprites.push(SpriteInfo { x: m.x, y: m.y, z: m.z });
                    by_icon.entry(name).or_default().push(idx);
                }
            }
            let mut start = 0u32;
            for (name, indices) in &by_icon {
                let slot = sprite_icon_slot.get(name).copied().unwrap_or(0);
                sprite_batches.push(SpriteBatch {
                    texture_slot: slot,
                    start_instance: start,
                    num_instances: indices.len() as u32,
                });
                start += indices.len() as u32;
            }
        }
        let total_sprites = sprites.len();
        // Unit quad for billboards
        let sprite_quad_vbuf = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("nwn3d_sprite_quad_vbuf"),
            contents: bytemuck::cast_slice(&[
                -0.5f32, -0.5f32, 0.0f32,  0.0, 0.0, 1.0,  0.0, 1.0,  1.0, 1.0, 1.0, 1.0,
                 0.5f32, -0.5f32, 0.0f32,  0.0, 0.0, 1.0,  1.0, 1.0,  1.0, 1.0, 1.0, 1.0,
                 0.5f32,  0.5f32, 0.0f32,  0.0, 0.0, 1.0,  1.0, 0.0,  1.0, 1.0, 1.0, 1.0,
                -0.5f32,  0.5f32, 0.0f32,  0.0, 0.0, 1.0,  0.0, 0.0,  1.0, 1.0, 1.0, 1.0,
            ]),
            usage: wgpu::BufferUsages::VERTEX,
        });
        let sprite_quad_ibuf = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("nwn3d_sprite_quad_ibuf"),
            contents: bytemuck::cast_slice(&[0u32, 1, 2, 0, 2, 3]),
            usage: wgpu::BufferUsages::INDEX,
        });
        let sprite_instance_buf = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("nwn3d_sprite_instance_buf"),
            size: (total_sprites.max(1) as u64) * 64, // 64 bytes per InstanceData
            usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });

        // Collect unique texture names from models
        let mut tex_names: Vec<String> = Vec::new();
        for m in &instanced.models {
            if let Some(ref tn) = m.texture_name {
                if !tex_names.iter().any(|n| n == tn) {
                    tex_names.push(tn.clone());
                }
            }
        }

        // Load textures one-at-a-time, building texture_slots directly (no intermediate Vec)
        // This avoids having all decoded textures in CPU RAM simultaneously
        let ram_limit_kb = (max_texture_bytes / 1024).saturating_mul(2);
        let mut total_tex_bytes: u64 = 0;
        let mut texture_slots: Vec<TextureSlot> = Vec::new();
        let mut loaded_count = 0usize;
        let mut tex_slot_map: std::collections::HashMap<String, usize> = std::collections::HashMap::new();
        for (i, name) in tex_names.iter().enumerate() {
            if total_tex_bytes >= max_texture_bytes {
                break;
            }
            if i % 4 == 0 && current_rss_kb() > ram_limit_kb && ram_limit_kb > 512 * 1024 {
                eprintln!("  RAM limit — stopped textures at {}/{}", i, tex_names.len());
                break;
            }
            let pending = load_texture(name, module_erf, hak_index.as_ref(), mod_path, hak_names);
            let (w, h) = pending.as_ref().map(|d| (d.0, d.1)).unwrap_or((2, 2));
            if pending.is_some() {
                loaded_count += 1;
                total_tex_bytes += w as u64 * h as u64 * 4;
            } else {
                continue;
            }
            let slot_idx = texture_slots.len() + 1; // +1 for fallback at index 0
            tex_slot_map.insert(name.clone(), slot_idx);
            let texture = device.create_texture(&wgpu::TextureDescriptor {
                label: Some(&format!("nwn3d_tex_{name}")),
                size: wgpu::Extent3d { width: w, height: h, depth_or_array_layers: 1 },
                mip_level_count: 1,
                sample_count: 1,
                dimension: wgpu::TextureDimension::D2,
                format: wgpu::TextureFormat::Rgba8UnormSrgb,
                usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
                view_formats: &[],
            });
            texture_slots.push(TextureSlot {
                view: texture.create_view(&wgpu::TextureViewDescriptor::default()),
                sampler: device.create_sampler(&wgpu::SamplerDescriptor {
                    label: Some("nwn3d_tex_sampler"),
                    address_mode_u: wgpu::AddressMode::Repeat,
                    address_mode_v: wgpu::AddressMode::Repeat,
                    address_mode_w: wgpu::AddressMode::Repeat,
                    mag_filter: wgpu::FilterMode::Linear,
                    min_filter: wgpu::FilterMode::Linear,
                    mipmap_filter: wgpu::FilterMode::Linear,
                    ..Default::default()
                }),
                texture,
                bind_group: None,
                pending,
            });
        }
        let skipped_count = tex_names.len().saturating_sub(texture_slots.len());
        eprintln!("  Textures: {} unique, {} loaded, {} skipped (cap={} MB)", tex_names.len(), loaded_count, skipped_count, max_texture_bytes / 1024 / 1024);


        // Create per-model group resources with instance buffers
        let mut group_resources = Vec::new();
        for (midx, model) in instanced.models.iter().enumerate() {
            let tex_slot = model.texture_name.as_ref()
                .and_then(|n| {
                    let found = tex_slot_map.contains_key(n.as_str());
                    if !found {
                        eprintln!("  MODEL GROUP: texture '{}' not in tex_slot_map (used model_name={:?})", n, model.texture_name);
                    }
                    tex_slot_map.get(n.as_str()).copied()
                })
                .unwrap_or_else(|| {
                    if model.texture_name.is_some() {
                        eprintln!("  MODEL GROUP: texture '{:?}' not found, using slot 0", model.texture_name);
                    }
                    0
                });
            if tex_slot == 0 && model.texture_name.is_some() {
                eprintln!("  MODEL GROUP SLOT0: tex_name='{:?}' — using fallback", model.texture_name);
            }

            let vertex_buf = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_inst_vbuf"),
                contents: bytemuck::cast_slice(&model.data.vertices),
                usage: wgpu::BufferUsages::VERTEX,
            });
            let index_buf = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_inst_ibuf"),
                contents: bytemuck::cast_slice(&model.data.indices),
                usage: wgpu::BufferUsages::INDEX,
            });
            let instance_buf = device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_inst_instance_buf"),
                contents: bytemuck::cast_slice(&instanced.instance_data[midx]),
                usage: wgpu::BufferUsages::VERTEX | wgpu::BufferUsages::COPY_DST,
            });

            group_resources.push(GroupResources {
                num_indices: model.data.indices.len() as u32,
                num_instances: instanced.instance_data[midx].len() as u32,
                vertex_buf,
                index_buf,
                instance_buf,
                texture_slot: tex_slot,
            });
        }

        // Add a fallback texture slot at index 0 (2x2 white)
        let fb_tex = device.create_texture(&wgpu::TextureDescriptor {
            label: Some("nwn3d_fallback_tex"),
            size: wgpu::Extent3d { width: 2, height: 2, depth_or_array_layers: 1 },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Rgba8UnormSrgb,
            usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
            view_formats: &[],
        });
        let fb_view = fb_tex.create_view(&wgpu::TextureViewDescriptor::default());
        texture_slots.insert(0, TextureSlot {
            texture: fb_tex,
            view: fb_view,
            sampler: device.create_sampler(&wgpu::SamplerDescriptor {
                label: Some("nwn3d_fallback_sampler"),
                address_mode_u: wgpu::AddressMode::Repeat,
                address_mode_v: wgpu::AddressMode::Repeat,
                address_mode_w: wgpu::AddressMode::Repeat,
                mag_filter: wgpu::FilterMode::Linear,
                min_filter: wgpu::FilterMode::Linear,
                mipmap_filter: wgpu::FilterMode::Linear,
                ..Default::default()
            }),
            bind_group: None,
            pending: None,
        });

        // Append sprite icon texture slots (after fallback [0] + tile textures)
        let sprite_slot_start = texture_slots.len();
        for (i, name) in sprite_icon_set.iter().enumerate() {
            let (w, h) = sprite_icon_tex_data[i].as_ref().map(|d| (d.0, d.1)).unwrap_or((2, 2));
            let tex = device.create_texture(&wgpu::TextureDescriptor {
                label: Some(&format!("nwn3d_sprite_tex_{name}")),
                size: wgpu::Extent3d { width: w, height: h, depth_or_array_layers: 1 },
                mip_level_count: 1,
                sample_count: 1,
                dimension: wgpu::TextureDimension::D2,
                format: wgpu::TextureFormat::Rgba8UnormSrgb,
                usage: wgpu::TextureUsages::TEXTURE_BINDING | wgpu::TextureUsages::COPY_DST,
                view_formats: &[],
            });
            texture_slots.push(TextureSlot {
                view: tex.create_view(&wgpu::TextureViewDescriptor::default()),
                sampler: device.create_sampler(&wgpu::SamplerDescriptor {
                    label: Some("nwn3d_sprite_sampler"),
                    address_mode_u: wgpu::AddressMode::ClampToEdge,
                    address_mode_v: wgpu::AddressMode::ClampToEdge,
                    address_mode_w: wgpu::AddressMode::ClampToEdge,
                    mag_filter: wgpu::FilterMode::Linear,
                    min_filter: wgpu::FilterMode::Linear,
                    mipmap_filter: wgpu::FilterMode::Linear,
                    ..Default::default()
                }),
                texture: tex,
                bind_group: None,
                pending: sprite_icon_tex_data[i].clone(),
            });
        }
        // Fix up sprite batch texture slots
        for batch in &mut sprite_batches {
            batch.texture_slot = sprite_slot_start + batch.texture_slot;
        }

        let uniform_bind_group_layout =
            device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
                label: Some("nwn3d_uniform_bgl"),
                entries: &[wgpu::BindGroupLayoutEntry {
                    binding: 0,
                    visibility: wgpu::ShaderStages::VERTEX | wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Buffer {
                        ty: wgpu::BufferBindingType::Uniform,
                        has_dynamic_offset: false,
                        min_binding_size: None,
                    },
                    count: None,
                }],
            });

        let texture_bind_group_layout =
            device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
                label: Some("nwn3d_texture_bgl"),
                entries: &[
                    wgpu::BindGroupLayoutEntry {
                        binding: 0,
                        visibility: wgpu::ShaderStages::FRAGMENT,
                        ty: wgpu::BindingType::Sampler(wgpu::SamplerBindingType::Filtering),
                        count: None,
                    },
                    wgpu::BindGroupLayoutEntry {
                        binding: 1,
                        visibility: wgpu::ShaderStages::FRAGMENT,
                        ty: wgpu::BindingType::Texture {
                            sample_type: wgpu::TextureSampleType::Float { filterable: true },
                            view_dimension: wgpu::TextureViewDimension::D2,
                            multisampled: false,
                        },
                        count: None,
                    },
                ],
            });

        let pipeline = pipeline::create_pipeline(device, config, &uniform_bind_group_layout, &texture_bind_group_layout, Some(wgpu::TextureFormat::Depth32Float));
        let tile_pipeline = pipeline::create_tile_pipeline(
            device,
            config.format,
            &uniform_bind_group_layout,
            &texture_bind_group_layout,
            Some(wgpu::TextureFormat::Depth32Float),
        );
        let marker_pipeline = pipeline::create_marker_pipeline(
            device,
            config.format,
            &uniform_bind_group_layout,
            &texture_bind_group_layout,
            Some(wgpu::TextureFormat::Depth32Float),
        );
        let walkmesh_pipeline = pipeline::create_walkmesh_pipeline(
            device,
            config.format,
            &uniform_bind_group_layout,
            &texture_bind_group_layout,
            Some(wgpu::TextureFormat::Depth32Float),
        );
        let floor_pipeline = pipeline::create_floor_pipeline(
            device,
            config.format,
            &uniform_bind_group_layout,
            &texture_bind_group_layout,
            Some(wgpu::TextureFormat::Depth32Float),
        );

        let walkmesh_data = tile_renderer::build_walkmesh(area);
        let walkmesh_vertex_buf = if !walkmesh_data.vertices.is_empty() {
            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_walkmesh_vbuf"),
                contents: bytemuck::cast_slice(&walkmesh_data.vertices),
                usage: wgpu::BufferUsages::VERTEX,
            }))
        } else { None };
        let walkmesh_index_buf = if !walkmesh_data.indices.is_empty() {
            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_walkmesh_ibuf"),
                contents: bytemuck::cast_slice(&walkmesh_data.indices),
                usage: wgpu::BufferUsages::INDEX,
            }))
        } else { None };

        let (walkmesh_edge_verts, walkmesh_edge_idx) = tile_renderer::build_walkmesh_edges(area);
        let walkmesh_edge_vbuf = if !walkmesh_edge_verts.is_empty() {
            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_walkedge_vbuf"),
                contents: bytemuck::cast_slice(&walkmesh_edge_verts),
                usage: wgpu::BufferUsages::VERTEX,
            }))
        } else { None };
        let walkmesh_edge_ibuf = if !walkmesh_edge_idx.is_empty() {
            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_walkedge_ibuf"),
                contents: bytemuck::cast_slice(&walkmesh_edge_idx),
                usage: wgpu::BufferUsages::INDEX,
            }))
        } else { None };
        let walkmesh_edge_count = walkmesh_edge_idx.len() as u32;

        let floor_data = tile_renderer::build_area_floor(area);
        let floor_vertex_buf = if !floor_data.vertices.is_empty() {
            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_floor_vbuf"),
                contents: bytemuck::cast_slice(&floor_data.vertices),
                usage: wgpu::BufferUsages::VERTEX,
            }))
        } else { None };
        let floor_index_buf = if !floor_data.indices.is_empty() {
            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_floor_ibuf"),
                contents: bytemuck::cast_slice(&floor_data.indices),
                usage: wgpu::BufferUsages::INDEX,
            }))
        } else { None };
        let floor_idx_count = floor_data.indices.len() as u32;

        let paint_data = tile_renderer::build_paint_overlay_ex(area, 0, false, [40, 80, 200, 160]);
        let paint_vertex_buf = if !paint_data.vertices.is_empty() {
            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_paint_vbuf"),
                contents: bytemuck::cast_slice(&paint_data.vertices),
                usage: wgpu::BufferUsages::VERTEX,
            }))
        } else { None };
        let paint_index_buf = if !paint_data.indices.is_empty() {
            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_paint_ibuf"),
                contents: bytemuck::cast_slice(&paint_data.indices),
                usage: wgpu::BufferUsages::INDEX,
            }))
        } else { None };

        let marker_vertex_buf = if !marker_data.vertices.is_empty() {
            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_marker_vbuf"),
                contents: bytemuck::cast_slice(&marker_data.vertices),
                usage: wgpu::BufferUsages::VERTEX,
            }))
        } else { None };
        let marker_index_buf = if !marker_data.indices.is_empty() {
            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_marker_ibuf"),
                contents: bytemuck::cast_slice(&marker_data.indices),
                usage: wgpu::BufferUsages::INDEX,
            }))
        } else { None };

        let uniform_buf = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("nwn3d_uniform_buf"),
            size: UNIFORM_BUF_SIZE,
            usage: wgpu::BufferUsages::UNIFORM | wgpu::BufferUsages::COPY_DST,
            mapped_at_creation: false,
        });
        let uniform_bind_group = device.create_bind_group(&wgpu::BindGroupDescriptor {
            label: Some("nwn3d_uniform_bg"),
            layout: &uniform_bind_group_layout,
            entries: &[wgpu::BindGroupEntry {
                binding: 0,
                resource: uniform_buf.as_entire_binding(),
            }],
        });

        // Create blit pipeline (full-screen quad to display our offscreen render)
        let blit_bind_group_layout = device.create_bind_group_layout(&wgpu::BindGroupLayoutDescriptor {
            label: Some("nwn3d_blit_bgl"),
            entries: &[
                wgpu::BindGroupLayoutEntry {
                    binding: 0,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Sampler(wgpu::SamplerBindingType::Filtering),
                    count: None,
                },
                wgpu::BindGroupLayoutEntry {
                    binding: 1,
                    visibility: wgpu::ShaderStages::FRAGMENT,
                    ty: wgpu::BindingType::Texture {
                        sample_type: wgpu::TextureSampleType::Float { filterable: true },
                        view_dimension: wgpu::TextureViewDimension::D2,
                        multisampled: false,
                    },
                    count: None,
                },
            ],
        });

        let blit_sampler = device.create_sampler(&wgpu::SamplerDescriptor {
            label: Some("nwn3d_blit_sampler"),
            address_mode_u: wgpu::AddressMode::ClampToEdge,
            address_mode_v: wgpu::AddressMode::ClampToEdge,
            address_mode_w: wgpu::AddressMode::ClampToEdge,
            mag_filter: wgpu::FilterMode::Nearest,
            min_filter: wgpu::FilterMode::Nearest,
            mipmap_filter: wgpu::FilterMode::Nearest,
            ..Default::default()
        });

        let blit_pipeline = create_blit_pipeline(device, config, &blit_bind_group_layout);
        let highlight_pipeline = pipeline::create_highlight_pipeline(device, config.format, &uniform_bind_group_layout);

        let marker_idx_count = marker_data.indices.len() as u32;
        let walkmesh_idx_count = walkmesh_data.indices.len() as u32;
        let paint_idx_count = paint_data.indices.len() as u32;

        // Evict models not in current area from cache to free memory
        let keep_set: std::collections::HashSet<String> = unique_models.iter().cloned().collect();
        model_cache.retain(&keep_set);

        // Build point light list from area lights + placeables with HasLight
        let mut lights: Vec<PointLightData> = area.lights.iter().take(MAX_POINT_LIGHTS as usize).map(|l| {
            let (rx, ry, rz) = tile_renderer::nwn_to_renderer(l.x, l.y, l.z);
            PointLightData {
                position_radius: [rx, ry, rz, l.radius.max(2.0)],
                color_pad: [
                    l.color[0] as f32 / 255.0 * 2.0,
                    l.color[1] as f32 / 255.0 * 2.0,
                    l.color[2] as f32 / 255.0 * 2.0,
                    1.0,
                ],
            }
        }).collect();
        let placeable_capacity = (MAX_POINT_LIGHTS as usize).saturating_sub(lights.len());
        for pl in area.placeables.iter().take(placeable_capacity) {
            if pl.has_light {
                let (rx, ry, rz) = tile_renderer::nwn_to_renderer(pl.x, pl.y, pl.z);
                lights.push(PointLightData {
                    position_radius: [rx, ry, rz, pl.light_radius.max(2.0)],
                    color_pad: [
                        pl.light_color[0] as f32 / 255.0 * 2.0,
                        pl.light_color[1] as f32 / 255.0 * 2.0,
                        pl.light_color[2] as f32 / 255.0 * 2.0,
                        1.0,
                    ],
                });
            }
        }

        Self {
            camera,
            area_version,
            area_resref: area.resref.clone(),
            markers: markers_result.markers,
            tile_count,
            color_format: config.format,
            marker_idx_count,
            draw_calls,
            group_count,
            marker_vertex_buf,
            marker_index_buf,
            walkmesh_idx_count,
            walkmesh_vertex_buf,
            walkmesh_index_buf,
            show_walkmesh,
            walkmesh_edge_vbuf,
            walkmesh_edge_ibuf,
            walkmesh_edge_count,
            show_walkmesh_edges: persist.show_walkmesh_edges,
            clear_color: wgpu::Color { r: 0.1, g: 0.1, b: 0.12, a: 1.0 },
            water_level: persist.water_level,
            show_water: persist.show_water,
            water_color: persist.water_color,
            water_idx_count: 0,
            water_vertex_buf: None,
            water_index_buf: None,
            paint_idx_count,
            paint_vertex_buf,
            paint_index_buf,
            show_paint: persist.show_paint,
            show_tiles,
            uniform_buf,
            uniform_bind_group,
            uniform_bind_group_layout,
            texture_bind_group_layout,
            groups: group_resources,
            texture_slots,
            default_instance_buf: device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                label: Some("nwn3d_default_instance"),
                contents: bytemuck::cast_slice(&[tile_renderer::InstanceData {
                    row0: [1.0, 0.0, 0.0, 0.0],
                    row1: [0.0, 1.0, 0.0, 0.0],
                    row2: [0.0, 0.0, 1.0, 0.0],
                    row3: [0.0, 0.0, 0.0, 1.0],
                }]),
                usage: wgpu::BufferUsages::VERTEX,
            }),
            pipeline,
            tile_pipeline,
            marker_pipeline,
            walkmesh_pipeline,
            viewport_size: (0, 0),
            color_tex: [None, None],
            color_view: [None, None],
            depth_tex: [None, None],
            depth_view: [None, None],
            blit_pipeline,
            blit_bind_group_layout,
            blit_bind_group: [None, None],
            blit_sampler,
            frame_index: 0,

            highlight_vbuf: None,
            highlight_ibuf: None,
            highlight_count: 0,
            tile_hl_vbuf: None,
            tile_hl_ibuf: None,
            tile_hl_count: 0,
            highlight_pipeline,
            cached_highlight: (Vec::new(), 0.0),
            cached_tile_highlight: None,

            floor_pipeline,
            floor_vertex_buf,
            floor_index_buf,
            floor_idx_count,
            show_grid: persist.show_grid,
            lighting_enabled: persist.lighting_enabled,
            show_fog: persist.show_fog,
            fog_color: [
                area.sun_fog_color[0] as f32 / 255.0,
                area.sun_fog_color[1] as f32 / 255.0,
                area.sun_fog_color[2] as f32 / 255.0,
                1.0,
            ],
            fog_amount_norm: area.sun_fog_amount as f32 / 255.0,
            fog_clip_dist: area.fog_clip_dist,
            ambient_color: [
                area.sun_ambient_color[0] as f32 / 255.0,
                area.sun_ambient_color[1] as f32 / 255.0,
                area.sun_ambient_color[2] as f32 / 255.0,
            ],
            diffuse_color: [
                area.sun_diffuse_color[0] as f32 / 255.0,
                area.sun_diffuse_color[1] as f32 / 255.0,
                area.sun_diffuse_color[2] as f32 / 255.0,
            ],

            sprites,
            sprite_batches,
            sprite_quad_vbuf,
            sprite_quad_ibuf,
            sprite_instance_buf,
            show_sprites: persist.show_sprites,

            instance_data: instanced.instance_data,
            tile_group_count,
            tile_instance_map: instanced.tile_instance_map,
            object_instance_map,

            lights,
            last_camera_right_up: None,
            sprite_instance_dirty: true,
        }

    }

    /// Fast-path: update a single tile's transform (height / orientation) without rebuilding the scene.
    pub fn set_tile_transform(&mut self, queue: &wgpu::Queue, col: usize, row: usize, height: i32, orientation: i32) {
        let Some(entries) = self.tile_instance_map.get(&(col, row)) else { return };
        let h = height as f32 * 4.0;
        for &(gidx, inst_idx) in entries {
            if gidx >= self.tile_group_count { continue; }
            if inst_idx >= self.instance_data[gidx].len() { continue; }
            let inst = tile_renderer::tile_instance_transform(col, row, h, orientation as u8);
            self.instance_data[gidx][inst_idx] = inst;
            let offset = inst_idx as u64 * 64;
            queue.write_buffer(&self.groups[gidx].instance_buf, offset, bytemuck::cast_slice(&[inst]));
        }
    }

    /// Fast-path: update a single object's instance transform without rebuilding the entire scene.
    /// `obj_type` is "placeable", "door", or "creature".
    pub fn set_object_transform(&mut self, queue: &wgpu::Queue, obj_type: &str, obj_idx: usize,
                                 x: f32, y: f32, z: f32, bearing: f32) {
        let key = (obj_type.to_string(), obj_idx);
        let Some(entries) = self.object_instance_map.get(&key) else { return };
        let (rx, ry, rz) = tile_renderer::nwn_to_renderer(x, y, z);
        let (s, c) = bearing.sin_cos();
        for &(gidx, inst_idx) in entries {
            let agidx = gidx + self.tile_group_count;
            if agidx >= self.groups.len() { continue; }
            if inst_idx >= self.instance_data[agidx].len() { continue; }
            let inst = tile_renderer::InstanceData {
                row0: [c, 0.0, -s, 0.0],
                row1: [0.0, 1.0, 0.0, 0.0],
                row2: [s, 0.0, c, 0.0],
                row3: [rx, ry, rz, 1.0],
            };
            // Update CPU copy
            self.instance_data[agidx][inst_idx] = inst;
            // Patch GPU buffer at the right offset (64 bytes per instance)
            let offset = inst_idx as u64 * 64;
            queue.write_buffer(&self.groups[agidx].instance_buf, offset, bytemuck::cast_slice(&[inst]));
        }
    }

    fn ensure_scene_textures(&mut self, device: &wgpu::Device, width: u32, height: u32) {
        if self.viewport_size.0 == width && self.viewport_size.1 == height && self.color_tex[0].is_some() {
            return;
        }
        self.viewport_size = (width, height);

        let color_desc = wgpu::TextureDescriptor {
            label: Some("nwn3d_scene_color"),
            size: wgpu::Extent3d { width, height, depth_or_array_layers: 1 },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: self.color_format,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::TEXTURE_BINDING,
            view_formats: &[],
        };
        let depth_desc = wgpu::TextureDescriptor {
            label: Some("nwn3d_scene_depth"),
            size: wgpu::Extent3d { width, height, depth_or_array_layers: 1 },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Depth32Float,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            view_formats: &[],
        };

        for i in 0..2 {
            let ct = device.create_texture(&color_desc);
            let cv = ct.create_view(&wgpu::TextureViewDescriptor::default());
            let dt = device.create_texture(&depth_desc);
            let dv = dt.create_view(&wgpu::TextureViewDescriptor::default());
            let bg = device.create_bind_group(&wgpu::BindGroupDescriptor {
                label: Some(&format!("nwn3d_blit_bg_{i}")),
                layout: &self.blit_bind_group_layout,
                entries: &[
                    wgpu::BindGroupEntry {
                        binding: 0,
                        resource: wgpu::BindingResource::Sampler(&self.blit_sampler),
                    },
                    wgpu::BindGroupEntry {
                        binding: 1,
                        resource: wgpu::BindingResource::TextureView(&cv),
                    },
                ],
            });
            self.color_tex[i] = Some(ct);
            self.color_view[i] = Some(cv);
            self.depth_tex[i] = Some(dt);
            self.depth_view[i] = Some(dv);
            self.blit_bind_group[i] = Some(bg);
        }

        // Recreate all pipelines with the offscreen color format
        self.pipeline = pipeline::create_pipeline_with_depth(
            device,
            self.color_format,
            &self.uniform_bind_group_layout,
            &self.texture_bind_group_layout,
            Some(wgpu::TextureFormat::Depth32Float),
        );
        self.tile_pipeline = pipeline::create_tile_pipeline(
            device,
            self.color_format,
            &self.uniform_bind_group_layout,
            &self.texture_bind_group_layout,
            Some(wgpu::TextureFormat::Depth32Float),
        );
        self.marker_pipeline = pipeline::create_marker_pipeline(
            device,
            self.color_format,
            &self.uniform_bind_group_layout,
            &self.texture_bind_group_layout,
            Some(wgpu::TextureFormat::Depth32Float),
        );
        self.walkmesh_pipeline = pipeline::create_walkmesh_pipeline(
            device,
            self.color_format,
            &self.uniform_bind_group_layout,
            &self.texture_bind_group_layout,
            Some(wgpu::TextureFormat::Depth32Float),
        );
        self.highlight_pipeline = pipeline::create_highlight_pipeline(
            device,
            self.color_format,
            &self.uniform_bind_group_layout,
        );
        self.floor_pipeline = pipeline::create_floor_pipeline(
            device,
            self.color_format,
            &self.uniform_bind_group_layout,
            &self.texture_bind_group_layout,
            Some(wgpu::TextureFormat::Depth32Float),
        );
    }

    pub fn update_uniforms(&mut self, queue: &wgpu::Queue, viewport_size: (u32, u32)) {
        self.camera.aspect = if viewport_size.1 > 0 {
            viewport_size.0 as f32 / viewport_size.1 as f32
        } else {
            1.0
        };
        let light_count = self.lights.len();
        let total_size = 144 + light_count * 32;
        let mut data = Vec::with_capacity(total_size);
        let vp = mat4_mul(self.camera.view_matrix(), self.camera.projection_matrix());
        data.extend_from_slice(bytemuck::cast_slice(&[vp]));
        data.resize(64, 0u8);
        let ambient = [
            self.ambient_color[0].max(0.5),
            self.ambient_color[1].max(0.5),
            self.ambient_color[2].max(0.5),
            if self.lighting_enabled { 1.0f32 } else { 0.0f32 },
        ];
        data.extend_from_slice(bytemuck::cast_slice(&ambient));
        let fog_dist = if self.show_fog && self.fog_clip_dist <= 0.0 {
            50.0
        } else {
            self.fog_clip_dist
        };
        data.extend_from_slice(bytemuck::cast_slice(&self.fog_color));
        let fog_params = [
            if self.show_fog { self.fog_amount_norm.max(0.01) } else { 0.0 },
            fog_dist,
            light_count as f32,
            0.0,
        ];
        data.extend_from_slice(bytemuck::cast_slice(&fog_params));
        let eye = self.camera.eye();
        data.extend_from_slice(bytemuck::cast_slice(&[eye[0], eye[1], eye[2], 0.0]));
        let diff = [
            self.diffuse_color[0].max(0.5),
            self.diffuse_color[1].max(0.5),
            self.diffuse_color[2].max(0.5),
        ];
        data.extend_from_slice(bytemuck::cast_slice(&diff));
        if !self.lights.is_empty() {
            data.extend_from_slice(bytemuck::cast_slice(&self.lights));
        }
        queue.write_buffer(&self.uniform_buf, 0, &data);
    }

    pub fn update_sprite_instances(&mut self, queue: &wgpu::Queue) {
        if !self.show_sprites || self.sprites.is_empty() {
            return;
        }
        let (right, up_vec) = self.camera.right_up();
        let camera_changed = self.last_camera_right_up.map_or(true, |last| last != (right, up_vec));
        if !camera_changed && !self.sprite_instance_dirty {
            return;
        }
        let sprite_size = 0.8;

        let mut instances = Vec::with_capacity(self.sprites.len());
        for sp in &self.sprites {
            instances.push(tile_renderer::InstanceData {
                row0: [right[0] * sprite_size, right[1] * sprite_size, right[2] * sprite_size, 0.0],
                row1: [up_vec[0] * sprite_size, up_vec[1] * sprite_size, up_vec[2] * sprite_size, 0.0],
                row2: [0.0, 0.0, 1.0, 0.0],
                row3: [sp.x, sp.y, sp.z, 1.0],
            });
        }
        queue.write_buffer(&self.sprite_instance_buf, 0, bytemuck::cast_slice(&instances));
        self.last_camera_right_up = Some((right, up_vec));
        self.sprite_instance_dirty = false;
    }

    pub fn render_3d(&self, render_pass: &mut wgpu::RenderPass) {
        render_pass.set_pipeline(&self.pipeline);
        render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);

        let fb_bg = self.texture_slots[0].bind_group.as_ref();

        // Render floor grid overlay (below tiles, always-visible depth)
        if self.show_grid {
            if let (Some(vbuf), Some(ibuf)) = (&self.floor_vertex_buf, &self.floor_index_buf) {
                if self.floor_idx_count > 0 {
                    render_pass.set_pipeline(&self.floor_pipeline);
                    render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);
                    if let Some(bg) = fb_bg {
                        render_pass.set_bind_group(1, bg, &[]);
                    }
                    render_pass.set_vertex_buffer(0, vbuf.slice(..));
                    render_pass.set_vertex_buffer(1, self.default_instance_buf.slice(..));
                    render_pass.set_index_buffer(ibuf.slice(..), wgpu::IndexFormat::Uint32);
                    render_pass.draw_indexed(0..self.floor_idx_count, 0, 0..1);
                }
            }
        }

        // Render instanced tile groups (depth-tested, with back-face culling)
        if self.show_tiles {
            render_pass.set_pipeline(&self.tile_pipeline);
            render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);
            let use_fallback = std::env::var("NWN_NO_TEX").is_ok();
            for grp in &self.groups {
                let bg = if use_fallback {
                    fb_bg
                } else {
                    let tex_slot = &self.texture_slots[grp.texture_slot];
                    tex_slot.bind_group.as_ref()
                };
                let bg = match bg {
                    Some(b) => b,
                    None => continue,
                };
                render_pass.set_bind_group(1, bg, &[]);
                render_pass.set_vertex_buffer(0, grp.vertex_buf.slice(..));
                render_pass.set_vertex_buffer(1, grp.instance_buf.slice(..));
                render_pass.set_index_buffer(grp.index_buf.slice(..), wgpu::IndexFormat::Uint32);
                render_pass.draw_indexed(0..grp.num_indices, 0, 0..grp.num_instances);
            }
        }

        // Render object markers (non-instanced, single batch) — use fallback texture, LessEqual depth
        if let (Some(bg), Some(mvbuf), Some(mibuf)) = (fb_bg, &self.marker_vertex_buf, &self.marker_index_buf) {
            if self.marker_idx_count > 0 {
                render_pass.set_pipeline(&self.marker_pipeline);
                render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);
                render_pass.set_bind_group(1, bg, &[]);
                render_pass.set_vertex_buffer(0, mvbuf.slice(..));
                render_pass.set_vertex_buffer(1, self.default_instance_buf.slice(..));
                render_pass.set_index_buffer(mibuf.slice(..), wgpu::IndexFormat::Uint32);
                render_pass.draw_indexed(0..self.marker_idx_count, 0, 0..1);
            }
        }

        // Render sprite billboards (camera-facing icon quads, LessEqual depth, one draw per batch)
        if self.show_sprites && !self.sprite_batches.is_empty() {
            let ibuf = &self.sprite_quad_ibuf;
            let vbuf = &self.sprite_quad_vbuf;
            for batch in &self.sprite_batches {
                if let Some(bg) = self.texture_slots[batch.texture_slot].bind_group.as_ref() {
                    render_pass.set_pipeline(&self.marker_pipeline);
                    render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);
                    render_pass.set_bind_group(1, bg, &[]);
                    render_pass.set_vertex_buffer(0, vbuf.slice(..));
                    render_pass.set_vertex_buffer(1, self.sprite_instance_buf.slice(
                        batch.start_instance as u64 * 64..(batch.start_instance + batch.num_instances) as u64 * 64,
                    ));
                    render_pass.set_index_buffer(ibuf.slice(..), wgpu::IndexFormat::Uint32);
                    render_pass.draw_indexed(0..6, 0, 0..batch.num_instances);
                }
            }
        }

        // Render walkmesh overlay (tile height-based semi-transparent green, depth-tested)
        if self.show_walkmesh {
            if let (Some(bg), Some(vbuf), Some(ibuf)) = (fb_bg, &self.walkmesh_vertex_buf, &self.walkmesh_index_buf) {
                if self.walkmesh_idx_count > 0 {
                    render_pass.set_pipeline(&self.walkmesh_pipeline);
                    render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);
                    render_pass.set_bind_group(1, bg, &[]);
                    render_pass.set_vertex_buffer(0, vbuf.slice(..));
                    render_pass.set_vertex_buffer(1, self.default_instance_buf.slice(..));
                    render_pass.set_index_buffer(ibuf.slice(..), wgpu::IndexFormat::Uint32);
                    render_pass.draw_indexed(0..self.walkmesh_idx_count, 0, 0..1);
                }
            }
        }

        // Render walkmesh edge wireframe (line overlay, uses highlight/LINE pipeline)
        if self.show_walkmesh_edges {
            if let (Some(vbuf), Some(ibuf)) = (&self.walkmesh_edge_vbuf, &self.walkmesh_edge_ibuf) {
                if self.walkmesh_edge_count > 0 {
                    render_pass.set_pipeline(&self.highlight_pipeline);
                    render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);
                    render_pass.set_vertex_buffer(0, vbuf.slice(..));
                    render_pass.set_index_buffer(ibuf.slice(..), wgpu::IndexFormat::Uint32);
                    render_pass.draw_indexed(0..self.walkmesh_edge_count, 0, 0..1);
                }
            }
        }

        // Render paint overlay (colored quads on tiles with user tints)
        if self.show_paint {
            if let (Some(bg), Some(vbuf), Some(ibuf)) = (fb_bg, &self.paint_vertex_buf, &self.paint_index_buf) {
                if self.paint_idx_count > 0 {
                    render_pass.set_pipeline(&self.walkmesh_pipeline);
                    render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);
                    render_pass.set_bind_group(1, bg, &[]);
                    render_pass.set_vertex_buffer(0, vbuf.slice(..));
                    render_pass.set_vertex_buffer(1, self.default_instance_buf.slice(..));
                    render_pass.set_index_buffer(ibuf.slice(..), wgpu::IndexFormat::Uint32);
                    render_pass.draw_indexed(0..self.paint_idx_count, 0, 0..1);
                }
            }
        }

        // Render water overlay (flat colored quad at water level)
        if self.show_water {
            if let (Some(bg), Some(vbuf), Some(ibuf)) = (
                self.texture_slots.first().and_then(|s| s.bind_group.as_ref()),
                &self.water_vertex_buf, &self.water_index_buf
            ) {
                if self.water_idx_count > 0 {
                    render_pass.set_pipeline(&self.walkmesh_pipeline);
                    render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);
                    render_pass.set_bind_group(1, bg, &[]);
                    render_pass.set_vertex_buffer(0, vbuf.slice(..));
                    render_pass.set_vertex_buffer(1, self.default_instance_buf.slice(..));
                    render_pass.set_index_buffer(ibuf.slice(..), wgpu::IndexFormat::Uint32);
                    render_pass.draw_indexed(0..self.water_idx_count, 0, 0..1);
                }
            }
        }

        // Render object highlight wireframe
        if let (Some(vbuf), Some(ibuf)) = (&self.highlight_vbuf, &self.highlight_ibuf) {
            if self.highlight_count > 0 {
                render_pass.set_pipeline(&self.highlight_pipeline);
                render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);
                render_pass.set_vertex_buffer(0, vbuf.slice(..));
                render_pass.set_index_buffer(ibuf.slice(..), wgpu::IndexFormat::Uint32);
                render_pass.draw_indexed(0..self.highlight_count, 0, 0..1);
            }
        }

        // Render tile highlight wireframe
        if let (Some(vbuf), Some(ibuf)) = (&self.tile_hl_vbuf, &self.tile_hl_ibuf) {
            if self.tile_hl_count > 0 {
                render_pass.set_pipeline(&self.highlight_pipeline);
                render_pass.set_bind_group(0, &self.uniform_bind_group, &[]);
                render_pass.set_vertex_buffer(0, vbuf.slice(..));
                render_pass.set_index_buffer(ibuf.slice(..), wgpu::IndexFormat::Uint32);
                render_pass.draw_indexed(0..self.tile_hl_count, 0, 0..1);
            }
        }
    }



    pub fn raypick(&self, screen_x: f32, screen_y: f32, view_w: f32, view_h: f32) -> Option<(usize, &MarkerInfo)> {
        if view_w <= 0.0 || view_h <= 0.0 { return None; }
        let (origin, dir) = self.camera.ray_from_screen(screen_x, screen_y, view_w, view_h);
        let eps = 1e-15;
        let inv_dir = [
            if dir[0].abs() > eps { 1.0 / dir[0] } else { f32::INFINITY },
            if dir[1].abs() > eps { 1.0 / dir[1] } else { f32::INFINITY },
            if dir[2].abs() > eps { 1.0 / dir[2] } else { f32::INFINITY },
        ];
        let mut best: Option<(usize, f32)> = None;
        for (idx, marker) in self.markers.iter().enumerate() {
            let (bx0, by0, bz0) = (marker.aabb_min[0], marker.aabb_min[1], marker.aabb_min[2]);
            let (bx1, by1, bz1) = (marker.aabb_max[0], marker.aabb_max[1], marker.aabb_max[2]);
            let tmin = ((bx0 - origin[0]) * inv_dir[0]).min((bx1 - origin[0]) * inv_dir[0]);
            let tmax = ((bx0 - origin[0]) * inv_dir[0]).max((bx1 - origin[0]) * inv_dir[0]);
            let tymin = ((by0 - origin[1]) * inv_dir[1]).min((by1 - origin[1]) * inv_dir[1]);
            let tymax = ((by0 - origin[1]) * inv_dir[1]).max((by1 - origin[1]) * inv_dir[1]);
            let tzmin = ((bz0 - origin[2]) * inv_dir[2]).min((bz1 - origin[2]) * inv_dir[2]);
            let tzmax = ((bz0 - origin[2]) * inv_dir[2]).max((bz1 - origin[2]) * inv_dir[2]);
            let t0 = tmin.max(tymin).max(tzmin);
            let t1 = tmax.min(tymax).min(tzmax);
            if t0 <= t1 && t1 >= 0.0 {
                let dist = if t0 >= 0.0 { t0 } else { t1 };
                let better = best.map_or(true, |(_, d)| dist < d);
                if better {
                    best = Some((idx, dist));
                }
            }
        }
        best.map(|(idx, _)| (idx, &self.markers[idx]))
    }

    pub fn world_to_screen(&self, world: [f32; 3], view_w: f32, view_h: f32) -> Option<[f32; 2]> {
        self.camera.world_to_screen(world, view_w, view_h)
    }

    /// Returns (world_x, world_y, world_z) where the ray hits the ground plane (Y=0 in renderer space).
    pub fn pick_ground(&self, screen_x: f32, screen_y: f32, view_w: f32, view_h: f32) -> Option<[f32; 3]> {
        if view_w <= 0.0 || view_h <= 0.0 { return None; }
        let (origin, dir) = self.camera.ray_from_screen(screen_x, screen_y, view_w, view_h);
        if dir[1].abs() < 1e-15 { return None; }
        let t = -origin[1] / dir[1];
        if t < 0.0 { return None; }
        Some([origin[0] + t * dir[0], origin[1] + t * dir[1], origin[2] + t * dir[2]])
    }

    /// Returns markers whose screen-space projection falls inside the given rectangle.
    pub fn screen_rect_select(&self, min_screen: [f32; 2], max_screen: [f32; 2], view_w: f32, view_h: f32) -> Vec<(usize, &MarkerInfo)> {
        let mut hits = Vec::new();
        let (x0, x1) = if min_screen[0] < max_screen[0] { (min_screen[0], max_screen[0]) } else { (max_screen[0], min_screen[0]) };
        let (y0, y1) = if min_screen[1] < max_screen[1] { (min_screen[1], max_screen[1]) } else { (max_screen[1], min_screen[1]) };
        for (idx, marker) in self.markers.iter().enumerate() {
            let render_pos = [marker.x, marker.z, -marker.y];
            if let Some(screen) = self.camera.world_to_screen(render_pos, view_w, view_h) {
                if screen[0] >= x0 && screen[0] <= x1 && screen[1] >= y0 && screen[1] <= y1 {
                    hits.push((idx, marker));
                }
            }
        }
        hits
    }

    pub fn set_highlight_tile(&mut self, device: &wgpu::Device, tile_idx: Option<usize>, col: usize, row: usize, height: f32) {
        let key = (tile_idx, col, row, height);
        if Some(key) == self.cached_tile_highlight {
            return;
        }
        self.cached_tile_highlight = Some((tile_idx, col, row, height));

        self.tile_hl_vbuf = None;
        self.tile_hl_ibuf = None;
        self.tile_hl_count = 0;

        if tile_idx.is_none() { return; }

        let tile_w = 10.0;
        let tx = col as f32 * tile_w;
        let tz = -(row as f32) * tile_w;
        let hy = height;
        let hh = 0.25;

        let corners: [[f32; 3]; 8] = [
            [tx,      hy - hh, tz],
            [tx + tile_w, hy - hh, tz],
            [tx + tile_w, hy - hh, tz - tile_w],
            [tx,      hy - hh, tz - tile_w],
            [tx,      hy + hh, tz],
            [tx + tile_w, hy + hh, tz],
            [tx + tile_w, hy + hh, tz - tile_w],
            [tx,      hy + hh, tz - tile_w],
        ];

        let edges: [(u32, u32); 12] = [
            (0,1),(1,2),(2,3),(3,0),  // bottom
            (4,5),(5,6),(6,7),(7,4),  // top
            (0,4),(1,5),(2,6),(3,7),  // vertical
        ];

        let color: [f32; 4] = [0.0, 1.0, 1.0, 1.0]; // bright cyan
        let mut verts: Vec<f32> = Vec::new();
        for &(a, b) in &edges {
            for &ci in &[a, b] {
                verts.push(corners[ci as usize][0]);
                verts.push(corners[ci as usize][1]);
                verts.push(corners[ci as usize][2]);
                verts.push(color[0]);
                verts.push(color[1]);
                verts.push(color[2]);
                verts.push(color[3]);
            }
        }
        let indices: Vec<u32> = (0..(edges.len() * 2) as u32).collect();

        if verts.is_empty() { return; }

        self.tile_hl_vbuf = Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("nwn3d_tile_hl_vbuf"),
            contents: bytemuck::cast_slice(&verts),
            usage: wgpu::BufferUsages::VERTEX,
        }));
        self.tile_hl_ibuf = Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("nwn3d_tile_hl_ibuf"),
            contents: bytemuck::cast_slice(&indices),
            usage: wgpu::BufferUsages::INDEX,
        }));
        self.tile_hl_count = indices.len() as u32;
    }

    /// Draw a green wireframe box around a world position (for selected objects).
    pub fn set_highlight_objects(&mut self, device: &wgpu::Device, positions: &[[f32; 3]], half_size: f32) {
        let key = (positions.to_vec(), half_size);
        if key == self.cached_highlight {
            return;
        }
        self.cached_highlight = key;

        self.highlight_vbuf = None;
        self.highlight_ibuf = None;
        self.highlight_count = 0;

        if positions.is_empty() { return; }

        const EDGES: [(u32, u32); 12] = [
            (0,1),(1,2),(2,3),(3,0),
            (4,5),(5,6),(6,7),(7,4),
            (0,4),(1,5),(2,6),(3,7),
        ];
        const COLOR: [f32; 4] = [0.0, 1.0, 0.2, 0.8];

        let mut verts: Vec<f32> = Vec::new();
        let mut idx_offset = 0u32;
        for &[cx, cy, cz] in positions {
            let hs = half_size;
            let corners: [[f32; 3]; 8] = [
                [cx - hs, cy - hs, cz - hs],
                [cx + hs, cy - hs, cz - hs],
                [cx + hs, cy - hs, cz + hs],
                [cx - hs, cy - hs, cz + hs],
                [cx - hs, cy + hs, cz - hs],
                [cx + hs, cy + hs, cz - hs],
                [cx + hs, cy + hs, cz + hs],
                [cx - hs, cy + hs, cz + hs],
            ];
            for &(a, b) in &EDGES {
                for &ci in &[a, b] {
                    verts.push(corners[ci as usize][0]);
                    verts.push(corners[ci as usize][1]);
                    verts.push(corners[ci as usize][2]);
                    verts.push(COLOR[0]);
                    verts.push(COLOR[1]);
                    verts.push(COLOR[2]);
                    verts.push(COLOR[3]);
                }
            }
            idx_offset += EDGES.len() as u32 * 2;
        }

        let indices: Vec<u32> = (0..idx_offset).collect();
        if verts.is_empty() { return; }

        self.highlight_vbuf = Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("nwn3d_highlight_obj_vbuf"),
            contents: bytemuck::cast_slice(&verts),
            usage: wgpu::BufferUsages::VERTEX,
        }));
        self.highlight_ibuf = Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
            label: Some("nwn3d_highlight_obj_ibuf"),
            contents: bytemuck::cast_slice(&indices),
            usage: wgpu::BufferUsages::INDEX,
        }));
        self.highlight_count = indices.len() as u32;
    }

    fn ensure_textures(&mut self, device: &wgpu::Device, queue: &wgpu::Queue) {
        for slot in &mut self.texture_slots {
            if slot.bind_group.is_some() {
                continue;
            }
            if let Some((width, height, ref data)) = slot.pending.take() {
                queue.write_texture(
                    wgpu::TexelCopyTextureInfo {
                        texture: &slot.texture,
                        mip_level: 0,
                        origin: wgpu::Origin3d::ZERO,
                        aspect: wgpu::TextureAspect::All,
                    },
                    data,
                    wgpu::TexelCopyBufferLayout {
                        offset: 0,
                        bytes_per_row: Some(width * 4),
                        rows_per_image: Some(height),
                    },
                    wgpu::Extent3d { width, height, depth_or_array_layers: 1 },
                );
            } else {
                // Default 2x2 white for fallback/no-data
                let white: [u8; 16] = [255; 16];
                queue.write_texture(
                    wgpu::TexelCopyTextureInfo {
                        texture: &slot.texture,
                        mip_level: 0,
                        origin: wgpu::Origin3d::ZERO,
                        aspect: wgpu::TextureAspect::All,
                    },
                    &white,
                    wgpu::TexelCopyBufferLayout {
                        offset: 0,
                        bytes_per_row: Some(8),
                        rows_per_image: Some(2),
                    },
                    wgpu::Extent3d { width: 2, height: 2, depth_or_array_layers: 1 },
                );
            }
            slot.bind_group = Some(device.create_bind_group(&wgpu::BindGroupDescriptor {
                label: Some("nwn3d_tex_bg"),
                layout: &self.texture_bind_group_layout,
                entries: &[
                    wgpu::BindGroupEntry {
                        binding: 0,
                        resource: wgpu::BindingResource::Sampler(&slot.sampler),
                    },
                    wgpu::BindGroupEntry {
                        binding: 1,
                        resource: wgpu::BindingResource::TextureView(&slot.view),
                    },
                ],
            }));
        }
    }
}

struct PendingArea {
    area: Arc<nwn_gamemodel::Area>,
    version: u64,
    format: wgpu::TextureFormat,
}

pub struct ViewportPersist {
    pub show_grid: bool,
    pub lighting_enabled: bool,
    pub show_fog: bool,
    pub show_water: bool,
    pub water_level: i32,
    pub water_color: [u8; 4],
    pub show_walkmesh: bool,
    pub show_walkmesh_edges: bool,
    pub show_paint: bool,
    pub show_sprites: bool,
}

fn current_rss_kb() -> u64 {
    #[cfg(target_os = "linux")]
    if let Ok(data) = std::fs::read_to_string("/proc/self/status") {
        if let Some(line) = data.lines().find(|l| l.starts_with("VmRSS:")) {
            if let Some(val) = line.split_whitespace().nth(1) {
                if let Ok(v) = val.parse::<u64>() {
                    return v;
                }
            }
        }
    }
    0
}

pub struct WgpuViewport {
    pub inner: Arc<Mutex<Option<ViewportState>>>,
    pending: Arc<Mutex<Option<PendingArea>>>,
    pending_rebuild: Arc<Mutex<Option<ViewportState>>>,
    rebuild_in_progress: Arc<AtomicBool>,
    visibility_filter: Arc<Mutex<tile_renderer::VisibilityFilter>>,
    texture_mem_limit: Arc<Mutex<u64>>,
    module_erf_bytes: Arc<Mutex<Option<Arc<Vec<u8>>>>>,
    mod_path: Arc<Mutex<Option<std::path::PathBuf>>>,
    hak_names: Arc<Mutex<Vec<String>>>,
    device: Arc<Mutex<Option<wgpu::Device>>>,
    queue: Arc<Mutex<Option<wgpu::Queue>>>,
    /// Persistent model cache to avoid reloading models from disk on rebuild
    model_cache: Arc<Mutex<tile_renderer::ModelCache>>,
    /// Persistent toggle states (survive scene rebuilds)
    persist_show_grid: Arc<Mutex<bool>>,
    persist_lighting_enabled: Arc<Mutex<bool>>,
    persist_show_fog: Arc<Mutex<bool>>,
    persist_show_water: Arc<Mutex<bool>>,
    persist_water_level: Arc<Mutex<i32>>,
    persist_water_color: Arc<Mutex<[u8; 4]>>,
    persist_show_walkmesh: Arc<Mutex<bool>>,
    persist_show_walkmesh_edges: Arc<Mutex<bool>>,
    persist_show_paint: Arc<Mutex<bool>>,
    persist_show_sprites: Arc<Mutex<bool>>,
}

impl WgpuViewport {
    pub fn new() -> Self {
        Self {
            inner: Arc::new(Mutex::new(None)),
            pending: Arc::new(Mutex::new(None)),
            pending_rebuild: Arc::new(Mutex::new(None)),
            rebuild_in_progress: Arc::new(AtomicBool::new(false)),
            visibility_filter: Arc::new(Mutex::new(Default::default())),
            texture_mem_limit: Arc::new(Mutex::new(512 * 1024 * 1024)),
            module_erf_bytes: Arc::new(Mutex::new(None)),
            mod_path: Arc::new(Mutex::new(None)),
            hak_names: Arc::new(Mutex::new(Vec::new())),
            device: Arc::new(Mutex::new(None)),
            queue: Arc::new(Mutex::new(None)),
            model_cache: Arc::new(Mutex::new(tile_renderer::ModelCache::new())),
            persist_show_grid: Arc::new(Mutex::new(true)),
            persist_lighting_enabled: Arc::new(Mutex::new(true)),
            persist_show_fog: Arc::new(Mutex::new(false)),
            persist_show_water: Arc::new(Mutex::new(false)),
            persist_water_level: Arc::new(Mutex::new(0)),
            persist_water_color: Arc::new(Mutex::new([40, 80, 200, 160])),
            persist_show_walkmesh: Arc::new(Mutex::new(false)),
            persist_show_walkmesh_edges: Arc::new(Mutex::new(false)),
            persist_show_paint: Arc::new(Mutex::new(false)),
            persist_show_sprites: Arc::new(Mutex::new(true)),
        }
    }

    pub fn clone_arc(&self) -> Self {
        Self {
            inner: Arc::clone(&self.inner),
            pending: Arc::clone(&self.pending),
            pending_rebuild: Arc::clone(&self.pending_rebuild),
            rebuild_in_progress: Arc::clone(&self.rebuild_in_progress),
            visibility_filter: Arc::clone(&self.visibility_filter),
            texture_mem_limit: Arc::clone(&self.texture_mem_limit),
            module_erf_bytes: Arc::clone(&self.module_erf_bytes),
            mod_path: Arc::clone(&self.mod_path),
            hak_names: Arc::clone(&self.hak_names),
            device: Arc::clone(&self.device),
            queue: Arc::clone(&self.queue),
            model_cache: Arc::clone(&self.model_cache),
            persist_show_grid: Arc::clone(&self.persist_show_grid),
            persist_lighting_enabled: Arc::clone(&self.persist_lighting_enabled),
            persist_show_fog: Arc::clone(&self.persist_show_fog),
            persist_show_water: Arc::clone(&self.persist_show_water),
            persist_water_level: Arc::clone(&self.persist_water_level),
            persist_water_color: Arc::clone(&self.persist_water_color),
            persist_show_walkmesh: Arc::clone(&self.persist_show_walkmesh),
            persist_show_walkmesh_edges: Arc::clone(&self.persist_show_walkmesh_edges),
            persist_show_paint: Arc::clone(&self.persist_show_paint),
            persist_show_sprites: Arc::clone(&self.persist_show_sprites),
        }
    }

    pub fn set_module_erf(&self, data: Option<Vec<u8>>) {
        if let Ok(mut guard) = self.module_erf_bytes.lock() {
            *guard = data.map(Arc::new);
        }
    }

    pub fn set_hak_info(&self, path: Option<std::path::PathBuf>, haks: Vec<String>) {
        if let Ok(mut guard) = self.mod_path.lock() {
            *guard = path;
        }
        if let Ok(mut guard) = self.hak_names.lock() {
            *guard = haks;
        }
    }

    pub fn set_visibility_filter(&self, filter: tile_renderer::VisibilityFilter) {
        if let Ok(mut guard) = self.visibility_filter.lock() {
            *guard = filter;
        }
    }

    pub fn set_texture_mem_limit(&self, limit_bytes: u64) {
        if let Ok(mut guard) = self.texture_mem_limit.lock() {
            *guard = limit_bytes;
        }
    }

    pub fn evict_model_cache(&self) {
        if let Ok(mut guard) = self.model_cache.lock() {
            let before = guard.cache.len();
            guard.cache.clear();
            if before > 0 {
                eprintln!("  Evicted {} model caches to free memory", before);
            }
        }
    }

    pub fn set_area(&self, area: Arc<nwn_gamemodel::Area>, version: u64, format: wgpu::TextureFormat) {
        if let Ok(mut guard) = self.pending.lock() {
            *guard = Some(PendingArea { area, version, format });
        }
    }

    /// Fast-path: update a single object's transform without rebuilding the scene.
    /// Fast-path: update a single tile's height/orientation without rebuilding the scene.
    pub fn set_tile_transform(&self, col: usize, row: usize, height: i32, orientation: i32) {
        let queue = self.queue.lock().ok().and_then(|q| q.clone());
        if let Some(queue) = queue {
            if let Ok(mut guard) = self.inner.lock() {
                if let Some(ref mut state) = *guard {
                    state.set_tile_transform(&queue, col, row, height, orientation);
                }
            }
        }
    }

    pub fn set_object_transform(&self, obj_type: &str, obj_idx: usize,
                                 x: f32, y: f32, z: f32, bearing: f32) {
        let queue = self.queue.lock().ok().and_then(|q| q.clone());
        if let Some(queue) = queue {
            if let Ok(mut guard) = self.inner.lock() {
                if let Some(ref mut state) = *guard {
                    state.set_object_transform(&queue, obj_type, obj_idx, x, y, z, bearing);
                }
            }
        }
    }

    pub fn set_show_grid(&self, show: bool) {
        if let Ok(mut guard) = self.persist_show_grid.lock() { *guard = show; }
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.show_grid = show;
            }
        }
    }

    pub fn get_show_grid(&self) -> bool {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return state.show_grid;
            }
        }
        self.persist_show_grid.lock().map(|g| *g).unwrap_or(true)
    }

    pub fn set_show_walkmesh_edges(&self, show: bool) {
        if let Ok(mut guard) = self.persist_show_walkmesh_edges.lock() { *guard = show; }
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.show_walkmesh_edges = show;
            }
        }
    }

    pub fn get_show_walkmesh_edges(&self) -> bool {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return state.show_walkmesh_edges;
            }
        }
        self.persist_show_walkmesh_edges.lock().map(|g| *g).unwrap_or(false)
    }

    pub fn set_lighting_enabled(&self, enabled: bool) {
        if let Ok(mut guard) = self.persist_lighting_enabled.lock() { *guard = enabled; }
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.lighting_enabled = enabled;
            }
        }
    }

    pub fn get_lighting_enabled(&self) -> bool {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return state.lighting_enabled;
            }
        }
        self.persist_lighting_enabled.lock().map(|g| *g).unwrap_or(true)
    }

    pub fn set_show_fog(&self, show: bool) {
        if let Ok(mut guard) = self.persist_show_fog.lock() { *guard = show; }
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.show_fog = show;
            }
        }
    }

    pub fn get_show_fog(&self) -> bool {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return state.show_fog;
            }
        }
        self.persist_show_fog.lock().map(|g| *g).unwrap_or(false)
    }

    pub fn set_show_walkmesh(&self, show: bool) {
        if let Ok(mut guard) = self.persist_show_walkmesh.lock() { *guard = show; }
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.show_walkmesh = show;
            }
        }
    }

    pub fn set_show_sprites(&self, show: bool) {
        if let Ok(mut guard) = self.persist_show_sprites.lock() { *guard = show; }
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.show_sprites = show;
            }
        }
    }

    pub fn get_show_sprites(&self) -> bool {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return state.show_sprites;
            }
        }
        self.persist_show_sprites.lock().map(|g| *g).unwrap_or(true)
    }

    pub fn set_show_paint(&self, show: bool) {
        if let Ok(mut guard) = self.persist_show_paint.lock() { *guard = show; }
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.show_paint = show;
            }
        }
    }

    pub fn set_clear_color(&self, color: wgpu::Color) {
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.clear_color = color;
            }
        }
    }

    pub fn set_water(&self, level: i32, show: bool, color: [u8; 4]) {
        if let Ok(mut guard) = self.persist_water_level.lock() { *guard = level; }
        if let Ok(mut guard) = self.persist_show_water.lock() { *guard = show; }
        if let Ok(mut guard) = self.persist_water_color.lock() { *guard = color; }
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.water_level = level;
                state.show_water = show;
                state.water_color = color;
            }
        }
    }

    pub fn camera_state(&self) -> Option<OrbitCamera> {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return Some(state.camera.clone());
            }
        }
        None
    }

    pub fn set_camera(&self, camera: &OrbitCamera) {
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.camera = camera.clone();
            }
        }
    }

    pub fn set_show_tiles(&self, show: bool) {
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.show_tiles = show;
            }
        }
    }

    pub fn get_show_tiles(&self) -> bool {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return state.show_tiles;
            }
        }
        true
    }

    pub fn walk_camera(&self, forward: f32, right: f32) {
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.camera.walk(forward, right);
            }
        }
    }

    pub fn rotate_camera(&self, delta_x: f32, delta_y: f32) {
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.camera.rotate(delta_x, delta_y);
            }
        }
    }

    pub fn zoom_camera(&self, delta: f32) {
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.camera.zoom(delta);
            }
        }
    }

    pub fn pan_camera(&self, delta_x: f32, delta_y: f32) {
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.camera.pan(delta_x, delta_y);
            }
        }
    }

    pub fn raypick(&self, screen_x: f32, screen_y: f32, view_w: f32, view_h: f32) -> Option<(usize, tile_renderer::MarkerInfo)> {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return state.raypick(screen_x, screen_y, view_w, view_h).map(|(i, m)| (i, *m));
            }
        }
        None
    }

    pub fn world_to_screen(&self, world: [f32; 3], view_w: f32, view_h: f32) -> Option<[f32; 2]> {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return state.world_to_screen(world, view_w, view_h);
            }
        }
        None
    }

    pub fn pick_ground(&self, screen_x: f32, screen_y: f32, view_w: f32, view_h: f32) -> Option<[f32; 3]> {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return state.pick_ground(screen_x, screen_y, view_w, view_h);
            }
        }
        None
    }

    pub fn screen_rect_select(&self, min_screen: [f32; 2], max_screen: [f32; 2], view_w: f32, view_h: f32) -> Vec<(usize, tile_renderer::ObjectType, usize)> {
        if let Ok(guard) = self.inner.lock() {
            if let Some(ref state) = *guard {
                return state.screen_rect_select(min_screen, max_screen, view_w, view_h)
                    .into_iter().map(|(i, m)| (i, m.obj_type, m.index)).collect();
            }
        }
        Vec::new()
    }

    pub fn set_highlight_objects(&self, positions: &[[f32; 3]], half_size: f32) {
        let device_guard = self.device.lock().ok();
        let device = device_guard.as_ref().and_then(|d| d.as_ref());
        let Some(device) = device else { return };
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.set_highlight_objects(device, positions, half_size);
            }
        }
    }

    pub fn set_highlight_object(&self, pos: Option<[f32; 3]>, half_size: f32) {
        let positions = match pos {
            Some(p) => vec![p],
            None => vec![],
        };
        self.set_highlight_objects(&positions, half_size);
    }

    pub fn set_highlight_tile(&self, tile_idx: Option<usize>, col: usize, row: usize, height: f32) {
        let device_guard = self.device.lock().ok();
        let device = device_guard.as_ref().and_then(|d| d.as_ref());
        let Some(device) = device else { return };
        if let Ok(mut guard) = self.inner.lock() {
            if let Some(ref mut state) = *guard {
                state.set_highlight_tile(device, tile_idx, col, row, height);
            }
        }
    }

    /// Capture the current viewport at a given resolution, returning RGBA pixels.
    /// Returns `None` if the viewport hasn't been initialized yet.
    pub fn capture_frame(&self, width: u32, height: u32) -> Option<Vec<u8>> {
        let device_guard = self.device.lock().ok()?;
        let device = device_guard.as_ref()?;
        let queue_guard = self.queue.lock().ok()?;
        let queue = queue_guard.as_ref()?;
        let mut guard = self.inner.lock().ok()?;
        let state = guard.as_mut()?;

        let fmt = state.color_format;

        // Temporary color + depth targets at capture size
        let color_tex = device.create_texture(&wgpu::TextureDescriptor {
            label: Some("nwn3d_capture_color"),
            size: wgpu::Extent3d { width, height, depth_or_array_layers: 1 },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: fmt,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT | wgpu::TextureUsages::COPY_SRC,
            view_formats: &[],
        });
        let color_view = color_tex.create_view(&wgpu::TextureViewDescriptor::default());

        let depth_tex = device.create_texture(&wgpu::TextureDescriptor {
            label: Some("nwn3d_capture_depth"),
            size: wgpu::Extent3d { width, height, depth_or_array_layers: 1 },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Depth32Float,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            view_formats: &[],
        });
        let depth_view = depth_tex.create_view(&wgpu::TextureViewDescriptor::default());

        state.update_uniforms(queue, (width, height));

        let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
            label: Some("nwn3d_capture_encoder"),
        });
        {
            let mut rpass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                label: Some("nwn3d_capture_pass"),
                color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                    view: &color_view,
                    resolve_target: None,
                    ops: wgpu::Operations {
                        load: wgpu::LoadOp::Clear(state.clear_color),
                        store: wgpu::StoreOp::Store,
                    },
                })],
                depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                    view: &depth_view,
                    depth_ops: Some(wgpu::Operations {
                        load: wgpu::LoadOp::Clear(1.0),
                        store: wgpu::StoreOp::Store,
                    }),
                    stencil_ops: None,
                }),
                timestamp_writes: None,
                occlusion_query_set: None,
            });
            state.render_3d(&mut rpass);
        }

        let bytes_per_row = width * 4;
        let align = wgpu::COPY_BYTES_PER_ROW_ALIGNMENT;
        let padded = ((bytes_per_row + align - 1) / align) * align;

        let staging = device.create_buffer(&wgpu::BufferDescriptor {
            label: Some("nwn3d_capture_staging"),
            size: (padded as u64) * height as u64,
            usage: wgpu::BufferUsages::COPY_DST | wgpu::BufferUsages::MAP_READ,
            mapped_at_creation: false,
        });

        encoder.copy_texture_to_buffer(
            wgpu::TexelCopyTextureInfo {
                texture: &color_tex,
                mip_level: 0,
                origin: wgpu::Origin3d::ZERO,
                aspect: wgpu::TextureAspect::All,
            },
            wgpu::TexelCopyBufferInfo {
                buffer: &staging,
                layout: wgpu::TexelCopyBufferLayout {
                    offset: 0,
                    bytes_per_row: Some(padded),
                    rows_per_image: Some(height),
                },
            },
            wgpu::Extent3d { width, height, depth_or_array_layers: 1 },
        );

        let cmd_buf = encoder.finish();
        queue.submit(std::iter::once(cmd_buf));
        device.poll(wgpu::Maintain::Wait);

        let slice = staging.slice(..);
        let (tx, rx) = std::sync::mpsc::channel();
        slice.map_async(wgpu::MapMode::Read, move |r| { let _ = tx.send(r); });
        device.poll(wgpu::Maintain::Wait);

        match rx.recv().ok() {
            Some(Ok(())) => {
                let mapped = slice.get_mapped_range();
                if padded == bytes_per_row {
                    Some(mapped.to_vec())
                } else {
                    let mut out = Vec::with_capacity((bytes_per_row * height) as usize);
                    for row in 0..height {
                        let off = row as usize * padded as usize;
                        out.extend_from_slice(&mapped[off..off + bytes_per_row as usize]);
                    }
                    Some(out)
                }
            }
            _ => None,
        }
    }
}

unsafe impl Send for WgpuViewport {}
unsafe impl Sync for WgpuViewport {}

impl CallbackTrait for WgpuViewport {
    fn prepare(
        &self,
        device: &wgpu::Device,
        queue: &wgpu::Queue,
        screen_descriptor: &ScreenDescriptor,
        _egui_encoder: &mut wgpu::CommandEncoder,
        _callback_resources: &mut CallbackResources,
    ) -> Vec<wgpu::CommandBuffer> {
        // Store device/queue for background rebuild usage
        if let Ok(mut d) = self.device.lock() { *d = Some(device.clone()); }
        if let Ok(mut q) = self.queue.lock() { *q = Some(queue.clone()); }

        // Check if a background rebuild finished
        if let Ok(mut rb_guard) = self.pending_rebuild.lock() {
            if let Some(mut state) = rb_guard.take() {
                // Copy camera from old state if user moved it during rebuild (same area only)
                if let Ok(guard) = self.inner.lock() {
                    if let Some(ref old) = *guard {
                        if state.area_resref == old.area_resref {
                            state.camera = old.camera.clone();
                        }
                        // Copy live object transforms (drag/rotate/nudge) from old state
                        for (key, old_entries) in &old.object_instance_map {
                            if let Some(new_entries) = state.object_instance_map.get(key) {
                                let count = old_entries.len().min(new_entries.len());
                                for k in 0..count {
                                    let (og, oi) = old_entries[k];
                                    let (ng, ni) = new_entries[k];
                                    if og < old.instance_data.len() && oi < old.instance_data[og].len()
                                        && ng < state.instance_data.len() && ni < state.instance_data[ng].len()
                                        && ng < state.groups.len()
                                    {
                                        let inst = old.instance_data[og][oi];
                                        state.instance_data[ng][ni] = inst;
                                        let offset = ni as u64 * 64;
                                        let queue = self.queue.lock().ok().and_then(|q| q.clone());
                                        if let Some(ref q) = queue {
                                            q.write_buffer(&state.groups[ng].instance_buf, offset, bytemuck::cast_slice(&[inst]));
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                if let Ok(mut guard) = self.inner.lock() {
                    *guard = Some(state);
                }
            }
        }

        // Spawn background rebuild if there's a pending area and no rebuild is running
        if let Ok(mut pending_guard) = self.pending.lock() {
            if pending_guard.is_some() && !self.rebuild_in_progress.load(Ordering::SeqCst) {
                // Hard cap: check RSS before starting a rebuild
                let rss_kb = current_rss_kb();
                let max_tex_bytes = self.texture_mem_limit.lock().map(|g| *g).unwrap_or(u64::MAX);
                let ram_limit_kb = (max_tex_bytes / 1024).saturating_mul(2);
                let already_over = rss_kb > ram_limit_kb && rss_kb > 512 * 1024;
                eprintln!("  prepare: pending rebuild, rss={} MB, max_tex={} MB, limit={} MB, already_over={}", rss_kb/1024, max_tex_bytes/1024/1024, ram_limit_kb/1024, already_over);
                if !already_over {
                    let pending = pending_guard.take().unwrap();
                    self.rebuild_in_progress.store(true, Ordering::SeqCst);

                    // Take old state NOW so its GPU resources are freed before the thread loads new ones
                    let old_state = self.inner.lock().ok().and_then(|mut g| g.take());
                    let existing_camera = old_state.as_ref().map(|s| s.camera.clone());

                    let pending_rebuild = self.pending_rebuild.clone();
                    let rebuild_flag = self.rebuild_in_progress.clone();
                    let vf = self.visibility_filter.lock().map(|g| g.clone()).unwrap_or_default();
                    let erf = self.module_erf_bytes.lock().ok()
                        .and_then(|g| g.clone())
                        .and_then(|bytes| nwn_erf::ErfFile::from_bytes(&bytes).ok());
                    let mod_path = self.mod_path.lock().ok().and_then(|g| g.clone());
                    let hak_names = self.hak_names.lock().map(|g| g.clone()).unwrap_or_default();
                    let device_arc = self.device.clone();
                    let size = screen_descriptor.size_in_pixels;
                    let model_cache_arc = self.model_cache.clone();
                    let max_tex_bytes = self.texture_mem_limit.lock().map(|g| *g).unwrap_or(u64::MAX);
                    let persist = ViewportPersist {
                        show_grid: self.persist_show_grid.lock().map(|g| *g).unwrap_or(true),
                        lighting_enabled: self.persist_lighting_enabled.lock().map(|g| *g).unwrap_or(true),
                        show_fog: self.persist_show_fog.lock().map(|g| *g).unwrap_or(false),
                        show_water: self.persist_show_water.lock().map(|g| *g).unwrap_or(false),
                        water_level: self.persist_water_level.lock().map(|g| *g).unwrap_or(0),
                        water_color: self.persist_water_color.lock().map(|g| *g).unwrap_or([40, 80, 200, 160]),
                        show_walkmesh: self.persist_show_walkmesh.lock().map(|g| *g).unwrap_or(false),
                        show_walkmesh_edges: self.persist_show_walkmesh_edges.lock().map(|g| *g).unwrap_or(false),
                        show_paint: self.persist_show_paint.lock().map(|g| *g).unwrap_or(false),
                        show_sprites: self.persist_show_sprites.lock().map(|g| *g).unwrap_or(true),
                    };

                std::thread::spawn(move || {
                    // Drop old state IMMEDIATELY to free GPU resources before loading new ones
                    drop(old_state);

                    let dev = device_arc.lock().ok().and_then(|g| g.clone());
                    if let Some(ref device) = dev.as_ref() {
                        let config = wgpu::SurfaceConfiguration {
                            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
                            format: pending.format,
                            width: size[0],
                            height: size[1],
                            present_mode: wgpu::PresentMode::AutoNoVsync,
                            alpha_mode: wgpu::CompositeAlphaMode::Auto,
                            view_formats: vec![],
                            desired_maximum_frame_latency: 3,
                        };
                        let existing_camera = existing_camera;
                        let mut cache_guard = match model_cache_arc.lock() {
                            Ok(guard) => guard,
                            Err(poisoned) => {
                                eprintln!("WARN: model_cache mutex was poisoned, recovering");
                                poisoned.into_inner()
                            }
                        };
                        // Clear old models BEFORE rebuilding to free memory for new allocations
                        let evicted = cache_guard.cache.len();
                        cache_guard.cache.clear();
                        if evicted > 0 {
                            eprintln!("  Cleared {} model caches before rebuild", evicted);
                        }
                        let water_level = persist.water_level;
                        let water_color = persist.water_color;
                        let mut state = ViewportState::new(device, &config, &pending.area, pending.version, vf, existing_camera,
                            erf.as_ref(),
                            mod_path.as_deref(),
                            &hak_names,
                            Some(&mut *cache_guard),
                            max_tex_bytes,
                            persist,
                        );
                        drop(cache_guard);
                        eprintln!("  Rebuild done: RSS={} MB", current_rss_kb()/1024);
                        let area_ref = &*pending.area;
                        let paint_data = tile_renderer::build_paint_overlay_ex(area_ref, 0, false, [40, 80, 200, 160]);
                        // Build water mesh (flat quad grid at water level)
                        let water_data = build_water_mesh(area_ref, water_level, water_color);
                        let paint_vertex_buf = if !paint_data.vertices.is_empty() {
                            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                                label: Some("nwn3d_paint_vbuf"),
                                contents: bytemuck::cast_slice(&paint_data.vertices),
                                usage: wgpu::BufferUsages::VERTEX,
                            }))
                        } else { None };
                        let paint_index_buf = if !paint_data.indices.is_empty() {
                            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                                label: Some("nwn3d_paint_ibuf"),
                                contents: bytemuck::cast_slice(&paint_data.indices),
                                usage: wgpu::BufferUsages::INDEX,
                            }))
                        } else { None };
                        state.paint_idx_count = paint_data.indices.len() as u32;
                        state.paint_vertex_buf = paint_vertex_buf;
                        state.paint_index_buf = paint_index_buf;
                        let water_vertex_buf = if !water_data.vertices.is_empty() {
                            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                                label: Some("nwn3d_water_vbuf"),
                                contents: bytemuck::cast_slice(&water_data.vertices),
                                usage: wgpu::BufferUsages::VERTEX,
                            }))
                        } else { None };
                        let water_index_buf = if !water_data.indices.is_empty() {
                            Some(device.create_buffer_init(&wgpu::util::BufferInitDescriptor {
                                label: Some("nwn3d_water_ibuf"),
                                contents: bytemuck::cast_slice(&water_data.indices),
                                usage: wgpu::BufferUsages::INDEX,
                            }))
                        } else { None };
                        state.water_idx_count = water_data.indices.len() as u32;
                        state.water_vertex_buf = water_vertex_buf;
                        state.water_index_buf = water_index_buf;
                        if let Ok(mut guard) = pending_rebuild.lock() {
                            *guard = Some(state);
                        }
                    }
                    rebuild_flag.store(false, Ordering::SeqCst);
                });
                }
            }
        }

        let mut guard = match self.inner.lock() {
            Ok(g) => g,
            Err(_) => return Vec::new(),
        };
        let state = match &mut *guard {
            Some(s) => s,
            None => return Vec::new(),
        };

        state.ensure_textures(device, queue);
        let size = (screen_descriptor.size_in_pixels[0], screen_descriptor.size_in_pixels[1]);
        state.update_uniforms(queue, size);
        state.update_sprite_instances(queue);
        state.ensure_scene_textures(device, size.0.max(1), size.1.max(1));

        // Alternate buffer each frame to avoid write/read race on the offscreen texture
        state.frame_index = (state.frame_index + 1) & 1;
        let idx = state.frame_index;
        let color_view = match state.color_view[idx].as_ref() {
            Some(v) => v.clone(),
            None => return Vec::new(),
        };
        let depth_view = match state.depth_view[idx].as_ref() {
            Some(v) => v.clone(),
            None => return Vec::new(),
        };

        // Render 3D scene to offscreen texture with depth buffer
        let mut encoder = device.create_command_encoder(&wgpu::CommandEncoderDescriptor {
            label: Some("nwn3d_scene_encoder"),
        });

        {
            let mut rpass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                label: Some("nwn3d_scene_pass"),
                color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                    view: &color_view,
                    resolve_target: None,
                        ops: wgpu::Operations {
                            load: wgpu::LoadOp::Clear(state.clear_color),
                            store: wgpu::StoreOp::Store,
                        },
                })],
                depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                    view: &depth_view,
                    depth_ops: Some(wgpu::Operations {
                        load: wgpu::LoadOp::Clear(1.0),
                        store: wgpu::StoreOp::Store,
                    }),
                    stencil_ops: None,
                }),
                timestamp_writes: None,
                occlusion_query_set: None,
            });

            state.render_3d(&mut rpass);
        }

        vec![encoder.finish()]
    }

    fn paint(
        &self,
        info: PaintCallbackInfo,
        render_pass: &mut wgpu::RenderPass<'static>,
        _callback_resources: &CallbackResources,
    ) {
        let guard = match self.inner.lock() {
            Ok(g) => g,
            Err(_) => return,
        };
        let state = match &*guard {
            Some(s) => s,
            None => return,
        };

        let clip = info.clip_rect_in_pixels();
        render_pass.set_scissor_rect(
            clip.left_px.max(0) as u32,
            clip.top_px.max(0) as u32,
            clip.width_px.max(0) as u32,
            clip.height_px.max(0) as u32,
        );

        if let Some(ref bg) = state.blit_bind_group[state.frame_index] {
            render_pass.set_pipeline(&state.blit_pipeline);
            render_pass.set_bind_group(0, bg, &[]);
            render_pass.draw(0..3, 0..1);
        }
    }

    fn finish_prepare(
        &self,
        _device: &wgpu::Device,
        _queue: &wgpu::Queue,
        _egui_encoder: &mut wgpu::CommandEncoder,
        _callback_resources: &mut CallbackResources,
    ) -> Vec<wgpu::CommandBuffer> {
        Vec::new()
    }
}

fn create_blit_pipeline(
    device: &wgpu::Device,
    config: &wgpu::SurfaceConfiguration,
    blit_bind_group_layout: &wgpu::BindGroupLayout,
) -> wgpu::RenderPipeline {
    let shader = device.create_shader_module(wgpu::ShaderModuleDescriptor {
        label: Some("nwn3d_blit_shader"),
        source: wgpu::ShaderSource::Wgsl(BLIT_SHADER.into()),
    });

    let pipeline_layout = device.create_pipeline_layout(&wgpu::PipelineLayoutDescriptor {
        label: Some("nwn3d_blit_layout"),
        bind_group_layouts: &[blit_bind_group_layout],
        push_constant_ranges: &[],
    });

    device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
        label: Some("nwn3d_blit_pipeline"),
        layout: Some(&pipeline_layout),
        vertex: wgpu::VertexState {
            module: &shader,
            entry_point: Some("vs_main"),
            buffers: &[],
            compilation_options: Default::default(),
        },
        primitive: wgpu::PrimitiveState {
            topology: wgpu::PrimitiveTopology::TriangleList,
            strip_index_format: None,
            front_face: wgpu::FrontFace::Ccw,
            cull_mode: None,
            polygon_mode: wgpu::PolygonMode::Fill,
            unclipped_depth: false,
            conservative: false,
        },
        depth_stencil: None,
        multisample: wgpu::MultisampleState {
            count: 1,
            mask: !0,
            alpha_to_coverage_enabled: false,
        },
        fragment: Some(wgpu::FragmentState {
            module: &shader,
            entry_point: Some("fs_main"),
            targets: &[Some(wgpu::ColorTargetState {
                format: config.format,
                blend: Some(wgpu::BlendState {
                    color: wgpu::BlendComponent::OVER,
                    alpha: wgpu::BlendComponent::OVER,
                }),
                write_mask: wgpu::ColorWrites::ALL,
            })],
            compilation_options: Default::default(),
        }),
        multiview: None,
        cache: None,
    })
}

/// Build a flat water mesh at the given Z level covering the full area extent.
fn build_water_mesh(area: &nwn_gamemodel::Area, water_level: i32, color: [u8; 4]) -> tile_renderer::MeshData {
    let cols = area.width.max(1) as usize;
    let rows = area.height.max(1) as usize;
    let tile_w = 10.0;
    let tile_h = 10.0;
    let wz = water_level as f32 * 0.25;
    let r = color[0] as f32 / 255.0;
    let g = color[1] as f32 / 255.0;
    let b = color[2] as f32 / 255.0;
    let a = color[3] as f32 / 255.0;
    let mut vertices = Vec::new();
    let mut indices = Vec::new();
    for row in 0..rows {
        for col in 0..cols {
            let tx = col as f32 * tile_w;
            let ty = -(row as f32) * tile_h;
            let base = vertices.len() as u32;
            vertices.push(tile_renderer::Vertex { position: [tx, wz, ty], normal: [0.0, 1.0, 0.0], uv: [0.0, 0.0], color: [r, g, b, a] });
            vertices.push(tile_renderer::Vertex { position: [tx + tile_w, wz, ty], normal: [0.0, 1.0, 0.0], uv: [1.0, 0.0], color: [r, g, b, a] });
            vertices.push(tile_renderer::Vertex { position: [tx + tile_w, wz, ty - tile_h], normal: [0.0, 1.0, 0.0], uv: [1.0, 1.0], color: [r, g, b, a] });
            vertices.push(tile_renderer::Vertex { position: [tx, wz, ty - tile_h], normal: [0.0, 1.0, 0.0], uv: [0.0, 1.0], color: [r, g, b, a] });
            indices.extend_from_slice(&[base, base + 1, base + 2, base, base + 2, base + 3]);
        }
    }
    tile_renderer::MeshData { vertices, indices }
}

const BLIT_SHADER: &str = r#"
@group(0) @binding(0) var blit_sampler: sampler;
@group(0) @binding(1) var blit_texture: texture_2d<f32>;

struct VertexOutput {
    @builtin(position) position: vec4<f32>,
    @location(0) uv: vec2<f32>,
}

@vertex
fn vs_main(@builtin(vertex_index) vi: u32) -> VertexOutput {
    var output: VertexOutput;
    let pos = vec2<f32>(
        f32(vi & 1u) * 4.0 - 1.0,
        f32(vi & 2u) * 2.0 - 1.0
    );
    output.position = vec4<f32>(pos, 0.0, 1.0);
    output.uv = vec2<f32>(pos.x * 0.5 + 0.5, -pos.y * 0.5 + 0.5);
    return output;
}

@fragment
fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
    return textureSample(blit_texture, blit_sampler, input.uv);
}
"#;
