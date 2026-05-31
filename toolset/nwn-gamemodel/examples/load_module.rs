#![allow(incomplete_features)]
#![feature(generic_const_exprs)]
fn main() {
    let path = std::env::args().nth(1).expect("Usage: load_module <path>");
    eprintln!("Loading module: {}", path);
    match nwn_gamemodel::Module::open(&path) {
        Ok(m) => {
            println!("OK: name={}, areas={}, scripts={}, conversations={}",
                m.name, m.num_areas(), m.scripts.len(), m.conversations.len());
            for name in m.area_names() {
                if let Some(area) = m.get_area(name) {
                    println!("  Area {}: {} ({}x{}, {} creatures)", name, area.name, area.width, area.height, area.creatures.len());
                }
            }
        }
        Err(e) => println!("ERR: {:?}", e),
    }
}
