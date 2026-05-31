#![feature(generic_const_exprs)]
#![allow(incomplete_features)]
fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 { eprintln!("Usage: dump_bic <file.bic>"); return; }
    let gff = nwn_gff::GffFile::from_path(&args[1]).unwrap();
    println!("{}", gff.to_json_pretty().unwrap());
}
