#![allow(incomplete_features)]
#![feature(generic_const_exprs)]
use nwn_erf::{ErfFile, erf::ResourceData};

fn main() {
    let path = std::env::args().nth(1).expect("Usage: check_data <module.mod>");
    let erf = ErfFile::open(&path).expect("Failed to open ERF");

    println!("File version: {:?}", erf.inner.header.file_version.as_str());
    println!("File type: {:?}", erf.inner.header.file_type.as_str());
    println!("Total resources: {}", erf.inner.resources.len());

    // Check first 5 ARE resources
    let mut are_count = 0;
    for r in &erf.inner.resources {
        if r.resource_type == 2012 {
            if are_count < 5 {
                println!("\nARE '{}':", r.file_name);
                match &r.data {
                    ResourceData::Buffer(buf) => {
                        println!("  Buffer: {} bytes", buf.len());
                        if buf.is_empty() {
                            println!("  *** EMPTY BUFFER ***");
                        } else {
                            let preview = if buf.len() > 32 { &buf[..32] } else { buf };
                            println!("  Hex: {:02x?}", preview);
                            if buf.len() >= 4 {
                                println!("  Magic: {:?}", &buf[..4]);
                            }
                        }
                    }
                    ResourceData::ArchiveOffset { offset, size } => {
                        println!("  ArchiveOffset: offset={}, size={}", offset, size);
                    }
                    ResourceData::File(path) => {
                        println!("  File: {:?}", path);
                    }
                }
            }
            are_count += 1;
        }
    }
    println!("\nTotal ARE count: {}", are_count);

    // Check IFO
    for r in &erf.inner.resources {
        if r.file_name.as_str() == "module" {
            println!("\n'{}' res type {}:", r.file_name, r.resource_type);
            match &r.data {
                ResourceData::Buffer(buf) => {
                    println!("  Buffer: {} bytes", buf.len());
                    if buf.len() >= 8 {
                        println!("  Magic: {:?}", &buf[..8]);
                    }
                    if buf.len() >= 4 {
                        let magic_u32 = u32::from_le_bytes([buf[0], buf[1], buf[2], buf[3]]);
                        println!("  First u32 (little-endian): {}", magic_u32);
                    }
                }
                ResourceData::ArchiveOffset { offset, size } => {
                    println!("  ArchiveOffset: offset={}, size={}", offset, size);
                }
                _ => {}
            }
        }
    }

    // Check GIT resources
    let mut git_count = 0;
    for r in &erf.inner.resources {
        if r.resource_type == 2023 {
            if git_count == 0 {
                println!("\nFirst GIT '{}':", r.file_name);
                match &r.data {
                    ResourceData::Buffer(buf) => {
                        println!("  Buffer: {} bytes", buf.len());
                        if buf.len() >= 8 {
                            println!("  Magic: {:?}", &buf[..8]);
                        }
                    }
                    ResourceData::ArchiveOffset { offset, size } => {
                        println!("  ArchiveOffset: offset={}, size={}", offset, size);
                    }
                    _ => {}
                }
            }
            git_count += 1;
        }
    }
    println!("Total GIT count: {}", git_count);
}
