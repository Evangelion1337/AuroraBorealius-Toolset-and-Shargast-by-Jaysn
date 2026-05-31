#![feature(generic_const_exprs)]
fn mat4_mul(a: [[f32; 4]; 4], b: [[f32; 4]; 4]) -> [[f32; 4]; 4] {
    let mut out = [[0.0f32; 4]; 4];
    for i in 0..4 {
        for j in 0..4 {
            out[i][j] = a[i][0] * b[0][j] + a[i][1] * b[1][j] + a[i][2] * b[2][j] + a[i][3] * b[3][j];
        }
    }
    out
}

fn main() {
    let path = "/home/grimshackle/Documents/Neverwinter Nights/modules/HOPE_Shargast_CH1.mod";
    let module = nwn_gamemodel::Module::open(path).expect("open module");
    let names = module.area_names();
    eprintln!("Module: {} areas", names.len());

    // Test first area
    let name = &names[0];
    eprintln!("\n=== First area: {} ===", name);
    let area = module.get_area(name).expect("get area");
    eprintln!("Tileset: '{}', {}x{} tiles, {} tiles loaded",
        area.tileset, area.width, area.height, area.tiles.len());

    let mut model_count = 0;
    let mut null_count = 0;
    for m in &area.tile_models {
        match m {
            Some(s) => { model_count += 1; }
            None => { null_count += 1; }
        }
    }
    eprintln!("Tile models: {} Some, {} None", model_count, null_count);

    // Build MDL tile mesh groups
    let mut cache = nwn_3d::tile_renderer::ModelCache::new();
    let groups = nwn_3d::tile_renderer::build_tiles_grouped(&area, &mut cache);
    eprintln!("Tile groups: {}", groups.len());
    for g in &groups {
        let tex = g.texture_name.as_deref().unwrap_or("(none)");
        eprintln!("  group '{}': {} verts, {} tris", tex, g.data.vertices.len(), g.data.indices.len() / 3);
    }

    // Merge groups for diagnostic checks
    let mesh = {
        let mut verts = Vec::new();
        let mut idxs = Vec::new();
        for g in &groups {
            let base = verts.len() as u32;
            verts.extend_from_slice(&g.data.vertices);
            for i in &g.data.indices {
                idxs.push(base + i);
            }
        }
        nwn_3d::tile_renderer::MeshData { vertices: verts, indices: idxs }
    };

    // Print first few vertices to check values
    for i in 0..mesh.vertices.len().min(5) {
        let v = &mesh.vertices[i];
        eprintln!("  v[{}]: pos=({:.2},{:.2},{:.2}) norm=({:.3},{:.3},{:.3}) color=({:.2},{:.2},{:.2})",
            i, v.position[0], v.position[1], v.position[2],
            v.normal[0], v.normal[1], v.normal[2],
            v.color[0], v.color[1], v.color[2]);
    }

    // Camera setup
    let camera = nwn_3d::camera::OrbitCamera::new(area.width as f32, area.height as f32);
    eprintln!("\nCamera target=({:.1},{:.1},{:.1}) radius={:.1}",
        camera.target[0], camera.target[1], camera.target[2], camera.radius);
    let eye = camera_eye(&camera);
    eprintln!("Camera eye=({:.1},{:.1},{:.1})", eye[0], eye[1], eye[2]);

    let view = camera.view_matrix();
    let proj = camera.projection_matrix();

    // Current approach: vp = view * proj
    let vp = mat4_mul(view, proj);

    // WGSL: M[c][r] = vp[r][c], then result[r] = sum_c M[c][r] * v[c] = sum_c vp[r][c] * v[c] = (vp * v)[r]
    eprintln!("\n=== Testing vertex transform ===");
    let mut visible_count = 0;
    for i in 0..mesh.vertices.len().min(50) {
        let v = &mesh.vertices[i];
        let wpos = [v.position[0], v.position[1], v.position[2], 1.0f32];

        // Simulate WGSL: result[r] = sum_c vp[r][c] * v[c]
        let mut clip = [0.0f32; 4];
        for r in 0..4 {
            for c in 0..4 {
                clip[r] += vp[r][c] * wpos[c];
            }
        }

        let ndc_w = clip[3];
        let visible = ndc_w > 0.0
            && clip[0].abs() <= ndc_w
            && clip[1].abs() <= ndc_w
            && clip[2].abs() <= ndc_w;
        if visible { visible_count += 1; }

        if i < 5 || visible {
            eprintln!("  v[{}]: world=({:.1},{:.1},{:.1}) clip=({:.2},{:.2},{:.2},{:.2}) ndc_w={:.2} visible={}",
                i, wpos[0], wpos[1], wpos[2],
                clip[0], clip[1], clip[2], clip[3], ndc_w, visible);
        }
    }
    eprintln!("  {}/{} vertices visible in NDC", visible_count, mesh.vertices.len().min(50));

    // Try all vertices to check area bounds
    let mut min_pos = [f32::MAX, f32::MAX, f32::MAX];
    let mut max_pos = [f32::MIN, f32::MIN, f32::MIN];
    for v in &mesh.vertices {
        for j in 0..3 {
            min_pos[j] = min_pos[j].min(v.position[j]);
            max_pos[j] = max_pos[j].max(v.position[j]);
        }
    }
    eprintln!("\nBounds: x=[{:.1},{:.1}] y=[{:.1},{:.1}] z=[{:.1},{:.1}]",
        min_pos[0], max_pos[0], min_pos[1], max_pos[1], min_pos[2], max_pos[2]);
    eprintln!("Area size: {}x{} tiles = {}x{} units",
        area.width, area.height, area.width as f32 * 10.0, area.height as f32 * 10.0);
}

fn camera_eye(camera: &nwn_3d::camera::OrbitCamera) -> [f32; 3] {
    use nwn_3d::camera::OrbitCamera;
    let (sin_t, cos_t) = camera.theta.sin_cos();
    let (sin_p, cos_p) = camera.phi.sin_cos();
    [
        camera.target[0] + camera.radius * cos_p * sin_t,
        camera.target[1] + camera.radius * sin_p,
        camera.target[2] + camera.radius * cos_p * cos_t,
    ]
}
