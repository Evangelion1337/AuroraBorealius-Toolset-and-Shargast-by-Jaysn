use std::collections::HashSet;
use std::fs;
use std::io::Cursor;
use std::path::Path;
use std::sync::Mutex;

use anyhow::{Context, Result};
use nwn_erf::ErfFile;
use nwn_gff::GffFile;
use nwnrs_types::checksums;
use nwnrs_types::compressedbuf::{self, Algorithm};
use nwnrs_types::nwsync::{Manifest, ManifestEntry};
use nwnrs_types::resman::ResolvedResRef;
use rayon::prelude::*;

fn get_module_hak_order(mod_path: &Path) -> Result<(Vec<String>, String)> {
    let erf = ErfFile::open(mod_path)?;
    let ifo_data = erf.get("module", 2005)
        .context("module.ifo not found in mod")?;
    let gff = GffFile::from_bytes(&ifo_data).context("failed to parse module.ifo GFF")?;

    let mut haks = Vec::new();
    if let Some(field) = gff.inner.root.find("Mod_HakList") {
        let list = field.unwrap_list();
        for entry in list {
            if let Some(hak_field) = entry.find("Mod_Hak") {
                let name = hak_field.unwrap_string().to_ascii_lowercase() + ".hak";
                haks.push(name);
            }
        }
    }

    let custom_tlk = gff.inner.root
        .find("Mod_CustomTlk")
        .map(|f| f.unwrap_string().clone())
        .unwrap_or_default();

    Ok((haks, custom_tlk))
}

fn collect_files_from_erf(path: &Path) -> Result<Vec<FileEntry>> {
    let erf = ErfFile::open(path)
        .with_context(|| format!("failed to read erf: {}", path.display()))?;

    let items: Vec<nwn_erf::ErfResource> = erf.resources();
    let entries: Vec<FileEntry> = items
        .into_par_iter()
        .filter_map(|res| {
            let fname = format!("{}.{}", res.resref, res.restype);
            let resolved = ResolvedResRef::try_from_filename(&fname)?;
            Some(FileEntry {
                data: res.data,
                filename: resolved.to_file(),
                resref: resolved.base().clone(),
            })
        })
        .collect();

    Ok(entries)
}

struct FileEntry {
    data: Vec<u8>,
    filename: String,
    resref: nwnrs_types::resman::ResRef,
}

fn process_files(
    entries: Vec<FileEntry>,
    processed: &Mutex<HashSet<String>>,
    sha1_cache: &Mutex<HashSet<String>>,
    data_dir: &Path,
) -> Vec<(ManifestEntry, Vec<u8>)> {
    entries
        .into_par_iter()
        .filter_map(|fe| {
            let mut p = processed.lock().unwrap();
            if p.contains(&fe.filename) {
                return None;
            }
            p.insert(fe.filename.clone());
            drop(p);

            let magic = compressedbuf::make_magic("NSYC").ok()?;
            let compressed = compressedbuf::compress_bytes(&fe.data, Algorithm::Zstd, magic).ok()?;
            let sha1 = checksums::secure_hash(&compressed);
            let sha1_hex = sha1.to_string();

            let mut sc = sha1_cache.lock().unwrap();
            if !sc.contains(&sha1_hex) {
                sc.insert(sha1_hex.clone());
                let sub1 = &sha1_hex[..2];
                let sub2 = &sha1_hex[2..4];
                let blob_dir = data_dir.join("sha1").join(sub1).join(sub2);
                fs::create_dir_all(&blob_dir).ok()?;
                fs::write(blob_dir.join(&sha1_hex), &compressed).ok()?;
            }
            drop(sc);

            let entry = ManifestEntry::new(sha1, fe.data.len() as u32, fe.resref);
            Some((entry, compressed))
        })
        .collect()
}

pub fn gen_nwsync(
    mod_path: &Path,
    hak_dir: &Path,
    output_dir: &Path,
    label: &str,
) -> Result<()> {
    eprintln!("=== {} ===", label);

    let (hak_order, custom_tlk) = get_module_hak_order(mod_path)?;
    eprintln!("  Haks in module order: {}", hak_order.len());
    eprintln!("  Custom TLK: {}", custom_tlk);

    let data_dir = output_dir.join("data");
    let manifests_dir = output_dir.join("manifests");
    fs::create_dir_all(&data_dir).context("failed to create data dir")?;
    fs::create_dir_all(&manifests_dir).context("failed to create manifests dir")?;

    if data_dir.join("sha1").exists() {
        fs::remove_dir_all(data_dir.join("sha1")).ok();
    }

    let processed: Mutex<HashSet<String>> = Mutex::new(HashSet::new());
    let sha1_cache: Mutex<HashSet<String>> = Mutex::new(HashSet::new());
    let all_entries: Mutex<Vec<ManifestEntry>> = Mutex::new(Vec::new());
    let total_compressed: Mutex<u64> = Mutex::new(0);
    let total_uncompressed: Mutex<u64> = Mutex::new(0);

    // 1. Mod files
    eprintln!("  Mod...");
    let mod_entries = collect_files_from_erf(mod_path)?;
    let results = process_files(mod_entries, &processed, &sha1_cache, &data_dir);
    {
        let mut ae = all_entries.lock().unwrap();
        let mut tc = total_compressed.lock().unwrap();
        let mut tu = total_uncompressed.lock().unwrap();
        for (entry, compressed) in &results {
            ae.push(entry.clone());
            *tc += compressed.len() as u64;
            *tu += entry.size as u64;
        }
    }
    eprintln!("  Mod: {} files", all_entries.lock().unwrap().len());

    // 2. Haks in reverse module order
    for hak_name in hak_order.iter().rev() {
        let hak_path = hak_dir.join(hak_name);
        if !hak_path.exists() {
            let lc = hak_name.to_ascii_lowercase();
            let dir_entries = fs::read_dir(hak_dir).ok();
            let found = dir_entries.and_then(|entries| {
                entries.filter_map(|e| e.ok()).find(|e| {
                    e.path()
                        .file_name()
                        .and_then(|s| s.to_str())
                        .map(|s| s.to_ascii_lowercase() == lc)
                        .unwrap_or(false)
                })
            });
            let actual = found.and_then(|e| e.file_name().to_str().map(|s| s.to_string()));
            if let Some(actual) = actual {
                let hp = hak_dir.join(&actual);
                if hp.exists() {
                    let _count_before = all_entries.lock().unwrap().len();
                    match collect_files_from_erf(&hp) {
                        Ok(entries) => {
                            let results = process_files(entries, &processed, &sha1_cache, &data_dir);
                            let mut ae = all_entries.lock().unwrap();
                            let mut tc = total_compressed.lock().unwrap();
                            let mut tu = total_uncompressed.lock().unwrap();
                            for (entry, compressed) in &results {
                                ae.push(entry.clone());
                                *tc += compressed.len() as u64;
                                *tu += entry.size as u64;
                            }
                            let added = ae.len() - _count_before;
                            eprintln!("    {}: +{} -> {} total", actual, added, ae.len());
                        }
                        Err(e) => eprintln!("    {}: SKIP ({})", actual, e),
                    }
                    continue;
                }
            }
            eprintln!("    {}: NOT FOUND", hak_name);
            continue;
        }
        let _count_before = all_entries.lock().unwrap().len();
        match collect_files_from_erf(&hak_path) {
            Ok(entries) => {
                let results = process_files(entries, &processed, &sha1_cache, &data_dir);
                let mut ae = all_entries.lock().unwrap();
                let mut tc = total_compressed.lock().unwrap();
                let mut tu = total_uncompressed.lock().unwrap();
                for (entry, compressed) in &results {
                    ae.push(entry.clone());
                    *tc += compressed.len() as u64;
                    *tu += entry.size as u64;
                }
                let added = ae.len() - _count_before;
                eprintln!("    {}: +{} -> {} total", hak_name, added, ae.len());
            }
            Err(e) => {
                eprintln!("    {}: SKIP ({})", hak_name, e);
            }
        }
    }

    // 3. Custom TLK
    if !custom_tlk.is_empty() {
        let user_dir = mod_path.parent().and_then(|p| p.parent());
        if let Some(ud) = user_dir {
            let tlk_filename = format!("{}.tlk", custom_tlk);
            let tlk_path = ud.join("tlk").join(&tlk_filename);
            if tlk_path.exists() {
                let _count_before = all_entries.lock().unwrap().len();
                let fname = tlk_path
                    .file_name()
                    .and_then(|s| s.to_str())
                    .unwrap_or("")
                    .to_string();
                if let Some(resolved) = ResolvedResRef::try_from_filename(&fname) {
                    let data = fs::read(&tlk_path)
                        .context("failed to read tlk file")?;
                    let fe = FileEntry {
                        data,
                        filename: resolved.to_file(),
                        resref: resolved.base().clone(),
                    };
                    let results = process_files(vec![fe], &processed, &sha1_cache, &data_dir);
                    let mut ae = all_entries.lock().unwrap();
                    let mut tc = total_compressed.lock().unwrap();
                    let mut tu = total_uncompressed.lock().unwrap();
                    for (entry, compressed) in &results {
                        ae.push(entry.clone());
                        *tc += compressed.len() as u64;
                        *tu += entry.size as u64;
                    }
                    let added = results.len();
                    eprintln!("  TLK: +{} -> {} total", added, ae.len());
                } else {
                    eprintln!("  TLK: SKIP (invalid resref: {})", custom_tlk);
                }
            } else {
                eprintln!("  TLK: {} not found at {}", custom_tlk, tlk_path.display());
            }
        } else {
            eprintln!("  TLK: SKIP (could not determine user dir from mod path)");
        }
    }

    let total = all_entries.lock().unwrap().len();
    let tc = *total_compressed.lock().unwrap();
    let tu = *total_uncompressed.lock().unwrap();
    eprintln!("  Total: {} files", total);

    // 4. Write manifest and metadata
    eprintln!("  Writing manifest...");
    let entries: Vec<ManifestEntry> = all_entries
        .lock()
        .unwrap()
        .drain(..)
        .collect();
    let mut manifest = Manifest::new(2);
    for entry in entries {
        manifest.add_entry(entry);
    }

    let mut manifest_buf = Cursor::new(Vec::new());
    nwnrs_types::nwsync::write_manifest(&mut manifest_buf, &manifest)
        .context("failed to write manifest")?;
    let manifest_data = manifest_buf.into_inner();
    let manifest_sha1 = checksums::secure_hash(&manifest_data).to_string();

    fs::write(manifests_dir.join(&manifest_sha1), &manifest_data)
        .context("failed to write manifest file")?;

    for entry in fs::read_dir(&manifests_dir)? {
        let entry = entry?;
        let name = entry.file_name();
        let name_str = name.to_string_lossy().to_string();
        if name_str != manifest_sha1 && name_str != format!("{}.json", manifest_sha1) {
            if !name_str.ends_with(".json") || {
                let base = name_str.trim_end_matches(".json");
                base != manifest_sha1
            } {
                fs::remove_file(entry.path()).ok();
            }
        }
    }

    #[derive(serde::Serialize)]
    struct MetaJson {
        version: u32,
        sha1: String,
        hash_tree_depth: u32,
        module_name: String,
        description: String,
        includes_module_contents: bool,
        includes_client_contents: bool,
        total_files: usize,
        total_bytes: u64,
        on_disk_bytes: u64,
        created: u64,
        created_with: String,
    }

    let meta = MetaJson {
        version: 3,
        sha1: manifest_sha1.clone(),
        hash_tree_depth: 2,
        module_name: String::new(),
        description: String::new(),
        includes_module_contents: false,
        includes_client_contents: true,
        total_files: total,
        total_bytes: tu,
        on_disk_bytes: tc,
        created: std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .unwrap()
            .as_secs(),
        created_with: "aurora-borealis".to_string(),
    };
    let meta_json = serde_json::to_string_pretty(&meta)?;
    fs::write(manifests_dir.join(&format!("{}.json", manifest_sha1)), &meta_json)
        .context("failed to write meta json")?;

    fs::write(output_dir.join("latest"), format!("{}\n", manifest_sha1))
        .context("failed to write latest")?;

    eprintln!("  Done! Hash: {}", manifest_sha1);
    eprintln!("  On-disk: {:.1}GB  Uncompressed: {:.1}GB  Entries: {}",
        tc as f64 / 1e9, tu as f64 / 1e9, total);

    Ok(())
}
