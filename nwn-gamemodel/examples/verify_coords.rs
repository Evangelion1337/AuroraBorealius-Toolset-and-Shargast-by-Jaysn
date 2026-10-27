#![allow(incomplete_features)]
#![feature(generic_const_exprs)]
use nwn_erf::ErfFile;
use nwn_gff::{GffFile, FieldValue};
use nwn_gamemodel::Module;

fn main() {
    let path = std::env::args().nth(1).expect("Usage: verify_coords <module.mod> [area_resref]");
    let area_filter = std::env::args().nth(2);
    
    let erf = ErfFile::open(&path).expect("Failed to open mod");
    let module = Module::open(&path).expect("Failed to load module");
    
    for area_name in module.area_names() {
        if let Some(ref filter) = area_filter {
            if !area_name.eq_ignore_ascii_case(filter) { continue; }
        }
        
        let area = match module.get_area(area_name) {
            Some(a) => a,
            None => { eprintln!("Area '{}' not loaded", area_name); continue; }
        };
        
        println!("\n=== Area: {} ({}x{} tiles, {}m x {}m) ===", 
            area_name, area.width, area.height, 
            area.width as f32 * 10.0, area.height as f32 * 10.0);
        
        // Get raw GIT data
        let git_data = erf.get(area_name, nwn_gamemodel::resource_types::GIT)
            .or_else(|| erf.get(&area_name.to_uppercase(), nwn_gamemodel::resource_types::GIT));
        
        if let Some(data) = git_data {
            let git_gff = GffFile::from_bytes(&data).expect("Failed to parse GIT");
            let root = git_gff.root();
            
            verify_list(&root, area.doors.as_slice(), &area.creatures, "Door_List", "Doors", |o| (o.x, o.y, o.z));
            // Just check creature count for now
            let raw_creatures = root.find("Creature_List")
                .and_then(|v| if let FieldValue::List(l) = v { Some(l.len()) } else { None })
                .unwrap_or(0);
            println!("  Creatures: {} loaded, {} in raw GIT", area.creatures.len(), raw_creatures);
            
            // Also check if Width/Height from GIT matches ARE
            if let Some(w) = root.find("Width").and_then(|v| if let FieldValue::Int(i) = v { Some(*i) } else { None }) {
                if w != area.width {
                    println!("  ** WARNING: GIT Width={} != ARE Width={} **", w, area.width);
                }
            }
            if let Some(h) = root.find("Height").and_then(|v| if let FieldValue::Int(i) = v { Some(*i) } else { None }) {
                if h != area.height {
                    println!("  ** WARNING: GIT Height={} != ARE Height={} **", h, area.height);
                }
            }
        } else {
            println!("  No GIT data found");
        }
    }
}

fn verify_list<T: Coorded>(
    root: &nwn_gff::Struct, 
    loaded: &[T],
    _creatures: &[nwn_gamemodel::CreatureInstance],
    list_name: &str, 
    label: &str,
    get_coords: fn(&T) -> (f32, f32, f32),
) {
    let raw_list = root.find(list_name)
        .and_then(|v| if let FieldValue::List(l) = v { Some(l) } else { None });
    
    let raw_count = raw_list.map(|l| l.len()).unwrap_or(0);
    
    println!("  {}: {} loaded, {} in raw GIT", label, loaded.len(), raw_count);
    
    if let Some(list) = raw_list {
        for (i, entry) in list.iter().enumerate() {
            let raw_x = entry.find("XPosition").or_else(|| entry.find("X"))
                .and_then(|v| match v { FieldValue::Float(f) => Some(*f), FieldValue::Double(f) => Some(*f as f32), _ => None })
                .unwrap_or(-999.0);
            let raw_y = entry.find("YPosition").or_else(|| entry.find("Y"))
                .and_then(|v| match v { FieldValue::Float(f) => Some(*f), FieldValue::Double(f) => Some(*f as f32), _ => None })
                .unwrap_or(-999.0);
            let raw_z = entry.find("ZPosition").or_else(|| entry.find("Z"))
                .and_then(|v| match v { FieldValue::Float(f) => Some(*f), FieldValue::Double(f) => Some(*f as f32), _ => None })
                .unwrap_or(-999.0);
            let resref = entry.find("TemplateResRef")
                .and_then(|v| if let FieldValue::ResRef(s) = v { Some(s.as_str()) } else { None })
                .unwrap_or("");
            
            let loaded_coords = if i < loaded.len() { get_coords(&loaded[i]) } else { (0.0, 0.0, 0.0) };
            
            let dx = (raw_x - loaded_coords.0).abs();
            let dy = (raw_y - loaded_coords.1).abs();
            let dz = (raw_z - loaded_coords.2).abs();
            
            if dx > 0.001 || dy > 0.001 || dz > 0.001 {
                println!("    [{}] {} raw=({:.4}, {:.4}, {:.4}) loaded=({:.4}, {:.4}, {:.4}) DIFF=({:.4}, {:.4}, {:.4})",
                    i, resref, raw_x, raw_y, raw_z,
                    loaded_coords.0, loaded_coords.1, loaded_coords.2,
                    dx, dy, dz);
            }
        }
    }
}

trait Coorded { fn coords(&self) -> (f32, f32, f32); }
impl Coorded for nwn_gamemodel::DoorInstance { fn coords(&self) -> (f32, f32, f32) { (self.x, self.y, self.z) } }
impl Coorded for nwn_gamemodel::WayPointInstance { fn coords(&self) -> (f32, f32, f32) { (self.x, self.y, self.z) } }
