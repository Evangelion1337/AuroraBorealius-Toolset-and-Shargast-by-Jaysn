use std::io::Write;
fn main() {
    let out = std::path::PathBuf::from(std::env::var("OUT_DIR").unwrap()).join("nwnx_scripts.rs");
    let mut f = std::fs::File::create(&out).unwrap();
    let dir = std::path::PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("nwnx_scripts");
    let mut entries: Vec<_> = std::fs::read_dir(&dir).unwrap()
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().is_some_and(|ext| ext == "nss"))
        .collect();
    entries.sort_by_key(|e| e.file_name());
    writeln!(f, "pub const NWNX_SCRIPTS: &[(&str, &[u8])] = &[").unwrap();
    for e in &entries {
        let name = e.file_name().to_string_lossy().to_string();
        writeln!(f, "    (\"{}\", include_bytes!(concat!(env!(\"CARGO_MANIFEST_DIR\"), \"/nwnx_scripts/\", {:?}))),", name, name).unwrap();
    }
    writeln!(f, "];").unwrap();
    println!("cargo::rerun-if-changed=nwnx_scripts");
}
