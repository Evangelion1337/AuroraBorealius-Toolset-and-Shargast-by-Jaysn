use std::io::Read;

fn main() {
    let path = std::env::args().nth(1).expect("Usage: check_raw <module.mod>");
    let mut file = std::fs::File::open(&path).expect("Failed to open");

    // Read raw header
    let mut hdr = [0u8; 160];
    file.read_exact(&mut hdr).expect("read header");

    let file_type = std::str::from_utf8(&hdr[0..4]).unwrap();
    let file_ver = std::str::from_utf8(&hdr[4..8]).unwrap();
    let locstr_count = u32::from_le_bytes(hdr[8..12].try_into().unwrap());
    let locstr_size = u32::from_le_bytes(hdr[12..16].try_into().unwrap());
    let keys_count = u32::from_le_bytes(hdr[16..20].try_into().unwrap());
    let locstr_off = u32::from_le_bytes(hdr[20..24].try_into().unwrap());
    let keys_off = u32::from_le_bytes(hdr[24..28].try_into().unwrap());
    let res_off = u32::from_le_bytes(hdr[28..32].try_into().unwrap());

    println!("File type: {:?}", file_type);
    println!("File version: {:?}", file_ver);
    println!("LocString count: {}", locstr_count);
    println!("LocString size: {}", locstr_size);
    println!("Keys count: {}", keys_count);
    println!("LocString offset: {}", locstr_off);
    println!("Keys offset: {}", keys_off);
    println!("Resources offset: {}", res_off);

    let has_long = file_ver >= "V1.1";
    let key_size: usize = if has_long { 40 } else { 24 };
    let keys_section_size = keys_count as usize * key_size;
    let res_tbl_size = keys_count as usize * 8;
    let data_start = res_off as usize + res_tbl_size;

    println!("Key entry size: {}", key_size);
    println!("Keys section size: {}", keys_section_size);
    println!("Resource table size: {}", res_tbl_size);
    println!("Data section offset: {}", data_start);

    let file_len = std::fs::metadata(&path).unwrap().len() as usize;
    println!("File size: {} bytes", file_len);

    // Read and dump the first resource table entry
    println!("\nFirst 5 raw resource table entries (at offset {}):", res_off);
    let mut tbl_buf = vec![0u8; 40]; // 5 * 8
    file.seek(std::io::SeekFrom::Start(res_off as u64)).unwrap();
    file.read_exact(&mut tbl_buf).unwrap();
    for i in 0..5 {
        let off = u32::from_le_bytes([tbl_buf[i*8], tbl_buf[i*8+1], tbl_buf[i*8+2], tbl_buf[i*8+3]]);
        let sz = u32::from_le_bytes([tbl_buf[i*8+4], tbl_buf[i*8+5], tbl_buf[i*8+6], tbl_buf[i*8+7]]);
        println!("  [{}] offset={}, size={}", i, off, sz);
    }

    // Check last key entry
    println!("\nLast 3 raw resource table entries (at offset {}+{}*8):", res_off, keys_count - 3);
    let last_start = res_off as usize + (keys_count as usize - 3) * 8;
    file.seek(std::io::SeekFrom::Start(last_start as u64)).unwrap();
    file.read_exact(&mut tbl_buf[..24]).unwrap();
    for i in 0..3 {
        let off = u32::from_le_bytes([tbl_buf[i*8], tbl_buf[i*8+1], tbl_buf[i*8+2], tbl_buf[i*8+3]]);
        let sz = u32::from_le_bytes([tbl_buf[i*8+4], tbl_buf[i*8+5], tbl_buf[i*8+6], tbl_buf[i*8+7]]);
        println!("  [{}] offset={}, size={}", keys_count as usize - 3 + i, off, sz);
    }

    // Check data at some sample non-zero resources
    println!("\nScanning for any non-zero-size raw entries:");
    file.seek(std::io::SeekFrom::Start(res_off as u64)).unwrap();
    let mut tbl_all = vec![0u8; res_tbl_size];
    file.read_exact(&mut tbl_all).unwrap();
    let mut nonzero = Vec::new();
    for i in 0..keys_count as usize {
        let off = u32::from_le_bytes([tbl_all[i*8], tbl_all[i*8+1], tbl_all[i*8+2], tbl_all[i*8+3]]);
        let sz = u32::from_le_bytes([tbl_all[i*8+4], tbl_all[i*8+5], tbl_all[i*8+6], tbl_all[i*8+7]]);
        if sz > 0 {
            nonzero.push((i, off, sz));
        }
    }
    println!("Non-zero entries: {}/{}", nonzero.len(), keys_count);
    for (idx, off, sz) in nonzero.iter().take(10) {
        // read the key name
        let key_pos = keys_off as usize + idx * key_size;
        let name_bytes = &hdr[..]; // dummy
        let mut name_buf = vec![0u8; 16];
        file.seek(std::io::SeekFrom::Start(key_pos as u64)).unwrap();
        file.read_exact(&mut name_buf).unwrap();
        let name = std::str::from_utf8(&name_buf).unwrap_or("???").trim_end_matches('\0');
        println!("  [{}] '{}' offset={}, size={}", idx, name, off, sz);
    }

    // Check: for index 0, what's in the keys section?
    println!("\nFirst 3 key entries (raw 24 bytes each):");
    for i in 0..3 {
        let kpos = keys_off as usize + i * 24;
        file.seek(std::io::SeekFrom::Start(kpos as u64)).unwrap();
        let mut kbuf = [0u8; 24];
        file.read_exact(&mut kbuf).unwrap();
        let name = std::str::from_utf8(&kbuf[..16]).unwrap();
        let resid = u32::from_le_bytes(kbuf[16..20].try_into().unwrap());
        let restype = u16::from_le_bytes(kbuf[20..22].try_into().unwrap());
        println!("  [{}] name={:?} resid={} restype={} pad={:02x?}", i, name, resid, restype, &kbuf[22..24]);
    }

    use std::io::Seek;
}
