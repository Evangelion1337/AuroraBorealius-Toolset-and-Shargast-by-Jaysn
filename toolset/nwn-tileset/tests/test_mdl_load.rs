#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

#[test]
fn load_mdl_test() {
    // First load the tileset to find model names
    match nwn_tileset::find_tileset_in_game_data("tin01") {
        Ok(Some(ts)) => {
            println!("tin01 tileset loaded: {} tile defs", ts.tiles.len());
            // Print first 15 model names
            let mut names: Vec<&str> = ts.tiles.values().map(|t| t.model_name.as_str()).collect();
            names.sort();
            names.dedup();
            println!("Unique models: {}", names.len());
            for n in names.iter().take(15) {
                println!("  model: {}", n);
            }
            // Try loading the first model
            if let Some(first_name) = names.first() {
                match nwn_tileset::load_model_mesh(first_name) {
                    Ok(Some(mesh)) => {
                        println!("  -> {}: {} verts, {} tris", first_name, mesh.positions.len(), mesh.indices.len() / 3);
                        if !mesh.positions.is_empty() {
                            let min_x = mesh.positions.iter().map(|p| p[0]).fold(f32::MAX, f32::min);
                            let max_x = mesh.positions.iter().map(|p| p[0]).fold(f32::MIN, f32::max);
                            let min_y = mesh.positions.iter().map(|p| p[1]).fold(f32::MAX, f32::min);
                            let max_y = mesh.positions.iter().map(|p| p[1]).fold(f32::MIN, f32::max);
                            let min_z = mesh.positions.iter().map(|p| p[2]).fold(f32::MAX, f32::min);
                            let max_z = mesh.positions.iter().map(|p| p[2]).fold(f32::MIN, f32::max);
                            println!("  -> pos X[{:.3}..{:.3}] Y[{:.3}..{:.3}] Z[{:.3}..{:.3}]", min_x, max_x, min_y, max_y, min_z, max_z);
                        }
                        println!("  -> tex: {:?}", mesh.texture_name);
                    }
                    Ok(None) => {
                        println!("  -> {}: not found in KEY/BIF", first_name);
                    }
                    Err(e) => {
                        println!("  -> {}: error: {}", first_name, e);
                    }
                }
            }
        }
        Ok(None) => println!("tin01 tileset not found"),
        Err(e) => println!("Error loading tin01 tileset: {}", e),
    }
}

#[test]
fn test_2da_lookups() {
    // Check door.2da appearance 0
    let door_0 = nwn_tileset::lookup_model_name_from_2da("door", 0, "ModelName", &[]);
    
    // Check door.2da for all appearances 0-10
    for row in 0..10 {
        let r = nwn_tileset::lookup_model_name_from_2da("door", row, "ModelName", &[]);
        if r.is_some() {
            println!("door.2da row {}: {:?}", row, r);
        }
    }
    
    // Check placeables.2da row 7
    let p7 = nwn_tileset::lookup_model_name_from_2da("placeables", 7, "ModelName", &[]);
    // Check appearance.2da
    let a0 = nwn_tileset::lookup_model_name_from_2da("appearance", 0, "model", &[]);
    for row in 0..10 {
        let r = nwn_tileset::lookup_model_name_from_2da("appearance", row, "model", &[]);
        if r.is_some() {
            println!("appearance.2da row {}: {:?}", row, r);
        }
    }
    
    // Check what columns exist in door.2da
    let home = std::env::var("HOME").unwrap();
    let data_dir = std::path::Path::new(&home)
        .join(".local/share/Steam/steamapps/common/Neverwinter Nights/data");
    if data_dir.is_dir() {
        use nwnrs_types::resman::ResRef;
        let resref = ResRef::new("door".to_string(), nwnrs_types::resman::ResType(2017)).unwrap();
        if let Ok(Some(data)) = nwn_tileset::load_resource_from_key(&resref, &data_dir) {
            let text = std::str::from_utf8(&data).unwrap();
            println!("\ndoor.2da header lines:");
            for (i, line) in text.lines().take(5).enumerate() {
                println!("  line {}: {:?}", i, line);
            }
            let total = text.lines().filter(|l| !l.trim().is_empty() && !l.starts_with('#') && !l.starts_with("2DA")).count();
            println!("  total data rows: {}", total - 1);
        }
    }
}
