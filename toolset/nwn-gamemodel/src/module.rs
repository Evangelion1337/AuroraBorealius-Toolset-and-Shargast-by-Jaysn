use std::borrow::Cow;
use std::cell::RefCell;
use std::collections::{HashMap, VecDeque};
use std::path::Path;
use std::sync::Arc;
use crate::{Result, ModelError, resource_types, area::{Area, build_git_gff, reload_from_git}, ResourceManager};

const MAX_CACHED_AREAS: usize = 10;
const MAX_CACHED_TILESETS: usize = 8;

pub struct Module {
    pub path: std::path::PathBuf,
    pub ifo: nwn_gff::GffFile,
    pub name: String,
    pub description: String,
    pub entry_area: String,
    pub on_player_enter: String,
    pub tag: String,
    pub haks: Vec<String>,
    pub modified_area_data: HashMap<String, Vec<u8>>,
    pub raw_git: HashMap<String, Vec<u8>>,
    pub raw_fac: Option<Vec<u8>>,
    pub area_names_list: Vec<String>,
    area_cache: RefCell<AreaCache>,
    tileset_cache: RefCell<HashMap<String, nwn_tileset::Tileset>>,
    tileset_order: RefCell<VecDeque<String>>,
    pub scripts: HashMap<String, Vec<u8>>,
    pub compiled: HashMap<String, Vec<u8>>,
    pub conversations: HashMap<String, Vec<u8>>,
    pub blueprints: HashMap<(String, u16), Vec<u8>>,
    pub modified_tlk: Option<(usize, Vec<u8>)>,
    pub modified_jrl: Option<Vec<u8>>,
    pub erf: Option<nwn_erf::ErfFile>,
    pub resource_manager: ResourceManager,
    pub modified: bool,
    pub hak_index: std::sync::OnceLock<nwn_tileset::HakIndex>,
    pub game_data: Option<crate::game_data::GameData>,
    cached_all_tags: std::cell::RefCell<Option<Vec<String>>>,
    cached_resref_list: std::cell::RefCell<Option<Vec<String>>>,
}

struct AreaCache {
    entries: HashMap<String, Arc<Area>>,
    order: VecDeque<String>,
    max: usize,
}
impl AreaCache {
    fn new(max: usize) -> Self {
        Self { entries: HashMap::new(), order: VecDeque::new(), max }
    }
    fn get(&mut self, key: &str) -> Option<Arc<Area>> {
        if self.entries.contains_key(key) {
            // Move to back (most recently used)
            if let Some(pos) = self.order.iter().position(|k| k == key) {
                self.order.remove(pos);
            }
            self.order.push_back(key.to_string());
            self.entries.get(key).cloned()
        } else {
            None
        }
    }
    fn insert(&mut self, key: String, area: Arc<Area>) {
        if self.entries.contains_key(&key) {
            if let Some(pos) = self.order.iter().position(|k| k == &key) {
                self.order.remove(pos);
            }
        } else if self.entries.len() >= self.max {
            if let Some(old) = self.order.pop_front() {
                self.entries.remove(&old);
            }
        }
        self.order.push_back(key.clone());
        self.entries.insert(key, area);
    }
}
// SAFETY: Module data is heap-owned and accessed from one thread at a time under a Mutex.
// The Rc<FixedSizeString<16>> from nwn-lib-rs is not shared across threads.
unsafe impl Send for Module {}
unsafe impl Sync for Module {}
impl Module {
    pub fn from_bytes(data: &[u8]) -> Result<Self> {
        let erf = nwn_erf::ErfFile::from_bytes(data)?;
        Self::from_erf(std::path::PathBuf::new(), erf)
    }

    pub fn new(name: &str) -> Self {
        let ifo_struct = nwn_gff::Struct {
            id: u32::MAX,
            fields: vec![
                make_field("Mod_Name", nwn_gff::FieldValue::String(name.to_string())),
                make_field("Mod_Tag", nwn_gff::FieldValue::String(name.to_string())),
                make_field("Mod_Entry_Area", nwn_gff::FieldValue::String("".to_string())),
                make_field("Mod_Description", nwn_gff::FieldValue::String("".to_string())),
            ],
        };
        use std::str::FromStr;
        let ifo = nwn_gff::GffFile {
            inner: nwn_lib_rs::gff::Gff {
                file_type: FromStr::from_str("IFO ").unwrap_or_default(),
                file_version: FromStr::from_str("V3.2").unwrap_or_default(),
                root: ifo_struct,
            },
        };
        Self {
            path: std::path::PathBuf::new(),
            ifo,
            name: name.to_string(),
            description: String::new(),
            entry_area: String::new(),
            on_player_enter: String::new(),
            tag: name.to_string(),
            haks: Vec::new(),
            modified_area_data: std::collections::HashMap::new(),
            raw_git: std::collections::HashMap::new(),
            raw_fac: None,
            area_names_list: Vec::new(),
            area_cache: RefCell::new(AreaCache::new(MAX_CACHED_AREAS)),
            tileset_cache: std::cell::RefCell::new(std::collections::HashMap::new()),
            tileset_order: std::cell::RefCell::new(VecDeque::new()),
            scripts: std::collections::HashMap::new(),
            compiled: std::collections::HashMap::new(),
            conversations: std::collections::HashMap::new(),
            blueprints: std::collections::HashMap::new(),
            modified_tlk: None,
            modified_jrl: None,
            erf: None,
            resource_manager: crate::ResourceManager::new(),
            modified: false,
            hak_index: std::sync::OnceLock::new(),
            game_data: None,
            cached_all_tags: std::cell::RefCell::new(None),
            cached_resref_list: std::cell::RefCell::new(None),
        }
    }

    pub fn new_empty_area(&mut self, name: &str, tileset: &str, w: i32, h: i32) -> String {
        let resref = name.to_string().to_uppercase();
        let are_struct = nwn_gff::Struct {
            id: u32::MAX,
            fields: vec![
                make_field("Area_Name", nwn_gff::FieldValue::String(name.to_string())),
                make_field("Tag", nwn_gff::FieldValue::String(name.to_string())),
                make_field("Width", nwn_gff::FieldValue::Int(w)),
                make_field("Height", nwn_gff::FieldValue::Int(h)),
                make_field("Tileset", nwn_gff::FieldValue::ResRef(tileset.to_string())),
                make_field("Tile_List", nwn_gff::FieldValue::List(nwn_gff::list_from_vec(Vec::new()))),
            ],
        };
        use std::str::FromStr;
        let are_gff = nwn_gff::GffFile {
            inner: nwn_lib_rs::gff::Gff {
                file_type: FromStr::from_str("ARE ").unwrap_or_default(),
                file_version: FromStr::from_str("V3.2").unwrap_or_default(),
                root: are_struct,
            },
        };
        let data = are_gff.to_bytes();
        let key = resref.clone();
        self.modified_area_data.insert(key.to_lowercase(), data);
        if !self.area_names_list.contains(&key) {
            self.area_names_list.push(key.clone());
        }
        // Create empty GIT
        let git_struct = nwn_gff::Struct {
            id: u32::MAX,
            fields: vec![],
        };
        let git_gff = nwn_gff::GffFile {
            inner: nwn_lib_rs::gff::Gff {
                file_type: FromStr::from_str("GIT ").unwrap_or_default(),
                file_version: FromStr::from_str("V3.2").unwrap_or_default(),
                root: git_struct,
            },
        };
        let git_bytes = git_gff.to_bytes();
        self.raw_git.insert(key.to_lowercase(), git_bytes);
        self.modified = true;
        resref
    }

    pub fn open(path: impl AsRef<Path>) -> Result<Self> {
        let path = path.as_ref().to_path_buf();
        let erf = nwn_erf::ErfFile::open(&path)?;
        let module = Self::from_erf(path, erf)?;
        if !module.haks.is_empty() {
            let missing = check_missing_haks(&module.haks, &module.path);
            if !missing.is_empty() {
                return Err(ModelError::MissingHaks(missing));
            }
        }
        Ok(module)
    }

    pub fn from_erf(path: std::path::PathBuf, erf: nwn_erf::ErfFile) -> Result<Self> {
        let ifo_data = erf.get("module", resource_types::IFO)
            .or_else(|| erf.get("Module", resource_types::IFO))
            .ok_or_else(|| ModelError::NotFound("module.ifo in MOD".into()))?;
        let ifo = nwn_gff::GffFile::from_bytes(&ifo_data)?;

        let name = ifo.get_string("Mod_Name").unwrap_or_default();
        let description = ifo.get_string("Mod_Description").unwrap_or_default();
        let entry_area = ifo.get_string("Mod_Entry_Area").unwrap_or_default();
        let on_player_enter = ifo.get_string("Mod_OnPlayerEnter").unwrap_or_default();
        let tag = ifo.get_string("Mod_Tag").unwrap_or_default();

        let mut haks = Vec::new();
        if let Some(nwn_gff::FieldValue::List(list)) = ifo.root().find("Mod_HakList") {
            for entry in list.iter() {
                if let Some(field) = entry.find("Mod_Hak") {
                    if let nwn_gff::FieldValue::ResRef(s) = field {
                        haks.push(s.clone());
                    } else if let nwn_gff::FieldValue::String(s) = field {
                        haks.push(s.clone());
                    }
                }
            }
        }
        let mut area_names_list = Vec::new();
        let mut scripts = HashMap::new();
        let mut conversations = HashMap::new();
        let mut resource_manager = ResourceManager::new();

        for r in &erf.inner.resources {
            let name = r.file_name.to_string().trim().to_string();
            match r.resource_type {
                t if t == resource_types::ARE => {
                    area_names_list.push(name);
                }
                t if t == resource_types::NSS => {
                    if let nwn_lib_rs::erf::ResourceData::Buffer(buf) = &r.data {
                        scripts.insert(name, buf.clone());
                    }
                }
                t if t == resource_types::DLG => {
                    if let nwn_lib_rs::erf::ResourceData::Buffer(buf) = &r.data {
                        conversations.insert(name, buf.clone());
                    }
                }
                t if t == resource_types::TWO_DA => {
                    if let nwn_lib_rs::erf::ResourceData::Buffer(buf) = &r.data {
                        if let Ok(s) = std::str::from_utf8(buf) {
                            let _ = resource_manager.load_2da(&name, s);
                        }
                    }
                }
                _ => {}
            }
        }

        if let Some(tlk_data) = erf.get("dialog", resource_types::TLK)
            .or_else(|| erf.get("Dialog", resource_types::TLK))
        {
            if let Ok(tlk) = nwn_tlk::TlkFile::from_bytes(&tlk_data) {
                resource_manager.tlks.push(tlk);
            }
        }

        Ok(Self {
            path,
            ifo,
            name,
            description,
            entry_area,
            on_player_enter,
            tag,
            haks,
            modified_area_data: HashMap::new(),
            raw_git: HashMap::new(),
            raw_fac: None,
            area_names_list,
            area_cache: RefCell::new(AreaCache::new(MAX_CACHED_AREAS)),
            tileset_cache: RefCell::new(HashMap::new()),
            tileset_order: RefCell::new(VecDeque::new()),
            scripts,
            compiled: std::collections::HashMap::new(),
            conversations,
            blueprints: std::collections::HashMap::new(),
            modified_tlk: None,
            modified_jrl: None,
            erf: Some(erf),
            resource_manager,
            modified: false,
            hak_index: std::sync::OnceLock::new(),
            game_data: crate::game_data::GameData::new(),
            cached_all_tags: std::cell::RefCell::new(None),
            cached_resref_list: std::cell::RefCell::new(None),
        })
    }

    pub fn area_names(&self) -> &[String] {
        &self.area_names_list
    }

    pub fn num_areas(&self) -> usize {
        self.area_names_list.len()
    }

    pub fn preload_areas(&self) {
        // No-op: areas are loaded on-demand via get_area()
    }

    fn raw_area_data(&self, name: &str) -> Option<Cow<'_, [u8]>> {
        let name_trim = name.trim();
        let name_lower = name_trim.to_lowercase();
        if let Some(data) = self.modified_area_data.get(&name_lower) {
            return Some(Cow::Owned(data.clone()));
        }
        self.erf.as_ref()
            .and_then(|erf| erf.get_slice(name_trim, resource_types::ARE)
                .map(Cow::Borrowed)
                .or_else(|| {
                    let upper = name_trim.to_uppercase();
                    erf.get_slice(&upper, resource_types::ARE).map(Cow::Borrowed)
                }))
    }

    pub fn preload_tilesets(&self) {
        let mut unique_tilesets: Vec<String> = Vec::new();
        for name in &self.area_names_list {
            if let Some(raw_data) = self.raw_area_data(name) {
                if let Ok(gff) = nwn_gff::GffFile::from_bytes(&raw_data) {
                    if let Some(nwn_gff::FieldValue::ResRef(ts)) = gff.root().find("Tileset") {
                        let key = ts.to_lowercase();
                        if !unique_tilesets.iter().any(|k| k == &key) && !self.tileset_cache.borrow().contains_key(&key) {
                            unique_tilesets.push(key);
                        }
                    }
                }
            }
        }
        if unique_tilesets.is_empty() {
            return;
        }
        eprintln!("TRACE: preloading {} unique tilesets", unique_tilesets.len());
        let set_type = nwn_lib_rs::erf::ResourceType::Set as u16;
        use rayon::prelude::*;
        // Only the module-ERF check runs in parallel (zero-copy, no I/O).
        // The fallback (find_and_load_tileset, which opens hak files from disk)
        // is serialized via a Mutex so threads don't collide on memory.
        let fallback_lock = std::sync::Mutex::new(());
        let results: Vec<_> = unique_tilesets.par_iter().map(|ts_key| {
            if let Some(ref erf) = self.erf {
                if let Some(data) = erf.get(ts_key, set_type) {
                    if let Ok(ts) = nwn_tileset::Tileset::from_bytes(ts_key, &data) {
                        return (ts_key.clone(), Some(ts));
                    }
                }
            }
            let _guard = fallback_lock.lock().unwrap();
            match nwn_tileset::find_and_load_tileset(ts_key, &self.path, &self.haks) {
                Ok(Some(ts)) => (ts_key.clone(), Some(ts)),
                _ => (ts_key.clone(), None),
            }
        }).collect();
        for (key, ts) in results {
            if let Some(ts) = ts {
                self.tileset_cache.borrow_mut().insert(key, ts);
            }
        }
    }

    pub fn get_area(&self, name: &str) -> Option<Arc<Area>> {
        {
            let mut cache = self.area_cache.borrow_mut();
            if let Some(area) = cache.get(name) {
                return Some(area);
            }
        }

        let raw_data = self.raw_area_data(name)?;
        let erf = self.erf.as_ref()?;

        let mut area = if let Ok(are_gff) = nwn_gff::GffFile::from_bytes(&raw_data) {
            Area::load_from_gff(&are_gff, name.to_string(), erf).ok()?
        } else {
            return None;
        };

        // Load GIT data (first check modified cache, then ERF)
        let name_trim = name.trim();
        let name_lower = name_trim.to_lowercase();
        let git_bytes = self.raw_git.get(&name_lower).cloned()
            .or_else(|| {
                self.erf.as_ref().and_then(|erf| {
                    erf.get(name_trim, resource_types::GIT)
                        .or_else(|| erf.get(&name_trim.to_uppercase(), resource_types::GIT))
                })
            });
        if let Some(ref data) = git_bytes {
            if let Ok(git_gff) = nwn_gff::GffFile::from_bytes(data) {
                reload_from_git(&mut area, &git_gff);
            }
        }

        // Evict least recently used tileset if needed
        if !area.tileset.is_empty() {
            let ts_key = area.tileset.to_lowercase();
            if !self.tileset_cache.borrow().contains_key(&ts_key) {
                // Evict oldest tileset if cache is too large
                {
                    let mut order = self.tileset_order.borrow_mut();
                    if order.len() >= MAX_CACHED_TILESETS {
                        if let Some(old) = order.pop_front() {
                            self.tileset_cache.borrow_mut().remove(&old);
                        }
                    }
                }
                match nwn_tileset::find_and_load_tileset(&area.tileset, &self.path, &self.haks) {
                    Ok(Some(ts)) => {
                        eprintln!("Loaded tileset '{}' with {} tile models", area.tileset, ts.tiles.len());
                        self.tileset_cache.borrow_mut().insert(ts_key.clone(), ts);
                        self.tileset_order.borrow_mut().push_back(ts_key.clone());
                    }
                    _ => {
                        let empty = nwn_tileset::Tileset {
                            name: ts_key.clone(),
                            tiles: std::collections::HashMap::new(),
                        };
                        self.tileset_cache.borrow_mut().insert(ts_key.clone(), empty);
                        self.tileset_order.borrow_mut().push_back(ts_key.clone());
                    }
                }
            } else {
                // Move tileset to back of access order
                let mut order = self.tileset_order.borrow_mut();
                if let Some(pos) = order.iter().position(|k| k == &ts_key) {
                    order.remove(pos);
                    order.push_back(ts_key.clone());
                }
            }
            if let Some(ts) = self.tileset_cache.borrow().get(&ts_key) {
                for tile in &area.tiles {
                    area.tile_models.push(
                        ts.tile_model(tile.id as u32).map(|s| s.to_string())
                    );
                }
            }
        }

        // Build hak index (reads only ERF headers, not full file data)
        let mod_dir = self.path.parent();
        let mod_dir_path = mod_dir.unwrap_or(Path::new("."));
        let hak_index = nwn_tileset::HakIndex::new(mod_dir_path, &self.haks);

        for p in &mut area.placeables {
            p.model_name = if p.appearance >= 0 {
                let mut name = nwn_tileset::lookup_placeable_model(p.appearance, &[erf]);
                if name.is_none() {
                    name = hak_index.parse_2da_across_haks("placeables", p.appearance, "ModelName", mod_dir_path);
                }
                name
            } else { None };
            // Fall back to .utp template ModelName (ERF → haks → game data)
            if p.model_name.is_none() || p.model_name.as_deref() == Some("USER") {
                let utp_data = erf.get(&p.resref, resource_types::UTP)
                    .or_else(|| hak_index.get_resource_from_path(&p.resref, resource_types::UTP, mod_dir_path))
                    .or_else(|| {
                        let dir = nwn_tileset::game_data_dir()?;
                        let r = nwnrs_types::resman::ResRef::new(
                            p.resref.to_lowercase(),
                            nwnrs_types::resman::ResType(resource_types::UTP),
                        ).ok()?;
                        nwn_tileset::load_resource_from_key(&r, &dir).ok().flatten()
                    });
                if let Some(data) = utp_data {
                    if let Ok(gff) = nwn_gff::GffFile::from_bytes(&data) {
                        let utp_model = gff.get_string("ModelName").ok();
                            if utp_model.is_some() && utp_model.as_deref() != Some("USER") {
                                    p.model_name = utp_model;
                                }
                    }
                }
            }
            // Last resort: if model name is still missing or "USER", use a base-game placeable model
            if p.model_name.as_deref().map_or(true, |n| n == "USER") {
                let pool = [
                    "PLC_A01", "PLC_A02", "PLC_A03", "PLC_A04", "PLC_A05",
                    "PLC_A06", "PLC_A07", "PLC_A08", "PLC_A09", "PLC_A10",
                    "PLC_B01", "PLC_B02", "PLC_B03", "PLC_B04", "PLC_B05",
                    "PLC_O01", "PLC_O02", "PLC_O03", "PLC_O04", "PLC_O05",
                ];
                let hash: u64 = p.resref.bytes().fold(314159u64, |h, b| h.wrapping_mul(2654435761).wrapping_add(b as u64));
                let idx = (hash as usize) % pool.len();
                p.model_name = Some(pool[idx].to_string());
            }
        }
        for d in &mut area.doors {
            // Search for .utd: module ERF → haks
            let generic_type = {
                let mut gt = erf.get(&d.resref, resource_types::UTD).and_then(|data| {
                    nwn_gff::GffFile::from_bytes(&data).ok()
                        .and_then(|gff| gff.get_int("GenericType").ok())
                });
                if gt.is_none() {
                    // Try haks
                    if let Some(data) = hak_index.get_resource_from_path(&d.resref, resource_types::UTD, mod_dir_path) {
                        if let Ok(gff) = nwn_gff::GffFile::from_bytes(&data) {
                            gt = gff.get_int("GenericType").ok();
                        }
                    }
                }
                gt.or(Some(0))
            };
            d.model_name = nwn_tileset::lookup_door_model(d.appearance, generic_type, &[erf]);
            if d.model_name.is_none() {
                if d.appearance > 0 {
                    d.model_name = hak_index.parse_2da_across_haks("doortypes", d.appearance, "ModelName", mod_dir_path);
                } else if d.appearance == 0 {
                    d.model_name = hak_index.parse_2da_across_haks("genericdoors", generic_type.unwrap_or(0), "ModelName", mod_dir_path);
                }
            }
            // Final fallback: .utd template ModelName
            if d.model_name.is_none() {
                if let Some(data) = erf.get(&d.resref, resource_types::UTD) {
                    if let Ok(gff) = nwn_gff::GffFile::from_bytes(&data) {
                        d.model_name = gff.get_string("ModelName").ok();
                    }
                }
            }
        }
        for c in &mut area.creatures {
            let mut creature_appearance = c.appearance;
            if creature_appearance < 0 {
                // Try .utc from module ERF → haks → game data
                let utc_data = erf.get(&c.resref, resource_types::UTC)
                    .or_else(|| hak_index.get_resource_from_path(&c.resref, resource_types::UTC, mod_dir_path))
                    .or_else(|| {
                        let dir = nwn_tileset::game_data_dir()?;
                        let r = nwnrs_types::resman::ResRef::new(
                            c.resref.to_lowercase(),
                            nwnrs_types::resman::ResType(resource_types::UTC),
                        ).ok()?;
                        nwn_tileset::load_resource_from_key(&r, &dir).ok().flatten()
                    });
                if let Some(data) = utc_data {
                    if let Ok(gff) = nwn_gff::GffFile::from_bytes(&data) {
                        creature_appearance = gff.get_int("Appearance").unwrap_or(-1);
                        // If still no appearance, try ModelName directly from .utc
                        if creature_appearance < 0 {
                            if let Ok(m) = gff.get_string("ModelName") {
                                c.model_name = Some(m);
                            }
                        }
                    }
                }
            }
            if c.model_name.is_none() {
                // If creature_appearance was -1 (no appearance data), try default appearance 0
                if creature_appearance < 0 {
                    creature_appearance = 0;
                }
                let mut name = nwn_tileset::lookup_creature_model(creature_appearance, &[erf]);
                if name.is_none() {
                    name = hak_index.parse_2da_across_haks("appearance", creature_appearance, "ModelName", mod_dir_path);
                    if name.is_none() {
                        name = hak_index.find_creature_across_haks(creature_appearance, mod_dir_path);
                    }
                }
                // Final fallback: use hash of resref to pick a diverse model
                if name.as_deref().map_or(true, |n| n.is_empty() || n.len() <= 2) {
                    let pool = [
                        "c_gnoll", "c_goblinx", "c_basilisk", "c_cat_mpanth",
                        "c_direrat", "c_rat", "c_spidgiant", "c_wagn2",
                        "c_wagn3", "c_behold", "c_jelly", "c_wingbat",
                        "c_wingbut", "c_wyrmlblk", "c_drider", "c_manticore",
                    ];
                    let hash: u64 = c.resref.bytes().fold(314159u64, |h, b| h.wrapping_mul(2654435761).wrapping_add(b as u64));
                    let idx = (hash as usize) % pool.len();
                    name = Some(pool[idx].to_string());
                }
                c.model_name = name;
            }
        }



        let arc = Arc::new(area);
        self.area_cache.borrow_mut().insert(name.to_string(), arc.clone());
        Some(arc)
    }

    pub fn get_area_mut(&mut self, _name: &str) -> Option<&mut Area> {
        None
    }

    pub fn script_names(&self) -> Vec<&str> {
        self.scripts.keys().map(|s| s.as_str()).collect()
    }

    pub fn get_script_source(&self, name: &str) -> Option<&str> {
        self.scripts.get(name).and_then(|d| std::str::from_utf8(d).ok())
    }

    pub fn tileset_info(&self, name: &str) -> Option<std::cell::Ref<'_, nwn_tileset::Tileset>> {
        std::cell::Ref::filter_map(self.tileset_cache.borrow(), |c| c.get(name)).ok()
    }

    pub fn conversation_names(&self) -> Vec<&str> {
        self.conversations.keys().map(|s| s.as_str()).collect()
    }

    pub fn update_ncs(&mut self, name: &str, ncs_data: &[u8]) {
        self.compiled.insert(name.to_string(), ncs_data.to_vec());
        self.modified = true;
        self.invalidate_caches();
    }

    pub fn update_2da(&mut self, name: &str, data: &str) {
        let _ = self.resource_manager.load_2da(name, data);
        if let Some(ref mut erf) = self.erf {
            erf.add_resource(name.trim(), resource_types::TWO_DA, data.as_bytes().to_vec());
        }
        self.modified = true;
    }

    pub fn get_conversation(&self, name: &str) -> Option<crate::Conversation> {
        let data = self.conversations.get(name)?;
        let gff = nwn_gff::GffFile::from_bytes(data).ok()?;
        crate::Conversation::from_gff(&gff).ok()
    }

    pub fn invalidate_caches(&self) {
        *self.cached_all_tags.borrow_mut() = None;
        *self.cached_resref_list.borrow_mut() = None;
    }

    /// Evict all CPU-side memory caches (areas, tilesets, tag/resref caches) to free RAM.
    pub fn evict_memory_caches(&self) {
        self.area_cache.borrow_mut().entries.clear();
        self.area_cache.borrow_mut().order.clear();
        self.tileset_cache.borrow_mut().clear();
        self.tileset_order.borrow_mut().clear();
        *self.cached_all_tags.borrow_mut() = None;
        *self.cached_resref_list.borrow_mut() = None;
    }

    pub fn update_area_git(&mut self, resref: &str, area: &Area) {
        let gff = build_git_gff(area);
        let data = gff.to_bytes();
        self.raw_git.insert(resref.trim().to_lowercase(), data);
        self.modified = true;
        self.invalidate_caches();
    }

    /// Resolve model name for a creature by appearance ID.
    /// Uses the same chain as area loading: ERF lookup → hak 2da → .utc → fallback pool.
    pub fn resolve_creature_model(&self, appearance: i32, resref: &str) -> Option<String> {
        let erf = self.erf.as_ref()?;
        let mut creature_appearance = appearance;
        if creature_appearance < 0 {
            let utc_data = erf.get(resref, resource_types::UTC)
                .or_else(|| {
                    let mod_dir = self.path.parent()?;
                    self.get_hak_index().get_resource_from_path(resref, resource_types::UTC, mod_dir)
                })
                .or_else(|| {
                    let dir = nwn_tileset::game_data_dir()?;
                    let r = nwnrs_types::resman::ResRef::new(
                        resref.to_lowercase(),
                        nwnrs_types::resman::ResType(resource_types::UTC),
                    ).ok()?;
                    nwn_tileset::load_resource_from_key(&r, &dir).ok().flatten()
                });
            if let Some(data) = utc_data {
                if let Ok(gff) = nwn_gff::GffFile::from_bytes(&data) {
                    creature_appearance = gff.get_int("Appearance").unwrap_or(-1);
                    if creature_appearance < 0 {
                        if let Ok(m) = gff.get_string("ModelName") {
                            return Some(m);
                        }
                    }
                }
            }
        }
        if creature_appearance < 0 {
            creature_appearance = 0;
        }
        let mut name = nwn_tileset::lookup_creature_model(creature_appearance, &[erf]);
        if name.is_none() {
            let hak_index = self.get_hak_index();
            if let Some(mod_dir) = self.path.parent() {
                name = hak_index.parse_2da_across_haks("appearance", creature_appearance, "ModelName", mod_dir);
                if name.is_none() {
                    name = hak_index.find_creature_across_haks(creature_appearance, mod_dir);
                }
            }
        }
        if name.as_deref().map_or(true, |n| n.is_empty() || n.len() <= 2) {
            // Also try the appearance 2da from resource_manager
            if let Some(two_da) = self.resource_manager.get_2da("appearance") {
                let model = two_da.get_cell_by_label(creature_appearance as usize, "Model");
                if let Some(m) = model {
                    if !m.is_empty() && m.len() > 2 {
                        return Some(m.to_string());
                    }
                }
            }
            let pool = [
                "c_gnoll", "c_goblinx", "c_basilisk", "c_cat_mpanth",
                "c_direrat", "c_rat", "c_spidgiant", "c_wagn2",
                "c_wagn3", "c_behold", "c_jelly", "c_wingbat",
                "c_wingbut", "c_wyrmlblk", "c_drider", "c_manticore",
            ];
            let hash: u64 = resref.bytes()
                .chain(appearance.to_le_bytes().iter().copied())
                .fold(314159u64, |h, b| h.wrapping_mul(2654435761).wrapping_add(b as u64));
            Some(pool[(hash as usize) % pool.len()].to_string())
        } else { name }
    }

    /// Resolve model name for a placeable by appearance ID.
    /// Uses: ERF lookup → hak 2da → .utp → fallback pool.
    pub fn resolve_placeable_model(&self, appearance: i32, resref: &str) -> Option<String> {
        let erf = self.erf.as_ref()?;
        let mut name = if appearance >= 0 {
            nwn_tileset::lookup_placeable_model(appearance, &[erf])
        } else { None };
        if name.as_ref().map_or(true, |n| n == "USER" || n.is_empty()) {
            let hak_index = self.get_hak_index();
            if let Some(mod_dir) = self.path.parent() {
                name = hak_index.parse_2da_across_haks("placeables", appearance, "ModelName", mod_dir);
            }
        }
        if name.as_ref().map_or(true, |n| n == "USER" || n.is_empty()) {
            if let Some(data) = erf.get(resref, resource_types::UTP)
                .or_else(|| {
                    let hak_index = self.get_hak_index();
                    let mod_dir = self.path.parent()?;
                    hak_index.get_resource_from_path(resref, resource_types::UTP, mod_dir)
                })
            {
                if let Ok(gff) = nwn_gff::GffFile::from_bytes(&data) {
                    if let Ok(m) = gff.get_string("ModelName") {
                        return Some(m);
                    }
                }
            }
        }
        if name.as_ref().map_or(true, |n| n == "USER" || n.is_empty()) {
            let pool = [
                "PLC_A01", "PLC_A02", "PLC_A03", "PLC_A04", "PLC_A05",
                "PLC_A06", "PLC_A07", "PLC_A08", "PLC_A09", "PLC_A10",
                "PLC_B01", "PLC_B02", "PLC_B03", "PLC_B04", "PLC_B05",
                "PLC_O01", "PLC_O02", "PLC_O03", "PLC_O04", "PLC_O05",
            ];
            let hash: u64 = resref.bytes().fold(314159u64, |h, b| h.wrapping_mul(2654435761).wrapping_add(b as u64));
            Some(pool[(hash as usize) % pool.len()].to_string())
        } else { name }
    }

    /// Resolve model name for a door by appearance ID.
    /// Uses: ERF lookup → hak 2da → .utd → fallback pool.
    pub fn resolve_door_model(&self, appearance: i32, resref: &str) -> Option<String> {
        let erf = self.erf.as_ref()?;
        let mut generic_type: Option<i32> = None;
        let mut name = if appearance > 0 {
            nwn_tileset::lookup_door_model(appearance, None, &[erf])
        } else { None };
        if name.is_none() {
            let hak_index = self.get_hak_index();
            if let Some(mod_dir) = self.path.parent() {
                name = hak_index.parse_2da_across_haks("doortypes", appearance, "ModelName", mod_dir);
                if name.is_none() && appearance <= 0 {
                    if let Some(data) = erf.get(resref, resource_types::UTD)
                        .or_else(|| {
                            let hak_index = self.get_hak_index();
                            let mod_dir = self.path.parent()?;
                            hak_index.get_resource_from_path(resref, resource_types::UTD, mod_dir)
                        })
                    {
                        if let Ok(gff) = nwn_gff::GffFile::from_bytes(&data) {
                            let ga = gff.get_int("GenericType").ok();
                            if let Some(g) = ga { generic_type = Some(g); }
                            name = gff.get_string("ModelName").ok();
                            if name.is_none() && appearance <= 0 {
                                name = if let Some(g) = generic_type {
                                    hak_index.parse_2da_across_haks("genericdoors", g, "ModelName", mod_dir)
                                } else { None };
                            }
                        }
                    }
                }
            }
        }
        if name.as_ref().map_or(true, |n| n.is_empty()) {
            let pool = ["doortype_home001", "doortype_home011", "doortype_castle002", "doortype_keep002"];
            let hash: u64 = resref.bytes().fold(314159u64, |h, b| h.wrapping_mul(2654435761).wrapping_add(b as u64));
            Some(pool[(hash as usize) % pool.len()].to_string())
        } else { name }
    }

    pub fn has_fac(&self) -> bool {
        self.raw_fac.is_some()
    }

    pub fn resource_exists(&self, resref: &str, restype: u16) -> bool {
        if restype == resource_types::FAC {
            return self.raw_fac.is_some();
        }
        if restype == resource_types::NSS {
            return self.scripts.contains_key(resref);
        }
        if restype == resource_types::DLG {
            return self.conversations.contains_key(resref);
        }
        if let Some(ref erf) = self.erf {
            erf.get(resref, restype).is_some()
        } else {
            false
        }
    }

    pub fn update_fac(&mut self, data: Vec<u8>) {
        self.raw_fac = Some(data);
        self.modified = true;
    }

    pub fn update_conversation(&mut self, name: &str, convo: &crate::Conversation) {
        let gff = convo.to_gff();
        let data = gff.to_bytes();
        self.conversations.insert(name.to_string(), data);
        self.modified = true;
        self.invalidate_caches();
    }

    pub fn update_blueprint(&mut self, resref: &str, restype: u16, data: Vec<u8>) {
        let key = (resref.trim().to_lowercase(), restype);
        self.blueprints.insert(key, data);
        self.modified = true;
        self.invalidate_caches();
    }

    pub fn update_tlk(&mut self, tlk_index: usize, data: Vec<u8>) {
        self.modified_tlk = Some((tlk_index, data));
        self.modified = true;
    }

    pub fn update_jrl(&mut self, data: Vec<u8>) {
        self.modified_jrl = Some(data);
        self.modified = true;
    }

    pub fn update_script(&mut self, name: &str, source: &str) {
        self.scripts.insert(name.to_string(), source.as_bytes().to_vec());
        self.modified = true;
        self.invalidate_caches();
    }

    pub fn all_tags(&self) -> Vec<String> {
        let mut cached = self.cached_all_tags.borrow_mut();
        if let Some(ref tags) = *cached {
            return tags.clone();
        }
        fn extract_tags_from_list(list: &[nwn_gff::Struct], tags: &mut std::collections::HashSet<String>) {
            for entry in list {
                if let Some(nwn_gff::FieldValue::String(tag)) = entry.find("Tag") {
                    if !tag.is_empty() {
                        tags.insert(tag.clone());
                    }
                }
            }
        }
        let mut tags = std::collections::HashSet::new();
        for (_, data) in &self.raw_git {
            if let Ok(gff) = nwn_gff::GffFile::from_bytes(data) {
                for list_name in &["Creature_List", "Creature List", "Door_List", "Door List",
                                   "Placeable_List", "Placeable List", "Trigger_List", "TriggerList",
                                   "Waypoint_List", "WaypointList", "Encounter_List", "Encounter List",
                                   "SoundList", "Sound_List", "LightList", "Light_List"] {
                    if let Some(fv) = gff.root().find(list_name) {
                        if let nwn_gff::FieldValue::List(list) = fv {
                            extract_tags_from_list(list, &mut tags);
                        }
                    }
                }
            }
        }
        let mut sorted: Vec<String> = tags.into_iter().collect();
        sorted.sort();
        *cached = Some(sorted.clone());
        sorted
    }

    pub fn all_resref_names(&self) -> Vec<String> {
        let mut cached = self.cached_resref_list.borrow_mut();
        if let Some(ref names) = *cached {
            return names.clone();
        }
        let mut names: Vec<String> = self.resource_list().iter()
            .map(|(r, _)| r.clone())
            .collect();
        names.sort();
        names.dedup();
        *cached = Some(names.clone());
        names
    }

    pub fn update_area_are(&mut self, resref: &str, area: &Area) {
        let key = resref.trim().to_lowercase();
        let raw_data = self.raw_area_data(resref.trim()).unwrap_or_default();
        let mut gff = match nwn_gff::GffFile::from_bytes(&raw_data) {
            Ok(g) => g,
            Err(_) => return,
        };
        crate::area::update_are_tiles(&mut gff, area);
        crate::area::update_are_lighting(&mut gff, area);
        crate::area::update_are_walkmesh_walls(&mut gff, area);
        crate::area::update_are_tile_tints(&mut gff, area);
        let data = gff.to_bytes();
        self.modified_area_data.insert(key.clone(), data);
        // Invalidate area cache so get_area() reloads from the override
        self.area_cache.borrow_mut().entries.remove(&key);
        self.area_cache.borrow_mut().order.retain(|k| k != &key);
        self.modified = true;
    }

    /// Returns a list of all (resref, restype) available in the module,
    /// combining tracked resources with original ERF resources.
    pub fn resource_list(&self) -> Vec<(String, u16)> {
        let mut seen = std::collections::HashSet::new();
        let mut list = Vec::new();

        // Tracked resources (TLK, JRL)
        if self.modified_tlk.is_some() {
            let key = ("dialog".to_string(), resource_types::TLK);
            seen.insert(key);
            list.push(("dialog".to_string(), resource_types::TLK));
        }
        if self.modified_jrl.is_some() {
            let key = ("journal".to_string(), resource_types::JRL);
            seen.insert(key);
            list.push(("journal".to_string(), resource_types::JRL));
        }

        // Tracked resources take precedence
        for ((name, rt), _) in &self.blueprints {
            let key = (name.clone(), *rt);
            if seen.insert(key) { list.push((name.clone(), *rt)); }
        }
        for name in self.scripts.keys() {
            let key = (name.to_lowercase(), resource_types::NSS);
            if seen.insert(key) { list.push((name.clone(), resource_types::NSS)); }
        }
        for name in self.compiled.keys() {
            let key = (name.to_lowercase(), resource_types::NCS);
            if seen.insert(key) { list.push((name.clone(), resource_types::NCS)); }
        }
        for name in self.conversations.keys() {
            let key = (name.to_lowercase(), resource_types::DLG);
            if seen.insert(key) { list.push((name.clone(), resource_types::DLG)); }
        }
        for name in &self.area_names_list {
            let key = (name.to_lowercase(), resource_types::ARE);
            if seen.insert(key) { list.push((name.clone(), resource_types::ARE)); }
        }
        for (name, _) in &self.modified_area_data {
            let key = (name.to_lowercase(), resource_types::ARE);
            if seen.insert(key) { list.push((name.clone(), resource_types::ARE)); }
        }
        for (name, _) in &self.raw_git {
            let key = (name.to_lowercase(), resource_types::GIT);
            if seen.insert(key) { list.push((name.clone(), resource_types::GIT)); }
        }
        if self.raw_fac.is_some() {
            let key = ("faction".to_string(), resource_types::FAC);
            if seen.insert(key) { list.push(("faction".to_string(), resource_types::FAC)); }
        }

        // Remaining ERF resources
        if let Some(ref erf) = self.erf {
            for r in &erf.inner.resources {
                let rname = r.file_name.to_string().trim().to_string();
                let key = (rname.to_lowercase(), r.resource_type);
                if seen.insert(key) {
                    list.push((rname.clone(), r.resource_type));
                }
            }
        }

        // Hak resources (not already seen)
        let hak_index = self.get_hak_index();
        for (resref, restype) in hak_index.all_resources() {
            let key = (resref.to_lowercase(), restype);
            if seen.insert(key) {
                list.push((resref.clone(), restype));
            }
        }

        list.sort_by(|a, b| a.0.to_lowercase().cmp(&b.0.to_lowercase()));
        list
    }

    /// Get raw data for a resource by (resref, restype).
    /// Returns tracked data (scripts, conversations, etc.) or original ERF data.
    pub fn get_resource_data(&self, resref: &str, restype: u16) -> Option<Vec<u8>> {
        let name = resref.trim().to_string();
        let name_lower = name.to_lowercase();

        let erf_fallback = |n: &str| -> Option<Vec<u8>> {
            let nl = n.trim().to_lowercase();
            self.erf.as_ref().and_then(|erf| {
                let idx = erf.inner.resources.iter().position(|r|
                    r.file_name.to_string().trim().to_lowercase() == nl && r.resource_type == restype
                )?;
                erf.read_resource_data(&erf.inner.resources[idx])
            })
        };

        let hak_fallback = |n: &str| -> Option<Vec<u8>> {
            let mod_dir = self.path.parent()?;
            self.get_hak_index().get_resource(n, restype, mod_dir)
        };

        let result = match restype {
            t if t == resource_types::NSS => {
                self.scripts.get(&name).cloned()
                    .or_else(|| erf_fallback(&name))
            }
            t if t == resource_types::NCS => {
                self.compiled.get(&name).cloned()
                    .or_else(|| erf_fallback(&name))
            }
            t if t == resource_types::DLG => {
                self.conversations.get(&name).cloned()
                    .or_else(|| erf_fallback(&name))
            }
            t if t == resource_types::ARE => {
                let nl = name.trim().to_lowercase();
                self.modified_area_data.get(&nl)
                    .cloned()
                    .or_else(|| erf_fallback(&name))
            }
            t if t == resource_types::GIT => {
                self.raw_git.get(&name_lower).cloned()
                    .or_else(|| erf_fallback(&name))
            }
            t if t == resource_types::FAC => {
                self.raw_fac.clone()
                    .or_else(|| erf_fallback(&name))
                    .or_else(|| {
                        if name.to_lowercase() == "faction" {
                            erf_fallback("repute")
                        } else if name.to_lowercase() == "repute" {
                            erf_fallback("faction")
                        } else {
                            None
                        }
                    })
            }
            t if t == resource_types::JRL => {
                self.modified_jrl.clone()
                    .or_else(|| erf_fallback(&name))
                    .or_else(|| {
                        if name.to_lowercase() == "journal" {
                            erf_fallback("module")
                        } else if name.to_lowercase() == "module" {
                            erf_fallback("journal")
                        } else {
                            None
                        }
                    })
            }
            t if t == resource_types::TLK => {
                self.modified_tlk.as_ref().map(|(_, d)| d.clone())
                    .or_else(|| erf_fallback(&name))
            }
            _ => {
                self.blueprints.get(&(name_lower, restype)).cloned()
                    .or_else(|| erf_fallback(&name))
            }
        };
        result.or_else(|| hak_fallback(&name)).or_else(|| {
            if restype == resource_types::WAV || restype == resource_types::BMU {
                let res = self.game_data.as_ref().and_then(|gd| gd.get_resource(&name, restype));
                if res.is_some() { eprintln!("get_resource_data: found via game_data"); }
                else { eprintln!("get_resource_data: game_data lookup failed for '{}.{}'", name, restype); }
                res
            } else {
                None
            }
        })
    }

    /// Get or create the hak index (lazily initialized).
    pub fn get_hak_index(&self) -> &nwn_tileset::HakIndex {
        self.hak_index.get_or_init(|| {
            let mod_dir = self.path.parent().unwrap_or(Path::new("."));
            nwn_tileset::HakIndex::new(mod_dir, &self.haks)
        })
    }

    /// List available blueprint resrefs for a given 2DA table (e.g. "placeables", "creatures").
    pub fn blueprint_resrefs(&self, two_da_name: &str) -> Vec<(String, String)> {
        let mod_dir = self.path.parent().unwrap_or(Path::new("."));
        let hak_index = self.get_hak_index();
        let result = hak_index.list_2da_column(two_da_name, "Label", mod_dir);
        if !result.is_empty() { return result; }
        // Fallback: try alternative 2DA names for known types
        match two_da_name {
            "creatures" => hak_index.list_2da_column("appearance", "Label", mod_dir),
            _ => result,
        }
    }

    /// Load relevant 2DA files from haks into the resource manager for the blueprint palette.
    pub fn load_hak_2das(&mut self) {
        let mod_dir = self.path.parent().unwrap_or(Path::new("."));
        let hak_index = nwn_tileset::HakIndex::new(mod_dir, &self.haks);
        for name in &["placeables", "doortypes", "baseitems", "appearance", "creatures", "genericdoors", "triggers", "waypoints", "encounters", "iprp", "armor", "weapons"] {
            if self.resource_manager.get_2da(name).is_some() { continue; }
            if let Some(data) = hak_index.get_resource(name, 2017, mod_dir) {
                if let Ok(s) = std::str::from_utf8(&data) {
                    let _ = self.resource_manager.load_2da(name, s);
                }
            } else if let Some(data) = self.game_data.as_ref().and_then(|gd| gd.get_resource(name, 2017)) {
                if let Ok(s) = String::from_utf8(data) {
                    let _ = self.resource_manager.load_2da(name, &s);
                }
            }
        }
    }

    pub fn save(&mut self) -> Result<()> {
        let p = self.path.clone();
        self.save_to(&p)
    }

    pub fn save_to(&mut self, path: &Path) -> Result<()> {
        let path = path.to_path_buf();
        let ext = path.extension().and_then(|e| e.to_str()).unwrap_or("");
        // nwn_lib_rs 0.4.0 to_bytes_head always writes 16-byte resrefs regardless
        // of nwn1 flag. Must use nwn1=true for V1.0 header so parsers expect
        // 16-byte key entries; V1.1 + 16-byte entries corrupts NWN:EE module loading.
        let mut erf = nwn_erf::ErfFile::new(
            if ext == "hak" || ext == "HAK" { "HAK " } else { "MOD " },
            true,
            None,
        );

        // Rebuild module.ifo from stored fields
        let ifo_struct = self.ifo.root_mut();
        if let Some(name_field) = ifo_struct.find_mut("Mod_Name") {
            if let nwn_lib_rs::gff::FieldValue::String(s) = name_field {
                *s = self.name.clone();
            }
        }
        if let Some(desc_field) = ifo_struct.find_mut("Mod_Description") {
            if let nwn_lib_rs::gff::FieldValue::String(s) = desc_field {
                *s = self.description.clone();
            }
        }
        if let Some(entry_field) = ifo_struct.find_mut("Mod_Entry_Area") {
            if let nwn_lib_rs::gff::FieldValue::String(s) = entry_field {
                *s = self.entry_area.clone();
            }
        }
        if let Some(tag_field) = ifo_struct.find_mut("Mod_Tag") {
            if let nwn_lib_rs::gff::FieldValue::String(s) = tag_field {
                *s = self.tag.clone();
            }
        }
        set_or_add_ifo(ifo_struct, "Mod_OnPlayerEnter", nwn_lib_rs::gff::FieldValue::ResRef(self.on_player_enter.clone()));
        // Write IFO
        let ifo_bytes = self.ifo.to_bytes();
        erf.add_resource("module", resource_types::IFO, ifo_bytes);

        // Write scripts (NSS and compiled NCS)
        for (name, data) in &self.scripts {
            erf.add_resource(name, resource_types::NSS, data.clone());
        }
        for (name, data) in &self.compiled {
            erf.add_resource(name, resource_types::NCS, data.clone());
        }

        // Write conversations (DLG)
        for (name, data) in &self.conversations {
            erf.add_resource(name, resource_types::DLG, data.clone());
        }

        // Write areas (ARE) — use modified data for dirty, originals from ERF
        for name in &self.area_names_list {
            let name_lower = name.trim().to_lowercase();
            let are_data = self.modified_area_data.get(&name_lower)
                .cloned()
                .or_else(|| self.erf.as_ref().and_then(|e| e.get(name.trim(), resource_types::ARE)))
                .unwrap_or_default();
            erf.add_resource(name.trim(), resource_types::ARE, are_data);
        }
        for (name, data) in &self.modified_area_data {
            let name_lower = name.trim().to_lowercase();
            if !self.area_names_list.iter().any(|n| n.trim().to_lowercase() == name_lower) {
                erf.add_resource(name.trim(), resource_types::ARE, data.clone());
            }
        }
        // Copy remaining resources from the original ERF
        if let Some(ref src_erf) = self.erf {
            for r in &src_erf.inner.resources {
                let rname = r.file_name.to_string().trim().to_string();
                let rt = r.resource_type;
                // Skip resources we already wrote
                if rt == resource_types::IFO { continue; }
                if rt == resource_types::NSS { continue; }
                if rt == resource_types::NCS { continue; }
                if rt == resource_types::DLG { continue; }
                if rt == resource_types::ARE { continue; }
                // Skip GIT resources that have been modified (written from raw_git)
                if rt == resource_types::GIT && self.raw_git.contains_key(&rname.to_lowercase()) { continue; }
                // Skip FAC if modified
                if rt == resource_types::FAC && self.raw_fac.is_some() { continue; }
                // Skip blueprints that have been modified
                if self.blueprints.contains_key(&(rname.to_lowercase(), rt)) { continue; }
                // Skip TLK if modified
                if rt == resource_types::TLK && self.modified_tlk.is_some() { continue; }
                // Skip JRL if modified
                if rt == resource_types::JRL && self.modified_jrl.is_some() { continue; }
                if let Some(data) = nwn_erf::extract_resource_data(&r.data) {
                    erf.add_resource(&rname, rt, data);
                }
            }
        }

        // Write modified GIT data
        for (name, data) in &self.raw_git {
            erf.add_resource(name, resource_types::GIT, data.clone());
        }

        // Write modified FAC data
        if let Some(ref fac_data) = self.raw_fac {
            erf.add_resource("faction", resource_types::FAC, fac_data.clone());
        }

        // Write modified blueprints
        for ((name, rt), data) in &self.blueprints {
            erf.add_resource(name, *rt, data.clone());
        }

        // Write modified TLK
        if let Some((_, ref tlk_data)) = self.modified_tlk {
            erf.add_resource("dialog", resource_types::TLK, tlk_data.clone());
        }

        // Write modified JRL
        if let Some(ref jrl_data) = self.modified_jrl {
            erf.add_resource("journal", resource_types::JRL, jrl_data.clone());
        }

        let bytes = erf.to_bytes()?;
        std::fs::write(&path, bytes)?;
        self.erf = Some(erf);
        self.path = path;
        self.modified = false;
        Ok(())
    }
}

fn check_missing_haks(haks: &[String], module_path: &Path) -> Vec<String> {
    let mod_dir = module_path.parent().unwrap_or_else(|| Path::new("."));
    let hak_dirs: Vec<std::path::PathBuf> = {
        let mut dirs = Vec::new();
        dirs.push(mod_dir.to_path_buf());
        dirs.push(mod_dir.join("hak"));
        if let Ok(home) = std::env::var("HOME") {
            dirs.push(Path::new(&home).join("Documents/Neverwinter Nights/hak"));
        }
        dirs
    };
    let mut missing = Vec::new();
    for hak in haks {
        let found = hak_dirs.iter().any(|dir| {
            let p = dir.join(format!("{}.hak", hak));
            p.is_file()
        });
        if !found {
            missing.push(hak.clone());
        }
    }
    missing
}

fn make_field(label: &str, value: nwn_gff::FieldValue) -> nwn_gff::Field {
    let fss: nwn_lib_rs::parsing::FixedSizeString<16> = std::str::FromStr::from_str(label).unwrap_or_default();
    nwn_gff::Field { label: std::rc::Rc::new(fss), value }
}

fn set_or_add_ifo(root: &mut nwn_gff::Struct, label: &str, value: nwn_gff::FieldValue) {
    let label_trim = label.trim().to_string();
    if let Some(idx) = root.fields.iter().position(|f| f.label.as_str().trim() == label_trim) {
        root.fields[idx].value = value;
    } else {
        root.fields.push(make_field(label, value));
    }
}

pub use nwn_erf::extract_resource_data;
