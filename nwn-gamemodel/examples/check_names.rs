#![feature(generic_const_exprs)]

use std::path::Path;
fn main() {
    let path = std::env::args()
        .nth(1)
        .expect("Usage: cargo run -p nwn-gamemodel --example check_names -- <module.mod>");
    let path = Path::new(&path);
    let erf = nwn_erf::ErfFile::open(path).unwrap();
    let mut total = 0;
    let mut with_name = 0;
    for (resref, resource_type) in erf.keys() {
        if resource_type != 2012 { continue; }
        total += 1;
        let resref = resref.trim();
        if let Some(data) = erf.get(resref, 2012) {
            if let Ok(gff) = nwn_gff::GffFile::from_bytes(&data) {
                let display = gff.get_string("Area_Name").unwrap_or_default();
                if !display.is_empty() && display != resref {
                    with_name += 1;
                    if with_name <= 5 {
                        println!("  '{}' -> '{}'", resref, display);
                    }
                }
            }
        }
    }
    println!("Total: {}, with different name: {}", total, with_name);
}
