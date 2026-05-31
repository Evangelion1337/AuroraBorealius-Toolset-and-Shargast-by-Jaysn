#![allow(incomplete_features)]
#![feature(generic_const_exprs)]
use nwn_gamemodel::Module;

fn main() {
    let path = std::env::args().nth(1).expect("Usage: inspect_module <module.mod>");
    let module = Module::open(&path).expect("Failed to load module");

    println!("=== Module: {} ===", module.name);
    println!("Entry Area: {}", module.entry_area);
    println!("Tag: {}", module.tag);
    println!("Description: {}", if module.description.len() > 80 { format!("{}...", &module.description[..80]) } else { module.description.clone() });
    println!("HAKs: {:?}", module.haks);
    println!("Total Areas: {}", module.num_areas());
    println!("Total Scripts: {}", module.scripts.len());
    println!("Total Conversations: {}", module.conversations.len());

    // Show first 10 areas in detail
    println!("\n=== First 10 Areas ===");
    for (i, name) in module.area_names().iter().take(10).enumerate() {
        if let Some(area) = module.get_area(name) {
            println!("\n  [{}/{}] {} (resref: {})", i + 1, module.num_areas(), area.name, area.resref);
            println!("    Tag: {}", area.tag);
            println!("    Size: {}x{}", area.width, area.height);
            println!("    Tileset: {}", area.tileset);
            println!("    Creatures: {}", area.creatures.len());
            println!("    Doors: {}", area.doors.len());
            println!("    Placeables: {}", area.placeables.len());
            println!("    Triggers: {}", area.triggers.len());
            println!("    Waypoints: {}", area.waypoints.len());
        }
    }

    // Show scripts
    println!("\n=== Scripts (showing first 10 of {}) ===", module.scripts.len());
    for (i, name) in module.script_names().iter().take(10).enumerate() {
        let src = module.get_script_source(name).unwrap_or("");
        let preview = if src.len() > 60 { format!("{}...", &src[..60]) } else { src.to_string() };
        println!("  {}. {}: {}", i + 1, name, preview);
    }

    // Check a specific area with many creatures
    println!("\n=== Area with most creatures ===");
    let mut max_creatures = 0usize;
    let mut max_area = String::new();
    for name in module.area_names() {
        if let Some(area) = module.get_area(name) {
            if area.creatures.len() > max_creatures {
                max_creatures = area.creatures.len();
                max_area = name.to_string();
            }
        }
    }
    if let Some(area) = module.get_area(&max_area) {
        println!("  {}: {} creatures", area.name, max_creatures);
        for (i, c) in area.creatures.iter().take(3).enumerate() {
            println!("    Creature {}: resref={}, x={}, y={}", i + 1, c.resref, c.x, c.y);
        }
    }
}
