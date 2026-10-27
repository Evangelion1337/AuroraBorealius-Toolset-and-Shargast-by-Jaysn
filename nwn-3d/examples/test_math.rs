#![feature(generic_const_exprs)]
use nwn_3d::tile_renderer;
use nwn_3d::camera::OrbitCamera;

fn main() {
    let path = std::env::args()
        .nth(1)
        .expect("Usage: cargo run -p nwn-3d --example test_math -- <module.mod>");
    eprintln!("Loading module: {}", path);
    let module = nwn_gamemodel::Module::open(path).expect("Failed to open module");
    let area_names = module.area_names();
    eprintln!("Module has {} areas", area_names.len());

    // Test first 5 areas (or fewer)
    let test_count = area_names.len().min(5);
    for i in 0..test_count {
        let name = &area_names[i];
        eprintln!("\n=== Area {}: {} ===", i, name);
        let area = module.get_area(name).expect("Failed to get area");
        eprintln!("Tileset: {}, {}x{} tiles, {} tiles", area.tileset, area.width, area.height, area.tiles.len());
        eprintln!("Creatures: {}, Doors: {}, Placeables: {}, Triggers: {}, Waypoints: {}",
            area.creatures.len(), area.doors.len(), area.placeables.len(),
            area.triggers.len(), area.waypoints.len());

        // Build mesh data (no GPU needed)
        let mesh = tile_renderer::build_tile_mesh(&area);
        let model_cache = tile_renderer::ModelCache::new();
        let markers = tile_renderer::build_object_markers(
            &area,
            tile_renderer::VisibilityFilter::default(),
            &model_cache,
        );
        eprintln!("Tile mesh: {} vertices, {} indices", mesh.vertices.len(), mesh.indices.len());
        eprintln!("Markers: {} vertices, {} indices", markers.mesh.vertices.len(), markers.mesh.indices.len());

        // If no mesh data, skip
        if mesh.vertices.is_empty() {
            eprintln!("SKIP: no tile mesh");
            continue;
        }

        // Camera setup
        let camera = OrbitCamera::new(area.width as f32, area.height as f32);
        eprintln!("Camera: target=({:.1}, {:.1}, {:.1}), radius={:.1}, theta={:.2}, phi={:.2}",
            camera.target[0], camera.target[1], camera.target[2],
            camera.radius, camera.theta, camera.phi);

        // Compute view-projection matrix: same as viewport.rs
        let view = camera.view_matrix();
        let proj = camera.projection_matrix();
        let vp = mat4_mul(view, proj);

        // Test a few tile vertices — use GPU equivalent transform
        let test_indices = [0usize, mesh.vertices.len() / 4, mesh.vertices.len() / 2, mesh.vertices.len() * 3 / 4, mesh.vertices.len() - 1];
        let mut any_visible = false;
        for &idx in &test_indices {
            if idx >= mesh.vertices.len() { continue; }
            let v = &mesh.vertices[idx];
            let wpos = [v.position[0], v.position[1], v.position[2], 1.0f32];
            let clip = gpu_transform(vp, wpos);
            let ndc = [clip[0] / clip[3], clip[1] / clip[3], clip[2] / clip[3], clip[3]];
            let visible = ndc[0] >= -1.0 && ndc[0] <= 1.0 && ndc[1] >= -1.0 && ndc[1] <= 1.0 && clip[3] > 0.0;
            if visible { any_visible = true; }
            eprintln!("  Vertex {}: world=({:.1}, {:.1}, {:.1}) -> NDC=({:.3}, {:.3}, {:.3}) [visible={}]",
                idx, wpos[0], wpos[1], wpos[2],
                ndc[0], ndc[1], ndc[2], visible);
        }

        // Test a marker vertex if any
        if !markers.mesh.vertices.is_empty() {
            let idx = 0;
            let v = &markers.mesh.vertices[idx];
            let wpos = [v.position[0], v.position[1], v.position[2], 1.0f32];
            let clip = gpu_transform(vp, wpos);
            let ndc = [clip[0] / clip[3], clip[1] / clip[3], clip[2] / clip[3], clip[3]];
            let visible = ndc[0] >= -1.0 && ndc[0] <= 1.0 && ndc[1] >= -1.0 && ndc[1] <= 1.0 && clip[3] > 0.0;
            if visible { any_visible = true; }
            eprintln!("  Marker {}: world=({:.1}, {:.1}, {:.1}) -> NDC=({:.3}, {:.3}, {:.3}) [visible={}]",
                idx, wpos[0], wpos[1], wpos[2],
                ndc[0], ndc[1], ndc[2], visible);
        }
        eprintln!("  => Any tile vertex visible: {}", any_visible);
    }
}

fn mat4_mul(a: [[f32; 4]; 4], b: [[f32; 4]; 4]) -> [[f32; 4]; 4] {
    let mut out = [[0.0f32; 4]; 4];
    for i in 0..4 {
        for j in 0..4 {
            out[i][j] = a[i][0] * b[0][j] + a[i][1] * b[1][j] + a[i][2] * b[2][j] + a[i][3] * b[3][j];
        }
    }
    out
}

/// Simulates what WGSL does: M_wgsl * v where M_wgsl[c][r] = m_row[r][c].
/// WGSL spec: (M * v)[r] = sum_c M[c][r] * v[c] = sum_c m_row[r][c] * v[c]
/// This is just standard row-major mat * vec: result = m_row * v
fn gpu_transform(m_row: [[f32; 4]; 4], v: [f32; 4]) -> [f32; 4] {
    let mut out = [0.0f32; 4];
    for r in 0..4 {
        for c in 0..4 {
            out[r] += m_row[r][c] * v[c];
        }
    }
    out
}


