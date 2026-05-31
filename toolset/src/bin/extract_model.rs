fn main() {
    let data_dir = std::path::Path::new(
        &std::env::var("HOME").unwrap_or_default()
    ).join(".local/share/Steam/steamapps/common/Neverwinter Nights/data");

    let key_path = data_dir.join("nwn_base.key");
    
    match nwnrs_types::key::read_key_table_from_file(&key_path) {
        Ok(key_table) => {
            use nwnrs_types::resman::{ResRef, ResType};
            // c_basilisk.MDL
            if let Ok(rr) = ResRef::new("c_basilisk".to_string(), ResType(2002)) {
                if key_table.contains(&rr) {
                    match key_table.demand(&rr) {
                        Ok(Some(data)) => {
                            println!("Found c_basilisk.MDL, size={}", data.len());
                            // Extract texture names
                            let text = String::from_utf8_lossy(&data);
                            for line in text.lines() {
                                let l = line.trim();
                                if l.contains("tex") || l.contains("bitmap") || l.starts_with("donemodel") {
                                    println!("  {}", l);
                                }
                            }
                        }
                        Ok(None) => println!("Not found in any BIF"),
                        Err(e) => println!("Error: {}", e),
                    }
                } else {
                    println!("c_basilisk.MDL not in key table");
                }
            }
        }
        Err(e) => println!("Failed to load key table: {}", e),
    }
}
