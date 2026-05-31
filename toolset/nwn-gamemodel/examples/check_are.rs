#![allow(incomplete_features)]
#![feature(generic_const_exprs)]
use nwn_erf::ErfFile;
use nwn_gff::GffFile;

fn main() {
    let path = std::env::args().nth(1).expect("Usage: check_are <mod>");
    let erf = ErfFile::open(&path).expect("open");

    for r in &erf.inner.resources {
        if r.resource_type == 2012 {
            let name = r.file_name.to_string().trim().to_string();
            if let Some(data) = erf.get(&name, 2012) {
                if let Ok(gff) = GffFile::from_bytes(&data) {
                    let root = gff.root();
                    println!("=== ARE: '{}' ===", name);
                    for f in &root.fields {
                        let desc = match &f.value {
                            nwn_gff::FieldValue::List(l) => format!("List({})", l.len()),
                            v => format!("{:?}", v).chars().take(60).collect::<String>(),
                        };
                        println!("  {} = {}", f.label.as_str(), desc);
                        if f.label.as_str() == "Tile_List" {
                            if let nwn_gff::FieldValue::List(tiles) = &f.value {
                                for (ti, tile) in tiles.iter().enumerate().take(5) {
                                    println!("    Tile[{}]:", ti);
                                    for tf in &tile.fields {
                                        let td = match &tf.value {
                                            nwn_gff::FieldValue::Byte(b) => format!("Byte({})", b),
                                            nwn_gff::FieldValue::Int(i) => format!("Int({})", i),
                                            nwn_gff::FieldValue::Short(s) => format!("Short({})", s),
                                            nwn_gff::FieldValue::ResRef(r) => format!("ResRef({})", r),
                                            v => format!("{:?}", v).chars().take(40).collect::<String>(),
                                        };
                                        println!("      {} = {}", tf.label.as_str(), td);
                                    }
                                }
                                if tiles.len() > 5 {
                                    println!("    ... {} more tiles", tiles.len() - 5);
                                }
                            }
                        }
                        if f.label.as_str() == "Tile_Height" || f.label.as_str() == "Tile_Type" {
                            // shown above
                        }
                    }
                    break;
                }
            }
        }
    }
}
