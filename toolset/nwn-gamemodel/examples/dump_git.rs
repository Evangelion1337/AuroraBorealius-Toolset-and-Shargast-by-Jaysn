#![allow(incomplete_features)]
#![feature(generic_const_exprs)]
use nwn_erf::ErfFile;
use nwn_gff::{GffFile, FieldValue, Struct};

fn dump(structs: &[Struct], label: &str) {
    println!("\n=== {} ({} entries) ===", label, structs.len());
    for (i, entry) in structs.iter().enumerate() {
        let resref = entry.find("TemplateResRef")
            .and_then(|v| if let FieldValue::ResRef(s) = v { Some(s.clone()) } else { None })
            .unwrap_or_default();
        let tag = entry.find("Tag")
            .and_then(|v| if let FieldValue::String(s) = v { Some(s.clone()) } else { None })
            .unwrap_or_default();
        
        let (x_val, x_field, x_type) = get_float_info(entry, "XPosition", "X");
        let (y_val, y_field, y_type) = get_float_info(entry, "YPosition", "Y");
        let (z_val, z_field, z_type) = get_float_info(entry, "ZPosition", "Z");
        
        println!("  [{}] resref={:<20} tag={:<20} pos=({:.4}, {:.4}, {:.4})  [{}, {}, {}] -> ({}, {}, {})",
            i, resref, tag, x_val, y_val, z_val, x_field, y_field, z_field, x_type, y_type, z_type);
    }
}

fn get_float_info(s: &Struct, primary: &str, fallback: &str) -> (f32, String, String) {
    let field_name;
    let val = if let Some(v) = s.find(primary) {
        field_name = primary.to_string();
        v
    } else if let Some(v) = s.find(fallback) {
        field_name = fallback.to_string();
        v
    } else {
        return (0.0, "MISSING".into(), "?".into());
    };
    match val {
        FieldValue::Float(f) => (*f, field_name, "Float".into()),
        FieldValue::Double(f) => (*f as f32, field_name, "Double".into()),
        _ => (0.0, field_name, format!("{:?}", val)),
    }
}

fn main() {
    let path = std::env::args().nth(1).expect("Usage: dump_git <module.mod> [area_resref]");
    let area_resref = std::env::args().nth(2).unwrap_or_default();
    
    let erf = ErfFile::open(&path).expect("Failed to open mod");

    let git_names: Vec<String> = erf.keys().iter()
        .filter_map(|(name, restype)| {
            if *restype == nwn_gamemodel::resource_types::GIT { Some(name.clone()) } else { None }
        })
        .collect();

    println!("Module: {}", path);
    println!("Available GIT resources: {}", git_names.len());

    for name in &git_names {
        if !area_resref.is_empty() && *name != area_resref && !name.eq_ignore_ascii_case(&area_resref) {
            continue;
        }
        let data = erf.get(name, nwn_gamemodel::resource_types::GIT)
            .or_else(|| erf.get(&name.to_uppercase(), nwn_gamemodel::resource_types::GIT))
            .expect("Failed to get GIT data");
        
        println!("\n=== Area: {} ===", name);
        let gff = GffFile::from_bytes(&data).expect("Failed to parse GFF");
        let root = gff.root();

        for (list_name, label) in [
            ("Creature_List", "Creatures"),
            ("Door_List", "Doors"),
            ("Placeable_List", "Placeables"),
            ("Trigger_List", "Triggers"),
            ("WaypointList", "Waypoints"),
            ("Encounter_List", "Encounters"),
            ("SoundList", "Sound Emitters"),
        ] {
            if let Some(FieldValue::List(list)) = root.find(list_name) {
                dump(list, label);
            }
        }
    }
}
