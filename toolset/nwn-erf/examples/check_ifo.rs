use std::io::Read;

fn main() {
    let path = std::env::args().nth(1).expect("Usage: check_ifo <module.mod>");
    let data = std::fs::read(&path).expect("Failed to read file");

    // Read header to find module IFO
    let keys_count = u32::from_le_bytes(data[16..20].try_into().unwrap());
    let keys_off = u32::from_le_bytes(data[24..28].try_into().unwrap());
    let res_off = u32::from_le_bytes(data[28..32].try_into().unwrap());

    // Scan keys for module IFO
    let key_size: usize = 24; // V1.0
    for i in 0..keys_count as usize {
        let kpos = keys_off as usize + i * key_size;
        let name = &data[kpos..kpos+16];
        let name_str = std::str::from_utf8(name).unwrap_or("???").trim_end_matches('\0');
        if name_str.to_lowercase() == "module" || name_str.to_lowercase() == "module " {
            let resid = u32::from_le_bytes(data[kpos+16..kpos+20].try_into().unwrap());
            let restype = u16::from_le_bytes(data[kpos+20..kpos+22].try_into().unwrap());
            let tpos = res_off as usize + i * 8;
            let off = u32::from_le_bytes(data[tpos..tpos+4].try_into().unwrap());
            let sz = u32::from_le_bytes(data[tpos+4..tpos+8].try_into().unwrap());
            println!("Found: [{}] name={:?} resid={} restype={} offset={} size={}", i, name_str, resid, restype, off, sz);
            if sz > 0 && off as usize + sz as usize <= data.len() {
                let ifo_data = &data[off as usize..(off + sz) as usize];
                println!("IFO data length: {} bytes", ifo_data.len());
                println!("First 32 bytes: {:02x?}", &ifo_data[..32.min(ifo_data.len())]);
                println!("Magic: {:?}", std::str::from_utf8(&ifo_data[..8]));
                
                // Try parsing with GFF
                match nwn_lib_rs::gff::Gff::from_bytes(ifo_data) {
                    Ok((_, gff)) => {
                        println!("GFF parsed OK! Root type={}, fields={}", gff.root.label.as_str(), gff.root.fields.len());
                        // Dump all top-level fields
                        for f in &gff.root.fields {
                            let label = f.label.as_str();
                            let val = match f.type_ {
                                0 => format!("BYTE: {:?}", f.value.get_u8(&gff.field_data)),
                                1 => format!("CHAR: {:?}", f.value.get_char(&gff.field_data)),
                                2 => format!("WORD: {:?}", f.value.get_u16(&gff.field_data)),
                                3 => format!("SHORT: {:?}", f.value.get_i16(&gff.field_data)),
                                4 => format!("DWORD: {:?}", f.value.get_u32(&gff.field_data)),
                                5 => format!("INT: {:?}", f.value.get_i32(&gff.field_data)),
                                6 => format!("DWORD64: {:?}", f.value.get_u64(&gff.field_data)),
                                7 => format!("INT64: {:?}", f.value.get_i64(&gff.field_data)),
                                8 => format!("FLOAT: {:?}", f.value.get_float(&gff.field_data)),
                                9 => format!("DOUBLE: {:?}", f.value.get_double(&gff.field_data)),
                                10 => format!("CExoString: {:?}", f.value.get_string(&gff.field_data)),
                                11 => format!("ResRef: {:?}", f.value.get_resref(&gff.field_data)),
                                12 => format!("CExoLocString: {:?}", f.value.get_locstring(&gff.field_data)),
                                13 => format!("Void: {:?}", f.value.get_void(&gff.field_data)),
                                14 => format!("Struct: {} children", f.value.get_struct_count(&gff.field_data)),
                                15 => format!("List: {} items", f.value.get_list_count(&gff.field_data)),
                                _ => format!("Unknown type {}", f.type_),
                            };
                            println!("  {} = {}", label, val);
                        }
                    }
                    Err(e) => {
                        println!("GFF parse FAILED: {:?}", e);
                    }
                }
            }
        }
    }
}
