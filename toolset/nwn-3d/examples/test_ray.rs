#![feature(generic_const_exprs)]
use nwn_3d::camera::OrbitCamera;

fn main() {
    // Simulate a 4x4 area with 800x600 window
    let mut camera = OrbitCamera::new(4.0, 4.0);
    camera.aspect = 800.0 / 600.0; // window aspect
    eprintln!("Camera: target=({:.1},{:.1},{:.1}) radius={:.1} aspect={:.1}",
        camera.target[0], camera.target[1], camera.target[2], camera.radius, camera.aspect);

    // Test ray at various screen positions
    eprintln!("\n--- ray_from_screen tests ---");
    let (w, h) = (800.0, 600.0);
    for (sx, sy) in [(400.0, 300.0), (100.0, 100.0), (700.0, 500.0), (400.0, 100.0), (400.0, 500.0)] {
        let (origin, dir) = camera.ray_from_screen(sx, sy, w, h);
        let hit_y0 = if dir[1].abs() > 1e-15 {
            let t = -origin[1] / dir[1];
            if t >= 0.0 {
                Some([origin[0] + t*dir[0], 0.0, origin[2] + t*dir[2]])
            } else { None }
        } else { None };
        eprintln!("screen=({:.0},{:.0}) origin=({:.1},{:.1},{:.1}) dir=({:.4},{:.4},{:.4})",
            sx, sy, origin[0], origin[1], origin[2], dir[0], dir[1], dir[2]);
        if let Some(h) = hit_y0 {
            let col = (h[0] / 10.0).floor() as i32;
            let row = (-h[2] / 10.0).floor() as i32;
            eprintln!("  Y=0 hit: ({:.1},{:.1}) -> nwn ({:.1},{:.1}) tile ({},{})",
                h[0], h[2], h[0], -h[2], col, row);
        } else {
            eprintln!("  No Y=0 intersection (dir[1]={:.6})", dir[1]);
        }
    }
}
