#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

use clap::Parser;

#[derive(Parser)]
#[command(name = "nevererf", about = "ERF archive manipulation tool")]
struct Cli {
    /// ERF file to operate on
    #[arg(short = 'f', long = "file")]
    file: String,

    /// List ERF contents
    #[arg(short = 't', long = "list")]
    list: bool,

    /// Extract resources
    #[arg(short = 'x', long = "extract")]
    extract: bool,

    /// Create ERF from files
    #[arg(short = 'c', long = "create")]
    create: bool,

    /// Print ERF metadata
    #[arg(short = 'i', long = "info")]
    info: bool,

    /// Recursive directory for --create
    #[arg(short = 'r', long = "recursive")]
    recursive: bool,
}

fn main() {
    let cli = Cli::parse();
    let result = if cli.list {
        cmd_list(&cli.file)
    } else if cli.extract {
        cmd_extract(&cli.file)
    } else if cli.create {
        cmd_create(&cli.file)
    } else if cli.info {
        cmd_info(&cli.file)
    } else {
        cmd_list(&cli.file)
    };
    if let Err(e) = result {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
}

fn cmd_list(path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let erf = nwn_erf::ErfFile::open(path)?;
    println!("ERF File: {}", path);
    println!("  Resources: {}", erf.resource_count());
    println!("  Description: {}", erf.description().unwrap_or_default());
    println!();
    for (resref, restype) in erf.keys() {
        let ext = nwn_gamemodel::resource_types::type_to_ext(restype).unwrap_or("???");
        println!("  {}.{}", resref, ext);
    }
    Ok(())
}

fn cmd_extract(path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let erf = nwn_erf::ErfFile::open(path)?;
    let out_dir = format!("{}_extracted", path);
    std::fs::create_dir_all(&out_dir)?;
    for (resref, restype) in erf.keys() {
        if let Some(data) = erf.get(&resref, restype) {
            let ext = nwn_gamemodel::resource_types::type_to_ext(restype).unwrap_or("dat");
            let filepath = format!("{}/{}.{}", out_dir, resref, ext);
            std::fs::write(&filepath, &data)?;
        }
    }
    println!("Extracted {} resources to {}", erf.resource_count(), out_dir);
    Ok(())
}

fn cmd_create(_path: &str) -> Result<(), Box<dyn std::error::Error>> {
    eprintln!("ERF creation not yet implemented");
    Ok(())
}

fn cmd_info(path: &str) -> Result<(), Box<dyn std::error::Error>> {
    let erf = nwn_erf::ErfFile::open(path)?;
    println!("File: {}", path);
    println!("Resources: {}", erf.resource_count());
    println!("Description: {}", erf.description().unwrap_or_default());
    Ok(())
}
