use std::collections::HashMap;
use std::path::{Path, PathBuf};
use std::sync::Mutex;

pub struct GameData {
    // (resref_lowercase, restype) -> (bif_index, resource_index)
    lookup: HashMap<(String, u16), (usize, u32)>,
    bifs: Mutex<Vec<BifFile>>,
    root: PathBuf,
}

struct BifFile {
    path: PathBuf,
    entries: Vec<BifEntry>,
}

struct BifEntry {
    offset: u32,
    size: u32,
}

impl GameData {
    pub fn new() -> Option<Self> {
        let root = nwn_root()?;
        let data_dir = root.join("data");
        if !data_dir.is_dir() {
            return None;
        }

        let mut lookup: HashMap<(String, u16), (usize, u32)> = HashMap::new();
        let mut bifs: Vec<BifFile> = Vec::new();
        let mut bif_paths: Vec<PathBuf> = Vec::new();

        eprintln!("GameData: root={:?} data_dir={:?}", root, data_dir);

        // Load both key files
        let key_files = ["nwn_base.key", "nwn_retail.key"];
        for key_name in &key_files {
            let key_path = data_dir.join(key_name);
            if !key_path.exists() {
                continue;
            }
            if let Ok(data) = std::fs::read(&key_path) {
                parse_key(&data, &root, &mut lookup, &mut bif_paths);
            }
        }

        // Pre-open BIF files (header + entry list only, not data)
        for bif_path in &bif_paths {
            // Read only the header to get entry count, then read entries
            use std::io::{Read, Seek, SeekFrom};
            let mut file = match std::fs::File::open(bif_path) {
                Ok(f) => f,
                Err(_) => continue,
            };
            let file_size = match file.metadata().map(|m| m.len()) {
                Ok(s) => s,
                Err(_) => continue,
            };
            // BIF header: 0-3 signature, 4-7 version, 8-11 VariableResourceCount,
            // 12-15 FixedResourceCount, 16-19 VariableResourceOffset
            let mut hdr = [0u8; 20];
            if file.read_exact(&mut hdr).is_err() { continue; }
            let count = u32::from_le_bytes([hdr[8], hdr[9], hdr[10], hdr[11]]) as usize;
            if count > 10_000_000 { continue; }
            let var_offset = u32::from_le_bytes([hdr[16], hdr[17], hdr[18], hdr[19]]) as usize;
            let entries_bytes = count.saturating_mul(12);
            let total_read = var_offset + entries_bytes;
            if total_read > file_size as usize { continue; }
            let mut data = vec![0u8; total_read];
            data[..20].copy_from_slice(&hdr);
            file.seek(SeekFrom::Start(var_offset as u64)).ok();
            if file.read_exact(&mut data[var_offset..]).is_err() { continue; }
            if let Some(bif) = parse_bif_header(&data, bif_path) {
                bifs.push(bif);
            }
        }

        eprintln!("GameData: {} BIFs loaded with {} total entries, {} KEY lookups registered", bifs.len(),
            bifs.iter().map(|b| b.entries.len()).sum::<usize>(), lookup.len());

        Some(Self { lookup, bifs: Mutex::new(bifs), root })
    }

    pub fn get_resource(&self, resref: &str, restype: u16) -> Option<Vec<u8>> {
        let key = (resref.trim().to_lowercase(), restype);
        eprintln!("GameData::get_resource: resref='{}' restype={}", resref, restype);
        // Check lookup table for KEY/BIF resources
        if let Some(&(bif_idx, resource_idx)) = self.lookup.get(&key) {
            eprintln!("GameData: found in BIF idx={} resource={}", bif_idx, resource_idx);
            let bifs = self.bifs.lock().ok()?;
            let bif = bifs.get(bif_idx)?;
            let entry = bif.entries.get(resource_idx as usize)?;
            return read_bif_resource(&bif.path, entry.offset, entry.size);
        }

        eprintln!("GameData: not in key, trying loose files");
        // Fallback: search for loose files in the NWN data directory
        self.find_loose_file(resref, restype)
    }

    fn find_loose_file(&self, resref: &str, restype: u16) -> Option<Vec<u8>> {
        let ext = crate::resource_types::type_to_ext(restype)?;
        let subdirs = ["amb", "mus", "streammusic", "streamwaves", "voice"];
        for subdir in &subdirs {
            let path = self.root.join("data").join(subdir).join(format!("{}.{}", resref, ext));
            if path.exists() {
                eprintln!("GameData: found loose file at {:?}", path);
                return std::fs::read(&path).ok();
            }
        }
        let path = self.root.join("data").join(format!("{}.{}", resref, ext));
        if path.exists() {
            eprintln!("GameData: found loose file at {:?}", path);
            return std::fs::read(&path).ok();
        }
        eprintln!("GameData: no loose file found for '{}.{}'", resref, ext);
        None
    }
}

fn nwn_root() -> Option<PathBuf> {
    // Try env var first
    if let Ok(nwn) = std::env::var("NWN") {
        if Path::new(&nwn).exists() {
            return Some(PathBuf::from(nwn));
        }
    }
    let home = std::env::var("HOME").ok()?;

    // Try common Steam library paths
    let steam_candidates = [
        format!("{}/.steam/steam/steamapps/common/Neverwinter Nights", home),
        format!("{}/.local/share/Steam/steamapps/common/Neverwinter Nights", home),
        format!("{}/snap/steam/common/.steam/steam/steamapps/common/Neverwinter Nights", home),
    ];
    for c in &steam_candidates {
        let p = Path::new(c);
        if p.join("data").is_dir() {
            return Some(p.to_path_buf());
        }
    }

    // Try home directory common NWN paths
    let candidates = [
        format!("{}/.local/share/Neverwinter Nights", home),
        format!("{}/Documents/Neverwinter Nights", home),
    ];
    for c in &candidates {
        let p = Path::new(c);
        if p.join("data").is_dir() {
            return Some(p.to_path_buf());
        }
    }
    None
}

fn parse_key(data: &[u8], root: &Path, lookup: &mut HashMap<(String, u16), (usize, u32)>, bif_paths: &mut Vec<PathBuf>) {
    if data.len() < 56 { return; }
    // Header
    let bif_count = u32::from_le_bytes([data[8], data[9], data[10], data[11]]) as usize;
    let key_count = u32::from_le_bytes([data[12], data[13], data[14], data[15]]) as usize;
    let off_file_tbl = u32::from_le_bytes([data[16], data[17], data[18], data[19]]) as usize;
    let off_key_tbl = u32::from_le_bytes([data[20], data[21], data[22], data[23]]) as usize;

    // Parse BIF entries (12 bytes each)
    let mut bif_filenames = Vec::new();
    for i in 0..bif_count {
        let base = off_file_tbl + i * 12;
        if base + 12 > data.len() { break; }
        let fn_off = u32::from_le_bytes([data[base+4], data[base+5], data[base+6], data[base+7]]) as usize;
        let fn_len = u16::from_le_bytes([data[base+8], data[base+9]]) as usize;
        if fn_off + fn_len <= data.len() {
            let name = std::str::from_utf8(&data[fn_off..fn_off + fn_len]).unwrap_or("").trim_end_matches('\0').to_string();
            // Convert the filename to an absolute path under the data directory
            let path = if name.contains('/') || name.contains('\\') {
                // Some BIF filenames are absolute paths or relative paths
                let clean = name.replace('\\', "/");
                let fname = clean.rsplit('/').next().unwrap_or(&clean);
                root.join("data").join(fname)
            } else {
                root.join("data").join(&name)
            };
            bif_filenames.push(path);
        }
    }

    // Keep track of the bif index offset
    let existing_count = bif_paths.len();
    bif_paths.extend(bif_filenames);

    // Parse key entries (22 bytes each: ResRef(16) + Restype(2) + ResourceID(4))
    for i in 0..key_count {
        let base = off_key_tbl + i * 22;
        if base + 22 > data.len() { break; }
        // ResRef: 16 bytes, null-terminated
        let resref_bytes = &data[base..base + 16];
        let end = resref_bytes.iter().position(|&b| b == 0).unwrap_or(16);
        let resref = String::from_utf8_lossy(&resref_bytes[..end]).trim().to_lowercase();
        if resref.is_empty() { continue; }
        let restype = u16::from_le_bytes([data[base+16], data[base+17]]);
        let resource_id = u32::from_le_bytes([data[base+18], data[base+19], data[base+20], data[base+21]]);
        // resource_id is (bif_index << 20) | resource_index
        let bif_idx_raw = (resource_id >> 20) as usize;
        let resource_idx = resource_id & 0xFFFFF;
        let bif_idx = existing_count + bif_idx_raw;
        lookup.insert((resref, restype), (bif_idx, resource_idx));
    }
}

fn parse_bif_header(data: &[u8], path: &Path) -> Option<BifFile> {
    if data.len() < 20 { return None; }
    let count = u32::from_le_bytes([data[8], data[9], data[10], data[11]]) as usize;
    // Sanity: reject absurdly large entry counts
    if count > 10_000_000 { return None; }
    let var_offset = u32::from_le_bytes([data[16], data[17], data[18], data[19]]) as usize;
    let mut entries = Vec::with_capacity(count.min(1_000_000));
    // Each entry is 12 bytes: id(u32) + offset(u32) + size(u32)
    for i in 0..count {
        let base = var_offset + i * 12;
        if base + 12 > data.len() { break; }
        let offset = u32::from_le_bytes([data[base+4], data[base+5], data[base+6], data[base+7]]);
        let size = u32::from_le_bytes([data[base+8], data[base+9], data[base+10], data[base+11]]);
        // Reject entries with implausible sizes
        if size > 100 * 1024 * 1024 { continue; }
        entries.push(BifEntry { offset, size });
    }
    Some(BifFile { path: path.to_path_buf(), entries })
}

fn read_bif_resource(path: &Path, offset: u32, size: u32) -> Option<Vec<u8>> {
    // Safety: reject implausibly large resources (over 100 MB)
    if size > 100 * 1024 * 1024 { return None; }
    use std::io::{Read, Seek, SeekFrom};
    let mut file = std::fs::File::open(path).ok()?;
    file.seek(SeekFrom::Start(offset as u64)).ok()?;
    let mut buf = vec![0u8; size as usize];
    file.read_exact(&mut buf).ok()?;
    Some(buf)
}
