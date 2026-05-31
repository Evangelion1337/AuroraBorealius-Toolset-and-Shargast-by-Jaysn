#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

#[test]
fn load_module_tilesets() {
    let path = if let Ok(home) = std::env::var("HOME") {
        format!("{}/Documents/Neverwinter Nights/modules/HOPE_Shargast_CH1.mod", home)
    } else {
        return;
    };
    let module = nwn_gamemodel::Module::open(&path).expect("Failed to open module");
    println!("Module: {} ({} areas)", module.name, module.num_areas());
    println!("Haks: {:?}", module.haks);

    let tilesets: Vec<String> = module.area_names().iter()
        .filter_map(|name| module.get_area(name))
        .map(|a| a.tileset.clone())
        .collect::<std::collections::HashSet<_>>()
        .into_iter()
        .collect();
    if !tilesets.is_empty() {
        println!("Unique tilesets: {:?}", tilesets);
    }

    if let Some(name) = module.area_names().first() {
        if let Some(area) = module.get_area(name) {
            println!("First area '{}': tileset='{}'", name, area.tileset);
            let model_count = area.tile_models.iter().filter(|m| m.is_some()).count();
            println!("  {} tiles, {} with model names", area.tiles.len(), model_count);
            let mut unique_models: Vec<&str> = area.tile_models.iter()
                .filter_map(|m| m.as_deref()).collect();
            unique_models.sort();
            unique_models.dedup();
            println!("  {} unique models e.g.: {:?}", unique_models.len(), &unique_models[..unique_models.len().min(10)]);
        }
    }
}
