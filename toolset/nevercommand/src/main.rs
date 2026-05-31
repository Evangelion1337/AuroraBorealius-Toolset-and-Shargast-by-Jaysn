#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

use clap::{Parser, Subcommand};
use nwn_gamemodel::resource_types;

#[derive(Parser)]
#[command(name = "nevercommand", about = "NWN resource command-line tool")]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    #[arg(short = 'd', long = "nwndir")]
    nwn_dir: Option<String>,

    #[arg(short = 'm', long = "module")]
    module: Option<String>,

    #[arg(short = 'o', long = "outfile")]
    outfile: Option<String>,
}

#[derive(Subcommand)]
enum Commands {
    /// List all resources with given extension
    Lookup {
        ext: String,
    },
    /// Human-readable dump of a resource
    Print {
        key: String,
        #[arg(default_value = "uti")]
        ext: String,
    },
    /// Extract resource bytes to file
    Get {
        key: String,
        #[arg(default_value = "uti")]
        ext: String,
    },
    /// Lookup dialog.tlk string
    Strref {
        strref: String,
    },
    /// Dump all entries of an ERF file
    Extract {
        erf: String,
    },
    /// Set a preference
    Setpref {
        key: String,
        value: String,
    },
}

fn main() {
    let cli = Cli::parse();
    let result = match &cli.command {
        Commands::Lookup { ext } => cmd_lookup(ext, &cli),
        Commands::Print { key, ext } => cmd_print(key, ext, &cli),
        Commands::Get { key, ext } => cmd_get(key, ext, &cli),
        Commands::Strref { strref } => cmd_strref(strref, &cli),
        Commands::Extract { erf } => cmd_extract(erf, &cli),
        Commands::Setpref { key, value } => cmd_setpref(key, value),
    };
    if let Err(e) = result {
        eprintln!("Error: {}", e);
        std::process::exit(1);
    }
}

fn find_mod(cli: &Cli) -> Option<String> {
    if let Some(m) = &cli.module { return Some(m.clone()); }
    if let Some(dir) = &cli.nwn_dir {
        let path = std::path::Path::new(dir);
        if let Ok(entries) = std::fs::read_dir(path) {
            for entry in entries.flatten() {
                let p = entry.path();
                if let Some(ext) = p.extension() {
                    if ext == "mod" || ext == "MOD" {
                        return Some(p.to_string_lossy().to_string());
                    }
                }
            }
        }
    }
    None
}

fn cmd_lookup(ext: &str, cli: &Cli) -> Result<(), Box<dyn std::error::Error>> {
    let mod_path = find_mod(cli).ok_or("No module found")?;
    let erf = nwn_erf::ErfFile::open(&mod_path)?;
    println!("Resources in {} with extension '{}':", mod_path, ext);
    for (resref, restype) in erf.keys() {
        if let Some(t) = resource_types::type_to_ext(restype) {
            if t == ext {
                println!("  {}.{}", resref, ext);
            }
        }
    }
    Ok(())
}

fn cmd_print(key: &str, ext: &str, cli: &Cli) -> Result<(), Box<dyn std::error::Error>> {
    let mod_path = find_mod(cli).ok_or("No module found")?;
    let erf = nwn_erf::ErfFile::open(&mod_path)?;
    let restype = resource_types::ext_to_type(ext).ok_or(format!("Unknown extension: {}", ext))?;
    let data = erf.get(key, restype).ok_or(format!("Resource {}.{} not found", key, ext))?;
    let gff = nwn_gff::GffFile::from_bytes(&data)?;
    println!("{}", gff.to_json_pretty()?);
    Ok(())
}

fn cmd_get(_key: &str, _ext: &str, _cli: &Cli) -> Result<(), Box<dyn std::error::Error>> {
    eprintln!("not yet implemented");
    Ok(())
}

fn cmd_strref(strref_str: &str, cli: &Cli) -> Result<(), Box<dyn std::error::Error>> {
    let strref = if let Some(hex) = strref_str.strip_prefix("0x") {
        u32::from_str_radix(hex, 16)?
    } else {
        strref_str.parse()?
    };
    let nwn_dir = cli.nwn_dir.as_ref().ok_or("Need --nwndir")?;
    let tlk_path = std::path::Path::new(nwn_dir).join("dialog.tlk");
    if tlk_path.exists() {
        let tlk = nwn_tlk::TlkFile::open(&tlk_path)?;
        match tlk.strref(strref) {
            Some(s) => println!("{}", s),
            None => println!("(no string for strref {})", strref),
        }
    } else {
        eprintln!("dialog.tlk not found in {}", nwn_dir);
    }
    Ok(())
}

fn cmd_extract(erf_path: &str, _cli: &Cli) -> Result<(), Box<dyn std::error::Error>> {
    let erf = nwn_erf::ErfFile::open(erf_path)?;
    let out_dir = format!("{}_extracted", erf_path);
    std::fs::create_dir_all(&out_dir)?;
    for (resref, restype) in erf.keys() {
        if let Some(data) = erf.get(&resref, restype) {
            let ext = resource_types::type_to_ext(restype).unwrap_or("dat");
            let filepath = format!("{}/{}.{}", out_dir, resref, ext);
            std::fs::write(&filepath, &data)?;
            println!("  Extracted: {}", filepath);
        }
    }
    println!("Extracted {} resources to {}", erf.resource_count(), out_dir);
    Ok(())
}

fn cmd_setpref(_key: &str, _value: &str) -> Result<(), Box<dyn std::error::Error>> {
    eprintln!("not yet implemented");
    Ok(())
}
