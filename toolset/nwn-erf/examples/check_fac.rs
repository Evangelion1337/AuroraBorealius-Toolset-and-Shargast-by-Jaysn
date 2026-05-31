#![allow(incomplete_features)]
#![feature(generic_const_exprs)]
use nwn_erf::ErfFile;
fn main() {
    let path = std::env::args().nth(1).expect("Usage: check_fac <module.mod>");
    let erf = ErfFile::open(&path).expect("Failed to open ERF");

    use std::collections::HashMap;
    let mut type_counts: HashMap<u16, u32> = HashMap::new();
    for r in &erf.inner.resources {
        *type_counts.entry(r.resource_type).or_insert(0) += 1;
    }
    let mut types: Vec<_> = type_counts.into_iter().collect();
    types.sort_by_key(|k| k.0);
    for (rt, count) in &types {
        let ext = nwn_lib_rs::erf::ResourceType::from(*rt).ext();
        println!("  Type {} ({:4}): {} resources", rt, ext, count);
    }

    println!("\nResources named 'faction' or 'Faction':");
    for r in &erf.inner.resources {
        let name = r.file_name.as_str().trim().to_lowercase();
        if name == "faction" || name == "factions" {
            println!("  '{}' type {} ({}): {:?}", r.file_name.as_str(), r.resource_type,
                nwn_lib_rs::erf::ResourceType::from(r.resource_type).ext(), r.data);
        }
    }
    println!("\nJournal (JRL, type 2056) resources:");
    for r in &erf.inner.resources {
        if r.resource_type == 2056 {
            println!("  '{}'", r.file_name.as_str());
        }
    }
    println!("\nFaction (FAC, type 2038) resources:");
    for r in &erf.inner.resources {
        if r.resource_type == 2038 {
            println!("  '{}'", r.file_name.as_str());
        }
    }
}
