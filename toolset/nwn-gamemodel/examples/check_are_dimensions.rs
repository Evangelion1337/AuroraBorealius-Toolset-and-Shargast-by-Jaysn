#![allow(incomplete_features)]
#![feature(generic_const_exprs)]
use nwn_gamemodel::Module;

fn main() {
    let path = std::env::args().nth(1).expect("Usage: check_are_dimensions <module.mod>");
    let module = Module::open(&path).expect("Failed to load module");

    println!("Module: {}", module.name);
    for name in module.area_names() {
        if let Some(area) = module.get_area(name) {
            println!("  {}: {}x{} tiles, {} loaded tiles, {} creatures, {} doors, {} placeables, {} triggers, {} waypoints",
                name, area.width, area.height, area.tiles.len(),
                area.creatures.len(), area.doors.len(), area.placeables.len(),
                area.triggers.len(), area.waypoints.len());
            
            if area.tiles.len() as i32 != area.width * area.height {
                println!("    *** TILE COUNT MISMATCH: expected {} tiles ({}x{}), got {}",
                    area.width * area.height, area.width, area.height, area.tiles.len());
            }

            // Show first few objects with their coordinates
            for (i, d) in area.doors.iter().take(3).enumerate() {
                println!("    Door[{}]: resref={} pos=({:.4}, {:.4}, {:.4})",
                    i, d.resref, d.x, d.y, d.z);
            }
            for (i, w) in area.waypoints.iter().take(3).enumerate() {
                println!("    WP[{}]: resref={} tag={} pos=({:.4}, {:.4}, {:.4})",
                    i, w.resref, w.tag, w.x, w.y, w.z);
            }
        }
    }
}
