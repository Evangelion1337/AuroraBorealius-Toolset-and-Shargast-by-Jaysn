fn main() {
    let data_dir = std::path::Path::new(
        &std::env::var("HOME").unwrap_or_default()
    ).join(".local/share/Steam/steamapps/common/Neverwinter Nights/data");
    
    let key_names = &["nwn_base.key", "nwn_retail.key", "nwn_expn.key", "nwn_x1.key", "nwn_x2.key", "nwnx1.key", "nwnx2.key"];
    
    let mut all_models = Vec::new();
    
    for key_name in key_names {
        let key_path = data_dir.join(key_name);
        if !key_path.exists() { continue; }
        if let Ok(key_table) = nwnrs_types::key::read_key_table_from_file(&key_path) {
            // The KeyTable has a method to iterate... but not directly exposed
            // Let's use `contains` and `demand` instead, and check some known names
        }
    }
    
    // Instead, let's try loading some common model names and see which ones exist
    let candidates = &[
        "NWH_1", "NWH_2", "NWH_3", "NWH_4", "NWH_5",
        "NWL_1", "NWL_2",
        "NW_CREATURE", "NW_CREATUR",
        "P_HUMAN_M", "P_HUMAN_F", "P_ELF_M", "P_ELF_F",
        "C_HUMAN_M", "C_HUMAN_F",
        "NWH_01", "NWH_02", "NWH_03",
    ];
    
    use nwnrs_types::resman::{ResRef, ResType};
    
    for name in candidates {
        for restype in &[2002u16, 2001u16] {
            let name_lower = name.to_lowercase();
            if let Ok(rr) = ResRef::new(name_lower, ResType(*restype)) {
                for key_name in key_names {
                    let key_path = data_dir.join(key_name);
                    if !key_path.exists() { continue; }
                    if let Ok(key_table) = nwnrs_types::key::read_key_table_from_file(&key_path) {
                        if key_table.contains(&rr) {
                            println!("FOUND: '{}' in {}", name, key_name);
                            break;
                        }
                    }
                }
            }
        }
    }
}
