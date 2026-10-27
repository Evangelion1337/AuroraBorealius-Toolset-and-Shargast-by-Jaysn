#![allow(incomplete_features)]
#![feature(generic_const_exprs)]
use std::sync::Arc;
use std::sync::atomic::{AtomicUsize, Ordering};
use eframe::egui;
#[cfg(target_arch = "wasm32")]
use wasm_bindgen::prelude::*;
use wgpu;
use nwn_gamemodel::FactionList;
use nwn_tlk::TlkFile;
use nwn_3d::{ObjectType, VisibilityFilter};
use nwn_gamemodel::LightInstance;
use nwn_gamemodel::PropertyBag;
use crate::inspector::{SelectedObject, show_inspector, show_bag_editor};
mod audio;
use audio::AudioSystem;

fn current_rss_kb() -> u64 {
    0
}

fn module_resref_names(module: &nwn_gamemodel::Module) -> Vec<String> {
    module.all_resref_names()
}

fn module_tag_names(module: &nwn_gamemodel::Module) -> Vec<String> {
    module.all_tags()
}

fn get_tile_palette(module: &nwn_gamemodel::Module, tileset: &str) -> Vec<(i32, String)> {
    let tileset_lower = tileset.to_lowercase();
    let two_da_name = format!("tileset_apply_{}", tileset_lower);
    if let Some(table) = module.resource_manager.get_2da(&two_da_name) {
        let entries: Vec<(i32, String)> = (0..table.row_count().min(500))
            .filter_map(|r| {
                let id = table.get_cell_by_label(r, "TileID").and_then(|s| s.parse::<i32>().ok()).unwrap_or(-1);
                let name = table.get_cell_by_label(r, "ResRef").unwrap_or("").to_string();
                if id < 0 || name.is_empty() { None } else { Some((id, name)) }
            })
            .collect();
        if !entries.is_empty() {
            return entries;
        }
    }
    if let Some(ts) = module.tileset_info(&tileset_lower) {
        let mut entries: Vec<(i32, String)> = ts.tiles.iter()
            .map(|(id, def)| (*id as i32, def.model_name.clone()))
            .collect();
        entries.sort_by_key(|(id, _)| *id);
        return entries;
    }
    Vec::new()
}

use nwn_gamemodel::resource_types;
use nwn_gamemodel::resource_types::type_to_ext;
use crate::script_editor::show_script_editor;
use crate::conversation_editor::{ConversationEditor, show_conversation_editor};
use crate::resource_viewer::show_resource_viewer;
use crate::blueprint_palette::show_blueprint_palette;
use crate::item_editor::show_item_browser;
use crate::two_da_editor::{TwoDaEditorState, show_two_da_editor};
use crate::texture_browser::{TextureBrowserState, show_texture_browser};

use crate::area_geometry_editor::{GeometryEditorState, show_geometry_editor};
use crate::universal_search::show_universal_search;
use crate::tools_panel::{Tool, show_tools_panel};

mod background_tasks;
mod icons;
mod inspector;
mod script_editor;
mod conversation_editor;
mod resource_viewer;
mod blueprint_palette;
mod item_editor;
mod faction_editor;
mod journal_editor;
mod two_da_editor;
mod encounter_editor;
mod texture_browser;

mod area_geometry_editor;
mod universal_search;
mod tools_panel;
mod nwsync_gen;

// ── Platform-specific file dialog helpers ──────────────────────────────
#[cfg(not(target_arch = "wasm32"))]
fn pick_open_module() -> Option<String> {
    rfd::FileDialog::new()
        .add_filter("NWN Module", &["mod", "MOD"])
        .pick_file()
        .map(|p| p.to_string_lossy().to_string())
}
#[cfg(not(target_arch = "wasm32"))]
fn pick_save_path(name: &str) -> Option<String> {
    rfd::FileDialog::new()
        .set_file_name(name)
        .add_filter("NWN Module", &["mod", "MOD"])
        .save_file()
        .map(|p| p.to_string_lossy().to_string())
}
#[cfg(not(target_arch = "wasm32"))]
fn pick_save_path_filtered(name: &str, filter_name: &str, exts: &[&str]) -> Option<String> {
    rfd::FileDialog::new()
        .set_file_name(name)
        .add_filter(filter_name, exts)
        .save_file()
        .map(|p| p.to_string_lossy().to_string())
}
#[cfg(target_arch = "wasm32")]
fn pick_open_module() -> Option<String> {
    None
}
#[cfg(target_arch = "wasm32")]
fn pick_save_path(_name: &str) -> Option<String> {
    None
}
#[cfg(target_arch = "wasm32")]
fn pick_save_path_filtered(_name: &str, _filter_name: &str, _exts: &[&str]) -> Option<String> {
    None
}

#[derive(Clone)]
#[allow(dead_code)]
struct ObjectClipboard {
    obj_type: String,
    resref: String,
    tag: String,
    bearing: f32,
    bag: nwn_gamemodel::PropertyBag,
}

#[allow(dead_code)]
struct CameraBookmark {
    name: String,
    target: [f32; 3],
    yaw: f32,
    pitch: f32,
    distance: f32,
}

enum PlacementState {
    Inactive,
    Pending(String, String),
}

#[allow(dead_code)]
enum ManipMode {
    None,
    Move,
    Rotate,
}

#[derive(Clone)]
#[allow(dead_code)]
struct DragState {
    obj_type: String,
    obj_idx: usize,
    orig_x: f32,
    orig_y: f32,
    orig_z: f32,
    orig_bearing: f32,
    start_render_x: f32,
    start_render_z: f32,
}

fn nwn_user_dir() -> std::path::PathBuf {
    #[cfg(target_os = "windows")]
    if let Some(docs) = std::env::var("USERPROFILE").ok().or_else(|| {
        dirs_fallback()
    }) {
        return std::path::PathBuf::from(docs).join("Documents/Neverwinter Nights");
    }
    #[cfg(not(target_os = "windows"))]
    if let Ok(home) = std::env::var("HOME") {
        return std::path::PathBuf::from(home).join("Documents/Neverwinter Nights");
    }
    std::path::PathBuf::from(".")
}

fn nwn_steam_linux_path() -> Option<std::path::PathBuf> {
    let candidates = [
        std::path::PathBuf::from("/home/grimshackle/.local/share/Steam/steamapps/common/Neverwinter Nights"),
        std::path::PathBuf::from(std::env::var("HOME").unwrap_or_default()).join(".steam/steam/steamapps/common/Neverwinter Nights"),
        std::path::PathBuf::from(std::env::var("HOME").unwrap_or_default()).join(".local/share/Steam/steamapps/common/Neverwinter Nights"),
    ];
    for c in &candidates {
        if c.join("bin/linux-x86/nwmain-linux").exists() || c.join("data").exists() {
            return Some(c.clone());
        }
    }
    None
}

#[cfg(target_os = "windows")]
fn nwn_windows_steam_path() -> Option<std::path::PathBuf> {
    #[cfg(target_os = "windows")]
    {
        let candidates = [
            "C:\\Program Files (x86)\\Steam\\steamapps\\common\\Neverwinter Nights",
            "C:\\Program Files\\Steam\\steamapps\\common\\Neverwinter Nights",
            "C:\\GOG Games\\Neverwinter Nights",
        ];
        for c in &candidates {
            let p = std::path::PathBuf::from(c);
            if p.join("bin\\win32\\nwmain.exe").exists() || p.join("data").exists() {
                return Some(p);
            }
        }
        // Registry fallback
        if let Ok(val) = std::fs::read_to_string("C:\\ProgramData\\BioWare\\NWN\\installpath.txt") {
            let p = std::path::PathBuf::from(val.trim());
            if p.exists() { return Some(p); }
        }
    }
    None
}

fn detect_nwn_install() -> Option<std::path::PathBuf> {
    if let Ok(nwn) = std::env::var("NWN") {
        let p = std::path::PathBuf::from(nwn);
        if p.exists() { return Some(p); }
    }
    #[cfg(target_os = "linux")]
    if let Some(p) = nwn_steam_linux_path() { return Some(p); }
    #[cfg(target_os = "windows")]
    if let Some(p) = nwn_windows_steam_path() { return Some(p); }
    #[cfg(target_os = "macos")]
    if let Ok(home) = std::env::var("HOME") {
        let p = std::path::PathBuf::from(home)
            .join("Library/Application Support/Steam/steamapps/common/Neverwinter Nights");
        if p.exists() { return Some(p); }
    }
    None
}

fn nwn_binary_path(root: &std::path::Path) -> std::path::PathBuf {
    #[cfg(target_os = "windows")]
    { root.join("bin/win32/nwmain.exe") }
    #[cfg(target_os = "linux")]
    { root.join("bin/linux-x86/nwmain-linux") }
    #[cfg(target_os = "macos")]
    { root.join("Neverwinter Nights.app/Contents/MacOS/nwmain") }
}

fn nwn_local_vault_dir(_root: &std::path::Path) -> std::path::PathBuf {
    #[cfg(target_os = "windows")]
    {
        nwn_user_dir().join("localvault")
    }
    #[cfg(target_os = "linux")]
    {
        std::path::PathBuf::from(std::env::var("HOME").unwrap_or_default())
            .join(".local/share/Neverwinter Nights/localvault")
    }
    #[cfg(target_os = "macos")]
    {
        std::path::PathBuf::from(std::env::var("HOME").unwrap_or_default())
            .join("Documents/Neverwinter Nights/localvault")
    }
}

fn nwn_game_tlk_path() -> Option<std::path::PathBuf> {
    #[cfg(target_os = "windows")]
    { return Some(nwn_user_dir().join("dialog.tlk")); }
    #[cfg(not(target_os = "windows"))]
    {
        let home = std::env::var("HOME").ok()?;
        // Check standard user dir first
        let user_path = std::path::PathBuf::from(&home).join("Documents/Neverwinter Nights/dialog.tlk");
        if user_path.exists() {
            return Some(user_path);
        }
        // Check tlk subdirectory (some setups place dialog.tlk here)
        let tlk_dir_path = std::path::PathBuf::from(&home).join("Documents/Neverwinter Nights/tlk/dialog.tlk");
        if tlk_dir_path.exists() {
            return Some(tlk_dir_path);
        }
        // Steam install (English)
        let steam_path = std::path::PathBuf::from(&home)
            .join(".local/share/Steam/steamapps/common/Neverwinter Nights/lang/en/data/dialog.tlk");
        if steam_path.exists() {
            return Some(steam_path);
        }
        // Fallback to Steam root data (non-English)
        let steam_root = std::path::PathBuf::from(&home)
            .join(".local/share/Steam/steamapps/common/Neverwinter Nights/data/dialog.tlk");
        if steam_root.exists() {
            return Some(steam_root);
        }
        None
    }
}

#[cfg(target_os = "windows")]
fn dirs_fallback() -> Option<String> {
    #[cfg(target_os = "windows")]
    {
        if let Ok(drive) = std::env::var("SystemDrive") {
            return Some(format!("{}\\Users\\Default", drive));
        }
    }
    None
}

struct CompileAllResult {
    results: Vec<(String, Vec<u8>)>,
    errors: Vec<(String, String)>,
}

#[derive(PartialEq)]
enum PaletteMode {
    Blueprints,
    Tiles,
}

struct AuroraBorealisApp {
    viewport: nwn_3d::WgpuViewport,
    current_area: Option<Arc<nwn_gamemodel::Area>>,
    area_version: u64,
    open_areas: Vec<String>,
    active_area_idx: usize,
    selected_object: Option<SelectedObject>,
    selected_obj_info: Option<(String, usize)>,
    selection_list: Vec<(String, usize)>,

    module: Option<nwn_gamemodel::Module>,
    module_name_edit: String,
    module_tag_edit: String,
    module_entry_edit: String,
    status: String,
    compile_progress: Option<(Arc<AtomicUsize>, usize)>,
    clear_override_enabled: bool,
    clear_override: Option<[u8; 3]>,
    show_resource_viewer: bool,
    texture_browser: TextureBrowserState,


    geometry_editor: GeometryEditorState,
    show_palette: bool,
    palette_mode: PaletteMode,
    universal_search_open: bool,
    show_sky_override: bool,
    show_launch_dialog: bool,
    nwn_process_handle: Option<std::process::Child>,
    #[allow(dead_code)]
    module_save_handle: Option<std::thread::JoinHandle<()>>,
    clipboard: Option<ObjectClipboard>,
    camera_bookmarks: Vec<CameraBookmark>,
    #[allow(dead_code)]
    faction_list: FactionList,
    conversation_editors: Vec<(String, ConversationEditor)>,
    two_da_editors: Vec<(String, TwoDaEditorState)>,
    script_editor_scripts: Vec<(String, String)>,
    blueprint_editors: Vec<(String, u16, nwn_gamemodel::PropertyBag)>,
    item_browser_open: bool,
    undo_stack: Vec<Arc<nwn_gamemodel::Area>>,
    redo_stack: Vec<Arc<nwn_gamemodel::Area>>,
    #[allow(dead_code)]
    inspector_expanded: std::collections::HashSet<String>,
    #[allow(dead_code)]
    snap_to_grid_value: f32,
    snap_to_grid_enabled: bool,
    show_navigator: bool,
    recent_files: Vec<String>,
    #[allow(dead_code)]
    tlk_file: Option<std::sync::Arc<TlkFile>>,
    #[allow(dead_code)]
    area_list_cache: Vec<(String, String)>,
    area_search: String,
    show_minimap: bool,
    graph_view_open: bool,
    graph_view_state: GraphViewState,
    height_map_open: bool,
    height_map_state: HeightMapState,
    show_sprites: bool,
    show_walkmesh: bool,
    show_walkmesh_edges: bool,
    show_paint: bool,
    show_creatures: bool,
    show_doors: bool,
    show_placeables: bool,
    show_triggers: bool,
    show_waypoints: bool,
    show_encounters: bool,
    show_sound_emitters: bool,
    show_lights: bool,
    water_level: i32,
    show_water: bool,
    module_props_popup: bool,
    module_description_edit: String,
    area_props_popup: bool,
    area_props_resref: String,
    area_props_name: String,
    area_props_tag: String,
    area_props_tileset: String,
    local_var_editor: Option<LocalVarEditorState>,
    appearance_picker: Option<AppearancePickerState>,
    object_comment_edit: Option<(String, usize, String)>,
    inventory_editor: Option<InventoryEditorState>,
    placement_state: PlacementState,
    manip_mode: ManipMode,
    drag_state: Option<DragState>,
    drag_select_start: Option<egui::Pos2>,
    space_move_active: bool,
    manip_nudge_speed: f32,
    ghost_screen_pos: Option<egui::Pos2>,
    faction_editor_open: bool,
    journal_editor_open: bool,
    encounter_editor_open: bool,
    encounter_editor_selected: Option<usize>,
    env_settings_open: bool,
    transition_editor_open: bool,
    module_tree_open: bool,
    find_replace_open: bool,
    find_replace_state: FindReplaceState,
    search_term: String,
    search_results: Vec<String>,
    sound_browser_open: bool,
    store_editor_open: bool,
    id_whois_open: bool,
    env_sun_fog_amount: u8,
    env_sun_fog_color: [u8; 3],
    env_moon_fog_amount: u8,
    env_moon_fog_color: [u8; 3],
    env_fog_clip_dist: f32,
    env_sun_ambient_color: [u8; 3],
    active_tool: Tool,
    walkmesh_gen_threshold: i32,
    terrain_edit_raise_amount: i32,
    terrain_smooth_radius: i32,
    show_contents_panel: bool,
    new_area_open: bool,
    new_area_resref: String,
    new_area_tileset: String,
    new_area_width: i32,
    new_area_height: i32,
    new_area_resref_filter: String,
    new_area_tileset_filter: String,
    show_tiles: bool,
    show_grid: bool,
    lighting_enabled: bool,
    show_fog: bool,
    selected_tile: Option<(usize, usize)>,
    tile_palette_filter: String,
    new_object_open: bool,
    new_object_type: String,
    new_object_resref: String,
    new_object_tag: String,
    new_object_filter: String,
    new_object_resref_browse_open: bool,
    new_object_blueprints: Vec<(String, String)>,
    new_object_x: f32,
    new_object_y: f32,
    new_object_z: f32,
    new_object_bearing: f32,
    nwsync_output_path: Option<std::path::PathBuf>,
    nwsync_busy: bool,
    nwsync_result: std::sync::Arc<std::sync::Mutex<Option<String>>>,
    max_ram_mb: u32,
    last_rss_mb: u64,
    icons: icons::Icons,
    last_frame_time: std::time::Instant,
    fps_accum: f64,
    fps_timer: f64,

    pending_compile_all: Option<tokio::sync::oneshot::Receiver<CompileAllResult>>,
    pending_save: Option<tokio::sync::oneshot::Receiver<(nwn_gamemodel::Module, Result<(), String>)>>,
    cli_pending_area: Option<String>,

    audio_system: AudioSystem,
    sound_enabled: bool,
}

#[derive(Debug, Clone)]
struct InventoryEditorState {
    obj_type: String,
    obj_idx: usize,
    items: Vec<PropertyBag>,
    editing_item: Option<usize>,
    add_blueprint_filter: String,
    add_blueprint_results: Vec<(String, u16)>,
}

#[derive(Debug, Clone)]
struct LocalVarEditorState {
    obj_type: String,
    obj_idx: usize,
    vars: Vec<LocalVar>,
}

#[derive(Debug, Clone)]
struct AppearancePickerState {
    obj_type: String,
    obj_idx: usize,
    filter: String,
    appearances: Vec<AppearanceEntry>,
}

#[derive(Debug, Clone)]
struct LocalVar {
    name: String,
    var_type: String,
    value: String,
}

#[derive(Debug, Clone)]
struct AppearanceEntry {
    id: i32,
    label: String,
    model: String,
}

struct FindReplaceState {
    find_text: String,
    replace_text: String,
    results: Vec<FindResult>,
    show_results: bool,
}

struct FindResult {
    script_name: String,
    line_number: usize,
    line_text: String,
}

impl Default for FindReplaceState {
    fn default() -> Self { Self { find_text: String::new(), replace_text: String::new(), results: Vec::new(), show_results: false } }
}

struct GraphViewState {
    pan_x: f32,
    pan_y: f32,
    zoom: f32,
    filter_creatures: bool,
    filter_doors: bool,
    filter_placeables: bool,
    filter_triggers: bool,
    filter_waypoints: bool,
    filter_encounters: bool,
    filter_sound_emitters: bool,
}

impl Default for GraphViewState {
    fn default() -> Self {
        Self {
            pan_x: 0.0,
            pan_y: 0.0,
            zoom: 8.0,
            filter_creatures: true,
            filter_doors: true,
            filter_placeables: true,
            filter_triggers: true,
            filter_waypoints: true,
            filter_encounters: true,
            filter_sound_emitters: true,
        }
    }
}

struct HeightMapState {
    pan_x: f32,
    pan_y: f32,
    zoom: f32,
    brush_size: i32,
    brush_amount: i32,
    show_heights: bool,
}

impl Default for HeightMapState {
    fn default() -> Self {
        Self {
            pan_x: 0.0,
            pan_y: 0.0,
            zoom: 20.0,
            brush_size: 1,
            brush_amount: 1,
            show_heights: false,
        }
    }
}

trait GraphLabel {
    fn graph_label(&self) -> String;
}

impl GraphLabel for nwn_gamemodel::CreatureInstance {
    fn graph_label(&self) -> String { format!("{} ({})", self.resref, self.tag) }
}
impl GraphLabel for nwn_gamemodel::DoorInstance {
    fn graph_label(&self) -> String { format!("{} ({})", self.resref, self.tag) }
}
impl GraphLabel for nwn_gamemodel::PlaceableInstance {
    fn graph_label(&self) -> String { format!("{} ({})", self.resref, self.tag) }
}
impl GraphLabel for nwn_gamemodel::TriggerInstance {
    fn graph_label(&self) -> String { format!("Trigger ({})", self.tag) }
}
impl GraphLabel for nwn_gamemodel::WayPointInstance {
    fn graph_label(&self) -> String { format!("Waypoint ({})", self.tag) }
}
impl GraphLabel for nwn_gamemodel::EncounterInstance {
    fn graph_label(&self) -> String { format!("{} ({})", self.name, self.tag) }
}
impl GraphLabel for nwn_gamemodel::SoundEmitterInstance {
    fn graph_label(&self) -> String { format!("Sound: {}", self.tag) }
}

fn load_local_vars(module: &nwn_gamemodel::Module, area_resref: &str, obj_type: &str, obj_idx: usize) -> Vec<LocalVar> {
    let git_key = area_resref.trim().to_lowercase();
    let git_data = module.raw_git.get(&git_key);
    let git_gff = git_data.and_then(|d| nwn_gff::GffFile::from_bytes(d).ok());
    let fv_list_name = git_list_name(obj_type);
    git_gff.as_ref().and_then(|gff| {
        let list_fv = gff.root().find(fv_list_name)?;
        let list = match list_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => return None,
        };
        let obj_struct = list.get(obj_idx)?;
        let vt_fv = obj_struct.find("VarTable")?;
        let vt_list = match vt_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => return None,
        };
        let mut vars = Vec::new();
        for entry in vt_list.iter() {
            let name = entry.find("Name").and_then(|fv| match fv {
                nwn_gff::FieldValue::String(s) => Some(s.clone()),
                nwn_gff::FieldValue::ResRef(s) => Some(s.clone()),
                _ => None,
            }).unwrap_or_default();
            let vtype = entry.find("Type").and_then(|fv| match fv {
                nwn_gff::FieldValue::Char(c) => Some(*c),
                nwn_gff::FieldValue::Byte(b) => Some(*b as i8),
                _ => None,
            }).unwrap_or(0);
            let type_str = match vtype {
                1 => "int",
                2 => "float",
                3 => "string",
                4 => "object",
                _ => "int",
            };
            let val = match vtype {
                1 => entry.find("Value").and_then(|fv| match fv { nwn_gff::FieldValue::Int(i) => Some(i.to_string()), _ => None }).unwrap_or_else(|| "0".into()),
                2 => entry.find("Value").and_then(|fv| match fv { nwn_gff::FieldValue::Float(f) => Some(f.to_string()), _ => None }).unwrap_or_else(|| "0.0".into()),
                3 => entry.find("Value").and_then(|fv| match fv { nwn_gff::FieldValue::String(s) => Some(s.clone()), _ => None }).unwrap_or_default(),
                _ => entry.find("Value").and_then(|fv| match fv { nwn_gff::FieldValue::Int(i) => Some(i.to_string()), _ => None }).unwrap_or_else(|| "0".into()),
            };
            vars.push(LocalVar { name, var_type: type_str.to_string(), value: val });
        }
        Some(vars)
    }).unwrap_or_default()
}

fn save_local_vars_to_git(module: &mut nwn_gamemodel::Module, area_resref: &str, obj_type: &str, obj_idx: usize, vars: &[LocalVar]) {
    use nwn_gamemodel::{PropertyBag, PropertyValue, Property};
    let git_key = area_resref.trim().to_lowercase();
    let data = match module.raw_git.get(&git_key) {
        Some(d) => d.clone(),
        None => return,
    };
    let mut gff = match nwn_gff::GffFile::from_bytes(&data) {
        Ok(g) => g,
        Err(_) => return,
    };
    let fv_list_name = git_list_name(obj_type);
    let struct_id = git_struct_id(obj_type);
    let bag = {
        // Build a bag from the existing struct + our modifications
        // We need to serialize the target struct to bytes, re-parse, then build bag
        // But we can't clone Struct. Instead, serialize the whole GFF, re-parse,
        // extract the struct reference, build bag, then write back.
        let gff_bytes = gff.to_bytes();
        let gff_copy = match nwn_gff::GffFile::from_bytes(&gff_bytes) {
            Ok(g) => g,
            Err(_) => return,
        };
        let list_fv = match gff_copy.root().find(fv_list_name) {
            Some(l) => l,
            None => return,
        };
        let list = match list_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => return,
        };
        let obj_struct = match list.get(obj_idx) {
            Some(s) => s,
            None => return,
        };
        let mut bag = PropertyBag::from_gff_struct(obj_struct);
        bag.properties.retain(|p| p.label != "VarTable");

        let mut vt_items: Vec<Box<PropertyBag>> = Vec::new();
        for v in vars {
            let mut entry = PropertyBag::new();
            entry.properties.push(Property { label: "Name".into(), value: PropertyValue::CExoString(v.name.clone()), field_type: 10, category: String::new(), description: String::new() });
            let (vtype_int, val_pv) = match v.var_type.as_str() {
                "float" => (2i8, v.value.parse::<f32>().map(PropertyValue::Float).unwrap_or(PropertyValue::Float(0.0))),
                "string" => (3i8, PropertyValue::CExoString(v.value.clone())),
                "object" => (4i8, PropertyValue::CExoString(v.value.clone())),
                _ => (1i8, v.value.parse::<i32>().map(PropertyValue::Int).unwrap_or(PropertyValue::Int(0))),
            };
            let type_field_type = match vtype_int { 2 => 8, 3 => 10, 4 => 10, _ => 5 };
            entry.properties.push(Property { label: "Type".into(), value: PropertyValue::Char(vtype_int), field_type: 1, category: String::new(), description: String::new() });
            entry.properties.push(Property { label: "Value".into(), value: val_pv, field_type: type_field_type, category: String::new(), description: String::new() });
            vt_items.push(Box::new(entry));
        }
        bag.properties.push(Property { label: "VarTable".into(), value: PropertyValue::List(vt_items), field_type: 15, category: String::new(), description: String::new() });
        bag
    };
    let new_struct = bag.to_gff_struct(struct_id);
    match gff.root_mut().find_mut(fv_list_name) {
        Some(nwn_gff::FieldValue::List(list)) => {
            if obj_idx < list.len() {
                list[obj_idx] = new_struct;
            }
        }
        _ => return,
    }
    module.raw_git.insert(git_key, gff.to_bytes());
    module.modified = true;
}

fn load_object_comment(module: &nwn_gamemodel::Module, area_resref: &str, obj_type: &str, obj_idx: usize) -> String {
    let git_key = area_resref.trim().to_lowercase();
    let git_data = module.raw_git.get(&git_key);
    let git_gff = git_data.and_then(|d| nwn_gff::GffFile::from_bytes(d).ok());
    let fv_list_name = git_list_name(obj_type);
    git_gff.as_ref().and_then(|gff| {
        let list_fv = gff.root().find(fv_list_name)?;
        let list = match list_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => return None,
        };
        let obj_struct = list.get(obj_idx)?;
        obj_struct.find("Comment").and_then(|fv| match fv {
            nwn_gff::FieldValue::String(s) => Some(s.clone()),
            nwn_gff::FieldValue::ResRef(s) => Some(s.clone()),
            _ => None,
        })
    }).unwrap_or_default()
}

fn save_object_comment(module: &mut nwn_gamemodel::Module, area_resref: &str, obj_type: &str, obj_idx: usize, comment: &str) {
    use nwn_gamemodel::{PropertyBag, PropertyValue, Property};
    let git_key = area_resref.trim().to_lowercase();
    let data = match module.raw_git.get(&git_key) {
        Some(d) => d.clone(),
        None => return,
    };
    let mut gff = match nwn_gff::GffFile::from_bytes(&data) {
        Ok(g) => g,
        Err(_) => return,
    };
    let fv_list_name = git_list_name(obj_type);
    let struct_id = git_struct_id(obj_type);
    let bag = {
        let gff_bytes = gff.to_bytes();
        let gff_copy = match nwn_gff::GffFile::from_bytes(&gff_bytes) {
            Ok(g) => g,
            Err(_) => return,
        };
        let list_fv = match gff_copy.root().find(fv_list_name) {
            Some(l) => l,
            None => return,
        };
        let list = match list_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => return,
        };
        let obj_struct = match list.get(obj_idx) {
            Some(s) => s,
            None => return,
        };
        let mut bag = PropertyBag::from_gff_struct(obj_struct);
        let mut found = false;
        for p in bag.properties.iter_mut() {
            if p.label == "Comment" {
                p.value = PropertyValue::CExoString(comment.to_string());
                found = true;
                break;
            }
        }
        if !found {
            bag.properties.push(Property { label: "Comment".into(), value: PropertyValue::CExoString(comment.to_string()), field_type: 10, category: String::new(), description: String::new() });
        }
        bag
    };
    let new_struct = bag.to_gff_struct(struct_id);
    match gff.root_mut().find_mut(fv_list_name) {
        Some(nwn_gff::FieldValue::List(list)) => {
            if obj_idx < list.len() {
                list[obj_idx] = new_struct;
            }
        }
        _ => return,
    }
    module.raw_git.insert(git_key, gff.to_bytes());
    module.modified = true;
}

/// Embedded NWScript compiler binary (extracted on first use).
#[cfg(all(not(target_arch = "wasm32"), target_os = "windows"))]
static NWNSC: &[u8] = include_bytes!("../../nwnsc.exe");

#[cfg(all(not(target_arch = "wasm32"), not(target_os = "windows")))]
static NWNSC: &[u8] = include_bytes!("../../nwnsc");

/// Embedded nwscript.nss fallback for when NWN is not installed.
#[cfg(not(target_arch = "wasm32"))]
static NWSCRIPT_NSS: &[u8] = include_bytes!("../scripts/nwscript.nss");

/// PRC constants missing from EE nwscript.nss, written to tmp dir as an include file.
const PRC_CONSTANTS_NSS: &[u8] = b"const int SAVING_THROW_TYPE_PARALYSE = 20;\nobject GetLastOpener();\n";

include!(concat!(env!("OUT_DIR"), "/nwnx_scripts.rs"));

#[cfg(not(target_arch = "wasm32"))]
fn nwnsc_exe() -> std::path::PathBuf {
    static PATH: std::sync::OnceLock<std::path::PathBuf> = std::sync::OnceLock::new();
    PATH.get_or_init(|| {
        let dir = std::env::temp_dir().join("aurora_nwnsc_bin");
        let _ = std::fs::create_dir_all(&dir);
        let exe_name = if cfg!(target_os = "windows") { "nwnsc.exe" } else { "nwnsc" };
        let path = dir.join(exe_name);
        let _ = std::fs::write(&path, NWNSC);
        #[cfg(target_os = "linux")]
        {
            use std::os::unix::fs::PermissionsExt;
            let _ = std::fs::set_permissions(&path, std::fs::Permissions::from_mode(0o755));
        }
        path
    }).clone()
}

fn set_object_appearance(module: &mut nwn_gamemodel::Module, area_resref: &str, obj_type: &str, obj_idx: usize, appearance_id: i32) {
    use nwn_gamemodel::{PropertyBag, PropertyValue, Property};
    let git_key = area_resref.trim().to_lowercase();
    let data = match module.raw_git.get(&git_key) {
        Some(d) => d.clone(),
        None => return,
    };
    let mut gff = match nwn_gff::GffFile::from_bytes(&data) {
        Ok(g) => g,
        Err(_) => return,
    };
    let fv_list_name = git_list_name(obj_type);
    let struct_id = git_struct_id(obj_type);
    let bag = {
        let gff_bytes = gff.to_bytes();
        let gff_copy = match nwn_gff::GffFile::from_bytes(&gff_bytes) {
            Ok(g) => g,
            Err(_) => return,
        };
        let list_fv = match gff_copy.root().find(fv_list_name) {
            Some(l) => l,
            None => return,
        };
        let list = match list_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => return,
        };
        let obj_struct = match list.get(obj_idx) {
            Some(s) => s,
            None => return,
        };
        let mut bag = PropertyBag::from_gff_struct(obj_struct);
        let mut found = false;
        for p in bag.properties.iter_mut() {
            if p.label == "Appearance" {
                p.value = PropertyValue::Int(appearance_id);
                found = true;
                break;
            }
        }
        if !found {
            bag.properties.push(Property { label: "Appearance".into(), value: PropertyValue::Int(appearance_id), field_type: 5, category: String::new(), description: String::new() });
        }
        bag
    };
    let new_struct = bag.to_gff_struct(struct_id);
    match gff.root_mut().find_mut(fv_list_name) {
        Some(nwn_gff::FieldValue::List(list)) => {
            if obj_idx < list.len() {
                list[obj_idx] = new_struct;
            }
        }
        _ => return,
    }
    module.raw_git.insert(git_key, gff.to_bytes());
    module.modified = true;
}

fn load_item_list(module: Option<&nwn_gamemodel::Module>, area_resref: &str, obj_type: &str, obj_idx: usize) -> Vec<PropertyBag> {
    let module = match module { Some(m) => m, None => return vec![] };
    let git_key = area_resref.trim().to_lowercase();
    let git_data = module.raw_git.get(&git_key);
    let git_gff = git_data.and_then(|d| nwn_gff::GffFile::from_bytes(d).ok());
    let fv_list_name = git_list_name(obj_type);
    let result = git_gff.as_ref().and_then(|gff| {
        let list_fv = gff.root().find(fv_list_name)?;
        let list = match list_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => return None,
        };
        let obj_struct = list.get(obj_idx)?;
        let item_list_fv = obj_struct.find("ItemList")?;
        let item_list = match item_list_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => return None,
        };
        if item_list.is_empty() { return None; }
        let items: Vec<PropertyBag> = item_list.iter().map(|s| PropertyBag::from_gff_struct(s)).collect();
        Some(items)
    });
    if let Some(items) = result { return items; }
    // Fallback: try blueprint .utc (creature) or .utp (placeable)
    let blueprint_restype = match obj_type {
        "creature" => resource_types::UTC,
        "placeable" => resource_types::UTP,
        _ => return vec![],
    };
    let fallback_result: Option<Vec<PropertyBag>> = git_gff.as_ref().and_then(|gff| {
        let list_fv = gff.root().find(fv_list_name)?;
        let list = match list_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => return None,
        };
        let obj_struct = list.get(obj_idx)?;
        let template_resref = obj_struct.find("TemplateResRef").and_then(|v| match v {
            nwn_gff::FieldValue::ResRef(s) => { eprintln!("INV_FALLBACK: TemplateResRef ResRef='{}'", s); Some(s.clone()) }
            nwn_gff::FieldValue::String(s) => { eprintln!("INV_FALLBACK: TemplateResRef String='{}'", s); Some(s.clone()) }
            _ => { eprintln!("INV_FALLBACK: TemplateResRef not found in GIT struct"); None }
        })?;
        let data = module.get_resource_data(&template_resref, blueprint_restype);
        if data.is_none() {
            eprintln!("INV_FALLBACK: '{}' .{} not found via get_resource_data", template_resref, if blueprint_restype == resource_types::UTC { "utc" } else { "utp" });
            // Try direct ERF access
            if let Some(ref erf) = module.erf {
                eprintln!("INV_FALLBACK: trying direct ERF lookup");
                let erf_data = (|| -> Option<Vec<u8>> {
                    let nl = template_resref.trim().to_lowercase();
                    let idx = erf.inner.resources.iter().position(|r|
                        r.file_name.to_string().trim().to_lowercase() == nl && r.resource_type == blueprint_restype
                    )?;
                    erf.read_resource_data(&erf.inner.resources[idx])
                })();
                if let Some(erf_data) = erf_data {
                    eprintln!("INV_FALLBACK: found in ERF directly!");
                    if let Ok(gff) = nwn_gff::GffFile::from_bytes(&erf_data) {
                        if let Some(item_list_fv) = gff.root().find("ItemList") {
                            if let nwn_gff::FieldValue::List(item_list) = item_list_fv {
                                eprintln!("INV_FALLBACK: ERF .utc has {} items", item_list.len());
                                let items: Vec<PropertyBag> = item_list.iter().map(|s| PropertyBag::from_gff_struct(s)).collect();
                                return Some(items);
                            }
                        }
                    }
                }
            }
            return None;
        }
        let data = data.unwrap();
        let gff = nwn_gff::GffFile::from_bytes(&data).ok()?;
        let item_list_fv = gff.root().find("ItemList")?;
        let item_list = match item_list_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => { eprintln!("INV_FALLBACK: ItemList not a List field in .utc"); return None; }
        };
        if item_list.is_empty() {
            eprintln!("INV_FALLBACK: .utc ItemList is empty");
            return None;
        }
        eprintln!("INV_FALLBACK: .utc has {} items", item_list.len());
        let items: Vec<PropertyBag> = item_list.iter().map(|s| PropertyBag::from_gff_struct(s)).collect();
        Some(items)
    });
    let result = fallback_result.unwrap_or_default();
    if result.is_empty() {
        eprintln!("INV_FALLBACK: no items found for {} #{}", obj_type, obj_idx);
    }
    result
}

fn save_item_list(module: Option<&mut nwn_gamemodel::Module>, area_resref: &str, obj_type: &str, obj_idx: usize, items: &[PropertyBag]) {
    let module = match module { Some(m) => m, None => return };
    let git_key = area_resref.trim().to_lowercase();
    let data = match module.raw_git.get(&git_key) {
        Some(d) => d.clone(),
        None => return,
    };
    let mut gff = match nwn_gff::GffFile::from_bytes(&data) {
        Ok(g) => g,
        Err(_) => return,
    };
    let fv_list_name = git_list_name(obj_type);
    let struct_id = git_struct_id(obj_type);
    let bag = {
        let gff_bytes = gff.to_bytes();
        let gff_copy = match nwn_gff::GffFile::from_bytes(&gff_bytes) {
            Ok(g) => g,
            Err(_) => return,
        };
        let list_fv = match gff_copy.root().find(fv_list_name) {
            Some(l) => l,
            None => return,
        };
        let list = match list_fv {
            nwn_gff::FieldValue::List(l) => l,
            _ => return,
        };
        let obj_struct = match list.get(obj_idx) {
            Some(s) => s,
            None => return,
        };
        let mut bag = PropertyBag::from_gff_struct(obj_struct);
        bag.properties.retain(|p| p.label != "ItemList");
        let item_bags: Vec<Box<PropertyBag>> = items.iter().map(|i| Box::new(i.clone())).collect();
        bag.properties.push(nwn_gamemodel::Property {
            label: "ItemList".into(),
            value: nwn_gamemodel::PropertyValue::List(item_bags),
            field_type: 15,
            category: String::new(),
            description: String::new(),
        });
        bag
    };
    let new_struct = bag.to_gff_struct(struct_id);
    match gff.root_mut().find_mut(fv_list_name) {
        Some(nwn_gff::FieldValue::List(list)) => {
            if obj_idx < list.len() {
                list[obj_idx] = new_struct;
            }
        }
        _ => return,
    }
    module.raw_git.insert(git_key, gff.to_bytes());
    module.modified = true;
}

impl AuroraBorealisApp {
    #[cfg(target_arch = "wasm32")]
    fn new(cc: &eframe::CreationContext<'_>) -> Self {
        Self::new_with_cli(cc, CliArgs::default())
    }

    fn new_with_cli(cc: &eframe::CreationContext<'_>, cli: CliArgs) -> Self {
        background_tasks::init_runtime();
        let viewport = nwn_3d::WgpuViewport::new();
        let mut recent_files: Vec<String> = load_recent_files();
        recent_files.retain(|f| std::path::Path::new(f).exists());
        let mut app = Self {
            viewport,
            current_area: None,
            area_version: 0,
            open_areas: Vec::new(),
            active_area_idx: 0,
            selected_object: None,
            selected_obj_info: None,
            selection_list: Vec::new(),

            module: None,
            module_name_edit: String::new(),
            module_tag_edit: String::new(),
            module_entry_edit: String::new(),
            status: "Ready.".to_string(),
            compile_progress: None,
            clear_override_enabled: false,
            clear_override: None,
            show_resource_viewer: false,
            texture_browser: TextureBrowserState::default(),


            geometry_editor: GeometryEditorState::default(),
            show_palette: false,
            palette_mode: PaletteMode::Blueprints,
            universal_search_open: false,
            show_sky_override: false,
            show_launch_dialog: false,
            nwn_process_handle: None,
            module_save_handle: None,
            clipboard: None,
            camera_bookmarks: Vec::new(),
            faction_list: FactionList { factions: Vec::new() },
            conversation_editors: Vec::new(),
            two_da_editors: Vec::new(),
            script_editor_scripts: Vec::new(),
            blueprint_editors: Vec::new(),
            item_browser_open: false,
            undo_stack: Vec::new(),
            redo_stack: Vec::new(),
            inspector_expanded: std::collections::HashSet::new(),
            snap_to_grid_value: 10.0,
            snap_to_grid_enabled: true,
            show_navigator: true,
            recent_files,
            tlk_file: nwn_game_tlk_path().and_then(|p| {
                match nwn_tlk::TlkFile::open(&p) {
                    Ok(tlk) => {
                        eprintln!("TLK: loaded '{}' with {} strrefs", p.display(), tlk.count());
                        Some(Arc::new(tlk))
                    }
                    Err(e) => {
                        eprintln!("TLK: failed to load '{}': {}", p.display(), e);
                        None
                    }
                }
            }),
            area_list_cache: Vec::new(),
            area_search: String::new(),
            show_minimap: false,
            graph_view_open: false,
            graph_view_state: GraphViewState::default(),
            height_map_open: false,
            height_map_state: HeightMapState::default(),
            show_sprites: true,
            show_walkmesh: false,
            show_walkmesh_edges: false,
            show_fog: false,
            show_paint: false,
            show_creatures: true,
            show_doors: true,
            show_placeables: true,
            show_triggers: true,
            show_waypoints: true,
            show_encounters: true,
            show_sound_emitters: true,
            show_lights: true,
            water_level: 0,
            show_water: false,
            module_props_popup: false,
            module_description_edit: String::new(),
            area_props_popup: false,
            area_props_resref: String::new(),
            area_props_name: String::new(),
            area_props_tag: String::new(),
            area_props_tileset: String::new(),
            local_var_editor: None,
            appearance_picker: None,
            object_comment_edit: None,
            inventory_editor: None,
            placement_state: PlacementState::Inactive,
            manip_mode: ManipMode::None,
            drag_state: None,
            drag_select_start: None,
            space_move_active: false,
            manip_nudge_speed: 0.5,
            ghost_screen_pos: None,
            faction_editor_open: false,
            journal_editor_open: false,
            encounter_editor_open: false,
            encounter_editor_selected: None,
            env_settings_open: false,
            transition_editor_open: false,
            module_tree_open: false,
            find_replace_open: false,
            find_replace_state: FindReplaceState::default(),
            search_term: String::new(),
            search_results: Vec::new(),
            sound_browser_open: false,
            store_editor_open: false,
            id_whois_open: false,
            env_sun_fog_amount: 0,
            env_sun_fog_color: [0, 0, 0],
            env_moon_fog_amount: 0,
            env_moon_fog_color: [0, 0, 0],
            env_fog_clip_dist: 45.0,
            env_sun_ambient_color: [0, 0, 0],
            active_tool: Tool::Select,
            walkmesh_gen_threshold: 3,
            terrain_edit_raise_amount: 1,
            terrain_smooth_radius: 2,
            show_contents_panel: false,
            new_area_open: false,
            new_area_resref: String::new(),
            new_area_tileset: String::new(),
            new_area_width: 16,
            new_area_height: 16,
            new_area_resref_filter: String::new(),
            new_area_tileset_filter: String::new(),
            show_tiles: true,
            selected_tile: None,
            show_grid: true,
            lighting_enabled: true,
            tile_palette_filter: String::new(),
            new_object_open: false,
            new_object_type: "creature".to_string(),
            new_object_resref: String::new(),
            new_object_tag: String::new(),
            new_object_filter: String::new(),
            new_object_resref_browse_open: false,
            new_object_blueprints: Vec::new(),
            new_object_x: 0.0,
            new_object_y: 0.0,
            new_object_z: 0.0,
            new_object_bearing: 0.0,
            nwsync_output_path: None,
            nwsync_busy: false,
            nwsync_result: std::sync::Arc::new(std::sync::Mutex::new(None)),
            max_ram_mb: 1536,
            last_rss_mb: 0,
            icons: icons::Icons::new(&cc.egui_ctx),
            last_frame_time: std::time::Instant::now(),
            fps_accum: 0.0,
            fps_timer: 0.0,

            pending_compile_all: None,
            pending_save: None,
            cli_pending_area: None,

            audio_system: AudioSystem::new(),
            sound_enabled: true,
        };
        if let Some(ref path) = cli.module {
            app.load_module_at_path(path);
        }
        app.cli_pending_area = cli.area;
        app
    }
}

impl eframe::App for AuroraBorealisApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        ctx.set_zoom_factor(1.5);
        self.check_pending_tasks();
        if self.pending_compile_all.is_some() || self.pending_save.is_some() {
            ctx.request_repaint();
        }
        // Callbacks from editors
        let save_2da: Option<(String, nwn_2da::TwoDa)> = None;
        let mut open_script: Option<String> = None;
        let mut open_conversation: Option<String> = None;
        let mut edit_blueprint: Option<(String, u16, Vec<u8>)> = None;
        let mut open_faction: Option<String> = None;
        let mut open_journal: Option<String> = None;
        let mut module_props_changed = false;

        // Compute render target format once for reuse
        let target_format = _frame.wgpu_render_state().map(|rs| rs.target_format).unwrap_or(wgpu::TextureFormat::Bgra8Unorm);

        // Handle pending area switch from CLI args
        if let Some(area_resref) = self.cli_pending_area.take() {
            if self.module.is_some() {
                self.switch_to_area(&area_resref, target_format);
            }
        }

        // ===================== TOP TOOLBARS =====================
        const S: f32 = 8.0;
        let has_mod = self.module.is_some();
        let has_area = self.current_area.is_some();
        let mut filter_changed = false;

        // ---- FILE BAR ----
        egui::TopBottomPanel::top("menu_file").min_height(14.0).show(ctx, |ui| {
            ui.style_mut().spacing.item_spacing = egui::vec2(1.0, 0.0);
            egui::ScrollArea::horizontal().id_salt("toolbar_file").show(ui, |ui| {
                ui.horizontal(|ui| {
                    if self.icons.label_button(ui, "Open", "open-folder", S).clicked() {
                        if let Some(path) = pick_open_module() {
                            self.load_module_at_path(&path);
                            add_recent_file(&mut self.recent_files, &path);
                        }
                    }
                    if !self.recent_files.is_empty() {
                        egui::menu::menu_button(ui, "Recent", |ui| {
                            for f in self.recent_files.clone() {
                                if ui.button(&f).clicked() {
                                    self.load_module_at_path(&f);
                                    add_recent_file(&mut self.recent_files, &f);
                                    ui.close_menu();
                                }
                            }
                        });
                    }
                    if has_mod && self.icons.label_button(ui, "Save", "save", S).clicked() {
                        self.save_module();
                    }
                    if has_mod && self.icons.label_button(ui, "SaveAs", "save", S).clicked() {
                        if let Some(ref module) = self.module {
                            if let Some(path) = pick_save_path(&module.name) {
                                self.save_module_as(&path);
                                self.status = format!("Module saved to {}", path);
                            }
                        }
                    }
                    if has_mod && self.icons.label_button(ui, "Props", "cog", S).clicked() {
                        if let Some(ref module) = self.module {
                            self.module_name_edit = module.name.clone();
                            self.module_tag_edit = module.tag.clone();
                            self.module_entry_edit = module.entry_area.clone();
                            self.module_description_edit = module.description.clone();
                            self.module_props_popup = true;
                        }
                    }
                    if has_area && self.icons.label_button(ui, "Minimap", "square", S).clicked() {
                        if let Some(ref area) = self.current_area {
                            if let Some(path) = pick_save_path_filtered(
                                &format!("{}_minimap.png", area.resref), "PNG", &["png"]
                            ) {
                                match export_minimap_png(area, &path) {
                                    Ok(()) => self.status = format!("Minimap saved to {}", path),
                                    Err(e) => self.status = format!("Minimap export error: {}", e),
                                }
                            }
                        }
                    }
                    if has_mod && self.icons.label_button(ui, "Launch", "play-button", S).clicked() {
                        self.show_launch_dialog = true;
                    }
                    self.icons.label_button(ui, "Quit", "cross-mark", S).clicked().then(|| {
                        ctx.send_viewport_cmd(egui::ViewportCommand::Close);
                    });
                    ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                        if let Some(ref module) = self.module {
                            if module.modified {
                                ui.colored_label(egui::Color32::YELLOW, "● Modified");
                            }
                        }
                    });
                });
            });
        });

        // ---- VIEW BAR ----
        egui::TopBottomPanel::top("menu_view").min_height(14.0).show(ctx, |ui| {
            ui.style_mut().spacing.item_spacing = egui::vec2(1.0, 0.0);
            egui::ScrollArea::horizontal().id_salt("toolbar_view").show(ui, |ui| {
                ui.horizontal(|ui| {
                    if self.icons.label_toggle(ui, "Res", "box", self.show_resource_viewer, S).clicked() {
                        self.show_resource_viewer = !self.show_resource_viewer;
                    }
                    if self.icons.label_toggle(ui, "Palette", "gate", self.show_palette, S).clicked() {
                        self.show_palette = !self.show_palette;
                    }
                    if self.icons.label_toggle(ui, "Items", "chest", self.item_browser_open, S).clicked() {
                        self.item_browser_open = !self.item_browser_open;
                    }
                    if self.icons.label_toggle(ui, "Search", "magnifying-glass", self.universal_search_open, S).clicked() {
                        self.universal_search_open = !self.universal_search_open;
                    }
                    if self.icons.label_toggle(ui, "Tree", "expand", self.module_tree_open, S).clicked() {
                        self.module_tree_open = !self.module_tree_open;
                    }
                    if self.icons.label_toggle(ui, "Con", "door", self.show_contents_panel, S).clicked() {
                        self.show_contents_panel = !self.show_contents_panel;
                    }
                    if self.icons.label_toggle(ui, "Graph", "new-shoot", self.graph_view_open, S).clicked() {
                        self.graph_view_open = !self.graph_view_open;
                    }
                    if self.icons.label_toggle(ui, "Height", "sun", self.height_map_open, S).clicked() {
                        self.height_map_open = !self.height_map_open;
                    }
                    if self.icons.label_toggle(ui, "Nav", "star-flag", self.show_navigator, S).clicked() {
                        self.show_navigator = !self.show_navigator;
                    }
                    if self.icons.label_toggle(ui, "Mini", "square", self.show_minimap, S).clicked() {
                        self.show_minimap = !self.show_minimap;
                    }
                    if self.icons.label_toggle(ui, "Sky", "sun", self.show_sky_override, S).clicked() {
                        self.show_sky_override = !self.show_sky_override;
                    }
                    ui.separator();
                    if self.icons.label_toggle(ui, "Tiles", "square", self.show_tiles, S).clicked() {
                        self.show_tiles = !self.show_tiles; self.viewport.set_show_tiles(self.show_tiles);
                    }
                    if self.icons.label_toggle(ui, "Grid", "", self.show_grid, S).clicked() {
                        self.show_grid = !self.show_grid; self.viewport.set_show_grid(self.show_grid);
                    }
                    if self.icons.label_toggle(ui, "Light", "light-bulb", self.lighting_enabled, S).clicked() {
                        self.lighting_enabled = !self.lighting_enabled; self.viewport.set_lighting_enabled(self.lighting_enabled);
                    }
                    if self.icons.label_toggle(ui, "Fog", "moon", self.show_fog, S).clicked() {
                        self.show_fog = !self.show_fog; self.viewport.set_show_fog(self.show_fog);
                    }
                    if self.icons.label_toggle(ui, "Walk", "rock", self.show_walkmesh, S).clicked() {
                        self.show_walkmesh = !self.show_walkmesh; self.viewport.set_show_walkmesh(self.show_walkmesh);
                    }
                    if self.icons.label_toggle(ui, "WEdges", "", self.show_walkmesh_edges, S).clicked() {
                        self.show_walkmesh_edges = !self.show_walkmesh_edges; self.viewport.set_show_walkmesh_edges(self.show_walkmesh_edges);
                    }
                    if self.icons.label_toggle(ui, "Paint", "pencil", self.show_paint, S).clicked() {
                        self.show_paint = !self.show_paint; self.viewport.set_show_paint(self.show_paint);
                    }
                    if self.icons.label_toggle(ui, "Sprite", "", self.show_sprites, S).clicked() {
                        self.show_sprites = !self.show_sprites; self.viewport.set_show_sprites(self.show_sprites);
                    }
                    if self.icons.label_toggle(ui, "Water", "", self.show_water, S).clicked() {
                        self.show_water = !self.show_water;
                        if self.show_water { self.viewport.set_water(self.water_level, true, [40, 80, 200, 160]); } else { self.viewport.set_water(0, false, [0;4]); }
                    }
                    if self.icons.label_toggle(ui, "Audio", "musical-notes", self.sound_enabled, S).clicked() {
                        self.sound_enabled = !self.sound_enabled;
                        if !self.sound_enabled { self.audio_system.stop_all(); }
                    }
                    if self.icons.label_toggle(ui, "Snap", "", self.snap_to_grid_enabled, S).clicked() {
                        self.snap_to_grid_enabled = !self.snap_to_grid_enabled;
                    }
                    ui.separator();
                    if has_area {
                        if self.icons.label_toggle(ui, "Creature", "person", self.show_creatures, S).clicked() {
                            self.show_creatures = !self.show_creatures; filter_changed = true;
                        }
                        if self.icons.label_toggle(ui, "Doors", "door", self.show_doors, S).clicked() {
                            self.show_doors = !self.show_doors; filter_changed = true;
                        }
                        if self.icons.label_toggle(ui, "Placeable", "chest", self.show_placeables, S).clicked() {
                            self.show_placeables = !self.show_placeables; filter_changed = true;
                        }
                        if self.icons.label_toggle(ui, "Trigger", "new-shoot", self.show_triggers, S).clicked() {
                            self.show_triggers = !self.show_triggers; filter_changed = true;
                        }
                        if self.icons.label_toggle(ui, "Waypoint", "star-flag", self.show_waypoints, S).clicked() {
                            self.show_waypoints = !self.show_waypoints; filter_changed = true;
                        }
                        if self.icons.label_toggle(ui, "Encounter", "star-flag", self.show_encounters, S).clicked() {
                            self.show_encounters = !self.show_encounters; filter_changed = true;
                        }
                        if self.icons.label_toggle(ui, "Sound", "musical-notes", self.show_sound_emitters, S).clicked() {
                            self.show_sound_emitters = !self.show_sound_emitters; filter_changed = true;
                        }
                        if self.icons.label_toggle(ui, "Light", "light-bulb", self.show_lights, S).clicked() {
                            self.show_lights = !self.show_lights; filter_changed = true;
                        }
                    }
                    if filter_changed { self.update_visibility_filter(target_format); }
                    ui.separator();
                    egui::menu::menu_button(ui, "...", |ui| {
                        if has_area {
                            if ui.button("Generate Walls").clicked() {
                                self.push_undo();
                                if let Some(ref mut area) = self.current_area {
                                    let area_mut = Arc::make_mut(area);
                                    let resref = area_mut.resref.clone();
                                    let count = generate_walkmesh_walls(area_mut, self.walkmesh_gen_threshold);
                                    if let Some(ref mut module) = self.module {
                                        module.update_area_are(&resref, area_mut);
                                    }
                                    self.area_version = self.area_version.wrapping_add(1);
                                    self.viewport.set_area(area.clone(), self.area_version, target_format);
                                    self.status = format!("Generated {} walkmesh walls (threshold={})", count, self.walkmesh_gen_threshold);
                                }
                            }
                            ui.add(egui::Slider::new(&mut self.walkmesh_gen_threshold, 1..=10).text("Wall Threshold"));
                        }
                        if self.show_water {
                            let mut wl = self.water_level;
                            ui.add(egui::Slider::new(&mut wl, -10..=50).text("Water Level"));
                            if wl != self.water_level { self.water_level = wl; self.viewport.set_water(wl, true, [40, 80, 200, 160]); }
                        }
                        if self.snap_to_grid_enabled {
                            let mut sv = self.snap_to_grid_value;
                            ui.add(egui::Slider::new(&mut sv, 0.5..=50.0).text("Grid Size"));
                            if sv != self.snap_to_grid_value { self.snap_to_grid_value = sv; }
                        }
                        ui.add(egui::Slider::new(&mut self.max_ram_mb, 2048..=4096).text("Max Texture Memory (MB)"));
                        self.viewport.set_texture_mem_limit(self.max_ram_mb as u64 * 1024 * 1024);
                    });
                });
            });
        });

        // ---- TOOLS BAR ----
        egui::TopBottomPanel::top("menu_tools").min_height(14.0).show(ctx, |ui| {
            ui.style_mut().spacing.item_spacing = egui::vec2(1.0, 0.0);
            egui::ScrollArea::horizontal().id_salt("toolbar_tools").show(ui, |ui| {
                ui.horizontal(|ui| {
                    if has_area && self.icons.label_toggle(ui, "Env", "moon", self.env_settings_open, S).clicked() {
                        if let Some(ref area) = self.current_area {
                            self.env_sun_fog_amount = area.sun_fog_amount;
                            self.env_sun_fog_color = area.sun_fog_color;
                            self.env_moon_fog_amount = area.moon_fog_amount;
                            self.env_moon_fog_color = area.moon_fog_color;
                            self.env_fog_clip_dist = area.fog_clip_dist;
                            self.env_sun_ambient_color = area.sun_ambient_color;
                        }
                        self.env_settings_open = !self.env_settings_open;
                    }
                    if self.icons.label_toggle(ui, "Factions", "person", self.faction_editor_open, S).clicked() {
                        self.faction_editor_open = !self.faction_editor_open;
                    }
                    if self.icons.label_toggle(ui, "Journal", "pencil", self.journal_editor_open, S).clicked() {
                        self.journal_editor_open = !self.journal_editor_open;
                    }
                    if self.icons.label_toggle(ui, "Enc", "star-flag", self.encounter_editor_open, S).clicked() {
                        self.encounter_editor_open = !self.encounter_editor_open;
                    }
                    if self.icons.label_toggle(ui, "Tex", "cube", self.texture_browser.open, S).clicked() {
                        self.texture_browser.open = !self.texture_browser.open;
                    }
                    if has_mod && self.icons.label_toggle(ui, "Sound", "musical-notes", self.sound_browser_open, S).clicked() {
                        self.sound_browser_open = !self.sound_browser_open;
                    }
                    if has_mod && self.icons.label_toggle(ui, "Store", "chest", self.store_editor_open, S).clicked() {
                        self.store_editor_open = !self.store_editor_open;
                    }
                    if has_mod && self.icons.label_toggle(ui, "Whois", "help", self.id_whois_open, S).clicked() {
                        self.id_whois_open = !self.id_whois_open;
                    }
                    if has_area && self.icons.label_toggle(ui, "Geom", "move", self.geometry_editor.open, S).clicked() {
                        self.geometry_editor.open = !self.geometry_editor.open;
                    }
                    if self.icons.label_toggle(ui, "Find", "magnifying-glass", self.find_replace_open, S).clicked() {
                        self.find_replace_open = !self.find_replace_open;
                    }
                    if has_mod && self.icons.label_toggle(ui, "Trans", "door", self.transition_editor_open, S).clicked() {
                        self.transition_editor_open = !self.transition_editor_open;
                        if self.transition_editor_open { self.status = "Scanning transitions.".to_string(); }
                    }
                    ui.separator();
                    if has_area && self.icons.label_button(ui, "New", "new-shoot", S).clicked() {
                        self.new_object_open = true;
                        self.new_object_type = "creature".to_string();
                        self.new_object_resref.clear();
                        self.new_object_tag.clear();
                        // Place at camera target (center of viewport)
                        if let Some(cam) = self.viewport.camera_state() {
                            let (tx, ty, tz) = (cam.target[0], cam.target[1], cam.target[2]);
                            // Renderer coords (x, z, -y) -> NWN coords (x, -z, y)
                            self.new_object_x = tx;
                            self.new_object_y = -tz;
                            self.new_object_z = ty;
                        } else {
                            self.new_object_x = 0.0;
                            self.new_object_y = 0.0;
                            self.new_object_z = 0.0;
                        }
                        self.new_object_bearing = 0.0;
                    }
                    if has_area && self.icons.label_button(ui, "Copy", "select", S).clicked() {
                        self.copy_selected_object();
                    }
                    if has_area && self.icons.label_button(ui, "Paste", "hand", S).clicked() {
                        self.paste_object(target_format);
                    }
                    if has_area && self.icons.label_button(ui, "Del", "trash-can", S).clicked() {
                        self.delete_selected_object();
                    }
                    ui.separator();
                    if self.icons.label_button(ui, "Undo", "return-arrow", S).clicked() {
                        self.undo(target_format);
                    }
                    if self.icons.label_button(ui, "Redo", "forward-field", S).clicked() {
                        self.redo(target_format);
                    }
                    if has_mod && self.icons.big_label_button(ui, "COMPILE!", "play-button").clicked() {
                        let nwnsc_path = nwnsc_exe();
                        let tmp_dir = std::env::temp_dir().join("aurora_nwnsc");
                        let _ = std::fs::remove_dir_all(&tmp_dir);
                        let _ = std::fs::create_dir_all(&tmp_dir);
                        // Only embed nwscript.nss when NWN is not installed, otherwise let
                        // the game's version (found via -n) take priority.
                        if detect_nwn_install().is_none() {
                            let _ = std::fs::write(tmp_dir.join("nwscript.nss"), NWSCRIPT_NSS);
                        }
                        // Build semicolon-separated include path: tmp_dir + loose script dirs
                        let mut include_paths = tmp_dir.to_string_lossy().to_string();
                        if let Some(ref module) = self.module {
                            let parent = module.path.parent();
                            for area in module.area_names() {
                                if let Some(p) = parent {
                                    let nss_dir = p.join(area).join("nss");
                                    if nss_dir.is_dir() {
                                        include_paths.push(';');
                                        include_paths.push_str(&nss_dir.to_string_lossy());
                                    }
                                }
                            }
                        }
                        // Custom user include directory (NOT added to -i; resolved by include resolver above)
                        let user_include_dir = std::path::PathBuf::from(std::env::var("HOME").unwrap_or_default()).join("Documents/Neverwinter Nights/include");
                        let scripts: Vec<(String, String)> = self.module.as_ref().map(|m| {
                            // Files that should use the user include dir version instead of
                            // the module ERF stub (which may lack needed declarations).
let skip = ["nwscript", "prc_inc_spells", "nw_i0_generic", "x0_i0_spawncond", "x3_inc_horse", "x2_inc_compon", "se_respawn_inc", "staticspawn", "shardrecovery", "shardrecovery1", "bosskill", "pc_eviladjust", "nw_o2_coninclude", "sd_ai_inc_spawn"];
                                m.script_names().into_iter().filter_map(|name| {
                                if skip.contains(&name) { return None; }
                                let source = m.get_script_source(name)?;
                                let nss_path = tmp_dir.join(format!("{}.nss", name));
                                // Filter out lines that define constants which conflict with
                                // EE nwscript.nss (the module ERF may contain old stub includes
                                // that duplicate constants now defined by the game's nwscript).
                                let filtered: String = if name == "prc_inc_spells" || name == "nw_i0_generic" {
                    let s: String = source.lines()
                .filter(|line| {
                    let t = line.trim();
                    !t.starts_with("const int EFFECT_TYPE_SLEEP")
                    && !t.starts_with("const int AI_LEVEL_")
                    && !t.starts_with("const int EVENT_")
                })
                .collect::<Vec<_>>()
                .join("\n");
                                    // Append PRC constant missing from EE nwscript.nss
                                    s
                                } else if name == "mk_inc_body" {
                                    source.replace("int MK_SetBodyPart(", "void MK_SetBodyPart(")
                                } else {
                                    format!("#include \"_prc_constants\"\n{}", source)
                                };
                                let _ = std::fs::write(&nss_path, filtered.as_bytes());
                                Some((name.to_string(), filtered))
                            }).collect()
                        }).unwrap_or_default();
                        // Write NWNX scripts AFTER module scripts so they take priority
                        for (name, data) in NWNX_SCRIPTS {
                            let _ = std::fs::write(tmp_dir.join(name), data);
                        }
                        let _ = std::fs::write(tmp_dir.join("_prc_constants.nss"), PRC_CONSTANTS_NSS);
                        if let Some(ref module) = self.module {
                            let nn_dir = std::path::PathBuf::from(std::env::var("HOME").unwrap_or_default()).join("Documents/Neverwinter Nights");
                            let sd_paths = [
                                nn_dir.join("development/sd_ai_inc_spawn.nss"),
                                nn_dir.join("development_ch2/sd_ai_inc_spawn.nss"),
                            ];
                            let sd_content = sd_paths.iter().find_map(|p| std::fs::read_to_string(p).ok())
                                .or_else(|| {
                                    let d = module.get_resource_data("sd_ai_inc_spawn", nwn_gamemodel::resource_types::NSS);
                                    d.map(|b| String::from_utf8_lossy(&b).to_string())
                                });
                            if let Some(c) = sd_content {
                                let _ = std::fs::write(tmp_dir.join("sd_ai_inc_spawn.nss"), format!("#include \"x2_inc_switches\"\n{}", c).as_bytes());
                            }
                        }
                        // Resolve #include "..." from haks/game data and write to temp dir
                        let loose_nss_dirs: Vec<std::path::PathBuf> = self.module.as_ref().map(|m| {
                            let parent = m.path.parent().unwrap_or(std::path::Path::new("."));
                            m.area_names().iter().filter_map(|area| {
                                let d = parent.join(area).join("nss");
                                if d.is_dir() { Some(d) } else { None }
                            }).collect()
                        }).unwrap_or_default();
                        if let Some(ref module) = self.module {
                            let mut resolved: std::collections::HashSet<String> = std::collections::HashSet::new();
                            let mut queue: Vec<String> = scripts.iter().map(|(n, _)| n.clone()).collect();
                            let mut found_count = 0;
                            let mut missing_count = 0;
                            while let Some(name) = queue.pop() {
                                if resolved.contains(&name) { continue; }
                                // nwscript and nwnx_sql are already in the temp dir
                                // (from -l flag and NWNX_SCRIPTS respectively).
                                // Skip include resolution for them to prevent overwriting
                                // with old versions from the module ERF or user include dir.
                                if ["nwscript", "nwnx_sql"].contains(&name.as_str()) {
                                    resolved.insert(name);
                                    continue;
                                }
                                // Already in tmp dir (module script with constant), preserve it
                                if std::fs::read(tmp_dir.join(format!("{}.nss", name))).is_ok() {
                                    resolved.insert(name.clone());
                                    for line in std::fs::read_to_string(tmp_dir.join(format!("{}.nss", name))).unwrap().lines() {
                                        let trimmed = line.trim();
                                        if trimmed.starts_with("#include") {
                                            if let Some(start) = trimmed.find('"') {
                                                if let Some(end) = trimmed[start+1..].find('"') {
                                                    let include_name = trimmed[start+1..start+1+end].trim().to_lowercase();
                                                    if !resolved.contains(&include_name) && std::fs::read(tmp_dir.join(format!("{}.nss", include_name))).is_err() {
                                                        queue.push(include_name);
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    continue;
                                }
let prefer_user_include = ["x0_i0_spawncond", "x3_inc_horse", "x2_inc_compon", "prc_inc_spells", "nw_i0_generic", "se_respawn_inc", "staticspawn", "shardrecovery", "shardrecovery1", "bosskill", "pc_eviladjust", "prc_inc_leadersh", "nw_o2_coninclude"];
                                let src = if prefer_user_include.contains(&name.as_str()) && std::fs::read(user_include_dir.join(format!("{}.nss", name))).is_ok() {
                                    let data = if name == "prc_inc_spells" {
                                        // Use full version but filter out conflicts with EE nwscript.nss,
                                        // the inc_item_props include (which leads to inc_persistsql → NSC1040),
                                        // and append missing PRC constants.
                                        let mut content = std::fs::read_to_string(user_include_dir.join("prc_inc_spells.nss")).unwrap();
                                        content = content.lines()
                                            .filter(|line| {
                                                let t = line.trim();
                                                !t.starts_with("const int EFFECT_TYPE_SLEEP")
                                                && !t.starts_with("const int AI_LEVEL_")
                                                && !t.starts_with("const int EVENT_")
                                                && !t.starts_with("#include \"inc_item_props\"")
                                            })
                                            .collect::<Vec<_>>()
                                            .join("\n");
                                        content.into_bytes()
                                    } else if name == "nw_i0_generic" {
                                        let mut content = std::fs::read_to_string(user_include_dir.join("nw_i0_generic.nss")).unwrap();
                                        content = format!("#include \"x0_i0_equip\"\n{}", content);
                                        content = content.lines()
                                            .filter(|line| {
                                                let t = line.trim();
                                                !t.starts_with("const int EFFECT_TYPE_SLEEP")
                                                && !t.starts_with("const int AI_LEVEL_")
                                                && !t.starts_with("const int EVENT_")
                                            })
                                            .collect::<Vec<_>>()
                                            .join("\n");
                                        content.into_bytes()
                                    } else if name == "se_respawn_inc" {
                                        let mut content = std::fs::read_to_string(user_include_dir.join("se_respawn_inc.nss")).unwrap();
                                        content = content.lines()
                                            .filter(|line| !line.trim().contains("#include \"se_respawn_inc\""))
                                            .collect::<Vec<_>>()
                                            .join("\n");
                                        content = format!("#include \"_prc_constants\"\n{}", content);
                                        content.into_bytes()
                                    } else if name == "prc_inc_leadersh" {
                                        let mut content = std::fs::read_to_string(user_include_dir.join("prc_inc_leadersh.nss")).unwrap();
                                        content = content.replace("GenerateBossTreasure(oCohort);", "GenerateBossTreasure(oCohort, OBJECT_SELF);");
                                        content.into_bytes()
                                    } else {
                                        std::fs::read(user_include_dir.join(format!("{}.nss", name))).unwrap()
                                    };
                                    let _ = std::fs::write(tmp_dir.join(format!("{}.nss", name)), &data);
                                    found_count += 1;
                                    String::from_utf8_lossy(&data).to_string()
                                } else if let Some(s) = module.get_script_source(&name) {
                                    s.to_string()
                                } else if !["nwscript", "nwnx_sql"].contains(&name.as_str()) && std::fs::read(user_include_dir.join(format!("{}.nss", name))).is_ok() {
                                    // DON'T copy nwscript.nss from user include dir — it has
                                    // duplicate constants that confuse the compiler. The -l flag
                                    // provides the correct one from game data.
                                    let data = std::fs::read(user_include_dir.join(format!("{}.nss", name))).unwrap();
                                    let _ = std::fs::write(tmp_dir.join(format!("{}.nss", name)), &data);
                                    found_count += 1;
                                    String::from_utf8_lossy(&data).to_string()
                                } else if !["nwscript", "nwnx_sql"].contains(&name.as_str()) && module.get_resource_data(&name, nwn_gamemodel::resource_types::NSS).is_some() {
                                    let data = module.get_resource_data(&name, nwn_gamemodel::resource_types::NSS).unwrap();
                                    let _ = std::fs::write(tmp_dir.join(format!("{}.nss", name)), &data);
                                    found_count += 1;
                                    String::from_utf8_lossy(&data).to_string()
                                } else if let Some(data) = loose_nss_dirs.iter().find_map(|d| std::fs::read(d.join(format!("{}.nss", name))).ok()) {
                                    let _ = std::fs::write(tmp_dir.join(format!("{}.nss", name)), &data);
                                    found_count += 1;
                                    String::from_utf8_lossy(&data).to_string()
                                } else {
                                    missing_count += 1;
                                    if missing_count <= 20 {
                                        eprintln!("[compile_inc] MISSING: {}", name);
                                    }
                                    continue;
                                };
                                resolved.insert(name);
                                for line in src.lines() {
                                    let trimmed = line.trim();
                                    if trimmed.starts_with("#include") {
                                        if let Some(start) = trimmed.find('"') {
                                            if let Some(end) = trimmed[start+1..].find('"') {
                                                let include_name = trimmed[start+1..start+1+end].trim().to_lowercase();
                                                if !resolved.contains(&include_name)
                                                    && std::fs::read(tmp_dir.join(format!("{}.nss", include_name))).is_err()
                                                {
                                                    queue.push(include_name);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            eprintln!("[compile_inc] Includes resolved: {}, unresolved: {}", found_count, missing_count);
                        }
                        let total = scripts.len();
                        let progress = Arc::new(AtomicUsize::new(0));
                        self.compile_progress = Some((progress.clone(), total));
                        self.status = format!("Compiling 0/{} scripts...", total);
                            let (tx, rx) = tokio::sync::oneshot::channel::<CompileAllResult>();
                            let np = nwnsc_path;
                            let ti = tmp_dir.clone();
                            let inc_paths = include_paths;
                            background_tasks::spawn_blocking(move || {
                                let pool = rayon::ThreadPoolBuilder::new()
                                    .num_threads(8)
                                    .build()
                                    .unwrap();
                                let out_dir = ti.join("out");
                                let _ = std::fs::create_dir_all(&out_dir);
                                let results = std::sync::Mutex::new(Vec::new());
                                let errors = std::sync::Mutex::new(Vec::new());
                                pool.scope(|s| {
                                    for (name, _) in &scripts {
                                        let name = name.clone();
                                        let np = np.clone();
                                        let ti = ti.clone();
                                        let inc_paths = inc_paths.clone();
                                        let out_dir = out_dir.clone();
                                        let results = &results;
                                        let errors = &errors;
                                        let progress = &progress;
                                        s.spawn(move |_| {
                                            let in_path = ti.join(format!("{}.nss", name));
                                            let out_path = out_dir.join(format!("{}.ncs", name));
                                            let mut child = match std::process::Command::new(&np)
                                                .arg("-l")
                                                .arg("-e")
                                            .arg("-i").arg(&inc_paths)
                                            .arg("-n").arg(detect_nwn_install().map(|p| p.to_string_lossy().to_string()).unwrap_or_default())
                                            .arg("-q")
                                            .arg("-w")
                                            .arg("-r").arg(&out_path)
                                                .arg(&in_path)
                                                .stdin(std::process::Stdio::null())
                                                .stdout(std::process::Stdio::piped())
                                                .stderr(std::process::Stdio::piped())
                                                .spawn()
                                            {
                                                Ok(c) => c,
                                                Err(e) => {
                                                    progress.fetch_add(1, Ordering::Relaxed);
                                                    errors.lock().unwrap().push((name, e.to_string()));
                                                    return;
                                                }
                                            };
                                            let start = std::time::Instant::now();
                                            loop {
                                                if start.elapsed() > std::time::Duration::from_secs(30) {
                                                    let _ = child.kill();
                                                    let _ = child.wait();
                                                    progress.fetch_add(1, Ordering::Relaxed);
                                                    errors.lock().unwrap().push((name, "Timeout (30s)".to_string()));
                                                    break;
                                                }
                                                match child.try_wait() {
                                                    Ok(Some(status)) => {
                                                        let stdout = child.stdout.take().map(|mut s| { let mut b = Vec::new(); let _ = std::io::Read::read_to_end(&mut s, &mut b); b }).unwrap_or_default();
                                                        let stderr = child.stderr.take().map(|mut s| { let mut b = Vec::new(); let _ = std::io::Read::read_to_end(&mut s, &mut b); b }).unwrap_or_default();
                                                        let msg = format!("{}{}", String::from_utf8_lossy(&stdout), String::from_utf8_lossy(&stderr));
                                                        progress.fetch_add(1, Ordering::Relaxed);
                                                        if status.success() {
                                                            if let Ok(ncs_data) = std::fs::read(&out_path) {
                                                                results.lock().unwrap().push((name, ncs_data));
                                                            }
                                                        } else {
                                                            errors.lock().unwrap().push((name, msg));
                                                        }
                                                        break;
                                                    }
                                                    Ok(None) => {
                                                        std::thread::sleep(std::time::Duration::from_millis(100));
                                                    }
                                                    Err(e) => {
                                                        progress.fetch_add(1, Ordering::Relaxed);
                                                        errors.lock().unwrap().push((name, e.to_string()));
                                                        break;
                                                    }
                                                }
                                            }
                                        });
                                    }
                                });
                                let _ = tx.send(CompileAllResult {
                                    results: results.into_inner().unwrap(),
                                    errors: errors.into_inner().unwrap(),
                                });
                            });
                            self.pending_compile_all = Some(rx);
                    }
                    // Right side: bookmarks + NWSync
                    ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                        if has_area {
                            if self.icons.icon_button(ui, "bookmark", "Add Camera Bookmark", 16.0).clicked() {
                                let idx = self.camera_bookmarks.len() + 1;
                                if let Some(cam) = self.viewport.camera_state() {
                                    self.camera_bookmarks.push(CameraBookmark {
                                        name: format!("Bookmark {}", idx),
                                        target: cam.target, yaw: cam.theta, pitch: cam.phi, distance: cam.radius,
                                    });
                                    self.status = format!("Camera bookmark '{}' added.", idx);
                                }
                            }
                            if !self.camera_bookmarks.is_empty() {
                                egui::menu::menu_button(ui, "BMs", |ui| {
                                    let mut to_remove = None;
                                    for (i, bm) in self.camera_bookmarks.iter().enumerate() {
                                        if ui.button(&bm.name).clicked() {
                                            self.viewport.set_camera(&nwn_3d::OrbitCamera {
                                                target: bm.target, theta: bm.yaw, phi: bm.pitch, radius: bm.distance, aspect: 1.0,
                                            });
                                            ui.close_menu();
                                        }
                                        if ui.button(format!("Del {}", bm.name)).clicked() { to_remove = Some(i); }
                                    }
                                    if let Some(i) = to_remove { self.camera_bookmarks.remove(i); }
                                });
                            }
                        }
                        if has_mod {
                            let nwsync_path = self.nwsync_output_path.clone();
                            if self.icons.icon_button(ui, "recycle", "NWSync Export", 16.0).clicked() {
                                if let Some(folder) = rfd::FileDialog::new().pick_folder() { self.nwsync_output_path = Some(folder); }
                            }
                            if let Some(ref out_dir) = nwsync_path {
                                ui.label(format!("{}", out_dir.display()));
                                let busy = self.nwsync_busy;
                                if ui.add_enabled(!busy, egui::Button::new("Write")).clicked() {
                                    self.nwsync_busy = true;
                                    self.status = "Writing NWSync...".to_string();
                                    let mod_path = self.module.as_ref().map(|m| m.path.clone()).unwrap_or_default();
                                    let out = out_dir.clone();
                                    let lbl = self.module.as_ref().map(|m| m.name.clone()).unwrap_or_default();
                                    let result = self.nwsync_result.clone();
                                    let hak_dir = nwn_user_dir().join("hak");
                                    std::thread::spawn(move || {
                                        let msg = match nwsync_gen::gen_nwsync(&mod_path, &hak_dir, &out, &lbl) {
                                            Ok(()) => format!("NWSync write OK for {}", lbl),
                                            Err(e) => format!("NWSync write FAILED for {}: {}", lbl, e),
                                        };
                                        if let Ok(mut r) = result.lock() { *r = Some(msg); }
                                    });
                                }
                            }
                        }
                    });
                });
            });
        });

        // ===================== FLOATING WINDOWS =====================
        // Module properties popup
        if self.module_props_popup {
            egui::Window::new("Module Properties")
                .default_size([400.0, 300.0])
                .show(ctx, |ui| {
                    egui::Grid::new("module_props_grid").num_columns(2).show(ui, |ui| {
                        ui.label("Name:");
                        ui.text_edit_singleline(&mut self.module_name_edit);
                        ui.end_row();

                        ui.label("Tag:");
                        ui.text_edit_singleline(&mut self.module_tag_edit);
                        ui.end_row();

                        ui.label("Entry Area:");
                        ui.text_edit_singleline(&mut self.module_entry_edit);
                        ui.end_row();

                        ui.label("Description:");
                        ui.text_edit_multiline(&mut self.module_description_edit);
                        ui.end_row();
                    });
                    if ui.button("Save").clicked() {
                        module_props_changed = true;
                        self.module_props_popup = false;
                    }
                });
        }

        // Area properties popup
        if self.area_props_popup {
            let mut changed = false;
            egui::Window::new("Area Properties")
                .default_size([400.0, 350.0])
                .show(ctx, |ui| {
                    egui::Grid::new("area_props_grid").num_columns(2).show(ui, |ui| {
                        ui.label("ResRef (read-only):");
                        ui.label(&self.area_props_resref);
                        ui.end_row();

                        ui.label("Tileset (read-only):");
                        ui.label(&self.area_props_tileset);
                        ui.end_row();

                        ui.label("Name:");
                        changed |= ui.text_edit_singleline(&mut self.area_props_name).changed();
                        ui.end_row();

                        ui.label("Tag:");
                        changed |= ui.text_edit_singleline(&mut self.area_props_tag).changed();
                        ui.end_row();
                    });
                    ui.separator();
                    ui.heading("Lighting");
                    if let Some(ref mut area) = self.current_area {
                        let area_mut = Arc::make_mut(area);
                        egui::Grid::new("area_lighting_grid").num_columns(2).show(ui, |ui| {
                            ui.label("Sun Ambient:");
                            changed |= ui.color_edit_button_srgb(&mut area_mut.sun_ambient_color).changed();
                            ui.end_row();
                            ui.label("Sun Diffuse:");
                            changed |= ui.color_edit_button_srgb(&mut area_mut.sun_diffuse_color).changed();
                            ui.end_row();
                            ui.label("Sun Fog Amount:");
                            changed |= ui.add(egui::Slider::new(&mut area_mut.sun_fog_amount, 0..=255)).changed();
                            ui.end_row();
                            ui.label("Sun Fog Color:");
                            changed |= ui.color_edit_button_srgb(&mut area_mut.sun_fog_color).changed();
                            ui.end_row();
                            ui.label("Moon Ambient:");
                            changed |= ui.color_edit_button_srgb(&mut area_mut.moon_ambient_color).changed();
                            ui.end_row();
                            ui.label("Moon Diffuse:");
                            changed |= ui.color_edit_button_srgb(&mut area_mut.moon_diffuse_color).changed();
                            ui.end_row();
                            ui.label("Moon Fog Amount:");
                            changed |= ui.add(egui::Slider::new(&mut area_mut.moon_fog_amount, 0..=255)).changed();
                            ui.end_row();
                            ui.label("Moon Fog Color:");
                            changed |= ui.color_edit_button_srgb(&mut area_mut.moon_fog_color).changed();
                            ui.end_row();
                            ui.label("Fog Clip Distance:");
                            changed |= ui.add(egui::Slider::new(&mut area_mut.fog_clip_dist, 0.0..=500.0)).changed();
                            ui.end_row();
                        });
                    }
                    if changed {
                        if let Some(ref mut area) = self.current_area {
                            if area.name != self.area_props_name || area.tag != self.area_props_tag {
                                let area_mut = Arc::make_mut(area);
                                area_mut.name = self.area_props_name.clone();
                                area_mut.tag = self.area_props_tag.clone();
                            }
                            let resref = area.resref.clone();
                            if let Some(ref mut module) = self.module {
                                module.update_area_are(&resref, area);
                            }
                            self.area_version = self.area_version.wrapping_add(1);
                            self.viewport.set_area(area.clone(), self.area_version, target_format);
                        }
                    }
                    if ui.button("Close").clicked() {
                        self.area_props_popup = false;
                    }
                });
        }

        // Local Variables editor
        if let Some(ref mut lve) = self.local_var_editor {
            let mut close = false;
            egui::Window::new("Local Variables")
                .default_size([500.0, 300.0])
                .show(ctx, |ui| {
                    egui::ScrollArea::both().show(ui, |ui| {
                        let mut ops: Vec<(usize, &str)> = Vec::new();
                        egui::Grid::new("local_vars_grid").num_columns(5).striped(true).show(ui, |ui| {
                            ui.label("Name"); ui.label("Type"); ui.label("Value"); ui.label(""); ui.label("");
                            ui.end_row();
                            let len = lve.vars.len();
                            for i in 0..len {
                                {
                                    let v = &mut lve.vars[i];
                                    ui.text_edit_singleline(&mut v.name);
                                    egui::ComboBox::from_id_salt(("var_type", i))
                                        .selected_text(&v.var_type.clone())
                                        .show_ui(ui, |ui| {
                                            ui.selectable_value(&mut v.var_type, "int".to_string(), "int");
                                            ui.selectable_value(&mut v.var_type, "float".to_string(), "float");
                                            ui.selectable_value(&mut v.var_type, "string".to_string(), "string");
                                            ui.selectable_value(&mut v.var_type, "object".to_string(), "object");
                                        });
                                    ui.text_edit_singleline(&mut v.value);
                                }
                                if ui.button("+").clicked() {
                                    ops.push((i, "insert"));
                                }
                                if ui.button("−").clicked() {
                                    ops.push((i, "remove"));
                                }
                                ui.end_row();
                            }
                        });
                        for op in ops.iter().rev() {
                            match op.1 {
                                "insert" => lve.vars.insert(op.0 + 1, LocalVar { name: String::new(), var_type: "int".to_string(), value: "0".to_string() }),
                                "remove" => { lve.vars.remove(op.0); }
                                _ => {}
                            }
                        }
                        if ui.button("+ Add Variable").clicked() {
                            lve.vars.push(LocalVar { name: String::new(), var_type: "int".to_string(), value: "0".to_string() });
                        }
                    });
                    ui.separator();
                    if ui.button("Save").clicked() {
                        if let (Some(area), Some(ref mut module)) = (self.current_area.as_ref(), self.module.as_mut()) {
                            save_local_vars_to_git(module, &area.resref, &lve.obj_type, lve.obj_idx, &lve.vars);
                        }
                        close = true;
                    }
                    if ui.button("Cancel").clicked() {
                        close = true;
                    }
                });
            if close {
                self.local_var_editor = None;
            }
        }

        // Appearance picker
        if let Some(ref mut ap) = self.appearance_picker {
            let mut close = false;
            egui::Window::new("Appearance Picker")
                .default_size([500.0, 400.0])
                .show(ctx, |ui| {
                    ui.horizontal(|ui| {
                        ui.label("Filter:");
                        ui.text_edit_singleline(&mut ap.filter);
                    });
                    ui.separator();
                    egui::ScrollArea::both().show(ui, |ui| {
                        egui::Grid::new("appearance_grid").num_columns(2).striped(true).show(ui, |ui| {
                            for entry in &ap.appearances {
                                if !ap.filter.is_empty() && !entry.label.to_lowercase().contains(&ap.filter.to_lowercase()) && !entry.model.to_lowercase().contains(&ap.filter.to_lowercase()) {
                                    continue;
                                }
                                if ui.selectable_label(false, &entry.label).clicked() {
                                    let area_resref = self.current_area.as_ref().map(|a| a.resref.clone()).unwrap_or_default();
                                    let mut should_rebuild = false;
                                    if let Some(ref mut module) = self.module {
                                        set_object_appearance(module, &area_resref, &ap.obj_type, ap.obj_idx, entry.id);
                                        if let Some(ref mut obj) = self.selected_object {
                                            for p in obj.bag.properties.iter_mut() {
                                                if p.label == "Appearance" {
                                                    p.value = nwn_gamemodel::PropertyValue::Int(entry.id);
                                                    break;
                                                }
                                            }
                                        }
                                        if let Some(area) = self.current_area.as_mut() {
                                            let area = Arc::make_mut(area);
                                            let model_name = match ap.obj_type.as_str() {
                                                "creature" => area.creatures.get_mut(ap.obj_idx).and_then(|c| {
                                                    let name = module.resolve_creature_model(entry.id, &c.resref);
                                                    c.model_name = name.clone();
                                                    name
                                                }),
                                                "placeable" => area.placeables.get_mut(ap.obj_idx).and_then(|p| {
                                                    let name = module.resolve_placeable_model(entry.id, &p.resref);
                                                    p.model_name = name.clone();
                                                    name
                                                }),
                                                "door" => area.doors.get_mut(ap.obj_idx).and_then(|d| {
                                                    let name = module.resolve_door_model(entry.id, &d.resref);
                                                    d.model_name = name.clone();
                                                    name
                                                }),
                                                _ => None,
                                            };
                                            if model_name.is_some() {
                                                should_rebuild = true;
                                            }
                                        }
                                    }
                                    if should_rebuild {
                                        if let Some(area) = self.current_area.as_ref().map(|a| a.as_ref().clone()) {
                                            self.area_version = self.area_version.wrapping_add(1);
                                            self.viewport.set_area(Arc::new(area), self.area_version, target_format);
                                        }
                                    } else {
                                    }
                                    self.status = format!("Appearance set to {} ({})", entry.label, entry.id);
                                    close = true;
                                }
                                ui.label(&entry.model);
                                ui.end_row();
                            }
                        });
                    });
                    if ui.button("Cancel").clicked() {
                        close = true;
                    }
                });
            if close {
                self.appearance_picker = None;
            }
        }

        // Object comment editor
        if let Some(ref mut comment_state) = self.object_comment_edit {
            let mut close = false;
            let (ref obj_type, obj_idx, ref mut comment) = *comment_state;
            egui::Window::new(format!("Comment - {} #{}", obj_type, obj_idx))
                .default_size([400.0, 200.0])
                .show(ctx, |ui| {
                    ui.label("Edit object comment/notes:");
                    ui.text_edit_multiline(comment);
                    if ui.button("Save").clicked() {
                        if let Some(ref mut module) = self.module {
                            save_object_comment(module, &self.current_area.as_ref().map(|a| a.resref.clone()).unwrap_or_default(), obj_type, obj_idx, comment);
                        }
                        close = true;
                    }
                    if ui.button("Cancel").clicked() {
                        close = true;
                    }
                });
            if close {
                self.object_comment_edit = None;
            }
        }

        // Inventory editor
        let inv_resrefs = self.module.as_ref().map(module_resref_names).unwrap_or_default();
        let inv_tags = self.module.as_ref().map(module_tag_names).unwrap_or_default();
        if let Some(ref mut inv) = self.inventory_editor {
            let mut close = false;
            egui::Window::new(format!("Inventory - {} #{}", inv.obj_type, inv.obj_idx))
                .default_size([500.0, 400.0])
                .show(ctx, |ui| {
                    if let Some(edit_idx) = inv.editing_item {
                        if let Some(item) = inv.items.get_mut(edit_idx) {
                            ui.heading(format!("Item #{}", edit_idx));
                            ui.separator();
                            let modified = show_bag_editor(ui, item, &inv_resrefs, &inv_tags, self.module.as_ref().map(|m| &m.resource_manager));
                            if modified {
                                let resref = self.current_area.as_ref().map(|a| a.resref.clone()).unwrap_or_default();
                                save_item_list(self.module.as_mut(), &resref, &inv.obj_type, inv.obj_idx, &inv.items);
                            }
                            if ui.button("← Back to List").clicked() {
                                inv.editing_item = None;
                            }
                        } else {
                            inv.editing_item = None;
                        }
                    } else {
                        ui.horizontal(|ui| {
                            ui.heading("Items");
                            if ui.button("+ Add from Blueprint").clicked() {
                                let mut results = Vec::new();
                                if let Some(ref module) = self.module {
                                    if let Some(ref erf) = module.erf {
                                        for r in erf.resources() {
                                            if r.restype == nwn_gamemodel::resource_types::UTI {
                                                results.push((r.resref.clone(), r.restype));
                                            }
                                        }
                                    }
                                }
                                inv.add_blueprint_filter = String::new();
                                inv.add_blueprint_results = results;
                            }
                        });
                        ui.separator();
                        egui::ScrollArea::vertical().show(ui, |ui| {
                            let mut remove_idx: Option<usize> = None;
                            for (i, item) in inv.items.iter().enumerate() {
                                let res = item.properties.iter().find(|p| p.label == "InventoryRes")
                                    .map(|p| match &p.value { nwn_gamemodel::PropertyValue::ResRef(s) => s.clone(), nwn_gamemodel::PropertyValue::CExoString(s) => s.clone(), _ => format!("{:?}", p.value) })
                                    .unwrap_or_else(|| format!("Item #{}", i));
                                let extra = item.properties.iter().find(|p| p.label == "StackSize")
                                    .and_then(|p| match &p.value { nwn_gamemodel::PropertyValue::Int(v) => Some(*v), _ => None })
                                    .map(|s| format!(" (x{})", s))
                                    .unwrap_or_default();
                                ui.horizontal(|ui| {
                                    if self.icons.icon_button(ui, "pencil", "Edit Item", 16.0).clicked() {
                                        inv.editing_item = Some(i);
                                    }
                                    ui.label(format!("{}{}", res, extra));
                                    if self.icons.icon_button(ui, "trash-can", "Remove Item", 16.0).clicked() {
                                        remove_idx = Some(i);
                                    }
                                });
                            }
                            if let Some(idx) = remove_idx {
                                inv.items.remove(idx);
                                let resref = self.current_area.as_ref().map(|a| a.resref.clone()).unwrap_or_default();
                                save_item_list(self.module.as_mut(), &resref, &inv.obj_type, inv.obj_idx, &inv.items);
                            }
                        });
                        if !inv.add_blueprint_filter.is_empty() || !inv.add_blueprint_results.is_empty() {
                            ui.separator();
                            ui.label("Search blueprints:");
                            ui.text_edit_singleline(&mut inv.add_blueprint_filter);
                            let mut selected: Option<String> = None;
                            egui::ScrollArea::vertical().max_height(200.0).show(ui, |ui| {
                                let filter = inv.add_blueprint_filter.clone();
                                for (name, _rt) in &inv.add_blueprint_results {
                                    if !filter.is_empty() && !name.to_lowercase().contains(&filter.to_lowercase()) {
                                        continue;
                                    }
                                    if ui.selectable_label(false, name).clicked() {
                                        selected = Some(name.clone());
                                    }
                                }
                            });
                            if let Some(ref blueprint_name) = selected {
                                let mut item = PropertyBag::new();
                                item.properties.push(nwn_gamemodel::Property {
                                    label: "InventoryRes".into(),
                                    value: nwn_gamemodel::PropertyValue::ResRef(blueprint_name.clone()),
                                    field_type: 11,
                                    category: String::new(),
                                    description: String::new(),
                                });
                                item.properties.push(nwn_gamemodel::Property {
                                    label: "StackSize".into(),
                                    value: nwn_gamemodel::PropertyValue::Int(1),
                                    field_type: 5,
                                    category: String::new(),
                                    description: String::new(),
                                });
                                inv.items.push(item);
                                let resref = self.current_area.as_ref().map(|a| a.resref.clone()).unwrap_or_default();
                                save_item_list(self.module.as_mut(), &resref, &inv.obj_type, inv.obj_idx, &inv.items);
                                inv.add_blueprint_results.clear();
                                inv.add_blueprint_filter.clear();
                            }
                            if ui.button("Close Blueprint Picker").clicked() {
                                inv.add_blueprint_results.clear();
                                inv.add_blueprint_filter.clear();
                            }
                        }
                        ui.separator();
                        if ui.button("Close Inventory").clicked() {
                            close = true;
                        }
                    }
                });
            if close {
                self.inventory_editor = None;
            }
        }

        // ===================== GRAPH AREA VIEW =====================
        if self.graph_view_open {
            let mut open = true;
            // Clone area for read-only use inside the window closure
            let area_clone = self.current_area.clone();
            let mut out_selection: Option<(String, usize)> = None;
            let mut out_select_tile: Option<(usize, usize)> = None;
            let mut area_update: Option<(String, String, usize, f32, f32)> = None;
            egui::Window::new("Graph Area View")
                .default_size([500.0, 400.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    if let Some(ref area) = area_clone {
                        ui.horizontal(|ui| {
                            ui.label(format!("Area: {}  {}x{}", area.resref, area.width, area.height));
                            if ui.button("Reset View").clicked() {
                                self.graph_view_state.pan_x = 0.0;
                                self.graph_view_state.pan_y = 0.0;
                                self.graph_view_state.zoom = 8.0;
                            }
                        });
                        ui.horizontal_wrapped(|ui| {
                            ui.checkbox(&mut self.graph_view_state.filter_creatures, "Creatures");
                            ui.checkbox(&mut self.graph_view_state.filter_doors, "Doors");
                            ui.checkbox(&mut self.graph_view_state.filter_placeables, "Placeables");
                            ui.checkbox(&mut self.graph_view_state.filter_triggers, "Triggers");
                            ui.checkbox(&mut self.graph_view_state.filter_waypoints, "Waypoints");
                            ui.checkbox(&mut self.graph_view_state.filter_encounters, "Encounters");
                            ui.checkbox(&mut self.graph_view_state.filter_sound_emitters, "Sound");
                        });
                        ui.separator();
                        let (resp, painter) = ui.allocate_painter(ui.available_size(), egui::Sense::click_and_drag());
                        let rect = resp.rect;
                        let aw = area.width as f32 * 10.0;
                        let ah = area.height as f32 * 10.0;
                        let zoom = self.graph_view_state.zoom.max(1.0);
                        let cx = rect.center().x + self.graph_view_state.pan_x;
                        let cy = rect.center().y + self.graph_view_state.pan_y;
                        let to_screen = |wx: f32, wy: f32| -> egui::Pos2 {
                            egui::pos2(
                                cx + (wx - aw / 2.0) * zoom,
                                cy - (wy - ah / 2.0) * zoom,
                            )
                        };
                        let to_world = |sx: f32, sy: f32| -> (f32, f32) {
                            let wx = (sx - cx) / zoom + aw / 2.0;
                            let wy = -(sy - cy) / zoom + ah / 2.0;
                            (wx, wy)
                        };
                        // Draw tiles
                        let tile_start_col = ((rect.left() - cx) / zoom + aw / 2.0 / 10.0).floor() as i32 - 1;
                        let tile_end_col = ((rect.right() - cx) / zoom + aw / 2.0 / 10.0).ceil() as i32 + 1;
                        let tile_start_row = (-(rect.bottom() - cy) / zoom + ah / 2.0 / 10.0).floor() as i32 - 1;
                        let tile_end_row = (-(rect.top() - cy) / zoom + ah / 2.0 / 10.0).ceil() as i32 + 1;
                        for row in tile_start_row.max(0)..tile_end_row.min(area.height as i32) {
                            for col in tile_start_col.max(0)..tile_end_col.min(area.width as i32) {
                                let idx = (row as usize) * area.width as usize + (col as usize);
                                let color = area.tiles.get(idx).map(|t| {
                                    let id = t.id as u32;
                                    let r = ((id * 137 + 53) % 200 + 55) as u8;
                                    let g = ((id * 251 + 97) % 200 + 55) as u8;
                                    let b = ((id * 199 + 173) % 200 + 55) as u8;
                                    egui::Color32::from_rgb(r, g, b)
                                }).unwrap_or(egui::Color32::from_gray(40));
                                let p0 = to_screen(col as f32 * 10.0, row as f32 * 10.0);
                                let p1 = to_screen((col + 1) as f32 * 10.0, (row + 1) as f32 * 10.0);
                                let t_rect = egui::Rect::from_min_max(
                                    egui::pos2(p0.x.min(p1.x), p0.y.min(p1.y)),
                                    egui::pos2(p0.x.max(p1.x), p0.y.max(p1.y)),
                                );
                                painter.rect_filled(t_rect, 0.0, color);
                                // Highlight selected tile
                                if let Some((sel_col, sel_row)) = self.selected_tile {
                                    let is_sel = sel_row == row as usize && sel_col == col as usize;
                                    painter.rect_stroke(t_rect, 0.0, egui::Stroke::new(if is_sel { 3.0 } else { 0.5_f32 }, if is_sel { egui::Color32::GREEN } else { egui::Color32::from_gray(60) }), egui::StrokeKind::Outside);
                                } else {
                                    painter.rect_stroke(t_rect, 0.0, egui::Stroke::new(0.5_f32, egui::Color32::from_gray(60)), egui::StrokeKind::Outside);
                                }
                            }
                        }
                        let selected = self.selected_obj_info.clone();
                        macro_rules! draw_objects {
                            ($list:expr, $typ:expr, $color:expr) => {{
                                for (i, obj) in $list.iter().enumerate() {
                                    let sp = to_screen(obj.x, obj.y);
                                    if !rect.contains(sp) { continue; }
                                    let is_sel = selected.as_ref().map_or(false, |(t, idx)| t == $typ && *idx == i);
                                    let radius = if is_sel { 6.0 } else { 4.0 };
                                    let fill = if is_sel { egui::Color32::WHITE } else { $color };
                                    painter.circle_filled(sp, radius, fill);
                                    if is_sel {
                                        painter.circle_stroke(sp, radius + 2.0, egui::Stroke::new(2.0_f32, egui::Color32::WHITE));
                                    }
                                    if zoom > 12.0 {
                                        let label_pos = egui::pos2(sp.x + 6.0, sp.y - 4.0);
                                        painter.text(label_pos, egui::Align2::LEFT_CENTER, &obj.graph_label(), egui::FontId::proportional(10.0), egui::Color32::WHITE);
                                    }
                                }
                            }};
                        }
                        macro_rules! hit_test_objects {
                            ($list:expr, $typ:expr, $hp:expr, $closest:expr) => {
                                for (i, obj) in $list.iter().enumerate() {
                                    let sp = to_screen(obj.x, obj.y);
                                    let dist = $hp.distance(sp);
                                    if dist < 12.0 {
                                        if $closest.as_ref().map_or(true, |(_, _, d)| dist < *d) {
                                            $closest = Some(($typ.to_string(), i, dist));
                                        }
                                    }
                                }
                            };
                        }
                        if self.graph_view_state.filter_creatures {
                            draw_objects!(area.creatures, "creature", egui::Color32::RED);
                        }
                        if self.graph_view_state.filter_doors {
                            draw_objects!(area.doors, "door", egui::Color32::YELLOW);
                        }
                        if self.graph_view_state.filter_placeables {
                            draw_objects!(area.placeables, "placeable", egui::Color32::BLUE);
                        }
                        if self.graph_view_state.filter_triggers {
                            draw_objects!(area.triggers, "trigger", egui::Color32::GREEN);
                        }
                        if self.graph_view_state.filter_waypoints {
                            draw_objects!(area.waypoints, "waypoint", egui::Color32::WHITE);
                        }
                        if self.graph_view_state.filter_encounters {
                            draw_objects!(area.encounters, "encounter", egui::Color32::from_rgb(255, 128, 0));
                        }
                        if self.graph_view_state.filter_sound_emitters {
                            draw_objects!(area.sound_emitters, "sound_emitter", egui::Color32::CYAN);
                        }
                        // Input handling
                        let hover_pos = resp.hover_pos();
                        let clicked = resp.clicked();
                        let drag_delta = resp.drag_delta();
                        let scroll = ui.input(|i| i.raw_scroll_delta);
                        if resp.hovered() && scroll.y != 0.0 {
                            let old_zoom = self.graph_view_state.zoom;
                            self.graph_view_state.zoom = (self.graph_view_state.zoom * (1.0 + scroll.y * 0.002)).clamp(1.0, 100.0);
                            if let Some(hp) = hover_pos {
                                let factor = self.graph_view_state.zoom / old_zoom;
                                let mx = hp.x - cx;
                                let my = hp.y - cy;
                                self.graph_view_state.pan_x = self.graph_view_state.pan_x * factor - mx * (factor - 1.0);
                                self.graph_view_state.pan_y = self.graph_view_state.pan_y * factor - my * (factor - 1.0);
                            }
                        }
                        if resp.dragged_by(egui::PointerButton::Secondary) || resp.dragged_by(egui::PointerButton::Middle) {
                            self.graph_view_state.pan_x += drag_delta.x;
                            self.graph_view_state.pan_y += drag_delta.y;
                        }
                        if clicked {
                            if let Some(hp) = hover_pos {
                                let mut closest: Option<(String, usize, f32)> = None;
                                if self.graph_view_state.filter_creatures {
                                    hit_test_objects!(area.creatures, "creature", hp, closest);
                                }
                                if self.graph_view_state.filter_doors {
                                    hit_test_objects!(area.doors, "door", hp, closest);
                                }
                                if self.graph_view_state.filter_placeables {
                                    hit_test_objects!(area.placeables, "placeable", hp, closest);
                                }
                                if self.graph_view_state.filter_triggers {
                                    hit_test_objects!(area.triggers, "trigger", hp, closest);
                                }
                                if self.graph_view_state.filter_waypoints {
                                    hit_test_objects!(area.waypoints, "waypoint", hp, closest);
                                }
                                if self.graph_view_state.filter_encounters {
                                    hit_test_objects!(area.encounters, "encounter", hp, closest);
                                }
                                if self.graph_view_state.filter_sound_emitters {
                                    hit_test_objects!(area.sound_emitters, "sound_emitter", hp, closest);
                                }
                                if let Some((typ, idx, _)) = closest {
                                    out_selection = Some((typ, idx));
                                } else {
                                    let (wx, wy) = to_world(hp.x, hp.y);
                                    let col = (wx / 10.0).floor() as usize;
                                    let row = (wy / 10.0).floor() as usize;
                                    if col < area.width as usize && row < area.height as usize {
                                        out_select_tile = Some((col, row));
                                    }
                                }
                            }
                        }
                        // Drag object to move (left-click drag on selected object)
                        if resp.dragged_by(egui::PointerButton::Primary) && resp.hovered() && self.selected_obj_info.is_some() {
                            if let Some(hp) = hover_pos {
                                if let Some((ref obj_type, obj_idx)) = self.selected_obj_info.clone() {
                                    let (wx, wy) = to_world(hp.x, hp.y);
                                    let (nx, ny) = snap_to_grid_pos(wx, wy, true, 10.0);
                                    area_update = Some((obj_type.clone(), area.resref.clone(), obj_idx, nx, ny));
                                }
                            }
                        }
                    } else {
                        ui.label("No area loaded.");
                    }
                });
            if !open {
                self.graph_view_open = false;
            }
            // Apply selection changes outside closure
            if let Some((ref typ, idx)) = out_selection {
                if let Some(ref area) = self.current_area {
                    let bag = match typ.as_str() {
                        "creature" => area.creatures.get(idx).map(|c| c.to_property_bag()),
                        "door" => area.doors.get(idx).map(|d| d.to_property_bag()),
                        "placeable" => area.placeables.get(idx).map(|p| p.to_property_bag()),
                        "trigger" => area.triggers.get(idx).map(|t| t.to_property_bag()),
                        "waypoint" => area.waypoints.get(idx).map(|w| w.to_property_bag()),
                        "encounter" => area.encounters.get(idx).map(|e| e.to_property_bag()),
                        "sound_emitter" => area.sound_emitters.get(idx).map(|s| s.to_property_bag()),
                        _ => None,
                    };
                    if let Some(bag) = bag {
                        self.selected_object = Some(SelectedObject { title: format!("{} #{}", typ, idx), bag });
                        self.selected_obj_info = Some((typ.clone(), idx));
                        self.selection_list.clear();
                        self.status = format!("Selected {} #{}", typ, idx);
                    }
                }
            }
            if let Some((col, row)) = out_select_tile {
                self.selected_tile = Some((col, row));
                self.selected_object = None;
                self.selected_obj_info = None;
                self.selection_list.clear();
                self.status = format!("Selected tile ({}, {})", col, row);
            }
            // Apply drag-move updates outside closure
            if let Some((obj_type, area_resref, obj_idx, nx, ny)) = area_update {
                if let Some(ref mut area) = self.current_area {
                    let area_mut = Arc::make_mut(area);
                    match obj_type.as_str() {
                        "creature" => if let Some(obj) = area_mut.creatures.get_mut(obj_idx) { obj.x = nx; obj.y = ny; }
                        "door" => if let Some(obj) = area_mut.doors.get_mut(obj_idx) { obj.x = nx; obj.y = ny; }
                        "placeable" => if let Some(obj) = area_mut.placeables.get_mut(obj_idx) { obj.x = nx; obj.y = ny; }
                        "trigger" => if let Some(obj) = area_mut.triggers.get_mut(obj_idx) { obj.x = nx; obj.y = ny; }
                        "waypoint" => if let Some(obj) = area_mut.waypoints.get_mut(obj_idx) { obj.x = nx; obj.y = ny; }
                        "encounter" => if let Some(obj) = area_mut.encounters.get_mut(obj_idx) { obj.x = nx; obj.y = ny; }
                        "sound_emitter" => if let Some(obj) = area_mut.sound_emitters.get_mut(obj_idx) { obj.x = nx; obj.y = ny; }
                        _ => {}
                    }
                    if let Some(ref mut module) = self.module {
                        module.update_area_git(&area_resref, area);
                    }
                    self.area_version = self.area_version.wrapping_add(1);
                }
            }
        }

        // ===================== HEIGHT MAP VIEW =====================
        if self.height_map_open {
            let mut open = true;
            let mut area_modified = false;
            egui::Window::new("Height Map")
                .default_size([500.0, 400.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    let hms = &mut self.height_map_state;
                    ui.horizontal(|ui| {
                        ui.label("Brush:");
                        ui.add(egui::Slider::new(&mut hms.brush_size, 1..=10).text("Size"));
                        ui.add(egui::Slider::new(&mut hms.brush_amount, 1..=50).text("Amount"));
                    });
                    ui.horizontal(|ui| {
                        if ui.button("Reset View").clicked() {
                            hms.pan_x = 0.0;
                            hms.pan_y = 0.0;
                            hms.zoom = 20.0;
                        }
                        ui.checkbox(&mut hms.show_heights, "Show Values");
                        ui.label("Left-click: raise  Shift+click: lower");
                    });
                    ui.separator();
                    if let Some(ref area) = self.current_area.clone() {
                        let (resp, painter) = ui.allocate_painter(ui.available_size(), egui::Sense::click_and_drag());
                        let rect = resp.rect;
                        let aw = area.width as f32;
                        let ah = area.height as f32;
                        let zoom = hms.zoom.max(2.0);
                        let tile_px = zoom;
                        let cx = rect.center().x + hms.pan_x;
                        let cy = rect.center().y + hms.pan_y;
                        let to_screen = |col: f32, row: f32| -> egui::Pos2 {
                            egui::pos2(
                                cx + (col - aw / 2.0) * tile_px,
                                cy + (row - ah / 2.0) * tile_px,
                            )
                        };
                        let to_grid = |sx: f32, sy: f32| -> (i32, i32) {
                            let col = ((sx - cx) / tile_px + aw / 2.0).floor() as i32;
                            let row = ((sy - cy) / tile_px + ah / 2.0).floor() as i32;
                            (col, row)
                        };
                        let col_start = ((rect.left() - cx) / tile_px + aw / 2.0).floor() as i32 - 1;
                        let col_end = ((rect.right() - cx) / tile_px + aw / 2.0).ceil() as i32 + 1;
                        let row_start = ((rect.top() - cy) / tile_px + ah / 2.0).floor() as i32 - 1;
                        let row_end = ((rect.bottom() - cy) / tile_px + ah / 2.0).ceil() as i32 + 1;
                        for row in row_start.max(0)..row_end.min(area.height as i32) {
                            for col in col_start.max(0)..col_end.min(area.width as i32) {
                                let idx = (row as usize) * area.width as usize + (col as usize);
                                let height = area.tiles.get(idx).map(|t| t.height).unwrap_or(0);
                                // Color gradient: 0=blue, 64=green, 128=yellow, 192=orange, 255=red
                                let (r, g, b) = height_to_color(height);
                                let p0 = to_screen(col as f32, row as f32);
                                let p1 = to_screen((col + 1) as f32, (row + 1) as f32);
                                let t_rect = egui::Rect::from_min_max(p0, p1);
                                painter.rect_filled(t_rect, 0.0, egui::Color32::from_rgb(r, g, b));
                                painter.rect_stroke(t_rect, 0.0, egui::Stroke::new(0.5_f32, egui::Color32::from_gray(40)), egui::StrokeKind::Outside);
                                if hms.show_heights && zoom > 8.0 {
                                    let center = t_rect.center();
                                    painter.text(center, egui::Align2::CENTER_CENTER, &format!("{}", height), egui::FontId::proportional(8.0), egui::Color32::WHITE);
                                }
                            }
                        }
                        // Handle click to raise/lower
                        let clicked = resp.clicked();
                        let dragged = resp.dragged_by(egui::PointerButton::Primary);
                        let scroll = ui.input(|i| i.raw_scroll_delta);
                        if resp.hovered() && scroll.y != 0.0 {
                            hms.zoom = (hms.zoom * (1.0 + scroll.y * 0.003)).clamp(2.0, 200.0);
                        }
                        if resp.dragged_by(egui::PointerButton::Secondary) || resp.dragged_by(egui::PointerButton::Middle) {
                            hms.pan_x += resp.drag_delta().x;
                            hms.pan_y += resp.drag_delta().y;
                        }
                        if (clicked || dragged) && resp.hovered() {
                            if let Some(hp) = resp.hover_pos() {
                                let (gcol, grow) = to_grid(hp.x, hp.y);
                                let half = hms.brush_size / 2;
                                let shift = ui.input(|i| i.modifiers.shift);
                                let amount = if shift { -hms.brush_amount } else { hms.brush_amount };
                                self.push_undo();
                                if let Some(ref mut area_mut) = self.current_area {
                                    let area_mut = Arc::make_mut(area_mut);
                                    for dr in -half..=half {
                                        for dc in -half..=half {
                                            let r = grow + dr;
                                            let c = gcol + dc;
                                            if r >= 0 && r < area_mut.height && c >= 0 && c < area_mut.width {
                                                let idx = (r as usize) * area_mut.width as usize + (c as usize);
                                                let new_h = (area_mut.tiles[idx].height + amount).clamp(0, 255);
                                                area_mut.tiles[idx].height = new_h;
                                            }
                                        }
                                    }
                                    area_modified = true;
                                }
                            }
                        }
                    } else {
                        ui.label("No area loaded.");
                    }
                });
            if !open {
                self.height_map_open = false;
            }
            if area_modified {
                if let Some(ref area) = self.current_area {
                    let resref = area.resref.clone();
                    if let Some(ref mut module) = self.module {
                        module.update_area_are(&resref, area);
                    }
                    self.area_version = self.area_version.wrapping_add(1);
                    self.viewport.set_area(area.clone(), self.area_version, target_format);
                    self.status = "Height map edited.".to_string();
                }
            }
        }

        // ===================== AREA TRANSITION EDITOR =====================
        if self.transition_editor_open {
            let mut open = true;
            let mut saved_any = false;
            let mut save_results: Vec<(String, String, String, String)> = Vec::new();
            egui::Window::new("Area Transition Editor")
                .default_size([700.0, 500.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    if let Some(ref module) = self.module {
                        ui.label("Objects with transitions (doors/triggers that link to another area).");
                        ui.separator();
                        let area_names = module.area_names();
                        if area_names.is_empty() {
                            ui.label("No areas in module.");
                            return;
                        }
                        egui::ScrollArea::both().show(ui, |ui| {
                            for area_resref in area_names {
                                let git_key = area_resref.trim().to_lowercase();
                                let git_data = module.raw_git.get(&git_key).cloned()
                                    .or_else(|| {
                                        module.erf.as_ref().and_then(|erf| {
                                            erf.get(area_resref.trim(), resource_types::GIT)
                                                .or_else(|| erf.get(&area_resref.trim().to_uppercase(), resource_types::GIT))
                                        })
                                    });
                                let gff = git_data.as_deref().and_then(|d| nwn_gff::GffFile::from_bytes(d).ok());
                                if gff.is_none() { continue; }
                                let gff = gff.unwrap();
                                let mut has_any = false;
                                // Check Door_List for transitions
                                if let Some(door_list) = gff.root().find("Door_List").and_then(|fv| match fv { nwn_gff::FieldValue::List(l) => Some(l), _ => None }) {
                                    for (i, door) in door_list.iter().enumerate() {
                                        let is_transition = door.find("Transition").and_then(|fv| match fv { nwn_gff::FieldValue::Int(v) => Some(*v != 0), _ => None }).unwrap_or(false);
                                        if !is_transition { continue; }
                                        has_any = true;
                                        let tag = door.find("Tag").and_then(|fv| match fv { nwn_gff::FieldValue::String(s) => Some(s.clone()), _ => None }).unwrap_or_default();
                                        let dest_area = door.find("TransitionDestin").and_then(|fv| match fv { nwn_gff::FieldValue::ResRef(s) => Some(s.clone()), nwn_gff::FieldValue::String(s) => Some(s.clone()), _ => None }).unwrap_or_default();
                                        let dest_tag = door.find("TransitionDestinTag").and_then(|fv| match fv { nwn_gff::FieldValue::String(s) => Some(s.clone()), _ => None }).unwrap_or_default();
                                        let header = format!("Door \"{}\" -> {} ({})", tag, dest_area, dest_tag);
                                        let id = egui::Id::new(("trans_door", area_resref.clone(), i));
                                        egui::CollapsingHeader::new(header)
                                            .id_salt(id)
                                            .default_open(false)
                                            .show(ui, |ui| {
                                                ui.horizontal(|ui| {
                                                    ui.label("Destination Area:");
                                                    let area_combo_id = egui::Id::new(("trans_area_combo", area_resref.clone(), i));
                                                    egui::ComboBox::from_id_salt(area_combo_id)
                                                        .selected_text(&dest_area)
                                                        .show_ui(ui, |ui| {
                                                            for an in area_names {
                                                                if ui.selectable_label(false, an).clicked() && an != &dest_area {
                                                                    save_results.push((area_resref.clone(), "Door_List".to_string(), i.to_string(), format!("TransitionDestin:{}", an)));
                                                                }
                                                            }
                                                        });
                                                });
                                                ui.horizontal(|ui| {
                                                    ui.label("To Waypoint:");
                                                    let new_tag = &mut dest_tag.clone();
                                                    if ui.text_edit_singleline(new_tag).changed() {
                                                    }
                                                    if ui.button("Save Waypoint").clicked() {
                                                        let val = new_tag.clone();
                                                        save_results.push((area_resref.clone(), "Door_List".to_string(), i.to_string(), format!("TransitionDestinTag:{}", val)));
                                                    }
                                                });
                                            });
                                    }
                                }
                                // Check Trigger_List for transitions
                                if let Some(trigger_list) = gff.root().find("Trigger_List").and_then(|fv| match fv { nwn_gff::FieldValue::List(l) => Some(l), _ => None }) {
                                    for (i, trigger) in trigger_list.iter().enumerate() {
                                        let transition = trigger.find("Transition").and_then(|fv| match fv { nwn_gff::FieldValue::Int(v) => Some(*v != 0), _ => None }).unwrap_or(false);
                                        let has_destin = trigger.find("TransitionDestin").is_some();
                                        if !transition && !has_destin { continue; }
                                        has_any = true;
                                        let tag = trigger.find("Tag").and_then(|fv| match fv { nwn_gff::FieldValue::String(s) => Some(s.clone()), _ => None }).unwrap_or_default();
                                        let dest_area = trigger.find("TransitionDestin").and_then(|fv| match fv { nwn_gff::FieldValue::ResRef(s) => Some(s.clone()), nwn_gff::FieldValue::String(s) => Some(s.clone()), _ => None }).unwrap_or_default();
                                        let dest_tag = trigger.find("TransitionDestinTag").and_then(|fv| match fv { nwn_gff::FieldValue::String(s) => Some(s.clone()), _ => None }).unwrap_or_default();
                                        let header = format!("Trigger \"{}\" -> {} ({})", tag, dest_area, dest_tag);
                                        let id = egui::Id::new(("trans_trigger", area_resref.clone(), i));
                                        egui::CollapsingHeader::new(header)
                                            .id_salt(id)
                                            .default_open(false)
                                            .show(ui, |ui| {
                                                ui.horizontal(|ui| {
                                                    ui.label("Destination Area:");
                                                    let area_combo_id = egui::Id::new(("trans_trig_combo", area_resref.clone(), i));
                                                    egui::ComboBox::from_id_salt(area_combo_id)
                                                        .selected_text(&dest_area)
                                                        .show_ui(ui, |ui| {
                                                            for an in area_names {
                                                                if ui.selectable_label(false, an).clicked() && an != &dest_area {
                                                                    save_results.push((area_resref.clone(), "Trigger_List".to_string(), i.to_string(), format!("TransitionDestin:{}", an)));
                                                                }
                                                            }
                                                        });
                                                });
                                                ui.horizontal(|ui| {
                                                    ui.label("To Waypoint:");
                                                    let new_tag = &mut dest_tag.clone();
                                                    ui.text_edit_singleline(new_tag);
                                                    if ui.button("Save Waypoint").clicked() {
                                                        let val = new_tag.clone();
                                                        save_results.push((area_resref.clone(), "Trigger_List".to_string(), i.to_string(), format!("TransitionDestinTag:{}", val)));
                                                    }
                                                });
                                            });
                                    }
                                }
                                if has_any {
                                    ui.separator();
                                }
                            }
                        });
                    } else {
                        ui.label("No module loaded.");
                    }
                });
            if !open {
                self.transition_editor_open = false;
            }
            // Apply saves outside closure
            for (area_resref, list_name, idx_str, action) in save_results {
                let idx: usize = match idx_str.parse() { Ok(i) => i, Err(_) => continue };
                let git_key = area_resref.trim().to_lowercase();
                let data = {
                    let m = match self.module.as_ref() {
                        Some(m) => m,
                        None => continue,
                    };
                    m.raw_git.get(&git_key).cloned()
                        .or_else(|| {
                            m.erf.as_ref().and_then(|erf| {
                                erf.get(area_resref.trim(), resource_types::GIT)
                                    .or_else(|| erf.get(&area_resref.trim().to_uppercase(), resource_types::GIT))
                            })
                        })
                };
                let mut gff = match data {
                    Some(ref d) => match nwn_gff::GffFile::from_bytes(d) { Ok(g) => g, Err(_) => continue },
                    None => continue,
                };
                let list_fv = match gff.root_mut().find_mut(&list_name) {
                    Some(fv) => fv,
                    None => continue,
                };
                let list = match list_fv {
                    nwn_gff::FieldValue::List(l) => l,
                    _ => continue,
                };
                let obj_struct = match list.get_mut(idx) {
                    Some(s) => s,
                    None => continue,
                };
                let parts: Vec<&str> = action.splitn(2, ':').collect();
                if parts.len() != 2 { continue; }
                let field_name = parts[0];
                let field_value = parts[1];
                let new_field_value = if field_name == "TransitionDestin" { nwn_gff::FieldValue::ResRef(field_value.to_string()) }
                                 else { nwn_gff::FieldValue::String(field_value.to_string()) };
                // Look for existing field and update, or push new
                let mut found = false;
                for f in obj_struct.fields.iter_mut() {
                    let label_str: String = f.label.to_string();
                    if label_str == field_name {
                        f.value = new_field_value;
                        found = true;
                        break;
                    }
                }
                if !found {
                    use std::str::FromStr;
                    let fss: nwn_lib_rs::parsing::FixedSizeString<16> = FromStr::from_str(field_name).unwrap_or_default();
                    obj_struct.fields.push(nwn_gff::Field { label: std::rc::Rc::new(fss), value: if field_name == "TransitionDestin" { nwn_gff::FieldValue::ResRef(field_value.to_string()) } else { nwn_gff::FieldValue::String(field_value.to_string()) } });
                }
                let new_data = gff.to_bytes();
                if let Some(ref mut module) = self.module {
                    module.raw_git.insert(git_key.to_string(), new_data);
                    module.modified = true;
                }
                saved_any = true;
            }
            if saved_any {
                // Reload current area if it's the one we edited
                if let Some(ref area) = self.current_area {
                    let key = area.resref.trim().to_lowercase();
                    if let Some(ref mut module) = self.module {
                        if let Some(git_data) = module.raw_git.get(&key) {
                            if let Ok(git_gff) = nwn_gff::GffFile::from_bytes(git_data) {
                                let area_resref = area.resref.clone();
                                let area_mut = Arc::make_mut(self.current_area.as_mut().unwrap());
                                nwn_gamemodel::reload_from_git(area_mut, &git_gff);
                                module.update_area_git(&area_resref, area_mut);
                            }
                        }
                    }
                    self.area_version = self.area_version.wrapping_add(1);
                    self.viewport.set_area(self.current_area.clone().unwrap(), self.area_version, target_format);
                }
                self.status = "Transition(s) saved.".to_string();
            }
        }

        // ===================== MODULE TREE VIEW =====================
        if self.module_tree_open {
            let mut open = true;
            egui::Window::new("Module Tree View")
                .default_size([450.0, 600.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    if let Some(ref module) = self.module {
                        egui::ScrollArea::both().show(ui, |ui| {
                            // Areas
                            let area_names = module.area_names();
                            ui.horizontal(|ui| {
                                ui.label("Search:");
                                ui.text_edit_singleline(&mut self.area_search);
                            });
                            let area_filter = self.area_search.to_lowercase();
                            egui::CollapsingHeader::new(format!("Areas ({})", area_names.len()))
                                .default_open(true)
                                .show(ui, |ui| {
                                    for name in area_names {
                                        let display = module.area_display_name(name);
                                        if !area_filter.is_empty() && !name.to_lowercase().contains(&area_filter) && !display.to_lowercase().contains(&area_filter) { continue; }
                                        let git_key = name.trim().to_lowercase();
                                        let counts = module.raw_git.get(&git_key).and_then(|d| {
                                            nwn_gff::GffFile::from_bytes(d).ok()
                                        }).map(|gff| {
                                            let cats = ["Creature_List", "Door_List", "Placeable_List", "Trigger_List", "Waypoint_List", "Encounter_List", "SoundEmitter_List"];
                                            let names = ["creatures", "doors", "placeables", "triggers", "waypoints", "encounters", "sounds"];
                                            let mut parts = Vec::new();
                                            for (i, cat) in cats.iter().enumerate() {
                                                let count = gff.root().find(cat).and_then(|fv| match fv { nwn_gff::FieldValue::List(l) => Some(l.len()), _ => None }).unwrap_or(0);
                                                if count > 0 { parts.push(format!("{}{}", count, &names[i][..1])); }
                                            }
                                            parts.join(" ")
                                        }).unwrap_or_default();
                                        let label = if display == *name {
                                            format!("  {}  [{}]", name, counts)
                                        } else {
                                            format!("  {} ({})  [{}]", display, name, counts)
                                        };
                                        if ui.selectable_label(false, label).clicked() {
                                            // We can't switch areas here easily due to borrows, just show a status
                                            self.status = format!("Double-click area '{}' in area list to switch.", name);
                                        }
                                    }
                                });
                            // Scripts
                            let scripts: Vec<String> = module.erf.as_ref().map(|erf| {
                                erf.resources().iter().filter(|r| r.restype == resource_types::NSS).map(|r| format!("{}.nss", r.resref)).collect()
                            }).unwrap_or_default();
                            egui::CollapsingHeader::new(format!("Scripts ({})", scripts.len()))
                                .default_open(false)
                                .show(ui, |ui| {
                                    for s in &scripts {
                                        if ui.selectable_label(false, format!("  {}", s)).clicked() {
                                            self.status = format!("Open '{}' in Script Editor via Tools menu.", s);
                                        }
                                    }
                                });
                            // Conversations
                            let convos: Vec<String> = module.erf.as_ref().map(|erf| {
                                erf.resources().iter().filter(|r| r.restype == resource_types::DLG).map(|r| format!("{}.dlg", r.resref)).collect()
                            }).unwrap_or_default();
                            egui::CollapsingHeader::new(format!("Conversations ({})", convos.len()))
                                .default_open(false)
                                .show(ui, |ui| {
                                    for c in &convos {
                                        ui.label(format!("  {}", c));
                                    }
                                });
                            // Blueprints grouped by type
                            let blueprint_types = [
                                (resource_types::UTC, "Creatures (UTC)"),
                                (resource_types::UTD, "Doors (UTD)"),
                                (resource_types::UTP, "Placeables (UTP)"),
                                (resource_types::UTT, "Triggers (UTT)"),
                                (resource_types::UTW, "Waypoints (UTW)"),
                                (resource_types::UTE, "Encounters (UTE)"),
                                (resource_types::UTS, "Sounds (UTS)"),
                                (resource_types::UTI, "Items (UTI)"),
                                (resource_types::UTM, "Stores (UTM)"),
                            ];
                            for &(restype, header) in &blueprint_types {
                                let items: Vec<String> = module.erf.as_ref().map(|erf| {
                                    erf.resources().iter().filter(|r| r.restype == restype).map(|r| r.resref.clone()).collect()
                                }).unwrap_or_default();
                                if items.is_empty() { continue; }
                                egui::CollapsingHeader::new(format!("{} ({})", header, items.len()))
                                    .default_open(false)
                                    .show(ui, |ui| {
                                        for item in &items {
                                            ui.label(format!("  {}", item));
                                        }
                                    });
                            }
                            // 2DAs
                            let twodas: Vec<String> = module.erf.as_ref().map(|erf| {
                                erf.resources().iter().filter(|r| r.restype == resource_types::TWO_DA).map(|r| r.resref.clone()).collect()
                            }).unwrap_or_default();
                            egui::CollapsingHeader::new(format!("2DAs ({})", twodas.len()))
                                .default_open(false)
                                .show(ui, |ui| {
                                    for t in &twodas {
                                        ui.label(format!("  {}", t));
                                    }
                                });
                        });
                    } else {
                        ui.label("No module loaded.");
                    }
                });
            if !open {
                self.module_tree_open = false;
            }
        }

        // ===================== FIND/REPLACE IN SCRIPTS =====================
        if self.find_replace_open {
            let mut open = true;
            egui::Window::new("Find/Replace in Scripts")
                .default_size([600.0, 400.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    let fr = &mut self.find_replace_state;
                    ui.horizontal(|ui| {
                        ui.label("Find:");
                        ui.text_edit_singleline(&mut fr.find_text);
                        if ui.button("Search").clicked() && !fr.find_text.is_empty() {
                            fr.results.clear();
                            if let Some(ref module) = self.module {
                                if let Some(ref erf) = module.erf {
                                    for res in erf.resources() {
                                        if res.restype != resource_types::NSS { continue; }
                                        if let Some(data) = erf.get(&res.resref, resource_types::NSS) {
                                            if let Ok(text) = String::from_utf8(data.clone()) {
                                                for (ln, line) in text.lines().enumerate() {
                                                    if line.to_lowercase().contains(&fr.find_text.to_lowercase()) {
                                                        fr.results.push(FindResult {
                                                            script_name: res.resref.clone(),
                                                            line_number: ln + 1,
                                                            line_text: line.to_string(),
                                                        });
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            fr.show_results = true;
                        }
                    });
                    if !fr.replace_text.is_empty() {
                        ui.horizontal(|ui| {
                            ui.label("Replace:");
                            ui.text_edit_singleline(&mut fr.replace_text);
                            if ui.button("Replace All").clicked() && !fr.find_text.is_empty() {
                                if let Some(ref mut module) = self.module {
                                    let find_lower = fr.find_text.to_lowercase();
                                    let mut count = 0;
                                    let new_resources: Vec<(String, u16, Vec<u8>)> = module.erf.as_ref().map(|erf| {
                                        erf.resources().iter().filter_map(|r| {
                                            if r.restype != resource_types::NSS { return None; }
                                            let data = erf.get(&r.resref, resource_types::NSS)?;
                                            let text = String::from_utf8(data.clone()).ok()?;
                                            if !text.to_lowercase().contains(&find_lower) { return None; }
                                            let new_text = text.replace(&fr.find_text, &fr.replace_text);
                                            count += 1;
                                            Some((r.resref.clone(), r.restype, new_text.into_bytes()))
                                        }).collect()
                                    }).unwrap_or_default();
                                    for (resref, _restype, data) in new_resources {
                                        module.update_script(&resref, &String::from_utf8_lossy(&data));
                                    }
                                    fr.show_results = false;
                                    fr.results.clear();
                                    self.status = format!("Replaced {} occurrence(s) in {} script(s).", count, count);
                                }
                            }
                        });
                    }
                    ui.separator();
                    if fr.show_results {
                        ui.label(format!("{} match(es)", fr.results.len()));
                        egui::ScrollArea::both().show(ui, |ui| {
                            egui::Grid::new("find_results").striped(true).show(ui, |ui| {
                                for r in &fr.results {
                                    ui.label(&r.script_name);
                                    ui.label(r.line_number.to_string());
                                    ui.label(&r.line_text);
                                    ui.end_row();
                                }
                            });
                        });
                    } else if self.module.is_some() {
                        ui.label("Enter search text and click 'Search'.");
                    } else {
                        ui.label("No module loaded.");
                    }
                });
            if !open {
                self.find_replace_open = false;
            }
        }

        // ===================== SOUND BROWSER =====================
        if self.sound_browser_open {
            let mut open = true;
            let audio_types = [resource_types::WAV];
            egui::Window::new("Sound Browser")
                .default_size([400.0, 500.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    if let Some(ref module) = self.module {
                        if let Some(ref erf) = module.erf {
                            let resources = erf.resources();
                            let sounds: Vec<&nwn_erf::ErfResource> = resources.iter().filter(|r| audio_types.contains(&r.restype)).collect();
                            if sounds.is_empty() {
                                ui.label("No audio resources found in module.");
                                return;
                            }
                            ui.label(format!("{} audio resources", sounds.len()));
                            ui.separator();
                            egui::ScrollArea::vertical().show(ui, |ui| {
                                for res in &sounds {
                                    let ext = if res.restype == resource_types::WAV { "wav" } else { "bmu" };
                                    let label = format!("{}.{}", res.resref, ext);
                                    ui.horizontal(|ui| {
                                        ui.label(&label);
                                        if ui.button("▶ Play").clicked() {
                                            if let Some(data) = erf.get(&res.resref, res.restype) {
                                                let tmp_path = format!("/tmp/opencode/{}.{}", res.resref, ext);
                                                let _ = std::fs::write(&tmp_path, &data);
                                                let result = std::process::Command::new("aplay")
                                                    .arg(&tmp_path).arg("-q").spawn();
                                                if result.is_err() {
                                                    let _ = std::process::Command::new("ffplay")
                                                        .arg(&tmp_path).arg("-nodisp").arg("-autoexit").arg("-loglevel").arg("quiet").spawn();
                                                }
                                            }
                                        }
                                        if ui.button("Export...").clicked() {
                                            if let Some(data) = erf.get(&res.resref, res.restype) {
                                                let ext = "wav";
                                                if let Some(path) = pick_save_path_filtered(&format!("{}.{}", res.resref, ext), "Audio", &[ext]) {
                                                    let _ = std::fs::write(&path, &data);
                                                }
                                            }
                                        }
                                    });
                                }
                            });
                        } else {
                            ui.colored_label(egui::Color32::RED, "No ERF loaded.");
                        }
                    } else {
                        ui.label("No module loaded.");
                    }
                });
            if !open {
                self.sound_browser_open = false;
            }
        }

        // ===================== STORE EDITOR =====================
        if self.store_editor_open {
            let mut open = true;
            let mut open_bag_editor: Option<(String, u16, PropertyBag)> = None;
            egui::Window::new("Store Editor")
                .default_size([500.0, 400.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    if let Some(ref module) = self.module {
                        if let Some(ref erf) = module.erf {
                            let resources = erf.resources();
                            let store_res: Vec<&nwn_erf::ErfResource> = resources.iter().filter(|r| r.restype == resource_types::UTM).collect();
                            if store_res.is_empty() {
                                ui.label("No store blueprints (UTM) found.");
                                return;
                            }
                            ui.label(format!("{} store(s)", store_res.len()));
                            ui.separator();
                            egui::ScrollArea::vertical().show(ui, |ui| {
                                for store in &store_res {
                                    let data = erf.get(&store.resref, resource_types::UTM);
                                    let bag = data.and_then(|d| nwn_gff::GffFile::from_bytes(&d).ok()).map(|gff| PropertyBag::from_gff_struct(gff.root()));
                                    let store_name = bag.as_ref().and_then(|b| b.get_string("StoreName")).unwrap_or(&store.resref).to_string();
                                    if ui.button(format!("{} ({})", store_name, store.resref)).clicked() {
                                        if let Some(b) = bag {
                                            open_bag_editor = Some((store.resref.clone(), resource_types::UTM, b));
                                        }
                                    }
                                }
                            });
                        }
                    } else {
                        ui.label("No module loaded.");
                    }
                });
            if !open {
                self.store_editor_open = false;
            }
        }

        // ===================== ID WHOIS UTILITY =====================
        if self.id_whois_open {
            let mut open = true;
            egui::Window::new("ID Whois Utility")
                .default_size([500.0, 500.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    if let Some(ref module) = self.module {
                        ui.label("Enter a ResRef to find where it is used across the module:");
                        ui.text_edit_singleline(&mut self.search_term);
                        if ui.button("Search").clicked() || ui.input(|i| i.key_pressed(egui::Key::Enter)) {
                            self.search_results.clear();
                            let term = self.search_term.to_lowercase();
                            if term.is_empty() { return; }
                            let area_names = module.area_names();

                            // Search in loaded area names/refs
                            for aname in area_names {
                                if aname.to_lowercase().contains(&term) {
                                    self.search_results.push(format!("Area ResRef: {}", aname));
                                }
                                if let Some(area) = module.get_area(aname) {
                                    if area.tag.to_lowercase().contains(&term) {
                                        self.search_results.push(format!("Area '{}' (tag: {})", aname, area.tag));
                                    }
                                    if area.name.to_lowercase().contains(&term) {
                                        self.search_results.push(format!("Area '{}' (name: {})", aname, area.name));
                                    }
                                    // Check object resrefs and tags
                                    for c in &area.creatures {
                                        if c.resref.to_lowercase().contains(&term) || c.tag.to_lowercase().contains(&term) {
                                            self.search_results.push(format!("Area {} / Creature '{}' (tag: {})", aname, c.resref, c.tag));
                                        }
                                    }
                                    for d in &area.doors {
                                        if d.resref.to_lowercase().contains(&term) || d.tag.to_lowercase().contains(&term) {
                                            self.search_results.push(format!("Area {} / Door '{}' (tag: {})", aname, d.resref, d.tag));
                                        }
                                    }
                                    for p in &area.placeables {
                                        if p.resref.to_lowercase().contains(&term) || p.tag.to_lowercase().contains(&term) {
                                            self.search_results.push(format!("Area {} / Placeable '{}' (tag: {})", aname, p.resref, p.tag));
                                        }
                                    }
                                    for t in &area.triggers {
                                        if t.resref.to_lowercase().contains(&term) || t.tag.to_lowercase().contains(&term) {
                                            self.search_results.push(format!("Area {} / Trigger '{}' (tag: {})", aname, t.resref, t.tag));
                                        }
                                    }
                                    for w in &area.waypoints {
                                        if w.tag.to_lowercase().contains(&term) {
                                            self.search_results.push(format!("Area {} / Waypoint '{}' (tag: {})", aname, w.resref, w.tag));
                                        }
                                    }
                                    for e in &area.encounters {
                                        if e.tag.to_lowercase().contains(&term) {
                                            self.search_results.push(format!("Area {} / Encounter (tag: {})", aname, e.tag));
                                        }
                                    }
                                    for s in &area.sound_emitters {
                                        if s.tag.to_lowercase().contains(&term) {
                                            self.search_results.push(format!("Area {} / Sound Emitter (tag: {})", aname, s.tag));
                                        }
                                    }
                                }
                            }

                            // Search ERF resource names
                            if let Some(ref erf) = module.erf {
                                for res in erf.resources() {
                                    let resref_lower = res.resref.to_lowercase();
                                    if resref_lower.contains(&term) {
                                        let ext = resource_types::type_to_ext(res.restype).unwrap_or("?");
                                        self.search_results.push(format!("Resource: {}.{}", res.resref, ext));
                                    }
                                    // Search script contents
                                    if res.restype == resource_types::NSS {
                                        if let Some(data) = erf.get(&res.resref, resource_types::NSS) {
                                            if let Ok(content) = String::from_utf8(data) {
                                                for (lineno, line) in content.lines().enumerate() {
                                                    if line.to_lowercase().contains(&term) {
                                                        self.search_results.push(format!("Script {}:{} — {}", res.resref, lineno + 1, line.trim()));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        ui.separator();
                        ui.label(format!("{} result(s)", self.search_results.len()));
                        ui.separator();
                        egui::ScrollArea::vertical().show(ui, |ui| {
                            for result in &self.search_results {
                                ui.label(result);
                            }
                        });
                    } else {
                        ui.label("No module loaded.");
                    }
                });
            if !open {
                self.id_whois_open = false;
            }
        }

        // Area Geometry Editor
        if self.geometry_editor.open {
            show_geometry_editor(&mut self.geometry_editor, ctx, self.current_area.as_ref());
            // Apply geometry changes from editor
            if let Some((typ, idx, new_geom)) = self.geometry_editor.commit.take() {
                self.push_undo();
                if let Some(ref mut module) = self.module {
                    if let Some(area) = self.current_area.as_mut() {
                        let area = Arc::make_mut(area);
                        match typ.as_str() {
                            "trigger" => {
                                if idx < area.triggers.len() {
                                    area.triggers[idx].geometry = new_geom;
                                    module.update_area_git(&area.resref, area);
                                }
                            }
                            "encounter" => {
                                if idx < area.encounters.len() {
                                    area.encounters[idx].geometry = new_geom;
                                    module.update_area_git(&area.resref, area);
                                }
                            }
                            _ => {}
                        }
                        self.area_version = self.area_version.wrapping_add(1);
                        self.viewport.set_area(Arc::new(area.clone()), self.area_version, target_format);
                    }
                }
            }
        }

        // Sky color override window
        if self.show_sky_override || self.clear_override_enabled {
            egui::Window::new("Sky Color Override")
                .default_size([200.0, 100.0])
                .show(ctx, |ui| {
                    let mut col = self.clear_override.unwrap_or([128, 150, 200]);
                    if ui.color_edit_button_srgb(&mut col).changed() {
                        self.clear_override = Some(col);
                        let c = self.clear_override.unwrap_or([128, 150, 200]);
                        self.viewport.set_clear_color(wgpu::Color {
                            r: c[0] as f64 / 255.0,
                            g: c[1] as f64 / 255.0,
                            b: c[2] as f64 / 255.0,
                            a: 1.0,
                        });
                    }
                    if ui.button("Reset to Area Default").clicked() {
                        self.clear_override = None;
                        self.clear_override_enabled = false;
                        self.area_version = self.area_version.wrapping_add(1);
                    }
                });
        }

        // Environment Settings dialog
        if self.env_settings_open {
            egui::Window::new("Environment Settings")
                .default_size([280.0, 400.0])
                .show(ctx, |ui| {
                    ui.label("Sun (Day)");
                    ui.horizontal(|ui| {
                        ui.label("Fog Amount");
                        ui.add(egui::Slider::new(&mut self.env_sun_fog_amount, 0..=255));
                    });
                    ui.horizontal(|ui| {
                        ui.label("Fog Color");
                        ui.color_edit_button_srgb(&mut self.env_sun_fog_color);
                    });
                    ui.horizontal(|ui| {
                        ui.label("Ambient");
                        ui.color_edit_button_srgb(&mut self.env_sun_ambient_color);
                    });
                    ui.separator();
                    ui.label("Moon (Night)");
                    ui.horizontal(|ui| {
                        ui.label("Fog Amount");
                        ui.add(egui::Slider::new(&mut self.env_moon_fog_amount, 0..=255));
                    });
                    ui.horizontal(|ui| {
                        ui.label("Fog Color");
                        ui.color_edit_button_srgb(&mut self.env_moon_fog_color);
                    });
                    ui.separator();
                    ui.horizontal(|ui| {
                        ui.label("Fog Clip Distance");
                        ui.add(egui::Slider::new(&mut self.env_fog_clip_dist, 1.0..=500.0));
                    });
                    ui.separator();
                    ui.horizontal(|ui| {
                        if ui.button("Apply").clicked() {
                            self.push_undo();
                            if let Some(ref mut area) = self.current_area {
                                let area_mut = Arc::make_mut(area);
                                area_mut.sun_fog_amount = self.env_sun_fog_amount;
                                area_mut.sun_fog_color = self.env_sun_fog_color;
                                area_mut.moon_fog_amount = self.env_moon_fog_amount;
                                area_mut.moon_fog_color = self.env_moon_fog_color;
                                area_mut.fog_clip_dist = self.env_fog_clip_dist;
                                area_mut.sun_ambient_color = self.env_sun_ambient_color;
                                let resref = area_mut.resref.clone();
                                if let Some(ref mut module) = self.module {
                                    module.update_area_are(&resref, area_mut);
                                }
                                self.area_version = self.area_version.wrapping_add(1);
                                self.viewport.set_area(area.clone(), self.area_version, target_format);
                                self.status = "Environment settings applied.".to_string();
                            }
                        }
                        if ui.button("Cancel").clicked() {
                            self.env_settings_open = false;
                        }
                    });
                });
        }

        // Texture Browser window
        if self.texture_browser.open {
            show_texture_browser(ctx, &mut self.texture_browser, &self.module);
        }

        // Tileset Browser window
        // Resource Viewer window
        if self.show_resource_viewer {
            egui::Window::new("Resource Viewer")
                .default_size([500.0, 400.0])
                .show(ctx, |ui| {
                    if let Some(ref module) = self.module {
                        show_resource_viewer(
                            ui, module,
                            &mut open_script,
                            &mut open_conversation,
                            &mut edit_blueprint,
                            &mut open_faction,
                            &mut open_journal,
                        );
                    } else {
                        ui.label("No module loaded.");
                    }
                });
        }

        // Handle blueprint editor requests from resource viewer
        if let Some((resref, restype, bytes)) = edit_blueprint {
            if let Ok(gff) = nwn_gff::GffFile::from_bytes(&bytes) {
                let bag = nwn_gamemodel::PropertyBag::from_gff_struct(gff.root());
                self.blueprint_editors.push((resref.clone(), restype, bag));
                self.status = format!("Opened blueprint editor for {}.{}", resref, type_to_ext(restype).unwrap_or("?"));
            }
        }
        if open_faction.is_some() {
            self.faction_editor_open = true;
        }
        if open_journal.is_some() {
            self.journal_editor_open = true;
        }

        // Palette selector window (always shown when palette is open)
        if self.show_palette {
            egui::Window::new("Palette")
                .default_size([300.0, 500.0])
                .show(ctx, |ui| {
                    egui::ComboBox::from_id_salt("palette_mode")
                        .selected_text(match self.palette_mode {
                            PaletteMode::Blueprints => "Blueprints",
                            PaletteMode::Tiles => "Tiles",
                        })
                        .show_ui(ui, |ui| {
                            ui.selectable_value(&mut self.palette_mode, PaletteMode::Blueprints, "Blueprints");
                            ui.selectable_value(&mut self.palette_mode, PaletteMode::Tiles, "Tiles");
                        });
                    ui.separator();
                    match self.palette_mode {
                        PaletteMode::Blueprints => {
                            if let Some(ref module) = self.module {
                                let mut place_cmd: Option<(String, String)> = None;
                                show_blueprint_palette(ui, &module.resource_manager, &mut place_cmd);
                                if let Some((typ, resref)) = place_cmd {
                                    self.status = format!("Placement mode: {} {}. Click in viewport to place.", typ, resref);
                                    self.placement_state = PlacementState::Pending(typ, resref);
                                }
                            }
                        }
                        PaletteMode::Tiles => {
                            ui.label("Use the Paint toggle in the View bar to open the tile selector.");
                        }
                    }
                });
        }
        // Tile palette window (shown when Paint is toggled on)
        if self.show_paint {
            let tileset_name = self.current_area.as_ref().map(|a| a.tileset.clone()).unwrap_or_default();
            let tiles_from_2da: Vec<(i32, String)> = if let Some(ref module) = self.module {
                get_tile_palette(module, &tileset_name)
            } else { Vec::new() };
            let mut paint_open = true;
            egui::Window::new("Paint")
                .id("paint_window".into())
                .default_size([300.0, 500.0])
                .open(&mut paint_open)
                .show(ctx, |ui| {
                    ui.label(format!("Tileset: {}", tileset_name));
                    ui.horizontal(|ui| {
                        ui.label("Filter:");
                        ui.text_edit_singleline(&mut self.tile_palette_filter);
                    });
                    ui.separator();
                    if tiles_from_2da.is_empty() {
                        ui.label(format!("No tileset data found for '{}'", tileset_name));
                    } else {
                        let mut filtered: Vec<(i32, String)> = tiles_from_2da.iter()
                            .filter(|(_, name)| {
                                self.tile_palette_filter.is_empty()
                                    || name.to_lowercase().contains(&self.tile_palette_filter.to_lowercase())
                            })
                            .cloned().collect();
                        filtered.sort_by_key(|(id, _)| *id);
                        ui.horizontal(|ui| {
                            ui.label("Auto:");
                            let fill_id = filtered.first().map(|(id, _)| *id).unwrap_or(0);
                            if ui.button("Fill All").clicked() {
                                self.fill_area_tiles(fill_id);
                                if let Some(ref area) = self.current_area {
                                    self.viewport.set_area(area.clone(), self.area_version, target_format);
                                }
                            }
                            if ui.button("Orient").clicked() {
                                self.auto_orient_tiles();
                                if let Some(ref area) = self.current_area {
                                    self.viewport.set_area(area.clone(), self.area_version, target_format);
                                }
                            }
                        });
                        ui.separator();
                        egui::Grid::new("paint_tile_grid").striped(true).show(ui, |ui| {
                            for (i, (tile_id, tile_name)) in filtered.iter().enumerate() {
                                if i % 4 == 0 && i > 0 { ui.end_row(); }
                                let shift = ui.input(|i| i.modifiers.shift);
                                if ui.button(format!("{}:{}", tile_id, tile_name)).clicked() {
                                    let paint_id = *tile_id;
                                    if shift {
                                        if let Some((tile_col, tile_row)) = self.selected_tile {
                                            self.tile_flood_fill(tile_col, tile_row, paint_id);
                                        }
                                    } else if let Some((tile_col, tile_row)) = self.selected_tile {
                                        self.push_undo();
                                        if let Some(ref mut area) = self.current_area {
                                            let idx = tile_row * area.width as usize + tile_col;
                                            let area_mut = Arc::make_mut(area);
                                            if idx < area_mut.tiles.len() {
                                                area_mut.tiles[idx].id = paint_id;
                                                // Keep tile_models in sync
                                                if let Some(ref module) = self.module {
                                                    if let Some(ts) = module.tileset_info(&area_mut.tileset) {
                                                        if idx < area_mut.tile_models.len() {
                                                            area_mut.tile_models[idx] = ts.tile_model(paint_id as u32).map(|s| s.to_string());
                                                        }
                                                    }
                                                }
                                                self.status = format!("Painted tile ({},{}) with id {}", tile_col, tile_row, paint_id);
                                                let resref = area_mut.resref.clone();
                                                if let Some(ref mut module) = self.module {
                                                    module.update_area_are(&resref, area_mut);
                                                }
                                                self.area_version = self.area_version.wrapping_add(1);
                                            }
                                        }
                                    }
                                    if let Some(ref area) = self.current_area {
                                        self.viewport.set_area(area.clone(), self.area_version, target_format);
                                    }
                                }
                            }
                        });
                    }
                });
            if !paint_open {
                self.show_paint = false;
                self.viewport.set_show_paint(false);
            }
        }

        // Item Browser window
        if self.item_browser_open {
            if let Some(ref module) = self.module {
                egui::Window::new("Item Browser")
                    .default_size([400.0, 500.0])
                    .show(ctx, |ui| {
                        show_item_browser(ui, &module.resource_manager);
                    });
            }
        }

        // Tools Panel window
        egui::Window::new("Tools")
            .default_size([350.0, 160.0])
            .show(ctx, |ui| {
                show_tools_panel(ui, &mut self.active_tool, &mut self.terrain_edit_raise_amount, &mut self.terrain_smooth_radius);
                ui.separator();
                ui.label(self.active_tool.description());
            });

        // Universal Search window
        if self.universal_search_open {
            if let Some(ref module) = self.module {
                let mut place_cmd: Option<(String, String)> = None;
                egui::Window::new("Universal Search")
                    .default_size([400.0, 500.0])
                    .show(ctx, |ui| {
                        show_universal_search(ui, &module.resource_manager, &mut place_cmd);
                    });
                if let Some((typ, resref)) = place_cmd {
                    self.status = format!("Placement mode: {} {}. Click in viewport to place.", typ, resref);
                    self.placement_state = PlacementState::Pending(typ, resref);
                }
            }
        }

        // Launch confirmation dialog
        if self.show_launch_dialog {
            let mut keep_open = true;
            let area_name = self.current_area.as_ref().map(|a| a.resref.clone()).unwrap_or_default();
            let mod_name = self.module.as_ref().map(|m| m.name.clone()).unwrap_or_default();
            egui::Window::new("Launch Module")
                .anchor(egui::Align2::CENTER_CENTER, [0.0, 0.0])
                .collapsible(false)
                .resizable(false)
                .open(&mut keep_open)
                .show(ctx, |ui| {
                    ui.vertical_centered(|ui| {
                        ui.heading("Launch Neverwinter Nights:EE?");
                    });
                    ui.add_space(8.0);
                    ui.label(format!("Module: {}", mod_name));
                    if !area_name.is_empty() {
                        ui.label(format!("Area: {}", area_name));
                    }
                    ui.add_space(4.0);
                    ui.colored_label(egui::Color32::GOLD, "The module will be copied to your NWN modules directory and NWN will launch.");
                    ui.add_space(4.0);
                    ui.colored_label(egui::Color32::LIGHT_BLUE, "Make sure you've saved your work first!");
                    ui.add_space(12.0);
                    ui.horizontal(|ui| {
                        ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                            if ui.button("Cancel").clicked() {
                                self.show_launch_dialog = false;
                            }
                            if ui.button("🚀 Launch").clicked() {
                                self.show_launch_dialog = false;
                                self.launch_nwn();
                            }
                        });
                    });
                });
            if !keep_open {
                self.show_launch_dialog = false;
            }
        }

        // Script editors
        let mut scripts_to_remove = Vec::new();
        let mut scripts_to_compile: Vec<(String, String)> = Vec::new();
        for (i, (name, source)) in self.script_editor_scripts.iter_mut().enumerate() {
            let mut open = true;
            egui::Window::new(format!("Script: {}", name))
                .id(egui::Id::new(("script_editor", i)))
                .default_size([600.0, 400.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    let mut modified = false;
                    if show_script_editor(ui, name, source, &mut modified) {
                        scripts_to_compile.push((name.clone(), source.clone()));
                    }
                    if modified {
                        if let Some(ref mut module) = self.module {
                            module.update_script(name, source);
                            module.modified = true;
                            self.status = format!("Script '{}' updated.", name);
                        }
                    }
                });
            if !open {
                scripts_to_remove.push(i);
            }
        }
        for (name, source) in scripts_to_compile {
            self.compile_script(&name, &source);
        }
        for i in scripts_to_remove.into_iter().rev() {
            self.script_editor_scripts.remove(i);
        }

        // Conversation editors
        let mut convos_to_remove = Vec::new();
        for (i, (name, editor)) in self.conversation_editors.iter_mut().enumerate() {
            let mut open = true;
            egui::Window::new(format!("Conversation: {}", name))
                .id(egui::Id::new(("conversation_editor", i)))
                .default_size([500.0, 400.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    if show_conversation_editor(ui, name, &mut editor.convo) {
                        editor.modified = true;
                        if let Some(ref mut module) = self.module {
                            module.update_conversation(name, &editor.convo);
                            module.modified = true;
                            self.status = format!("Conversation '{}' updated.", name);
                        }
                    }
                });
            if !open {
                convos_to_remove.push(i);
            }
        }
        for i in convos_to_remove.into_iter().rev() {
            self.conversation_editors.remove(i);
        }

        // 2DA editors
        let mut twodas_to_remove = Vec::new();
        for (i, (name, state)) in self.two_da_editors.iter_mut().enumerate() {
            let mut open = true;
            egui::Window::new(format!("2DA: {}", name))
                .id(egui::Id::new(("two_da_editor", i)))
                .default_size([500.0, 400.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    let mut on_save: Option<(String, String)> = None;
                    show_two_da_editor(ui, state, &mut on_save);
                    if let Some((_name, data)) = on_save {
                        if let Some(ref mut module) = self.module {
                            module.update_2da(name, &data);
                            module.modified = true;
                            self.status = format!("2DA '{}' updated.", name);
                        }
                    }
                });
            if !open {
                twodas_to_remove.push(i);
            }
        }
        for i in twodas_to_remove.into_iter().rev() {
            self.two_da_editors.remove(i);
        }

        // Blueprint editors
        let mut bp_to_remove = Vec::new();
        let bp_resrefs = self.module.as_ref().map(module_resref_names).unwrap_or_default();
        let bp_tags = self.module.as_ref().map(module_tag_names).unwrap_or_default();
        for i in 0..self.blueprint_editors.len() {
            let (resref, restype, bag) = &mut self.blueprint_editors[i];
            let (resref_clone, restype_clone) = (resref.clone(), *restype);
            let ext = type_to_ext(restype_clone).unwrap_or("?");
            let mut open = true;
            egui::Window::new(format!("Blueprint: {}.{}", resref_clone, ext))
                .id(egui::Id::new(("blueprint_editor", i)))
                .default_size([400.0, 500.0])
                .open(&mut open)
                .show(ctx, |ui| {
                    ui.label(format!("ResRef: {}  Type: {}", resref_clone, ext));
                    ui.separator();
                    show_bag_editor(ui, bag, &bp_resrefs, &bp_tags, self.module.as_ref().map(|m| &m.resource_manager));
                    ui.separator();
                    if ui.button("Save to Module").clicked() {
                        if let Some(ref mut module) = self.module {
                            let struct_id = match restype_clone {
                                rt if rt == resource_types::UTC => 4,
                                rt if rt == resource_types::UTD => 5,
                                rt if rt == resource_types::UTP => 6,
                                rt if rt == resource_types::UTT => 7,
                                rt if rt == resource_types::UTW => 8,
                                rt if rt == resource_types::UTE => 9,
                                rt if rt == resource_types::UTS => 10,
                                _ => 0,
                            };
                            let ft = format!("{:<4}", ext);
                            let gff = bag.to_gff(&ft, "V3.2", struct_id);
                            let data = gff.to_bytes();
                            module.update_blueprint(&resref_clone, restype_clone, data);
                            self.status = format!("Blueprint '{}.{}' saved.", resref_clone, ext);
                        }
                    }
                });
            if !open {
                bp_to_remove.push(i);
            }
        }
        for i in bp_to_remove.into_iter().rev() {
            self.blueprint_editors.remove(i);
        }

        // ===================== AREA TABS =====================
        if !self.open_areas.is_empty() {
            let tab_resrefs = self.open_areas.clone();
            let active_idx = self.active_area_idx;
            let current_resref = self.current_area.as_ref().map(|a| a.resref.clone());
            egui::TopBottomPanel::top("area_tabs")
                .min_height(28.0)
                .show(ctx, |ui| {
                    ui.horizontal(|ui| {
                        for (i, name) in tab_resrefs.iter().enumerate() {
                            let is_active = i == active_idx || current_resref.as_ref().map_or(false, |r| r == name);
                            let btn = egui::Button::new(
                                egui::RichText::new(name).size(14.0)
                            )
                            .fill(if is_active { ui.style().visuals.selection.bg_fill } else { ui.style().visuals.window_fill() })
                            .min_size(egui::vec2(60.0, 24.0));
                            let resp = ui.add(btn);
                            if resp.clicked() {
                                let name_to_switch = name.clone();
                                self.switch_to_area(&name_to_switch, target_format);
                            }
                            if self.icons.icon_button(ui, "cross-mark", "Close tab", 14.0).clicked() {
                                self.close_area_tab(i);
                                if self.current_area.is_none() && !self.open_areas.is_empty() {
                                    let next = self.open_areas[self.active_area_idx].clone();
                                    self.switch_to_area(&next, target_format);
                                }
                            }
                        }
                        ui.allocate_space(ui.available_size());
                    });
                });
        }

        // ===================== LEFT NAVIGATOR =====================
        let current_resref = self.current_area.as_ref().map(|a| a.resref.clone());
        egui::SidePanel::left("navigator")
            .resizable(true)
            .default_width(380.0)
            .show(ctx, |ui| {
                ui.horizontal(|ui| {
                    ui.heading("Areas");
                    if self.module.is_some() {
                        if self.icons.icon_button(ui, "new-shoot", "New Area", 20.0).clicked() {
                            self.new_area_open = true;
                        }
                    }
                });
                ui.separator();
                let names: Vec<String> = self.module.as_ref().map(|m| m.area_names().iter().map(|s| s.to_string()).collect()).unwrap_or_default();
                let area_labels: Vec<String> = self.module.as_ref().map(|m| {
                    names.iter().map(|n| {
                        let d = m.area_display_name(n);
                        if d == *n { n.clone() } else { format!("{} ({})", d, n) }
                    }).collect()
                }).unwrap_or_default();
                if names.is_empty() {
                    ui.label("No module loaded.");
                } else {
                    ui.text_edit_singleline(&mut self.area_search);
                    let area_filter = self.area_search.to_lowercase();
                    egui::ScrollArea::vertical().show(ui, |ui| {
                        let mut delete_name: Option<String> = None;
                        for (i, name) in names.iter().enumerate() {
                            let label = &area_labels[i];
                            if !area_filter.is_empty() && !name.to_lowercase().contains(&area_filter) && !label.to_lowercase().contains(&area_filter) { continue; }
                            let selected = current_resref.as_ref().map(|r| r == name).unwrap_or(false);
                            ui.horizontal(|ui| {
                                if ui.selectable_label(selected, label.as_str()).clicked() {
                                    self.switch_to_area(name, target_format);
                                }
                                if selected {
                                    if self.icons.icon_button(ui, "trash-can", "Delete Area", 16.0).clicked() {
                                        delete_name = Some(name.clone());
                                    }
                                    if self.icons.icon_button(ui, "cog", "Area Properties", 16.0).clicked() {
                                        if let Some(ref area) = self.current_area {
                                            self.area_props_resref = area.resref.clone();
                                            self.area_props_name = area.name.clone();
                                            self.area_props_tag = area.tag.clone();
                                            self.area_props_tileset = area.tileset.clone();
                                            self.area_props_popup = true;
                                        }
                                    }
                                }
                            });
                        }
                        if let Some(name) = delete_name {
                            // Close tab before module mutable borrow
                            if let Some(tab_idx) = self.open_areas.iter().position(|r| r == &name) {
                                self.close_area_tab(tab_idx);
                            }
                            if let Some(ref mut module) = self.module {
                                module.area_names_list.retain(|n| n != &name);
                                module.modified_area_data.remove(&name.to_lowercase());
                                module.raw_git.remove(&name.to_lowercase());
                                module.modified = true;
                            }
                            // Switch to next open tab if one exists
                            if self.current_area.is_none() || self.current_area.as_ref().map_or(false, |a| a.resref == name) {
                                self.current_area = None;
                                self.selected_object = None;
                                self.selected_obj_info = None;
                                self.selected_tile = None;
                                if !self.open_areas.is_empty() {
                                    let next = self.open_areas[self.active_area_idx].clone();
                                    if let Some(ref module) = self.module {
                                        if let Some(area) = module.get_area(&next) {
                                            self.area_version = self.area_version.wrapping_add(1);
                                            self.viewport.set_area(area.clone(), self.area_version, target_format);
                                            self.current_area = Some(area);
                                            self.sync_area_sounds();
                                        }
                                    }
                                    self.status = format!("Deleted '{}', switched to '{}'.", name, next);
                                } else {
                                    self.status = format!("Deleted area '{}'.", name);
                                }
                            } else {
                                self.status = format!("Deleted area '{}'.", name);
                            }
                        }
                    });
                }
            });

        // ===================== CENTRAL PANEL (3D VIEWPORT) =====================
        egui::CentralPanel::default().show(ctx, |ui| {
            if let Some(ref area) = self.current_area.clone() {
                if self.show_navigator {
                    ui.horizontal(|ui| {
                        ui.heading(format!("Area: {}", area.resref));
                    });
                    ui.separator();
                }
                let (_id, rect) = ui.allocate_space(ui.available_size());
                let viewport_resp = ui.allocate_rect(rect, egui::Sense::click_and_drag());
                // Minimap overlay (bottom-right corner of viewport)
                // Must use a separate foreground layer so it renders on top of the 3D paint callback
                if self.show_minimap {
                    let mini_size = egui::vec2(150.0, 100.0);
                    let mini_rect = egui::Rect::from_min_size(
                        egui::pos2(rect.right() - mini_size.x - 6.0, rect.bottom() - mini_size.y - 6.0),
                        mini_size,
                    );
                    let layer_id = egui::LayerId::new(egui::Order::Foreground, egui::Id::new("minimap_overlay"));
                    let painter = egui::Painter::new(ui.ctx().clone(), layer_id, mini_rect);
                    painter.rect_filled(mini_rect, 2.0, egui::Color32::from_black_alpha(180));
                    let w = area.width.max(1) as usize;
                    let h = area.height.max(1) as usize;
                    let cell = ((mini_size.x / w as f32).min(mini_size.y / h as f32)).max(1.0);
                    let total_w = w as f32 * cell;
                    let total_h = h as f32 * cell;
                    let ox = mini_rect.left() + (mini_size.x - total_w) / 2.0;
                    let oy = mini_rect.top() + (mini_size.y - total_h) / 2.0;
                    for row in 0..h {
                        for col in 0..w {
                            let ti = row * w + col;
                            let tile = area.tiles.get(ti);
                            let tint = area.tile_tints.iter().find(|&&(t, _)| t == ti).map(|&(_, c)| c);
                            let (r, g, b) = if let Some(c) = tint {
                                (c[0], c[1], c[2])
                            } else if let Some(t) = tile {
                                let id = t.id as u32;
                                (((id * 137 + 53) % 200 + 55) as u8,
                                 ((id * 251 + 97) % 200 + 55) as u8,
                                 ((id * 199 + 173) % 200 + 55) as u8)
                            } else {
                                (40, 40, 40)
                            };
                            let cx = ox + col as f32 * cell;
                            let cy = oy + row as f32 * cell;
                            let c = egui::Color32::from_rgb(r, g, b);
                            painter.rect_filled(
                                egui::Rect::from_min_size(egui::pos2(cx, cy), egui::vec2(cell, cell)),
                                0.0, c,
                            );
                        }
                    }
                }

                // Ghost preview: track mouse over viewport during placement mode
                if matches!(self.placement_state, PlacementState::Pending(..)) {
                    let hover_pos = ctx.input(|i| i.pointer.hover_pos());
                    self.ghost_screen_pos = hover_pos.filter(|p| rect.contains(*p));
                    if self.ghost_screen_pos.is_some() {
                        ctx.set_cursor_icon(egui::CursorIcon::Crosshair);
                    }
                } else {
                    self.ghost_screen_pos = None;
                }

                let is_hovered = viewport_resp.hovered();
                let (has_w, has_s, has_a, has_d, delta, secondary_down, middle_down, primary_clicked, primary_down, click_pos, scroll) = ctx.input(|i| {
                    let w = i.keys_down.contains(&egui::Key::W);
                    let s = i.keys_down.contains(&egui::Key::S);
                    let a = i.keys_down.contains(&egui::Key::A);
                    let d = i.keys_down.contains(&egui::Key::D);
                    (w, s, a, d, i.pointer.delta(), i.pointer.secondary_down(), i.pointer.middle_down(), i.pointer.primary_clicked(), i.pointer.primary_down(), i.pointer.interact_pos(), i.raw_scroll_delta)
                });
                let vp_w = rect.width();
                let vp_h = rect.height();

                // Handle DnD drop from blueprint palette over viewport
                if is_hovered {
                    if let Some(payload) = egui::DragAndDrop::take_payload::<String>(ctx) {
                        if let Some((typ, resref)) = payload.split_once(':') {
                            self.status = format!("Placement mode: {} {}. Click in viewport to place.", typ, resref);
                            self.placement_state = PlacementState::Pending(typ.to_string(), resref.to_string());
                        }
                    }
                }

                // Walkmesh wall toggle on click
                if primary_clicked && is_hovered && self.active_tool == Tool::WalkmeshWall {
                    if let Some(pos) = click_pos {
                        let vp_x = pos.x - rect.left();
                        let vp_y = pos.y - rect.top();
                        if let Some(world) = self.viewport.pick_ground(vp_x, vp_y, vp_w, vp_h) {
                            let wall_x = (world[0] / 10.0).round() as usize;
                            let _wall_z = (world[2] / 10.0).round() as usize;
                            let edge = 0u8;
                            if let Some(ref mut area) = self.current_area {
                                let area_mut = Arc::make_mut(area);
                                toggle_walkmesh_wall(area_mut, (wall_x, edge), &mut self.status);
                                self.area_version = self.area_version.wrapping_add(1);
                            }
                        }
                    }
                }

                // Terrain smoothing on click
                if primary_clicked && is_hovered && self.active_tool == Tool::TerrainSmooth {
                    if let Some(pos) = click_pos {
                        let vp_x = pos.x - rect.left();
                        let vp_y = pos.y - rect.top();
                        if let Some(world) = self.viewport.pick_ground(vp_x, vp_y, vp_w, vp_h) {
                            let center_col = (world[0] / 10.0).floor() as i32;
                            let center_row = (-world[2] / 10.0).floor() as i32;
                            let in_bounds = self.current_area.as_ref().map_or(false, |area| {
                                center_col >= 0 && center_col < area.width && center_row >= 0 && center_row < area.height
                            });
                            if in_bounds {
                                self.push_undo();
                                if let Some(ref mut area) = self.current_area {
                                    let area_mut = Arc::make_mut(area);
                                    let w = area_mut.width;
                                    let h = area_mut.height;
                                    let radius = self.terrain_smooth_radius;

                                    let mut new_heights: Vec<i32> = area_mut.tiles.iter().map(|t| t.height).collect();

                                    for r in 0..h {
                                        for c in 0..w {
                                            if (c - center_col).abs() > radius || (r - center_row).abs() > radius {
                                                continue;
                                            }
                                            let mut sum = 0i64;
                                            let mut count = 0i64;
                                            for dr in -radius..=radius {
                                                for dc in -radius..=radius {
                                                    let nr = r + dr;
                                                    let nc = c + dc;
                                                    if nr >= 0 && nr < h && nc >= 0 && nc < w {
                                                        let idx = (nr * w + nc) as usize;
                                                        sum += area_mut.tiles[idx].height as i64;
                                                        count += 1;
                                                    }
                                                }
                                            }
                                            if count > 0 {
                                                let idx = (r * w + c) as usize;
                                                new_heights[idx] = ((sum / count) as i32).max(0).min(255);
                                            }
                                        }
                                    }

                                    for (i, h) in new_heights.iter().enumerate() {
                                        area_mut.tiles[i].height = *h;
                                    }

                                    let resref = area_mut.resref.clone();
                                    if let Some(ref mut module) = self.module {
                                        module.update_area_are(&resref, area_mut);
                                    }
                                    self.area_version = self.area_version.wrapping_add(1);
                                    self.viewport.set_area(area.clone(), self.area_version, target_format);
                                    self.status = format!("Smoothed terrain at ({},{}) radius {}", center_col, center_row, radius);
                                }
                            }
                        }
                    }
                }

                // Terrain height editing on click
                if primary_clicked && is_hovered && self.active_tool == Tool::TerrainRaise {
                    if let Some(pos) = click_pos {
                        let vp_x = pos.x - rect.left();
                        let vp_y = pos.y - rect.top();
                        if let Some(world) = self.viewport.pick_ground(vp_x, vp_y, vp_w, vp_h) {
                            let tile_col = (world[0] / 10.0).floor() as usize;
                            let tile_row = (-world[2] / 10.0).floor() as usize;
                            let in_bounds = self.current_area.as_ref().map_or(false, |area| {
                                tile_col < area.width as usize && tile_row < area.height as usize
                            });
                            if in_bounds {
                                let shift = ctx.input(|i| i.modifiers.shift);
                                let amount = if shift { -self.terrain_edit_raise_amount } else { self.terrain_edit_raise_amount };
                                self.push_undo();
                                if let Some(ref mut area) = self.current_area {
                                    let area_mut = Arc::make_mut(area);
                                    let idx = tile_row * area_mut.width as usize + tile_col;
                                    area_mut.tiles[idx].height = (area_mut.tiles[idx].height + amount).max(0).min(255);
                                    let new_h = area_mut.tiles[idx].height;
                                    let resref = area_mut.resref.clone();
                                    if let Some(ref mut module) = self.module {
                                        module.update_area_are(&resref, area_mut);
                                    }
                                    self.area_version = self.area_version.wrapping_add(1);
                                    self.viewport.set_area(area.clone(), self.area_version, target_format);
                                    self.status = format!("Tile ({},{}) height: {}", tile_col, tile_row, new_h);
                                }
                            }
                        }
                    }
                }

                if is_hovered && self.drag_state.is_none() {
                    let mut fwd = 0.0f32;
                    let mut rgt = 0.0f32;
                    if has_w { fwd += 1.0; }
                    if has_s { fwd -= 1.0; }
                    if has_a { rgt -= 1.0; }
                    if has_d { rgt += 1.0; }
                    if fwd != 0.0 || rgt != 0.0 {
                        self.viewport.walk_camera(fwd, rgt);
                    }
                    if secondary_down {
                        self.viewport.rotate_camera(delta.x, delta.y);
                    }
                    if middle_down {
                        self.viewport.pan_camera(delta.x, delta.y);
                    }
                    if scroll.y != 0.0 {
                        self.viewport.zoom_camera(scroll.y);
                    }
                    if primary_clicked {
                        if let Some(pos) = click_pos {
                            let vp_x = pos.x - rect.left();
                            let vp_y = pos.y - rect.top();

                            // Placement mode: place object at ground hit
                            let is_placement = matches!(self.placement_state, PlacementState::Pending(..));
                            if is_placement {
                                let (typ, resref) = match &self.placement_state { PlacementState::Pending(t, r) => (t.clone(), r.clone()), _ => unreachable!() };
                                if let Some(world) = self.viewport.pick_ground(vp_x, vp_y, vp_w, vp_h) {
                                    let (nwn_x, nwn_y) = snap_to_grid_pos(world[0], -world[2], self.snap_to_grid_enabled, self.snap_to_grid_value);
                                    let nwn_z = world[1].max(0.0);
                                    let mut placed = false;
                                    self.push_undo();
                                    if let Some(area) = self.current_area.as_mut() {
                                        let area = Arc::make_mut(area);
                                        let tag = format!("{}_{}", typ, resref);
                                        match typ.as_str() {
                                            "creature" => {
                                                area.creatures.push(nwn_gamemodel::CreatureInstance {
                                                    resref: resref.clone(), tag: tag.clone(),
                                                    x: nwn_x, y: nwn_y, z: nwn_z, bearing: 0.0,
                                                    appearance: 0, model_name: None,
                                                    gender: 0, plt_layers: nwn_gamemodel::CreatureInstance::default_plt_layers(),
                                                });
                                                placed = true;
                                            }
                                            "placeable" => {
                                                area.placeables.push(nwn_gamemodel::PlaceableInstance {
                                                    resref: resref.clone(), tag: tag.clone(),
                                                    x: nwn_x, y: nwn_y, z: nwn_z, bearing: 0.0,
                                                    appearance: 0, model_name: None,
                                                    has_light: false, light_color: [255, 255, 255, 255], light_radius: 5.0,
                                                });
                                                placed = true;
                                            }
                                            "door" => {
                                                area.doors.push(nwn_gamemodel::DoorInstance {
                                                    resref: resref.clone(), tag: tag.clone(),
                                                    x: nwn_x, y: nwn_y, z: nwn_z, bearing: 0.0,
                                                    appearance: 0, model_name: None,
                                                });
                                                placed = true;
                                            }
                                            "item" => {
                                                area.placeables.push(nwn_gamemodel::PlaceableInstance {
                                                    resref: resref.clone(), tag: tag.clone(),
                                                    x: nwn_x, y: nwn_y, z: nwn_z, bearing: 0.0,
                                                    appearance: 0, model_name: None,
                                                    has_light: false, light_color: [255, 255, 255, 255], light_radius: 5.0,
                                                });
                                                placed = true;
                                            }
                                            _ => {}
                                        }
                                        if placed {
                                            let resref_name = area.resref.clone();
                                            if let Some(ref mut module) = self.module {
                                                module.update_area_git(&resref_name, area);
                                            }
                                            self.area_version = self.area_version.wrapping_add(1);
                                            self.status = format!("Placed {} '{}' at ({:.1}, {:.1})", typ, resref, nwn_x, nwn_y);
                                        }
                                    }
                                }
                                self.placement_state = PlacementState::Inactive;
                                self.manip_mode = ManipMode::None;
                            } else if let Some((_idx, marker)) = self.viewport.raypick(vp_x, vp_y, vp_w, vp_h) {
                                let ctrl_held = ctx.input(|i| i.modifiers.ctrl);
                                if let Some(ref area) = self.current_area {
                                    let obj_type_str = match marker.obj_type {
                                        ObjectType::Creature => "creature",
                                        ObjectType::Door => "door",
                                        ObjectType::Placeable => "placeable",
                                        ObjectType::Trigger => "trigger",
                                        ObjectType::Waypoint => "waypoint",
                                        ObjectType::Encounter => "encounter",
                                        ObjectType::SoundEmitter => "sound_emitter",
                                        ObjectType::Light => "light",
                                    };
                                    let key = (obj_type_str.to_string(), marker.index);

                                    if ctrl_held && self.selection_list.iter().any(|x| *x == key) {
                                        // Ctrl+Click on an already-selected object: deselect it
                                        self.selection_list.retain(|x| *x != key);
                                        if let Some(last) = self.selection_list.last().cloned() {
                                            select_single_object(area, self.module.as_ref(), &mut self.selected_object, &mut self.selected_obj_info, &mut self.selected_tile, &last.0, last.1);
                                        } else {
                                            self.selected_object = None;
                                            self.selected_obj_info = None;
                                        }
                                        self.status = format!("Deselected. {} object(s) remain.", self.selection_list.len());
                                    } else {
                                        if ctrl_held {
                                            self.selection_list.push(key.clone());
                                        } else {
                                            self.selection_list.clear();
                                            self.selection_list.push(key.clone());
                                        }
                                        let bag = match marker.obj_type {
                                            ObjectType::Creature => {
                                                area.creatures.get(marker.index).map(|c| (format!("Creature: {}", c.resref), c.to_property_bag()))
                                            }
                                            ObjectType::Door => {
                                                area.doors.get(marker.index).map(|d| (format!("Door: {}", d.resref), d.to_property_bag()))
                                            }
                                            ObjectType::Placeable => {
                                                area.placeables.get(marker.index).map(|p| (format!("Placeable: {}", p.resref), p.to_property_bag()))
                                            }
                                            ObjectType::Trigger => {
                                                area.triggers.get(marker.index).map(|t| (format!("Trigger: {}", t.tag), t.to_property_bag()))
                                            }
                                            ObjectType::Waypoint => {
                                                area.waypoints.get(marker.index).map(|w| (format!("Waypoint: {}", w.tag), w.to_property_bag()))
                                            }
                                            ObjectType::Encounter => {
                                                area.encounters.get(marker.index).map(|e| (format!("Encounter: {}", e.name), e.to_property_bag()))
                                            }
                                            ObjectType::SoundEmitter => {
                                                area.sound_emitters.get(marker.index).map(|s| (format!("Sound: {}", s.tag), s.to_property_bag()))
                                            }
                                            ObjectType::Light => {
                                                area.lights.get(marker.index).map(|l| (format!("Light: {}", l.tag), LightInstance::to_property_bag(l)))
                                            }
                                        };
                                        if let Some((title, bag)) = bag {
                                            let full_bag = self.module.as_ref().and_then(|module| {
                                                let area_key = area.resref.trim().to_lowercase();
                                                let git_bytes = module.raw_git.get(&area_key)?;
                                                let gff = nwn_gff::GffFile::from_bytes(git_bytes).ok()?;
                                                let list_name = git_list_name(obj_type_str);
                                                let s = gff.root().find(list_name)?.unwrap_list().get(marker.index)?;
                                                Some(PropertyBag::from_gff_struct(s))
                                            });
                                            self.selected_object = Some(SelectedObject { title, bag: full_bag.unwrap_or(bag) });
                                            self.selected_obj_info = Some(key);

                                            // Start 3D drag-to-move
                                            if !ctrl_held && self.active_tool == Tool::Select {
                                                if let Some(world) = self.viewport.pick_ground(vp_x, vp_y, vp_w, vp_h) {
                                                    let orig = match marker.obj_type {
                                                        ObjectType::Creature => area.creatures.get(marker.index).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                        ObjectType::Door => area.doors.get(marker.index).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                        ObjectType::Placeable => area.placeables.get(marker.index).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                        ObjectType::Trigger => area.triggers.get(marker.index).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                        ObjectType::Waypoint => area.waypoints.get(marker.index).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                        ObjectType::Encounter => area.encounters.get(marker.index).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                        ObjectType::SoundEmitter => area.sound_emitters.get(marker.index).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                        ObjectType::Light => area.lights.get(marker.index).map(|o| (o.x, o.y, o.z, 0.0)),
                                                    };
                                                    if let Some((ox, oy, oz, ob)) = orig {
                                                        self.drag_state = Some(DragState {
                                                            obj_type: obj_type_str.to_string(),
                                                            obj_idx: marker.index,
                                                            orig_x: ox, orig_y: oy, orig_z: oz, orig_bearing: ob,
                                                            start_render_x: world[0],
                                                            start_render_z: world[2],
                                                        });
                                                    }
                                                }
                                            }

                                            let total = self.selection_list.len();
                                            if total > 1 {
                                                self.status = format!("Selected {} #{} (+{} more)", obj_type_str, marker.index, total - 1);
                                            } else {
                                                self.status = format!("Selected {} #{}", obj_type_str, marker.index);
                                            }
                                        }
                                    }
                                }
                            } else {
                                let ctrl_held = ctx.input(|i| i.modifiers.ctrl);
                                // Click on empty ground — drag selected object, or select tile
                                if let Some(ref info) = self.selected_obj_info {
                                    if !ctrl_held && self.active_tool == Tool::Select {
                                        if let Some(world) = self.viewport.pick_ground(vp_x, vp_y, vp_w, vp_h) {
                                            if let Some(ref area) = self.current_area {
                                                let orig = match info.0.as_str() {
                                                    "creature" => area.creatures.get(info.1).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                    "door" => area.doors.get(info.1).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                    "placeable" => area.placeables.get(info.1).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                    "trigger" => area.triggers.get(info.1).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                    "waypoint" => area.waypoints.get(info.1).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                    "encounter" => area.encounters.get(info.1).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                    "sound_emitter" => area.sound_emitters.get(info.1).map(|o| (o.x, o.y, o.z, o.bearing)),
                                                    _ => None,
                                                };
                                                if let Some((ox, oy, oz, ob)) = orig {
                                                    self.drag_state = Some(DragState {
                                                        obj_type: info.0.clone(),
                                                        obj_idx: info.1,
                                                        orig_x: ox, orig_y: oy, orig_z: oz, orig_bearing: ob,
                                                        start_render_x: world[0],
                                                        start_render_z: world[2],
                                                    });
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    // Record start of potential drag-select or tile click
                                    self.drag_select_start = click_pos;
                                }
                            }
                        }
                    }
                }

                // ── 3D drag-to-move (live update while dragging, commit on release) ──
                let drag_clone = self.drag_state.clone();
                if let Some(ref drag) = drag_clone {
                    if primary_down {
                        if is_hovered {
                            let cur_hover = ctx.input(|i| i.pointer.hover_pos());
                            if let Some(pos) = cur_hover.filter(|p| rect.contains(*p)) {
                                let vp_cx = pos.x - rect.left();
                                let vp_cy = pos.y - rect.top();
                                if let Some(world) = self.viewport.pick_ground(vp_cx, vp_cy, vp_w, vp_h) {
                                    let dx = world[0] - drag.start_render_x;
                                    let dz = world[2] - drag.start_render_z;
                                    let new_x = drag.orig_x + dx;
                                    let new_y = drag.orig_y - dz;
                                    if let Some(area) = self.current_area.as_mut() {
                                        let area = Arc::make_mut(area);
                                        match drag.obj_type.as_str() {
                                            "creature" => { if let Some(c) = area.creatures.get_mut(drag.obj_idx) { c.x = new_x; c.y = new_y; } }
                                            "door" => { if let Some(d) = area.doors.get_mut(drag.obj_idx) { d.x = new_x; d.y = new_y; } }
                                            "placeable" => { if let Some(p) = area.placeables.get_mut(drag.obj_idx) { p.x = new_x; p.y = new_y; } }
                                            "trigger" => { if let Some(t) = area.triggers.get_mut(drag.obj_idx) { t.x = new_x; t.y = new_y; } }
                                            "waypoint" => { if let Some(w) = area.waypoints.get_mut(drag.obj_idx) { w.x = new_x; w.y = new_y; } }
                                            "encounter" => { if let Some(e) = area.encounters.get_mut(drag.obj_idx) { e.x = new_x; e.y = new_y; } }
                                            "sound_emitter" => { if let Some(s) = area.sound_emitters.get_mut(drag.obj_idx) { s.x = new_x; s.y = new_y; } }
                                            _ => {}
                                        }
                                        // Fast-path: update GPU instance buffer directly (no full scene rebuild)
                                        self.viewport.set_object_transform(&drag.obj_type, drag.obj_idx, new_x, new_y, drag.orig_z, drag.orig_bearing);
                                    }
                                }
                            }
                        }
                    } else {
                        // Primary released — commit drag (skip if no actual movement)
                        if let Some(ref drag) = self.drag_state.take() {
                            let moved = self.current_area.as_ref().and_then(|area| {
                                let pos = match drag.obj_type.as_str() {
                                    "creature" => area.creatures.get(drag.obj_idx).map(|c| (c.x, c.y)),
                                    "door" => area.doors.get(drag.obj_idx).map(|d| (d.x, d.y)),
                                    "placeable" => area.placeables.get(drag.obj_idx).map(|p| (p.x, p.y)),
                                    "trigger" => area.triggers.get(drag.obj_idx).map(|t| (t.x, t.y)),
                                    "waypoint" => area.waypoints.get(drag.obj_idx).map(|w| (w.x, w.y)),
                                    "encounter" => area.encounters.get(drag.obj_idx).map(|e| (e.x, e.y)),
                                    "sound_emitter" => area.sound_emitters.get(drag.obj_idx).map(|s| (s.x, s.y)),
                                    "light" => area.lights.get(drag.obj_idx).map(|l| (l.x, l.y)),
                                    _ => None,
                                };
                                pos.map(|(cx, cy)| (cx - drag.orig_x).abs() > 0.0001 || (cy - drag.orig_y).abs() > 0.0001)
                            }).unwrap_or(false);
                            if moved {
                                self.push_undo();
                                if let Some(area) = self.current_area.as_mut() {
                                    let area = Arc::make_mut(area);
                                    let resref = area.resref.clone();
                                    if let Some(ref mut module) = self.module {
                                        module.update_area_git(&resref, area);
                                    }
                                    self.area_version = self.area_version.wrapping_add(1);
                                    self.viewport.set_area(Arc::new(area.clone()), self.area_version, target_format);
                                    self.status = format!("Moved {} #{}", drag.obj_type, drag.obj_idx);
                                }
                            }
                        }
                    }
                }

                // ── Drag-to-select (marquee selection) ──
                if self.drag_select_start.is_some() && !primary_down {
                    let start = self.drag_select_start.take().unwrap();
                    let cur_hover = ctx.input(|i| i.pointer.hover_pos());
                    let dist = cur_hover.map(|p| (p.x - start.x).abs().max((p.y - start.y).abs())).unwrap_or(0.0);
                    if dist > 5.0 {
                        // Drag-select: find objects inside rectangle
                        if let Some(area) = self.current_area.as_ref() {
                            let end = cur_hover.unwrap_or(start);
                            let mut min_x = start.x.min(end.x) - rect.left();
                            let mut max_x = start.x.max(end.x) - rect.left();
                            let mut min_y = start.y.min(end.y) - rect.top();
                            let mut max_y = start.y.max(end.y) - rect.top();
                            min_x = min_x.clamp(0.0, vp_w);
                            max_x = max_x.clamp(0.0, vp_w);
                            min_y = min_y.clamp(0.0, vp_h);
                            max_y = max_y.clamp(0.0, vp_h);
                            let hits = self.viewport.screen_rect_select([min_x, min_y], [max_x, max_y], vp_w, vp_h);
                            let ctrl_held = ctx.input(|i| i.modifiers.ctrl);
                            if !ctrl_held {
                                self.selection_list.clear();
                            }
                            for (_, obj_type, obj_idx) in hits {
                                let key = (match obj_type {
                                    ObjectType::Creature => "creature",
                                    ObjectType::Door => "door",
                                    ObjectType::Placeable => "placeable",
                                    ObjectType::Trigger => "trigger",
                                    ObjectType::Waypoint => "waypoint",
                                    ObjectType::Encounter => "encounter",
                                    ObjectType::SoundEmitter => "sound_emitter",
                                    ObjectType::Light => "light",
                                }.to_string(), obj_idx);
                                if !self.selection_list.contains(&key) {
                                    self.selection_list.push(key);
                                }
                            }
                            if let Some(last) = self.selection_list.last().cloned() {
                                select_single_object(area, self.module.as_ref(), &mut self.selected_object, &mut self.selected_obj_info, &mut self.selected_tile, &last.0, last.1);
                            }
                            self.status = format!("Drag-selected {} object(s)", self.selection_list.len());
                        }
                    } else {
                        // Small click: select tile
                        let click_in_rect = egui::Pos2 { x: start.x - rect.left(), y: start.y - rect.top() };
                        if let Some(world) = self.viewport.pick_ground(click_in_rect.x, click_in_rect.y, vp_w, vp_h) {
                            if let Some(ref area) = self.current_area {
                                let tile_col = (world[0] / 10.0).floor() as usize;
                                let tile_row = (-world[2] / 10.0).floor() as usize;
                                if tile_col < area.width as usize && tile_row < area.height as usize {
                                    self.selected_tile = Some((tile_col, tile_row));
                                    self.status = format!("Selected tile ({}, {})", tile_col, tile_row);
                                }
                            }
                        }
                    }
                }

                // ── Space-bar hold-to-move (selected object follows cursor on ground) ──
                let space_held = ctx.input(|i| i.keys_down.contains(&egui::Key::Space));
                let space_released = ctx.input(|i| i.key_released(egui::Key::Space));
                if space_released && self.space_move_active {
                    self.space_move_active = false;
                    // Commit position
                    self.push_undo();
                    if let Some(area) = self.current_area.as_mut() {
                        let area = Arc::make_mut(area);
                        let resref = area.resref.clone();
                        if let Some(ref mut module) = self.module {
                            module.update_area_git(&resref, area);
                        }
                        self.area_version = self.area_version.wrapping_add(1);
                        self.viewport.set_area(Arc::new(area.clone()), self.area_version, target_format);
                        self.status = "Moved with space".to_string();
                    }
                }
                if space_held && is_hovered && !primary_down && self.drag_state.is_none()
                    && !matches!(self.placement_state, PlacementState::Pending(..)) && self.active_tool == Tool::Select
                {
                    if let Some(ref info) = self.selected_obj_info {
                        let cur_hover = ctx.input(|i| i.pointer.hover_pos());
                        if let Some(pos) = cur_hover.filter(|p| rect.contains(*p)) {
                            let vp_cx = pos.x - rect.left();
                            let vp_cy = pos.y - rect.top();
                            if let Some(world) = self.viewport.pick_ground(vp_cx, vp_cy, vp_w, vp_h) {
                                let nwn_x = world[0];
                                let nwn_y = -world[2];
                                if let Some(area) = self.current_area.as_mut() {
                                    let area = Arc::make_mut(area);
                                    let bearing = match info.0.as_str() {
                                        "creature" => area.creatures.get(info.1).map(|o| o.bearing),
                                        "door" => area.doors.get(info.1).map(|o| o.bearing),
                                        "placeable" => area.placeables.get(info.1).map(|o| o.bearing),
                                        "trigger" => area.triggers.get(info.1).map(|o| o.bearing),
                                        "waypoint" => area.waypoints.get(info.1).map(|o| o.bearing),
                                        "encounter" => area.encounters.get(info.1).map(|o| o.bearing),
                                        "sound_emitter" => area.sound_emitters.get(info.1).map(|o| o.bearing),
                                        _ => None,
                                    };
                                    let z_pos = match info.0.as_str() {
                                        "creature" => area.creatures.get(info.1).map(|o| o.z),
                                        "door" => area.doors.get(info.1).map(|o| o.z),
                                        "placeable" => area.placeables.get(info.1).map(|o| o.z),
                                        _ => None,
                                    };
                                    if let Some(b) = bearing {
                                        let z = z_pos.unwrap_or(0.0);
                                        match info.0.as_str() {
                                            "creature" => { if let Some(o) = area.creatures.get_mut(info.1) { o.x = nwn_x; o.y = nwn_y; } }
                                            "door" => { if let Some(o) = area.doors.get_mut(info.1) { o.x = nwn_x; o.y = nwn_y; } }
                                            "placeable" => { if let Some(o) = area.placeables.get_mut(info.1) { o.x = nwn_x; o.y = nwn_y; } }
                                            "trigger" => { if let Some(o) = area.triggers.get_mut(info.1) { o.x = nwn_x; o.y = nwn_y; } }
                                            "waypoint" => { if let Some(o) = area.waypoints.get_mut(info.1) { o.x = nwn_x; o.y = nwn_y; } }
                                            "encounter" => { if let Some(o) = area.encounters.get_mut(info.1) { o.x = nwn_x; o.y = nwn_y; } }
                                            "sound_emitter" => { if let Some(o) = area.sound_emitters.get_mut(info.1) { o.x = nwn_x; o.y = nwn_y; } }
                                            _ => {}
                                        }
                                        self.viewport.set_object_transform(&info.0, info.1, nwn_x, nwn_y, z, b);
                                        self.space_move_active = true;
                                    }
                                }
                            }
                        }
                    }
                }

                // Keyboard manipulation of selected object(s)
                if is_hovered && self.selected_obj_info.is_some() && !matches!(self.placement_state, PlacementState::Pending(..)) {
                    let mut nudge_targets: Vec<(String, usize)> = self.selection_list.clone();
                    if nudge_targets.is_empty() {
                        nudge_targets = vec![self.selected_obj_info.clone().unwrap()];
                    }
                    let mut needs_update = false;
                    let mut nudge_x = 0.0f32;
                    let mut nudge_y = 0.0f32;
                    let mut rotate_delta = 0.0f32;
                    let mut do_delete = false;

                    let keys = ctx.input(|i| {
                        let left = i.keys_down.contains(&egui::Key::ArrowLeft);
                        let right = i.keys_down.contains(&egui::Key::ArrowRight);
                        let up = i.keys_down.contains(&egui::Key::ArrowUp);
                        let down = i.keys_down.contains(&egui::Key::ArrowDown);
                        let q = i.keys_down.contains(&egui::Key::Q);
                        let e = i.keys_down.contains(&egui::Key::E);
                        let r = i.keys_down.contains(&egui::Key::R);
                        let delete = i.key_pressed(egui::Key::Delete);
                        (left, right, up, down, q, e, r, delete)
                    });

                    if keys.0 { nudge_x -= 1.0; }
                    if keys.1 { nudge_x += 1.0; }
                    if keys.2 { nudge_y += 1.0; }
                    if keys.3 { nudge_y -= 1.0; }
                    if keys.4 { rotate_delta -= 0.1; }
                    if keys.5 { rotate_delta += 0.1; }
                    if keys.7 { do_delete = true; }

                    if nudge_x != 0.0 || nudge_y != 0.0 || rotate_delta != 0.0 || do_delete {
                        self.push_undo();
                        if let Some(area) = self.current_area.as_mut() {
                            let area = Arc::make_mut(area);
                            let speed = self.manip_nudge_speed;
                            if do_delete {
                                // Delete in reverse index order to preserve indices
                                let mut to_delete: Vec<(String, usize)> = nudge_targets.clone();
                                to_delete.sort_by(|a, b| b.1.cmp(&a.1));
                                for (ref t, i) in to_delete {
                                    match t.as_str() {
                                        "creature" => { if i < area.creatures.len() { area.creatures.remove(i); } }
                                        "door" => { if i < area.doors.len() { area.doors.remove(i); } }
                                        "placeable" => { if i < area.placeables.len() { area.placeables.remove(i); } }
                                        "trigger" => { if i < area.triggers.len() { area.triggers.remove(i); } }
                                        "waypoint" => { if i < area.waypoints.len() { area.waypoints.remove(i); } }
                                        "encounter" => { if i < area.encounters.len() { area.encounters.remove(i); } }
                                        "sound_emitter" => { if i < area.sound_emitters.len() { area.sound_emitters.remove(i); } }
                                        _ => {}
                                    }
                                }
                                self.selected_object = None;
                                self.selected_obj_info = None;
                                self.selection_list.clear();
                                self.status = format!("Deleted {} object(s)", nudge_targets.len());
                                needs_update = true;
                            } else {
                                for (t, i) in &nudge_targets {
                                    let do_snap = self.snap_to_grid_enabled;
                                    let snap_val = self.snap_to_grid_value;
                                    match t.as_str() {
                                        "creature" => {
                                            if let Some(c) = area.creatures.get_mut(*i) {
                                                c.x += nudge_x * speed; c.y += nudge_y * speed;
                                                if do_snap { let (sx, sy) = snap_to_grid_pos(c.x, c.y, true, snap_val); c.x = sx; c.y = sy; }
                                                c.bearing = (c.bearing + rotate_delta).rem_euclid(std::f32::consts::TAU); needs_update = true;
                                                self.viewport.set_object_transform(t, *i, c.x, c.y, c.z, c.bearing);
                                            }
                                        }
                                        "door" => {
                                            if let Some(d) = area.doors.get_mut(*i) {
                                                d.x += nudge_x * speed; d.y += nudge_y * speed;
                                                if do_snap { let (sx, sy) = snap_to_grid_pos(d.x, d.y, true, snap_val); d.x = sx; d.y = sy; }
                                                d.bearing = (d.bearing + rotate_delta).rem_euclid(std::f32::consts::TAU); needs_update = true;
                                                self.viewport.set_object_transform(t, *i, d.x, d.y, d.z, d.bearing);
                                            }
                                        }
                                        "placeable" => {
                                            if let Some(p) = area.placeables.get_mut(*i) {
                                                p.x += nudge_x * speed; p.y += nudge_y * speed;
                                                if do_snap { let (sx, sy) = snap_to_grid_pos(p.x, p.y, true, snap_val); p.x = sx; p.y = sy; }
                                                p.bearing = (p.bearing + rotate_delta).rem_euclid(std::f32::consts::TAU); needs_update = true;
                                                self.viewport.set_object_transform(t, *i, p.x, p.y, p.z, p.bearing);
                                            }
                                        }
                                        "trigger" => {
                                            if let Some(t) = area.triggers.get_mut(*i) {
                                                t.x += nudge_x * speed; t.y += nudge_y * speed;
                                                if do_snap { let (sx, sy) = snap_to_grid_pos(t.x, t.y, true, snap_val); t.x = sx; t.y = sy; }
                                                t.bearing = (t.bearing + rotate_delta).rem_euclid(std::f32::consts::TAU); needs_update = true;
                                            }
                                        }
                                        "waypoint" => {
                                            if let Some(w) = area.waypoints.get_mut(*i) {
                                                w.x += nudge_x * speed; w.y += nudge_y * speed;
                                                if do_snap { let (sx, sy) = snap_to_grid_pos(w.x, w.y, true, snap_val); w.x = sx; w.y = sy; }
                                                w.bearing = (w.bearing + rotate_delta).rem_euclid(std::f32::consts::TAU); needs_update = true;
                                            }
                                        }
                                        "encounter" => {
                                            if let Some(e) = area.encounters.get_mut(*i) {
                                                e.x += nudge_x * speed; e.y += nudge_y * speed;
                                                if do_snap { let (sx, sy) = snap_to_grid_pos(e.x, e.y, true, snap_val); e.x = sx; e.y = sy; }
                                                e.bearing = (e.bearing + rotate_delta).rem_euclid(std::f32::consts::TAU); needs_update = true;
                                            }
                                        }
                                        "sound_emitter" => {
                                            if let Some(s) = area.sound_emitters.get_mut(*i) {
                                                s.x += nudge_x * speed; s.y += nudge_y * speed;
                                                if self.snap_to_grid_enabled {
                                                    let (sx, sy) = snap_to_grid_pos(s.x, s.y, true, self.snap_to_grid_value);
                                                    s.x = sx; s.y = sy;
                                                }
                                                s.bearing = (s.bearing + rotate_delta).rem_euclid(std::f32::consts::TAU);
                                            }
                                        }
                                        _ => {}
                                    }
                                }
                            }
                            if needs_update {
                                let resref = area.resref.clone();
                                if let Some(ref mut module) = self.module {
                                    module.update_area_git(&resref, area);
                                }
                                self.area_version = self.area_version.wrapping_add(1);
                            }
                        }
                    }
                }

                // Update highlights
                let mut highlight_positions: Vec<[f32; 3]> = Vec::new();
                if let Some(ref area) = self.current_area {
                    for sel in &self.selection_list {
                        if let Some(pos) = get_object_position(area, sel) {
                            highlight_positions.push(pos);
                        }
                    }
                }
                self.viewport.set_highlight_objects(&highlight_positions, 1.5);
                if let Some((col, row)) = self.selected_tile {
                    if let Some(ref area) = self.current_area {
                        let idx = row * area.width as usize + col;
                        let h = area.tiles.get(idx).map(|t| t.height).unwrap_or(0);
                        let height = h as f32 * 0.25 + 0.05;
                        self.viewport.set_highlight_tile(Some(1), col, row, height);
                    }
                } else {
                    self.viewport.set_highlight_tile(None, 0, 0, 0.0);
                }

                let cb = egui_wgpu::Callback::new_paint_callback(rect, self.viewport.clone_arc());
                ui.painter().add(cb);

                // Ghost placement preview overlay (in foreground layer to be above 3D viewport)
                if let Some(ghost_pos) = self.ghost_screen_pos {
                    let ghost_layer_id = egui::LayerId::new(egui::Order::Foreground, egui::Id::new("ghost_preview"));
                    let painter = egui::Painter::new(ui.ctx().clone(), ghost_layer_id, rect);
                    painter.line_segment(
                        [ghost_pos - egui::vec2(10.0, 0.0), ghost_pos + egui::vec2(10.0, 0.0)],
                        egui::Stroke::new(2.0_f32, egui::Color32::YELLOW),
                    );
                    painter.line_segment(
                        [ghost_pos - egui::vec2(0.0, 10.0), ghost_pos + egui::vec2(0.0, 10.0)],
                        egui::Stroke::new(2.0_f32, egui::Color32::YELLOW),
                    );
                    if let PlacementState::Pending(ref typ, ref resref) = self.placement_state {
                        painter.text(
                            ghost_pos + egui::vec2(15.0, -15.0),
                            egui::Align2::LEFT_TOP,
                            format!("Place {}: {}", typ, resref),
                            egui::FontId::proportional(14.0),
                            egui::Color32::YELLOW,
                        );
                    }
                }

                // Drag-select rectangle overlay
                if let Some(start) = self.drag_select_start {
                    let cur_hover = ui.ctx().input(|i| i.pointer.hover_pos());
                    if let Some(end) = cur_hover.filter(|p| rect.contains(*p)) {
                        let sel_layer = egui::LayerId::new(egui::Order::Foreground, egui::Id::new("drag_select_rect"));
                        let painter = egui::Painter::new(ui.ctx().clone(), sel_layer, rect);
                        let min = egui::pos2(start.x.min(end.x), start.y.min(end.y));
                        let max = egui::pos2(start.x.max(end.x), start.y.max(end.y));
                        let fill = egui::Color32::from_rgba_premultiplied(100, 150, 255, 40);
                        let stroke = egui::Stroke::new(1.5_f32, egui::Color32::from_rgb(100, 150, 255));
                        painter.rect(egui::Rect::from_min_max(min, max), 0.0, fill, stroke, egui::StrokeKind::Inside);
                    }
                }
                // Reticle (crosshair at center of viewport)
                {
                    let cx = rect.center().x;
                    let cy = rect.center().y;
                    let reticle_layer = egui::LayerId::new(egui::Order::Foreground, egui::Id::new("reticle"));
                    let rp = egui::Painter::new(ui.ctx().clone(), reticle_layer, rect);
                    let size = 10.0;
                    let gap = 3.0;
                    let color = egui::Color32::WHITE;
                    rp.line_segment([egui::pos2(cx, cy - gap - size), egui::pos2(cx, cy - gap)], egui::Stroke::new(1.5_f32, color));
                    rp.line_segment([egui::pos2(cx, cy + gap), egui::pos2(cx, cy + gap + size)], egui::Stroke::new(1.5_f32, color));
                    rp.line_segment([egui::pos2(cx - gap - size, cy), egui::pos2(cx - gap, cy)], egui::Stroke::new(1.5_f32, color));
                    rp.line_segment([egui::pos2(cx + gap, cy), egui::pos2(cx + gap + size, cy)], egui::Stroke::new(1.5_f32, color));
                }
            } else if self.module.is_some() {
                ui.heading("Select an area from the navigator");
                ui.separator();
                ui.label("Click an area name in the left panel to view it.");
            } else {
                ui.heading("The Aurora BorealiuS Toolset");
                ui.separator();
                ui.label(&self.status);
                ui.separator();
                egui::ScrollArea::vertical().show(ui, |ui| {
                    ui.label("Open a Neverwinter Nights module to get started.");
                    ui.label("The toolset supports:");
                    ui.label("  - Module loading and area browsing");
                    ui.label("  - 3D area map viewport");
                    ui.label("  - Property editing");
                    ui.label("  - NWScript syntax highlighting and editing");
                    ui.label("  - Conversation tree editing");
                    ui.label("  - ERF/MOD/HAK packaging");
                });
            }
        });

        // Tool hotkeys & Escape
        let pressed = |k| ctx.input(|i| i.key_pressed(k));
        if pressed(egui::Key::Escape) {
            if matches!(self.placement_state, PlacementState::Pending(..)) {
                self.placement_state = PlacementState::Inactive;
                self.status = "Placement cancelled.".to_string();
            }
            self.active_tool = Tool::Select;
            self.selected_object = None;
            self.selection_list.clear();
            self.selected_obj_info = None;
        }
        if pressed(egui::Key::Num1) { self.active_tool = Tool::Select; }
        if pressed(egui::Key::Num2) { self.active_tool = Tool::TerrainRaise; }
        if pressed(egui::Key::Num3) { self.active_tool = Tool::TerrainSmooth; }
        if pressed(egui::Key::Num4) { self.active_tool = Tool::WalkmeshWall; }

        // Global keyboard shortcuts
        let ctrl_c = ctx.input(|i| i.modifiers.ctrl && i.key_pressed(egui::Key::C));
        let ctrl_v = ctx.input(|i| i.modifiers.ctrl && i.key_pressed(egui::Key::V));
        let ctrl_z = ctx.input(|i| i.modifiers.ctrl && !i.modifiers.shift && i.key_pressed(egui::Key::Z));
        let ctrl_shift_z = ctx.input(|i| i.modifiers.ctrl && i.modifiers.shift && i.key_pressed(egui::Key::Z));
        if ctrl_c {
            self.copy_selected_object();
        }
        if ctrl_v {
            self.paste_object(target_format);
        }
        if ctrl_z {
            self.undo(target_format);
        }
        if ctrl_shift_z {
            self.redo(target_format);
        }

        // ===================== STATUS BAR =====================
        let now = std::time::Instant::now();
        let dt = now.duration_since(self.last_frame_time).as_secs_f64();
        self.last_frame_time = now;
        self.fps_accum += 1.0;
        self.fps_timer += dt;

        // Per-frame memory check — hard cap enforcement
        let rss_kb = current_rss_kb();
        let rss_mb = rss_kb / 1024;
        let limit_mb = self.max_ram_mb as u64;
        let limit_kb = limit_mb * 1024;
        if rss_kb > limit_kb {
            // Over hard cap — evict everything we can
            self.viewport.evict_model_cache();
            self.viewport.set_texture_mem_limit(64 * 1024 * 1024);
            if let Some(ref module) = self.module {
                module.evict_memory_caches();
            }
            if self.last_rss_mb <= limit_mb {
                self.status = format!("OVER MEM LIMIT! {} MB / {} MB — caches flushed", rss_mb, limit_mb);
            }
        } else {
            // Texture budget: 10% of free RAM, clamped 32 MB .. 128 MB
            let free_mb = limit_mb.saturating_sub(rss_mb);
            let tex_budget_mb = (free_mb / 10).max(2048);
            self.viewport.set_texture_mem_limit(tex_budget_mb * 1024 * 1024);
        }
        self.last_rss_mb = rss_mb;

        let fps_str = if self.fps_timer >= 1.0 {
            let fps = (self.fps_accum / self.fps_timer) as usize;
            self.fps_accum = 0.0;
            self.fps_timer = 0.0;
            if rss_kb > limit_kb {
                self.status = format!("OVER MEM LIMIT! {} MB / {} MB — caches flushed", rss_mb, limit_mb);
            } else if rss_kb > limit_kb * 85 / 100 {
                self.status = format!("High memory: {} MB / {} MB", rss_mb, limit_mb);
            }
            format!("{} FPS | RAM: {} / {} MB", fps, rss_mb, limit_mb)
        } else {
            format!("{:.0} FPS | RAM: {} / {} MB", self.fps_accum / self.fps_timer.max(0.001), self.last_rss_mb, limit_mb)
        };
        egui::TopBottomPanel::bottom("status").show(ctx, |ui| {
            ui.horizontal(|ui| {
                if let Some((ref progress, total)) = self.compile_progress {
                    let done = progress.load(Ordering::Relaxed);
                    let pct = done as f64 / total as f64;
                    ui.label(format!("Compiling {}/{} scripts", done, total));
                    ui.add(
                        egui::ProgressBar::new(pct as f32)
                            .desired_width(120.0)
                            .show_percentage()
                            .animate(true)
                    );
                } else {
                    ui.label(&self.status);
                }
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    ui.label(&fps_str);
                    ui.separator();
                    if let Some(ref module) = self.module {
                        ui.label(format!("{} areas", module.num_areas()));
                        ui.separator();
                        ui.label(&module.name);
                    }
                });
            });
        });

        // ===================== POST-RENDER HANDLERS =====================
        // Check NWSync result
        if let Ok(mut r) = self.nwsync_result.lock() {
            if let Some(msg) = r.take() {
                self.status = msg;
                self.nwsync_busy = false;
            }
        }

        // Handle module properties save
        if module_props_changed {
            if let Some(ref mut module) = self.module {
                module.name = self.module_name_edit.clone();
                module.tag = self.module_tag_edit.clone();
                module.entry_area = self.module_entry_edit.clone();
                module.description = self.module_description_edit.clone();
                module.modified = true;
                self.status = "Module properties updated.".to_string();
            }
        }

        // Handle resource viewer callbacks
        if let Some((name, table)) = save_2da {
            if let Some(ref mut module) = self.module {
                let data = table.to_2da_string();
                module.update_2da(&name, &data);
                self.status = format!("2DA '{}' updated via resource viewer.", name);
            }
        }
        if let Some(name) = open_script {
            if let Some(ref module) = self.module {
                if let Some(source) = module.get_script_source(&name) {
                    self.script_editor_scripts.push((name.clone(), source.to_string()));
                    self.status = format!("Opened script '{}'.", name);
                }
            }
        }
        if let Some(name) = open_conversation {
            if let Some(ref module) = self.module {
                if let Some(convo) = module.get_conversation(&name) {
                    self.conversation_editors.push((name.clone(), ConversationEditor::new(name.clone(), convo)));
                    self.status = format!("Opened conversation '{}'.", name);
                }
            }
        }

        // ===================== CONTENTS PANEL =====================
        if self.show_contents_panel {
            egui::SidePanel::left("contents_panel")
                .resizable(true)
                .default_width(250.0)
                .show(ctx, |ui| {
                    ui.heading("Contents");
                    ui.separator();
                    if let Some(ref area) = self.current_area {
                        egui::ScrollArea::vertical().show(ui, |ui| {
                            fn list_category(ui: &mut egui::Ui, label: &str, items: &[impl AsRef<str>], selected: Option<usize>, on_select: &mut impl FnMut(usize)) {
                                egui::CollapsingHeader::new(format!("{} ({})", label, items.len()))
                                    .default_open(!items.is_empty())
                                    .show(ui, |ui| {
                                        for (i, item) in items.iter().enumerate() {
                                            let is_selected = selected == Some(i);
                                            let resp = ui.selectable_label(is_selected, item.as_ref());
                                            if resp.clicked() {
                                                on_select(i);
                                            }
                                        }
                                    });
                            }
                            // Cache lists to avoid borrowing issues
                            let creature_labels: Vec<String> = area.creatures.iter().map(|c| format!("{} ({})", c.resref, c.tag)).collect();
                            let door_labels: Vec<String> = area.doors.iter().map(|d| format!("{} ({})", d.resref, d.tag)).collect();
                            let placeable_labels: Vec<String> = area.placeables.iter().map(|p| format!("{} ({})", p.resref, p.tag)).collect();
                            let trigger_labels: Vec<String> = area.triggers.iter().map(|t| format!("Trigger ({})", t.tag)).collect();
                            let waypoint_labels: Vec<String> = area.waypoints.iter().map(|w| format!("Waypoint ({})", w.tag)).collect();
                            let encounter_labels: Vec<String> = area.encounters.iter().map(|e| format!("{} ({})", e.name, e.tag)).collect();
                            let sound_emitter_labels: Vec<String> = area.sound_emitters.iter().map(|s| format!("Sound: {}", s.tag)).collect();
                            let sel_info = self.selected_obj_info.clone();
                            let mut new_sel: Option<(String, usize)> = None;
                            list_category(ui, "Creatures", &creature_labels, if sel_info.as_ref().map_or(false, |(t, _)| t == "creature") { sel_info.as_ref().map(|(_, i)| *i) } else { None }, &mut |i| new_sel = Some(("creature".to_string(), i)));
                            list_category(ui, "Doors", &door_labels, if sel_info.as_ref().map_or(false, |(t, _)| t == "door") { sel_info.as_ref().map(|(_, i)| *i) } else { None }, &mut |i| new_sel = Some(("door".to_string(), i)));
                            list_category(ui, "Placeables", &placeable_labels, if sel_info.as_ref().map_or(false, |(t, _)| t == "placeable") { sel_info.as_ref().map(|(_, i)| *i) } else { None }, &mut |i| new_sel = Some(("placeable".to_string(), i)));
                            list_category(ui, "Triggers", &trigger_labels, if sel_info.as_ref().map_or(false, |(t, _)| t == "trigger") { sel_info.as_ref().map(|(_, i)| *i) } else { None }, &mut |i| new_sel = Some(("trigger".to_string(), i)));
                            list_category(ui, "Waypoints", &waypoint_labels, if sel_info.as_ref().map_or(false, |(t, _)| t == "waypoint") { sel_info.as_ref().map(|(_, i)| *i) } else { None }, &mut |i| new_sel = Some(("waypoint".to_string(), i)));
                            list_category(ui, "Encounters", &encounter_labels, if sel_info.as_ref().map_or(false, |(t, _)| t == "encounter") { sel_info.as_ref().map(|(_, i)| *i) } else { None }, &mut |i| new_sel = Some(("encounter".to_string(), i)));
                            list_category(ui, "Sound Emitters", &sound_emitter_labels, if sel_info.as_ref().map_or(false, |(t, _)| t == "sound_emitter") { sel_info.as_ref().map(|(_, i)| *i) } else { None }, &mut |i| new_sel = Some(("sound_emitter".to_string(), i)));
                            if let Some((obj_type, obj_idx)) = new_sel {
                                if let Some(ref area) = self.current_area {
                                    let bag = match obj_type.as_str() {
                                        "creature" => area.creatures.get(obj_idx).map(|c| c.to_property_bag()),
                                        "door" => area.doors.get(obj_idx).map(|d| d.to_property_bag()),
                                        "placeable" => area.placeables.get(obj_idx).map(|p| p.to_property_bag()),
                                        "trigger" => area.triggers.get(obj_idx).map(|t| t.to_property_bag()),
                                        "waypoint" => area.waypoints.get(obj_idx).map(|w| w.to_property_bag()),
                                        "encounter" => area.encounters.get(obj_idx).map(|e| e.to_property_bag()),
                                        "sound_emitter" => area.sound_emitters.get(obj_idx).map(|s| s.to_property_bag()),
                                        _ => None,
                                    };
                                    if let Some(bag) = bag {
                                        self.selected_object = Some(SelectedObject { title: format!("{} #{}", obj_type, obj_idx), bag });
                                        self.selected_obj_info = Some((obj_type, obj_idx));
                                    }
                                }
                            }
                        });
                    } else {
                        ui.label("No area loaded.");
                    }
                });
        }

        // ===================== NEW AREA DIALOG =====================
        if self.new_area_open {
            let mut new_area_open = true;
            // Collect existing area names and tilesets
            let area_names: Vec<String> = self.module.as_ref().map(|m| m.area_names().to_vec()).unwrap_or_default();
            let mut tilesets: Vec<String> = Vec::new();
            if let Some(ref module) = self.module {
                let mut seen = std::collections::HashSet::new();
                for an in &area_names {
                    if let Some(area) = module.get_area(an) {
                        if seen.insert(area.tileset.clone()) {
                            tilesets.push(area.tileset.clone());
                        }
                    }
                }
                tilesets.sort();
            }
            egui::Window::new("New Area")
                .default_size([400.0, 350.0])
                .open(&mut new_area_open)
                .show(ctx, |ui| {
                    ui.horizontal(|ui| {
                        ui.label("Resref:");
                        ui.text_edit_singleline(&mut self.new_area_resref_filter);
                        egui::ScrollArea::vertical().max_height(100.0).show(ui, |ui| {
                            let filter = self.new_area_resref_filter.to_lowercase();
                            for name in &area_names {
                                if !filter.is_empty() && !name.to_lowercase().contains(&filter) {
                                    continue;
                                }
                                if ui.selectable_label(self.new_area_resref == *name, name).clicked() {
                                    self.new_area_resref = name.clone();
                                }
                            }
                        });
                    });
                    ui.horizontal(|ui| {
                        ui.label("Tileset:");
                        ui.text_edit_singleline(&mut self.new_area_tileset_filter);
                        egui::ScrollArea::vertical().max_height(100.0).show(ui, |ui| {
                            let filter = self.new_area_tileset_filter.to_lowercase();
                            for name in &tilesets {
                                if !filter.is_empty() && !name.to_lowercase().contains(&filter) {
                                    continue;
                                }
                                if ui.selectable_label(self.new_area_tileset == *name, name).clicked() {
                                    self.new_area_tileset = name.clone();
                                }
                            }
                        });
                    });
                    ui.horizontal(|ui| {
                        ui.label("Width:");
                        ui.add(egui::DragValue::new(&mut self.new_area_width).range(4..=64));
                    });
                    ui.horizontal(|ui| {
                        ui.label("Height:");
                        ui.add(egui::DragValue::new(&mut self.new_area_height).range(4..=64));
                    });
                    ui.separator();
                    if ui.button("Create Area").clicked() {
                        if !self.new_area_resref.is_empty() && !self.new_area_tileset.is_empty() {
                            if let Some(ref mut module) = self.module {
                                let resref = module.new_empty_area(&self.new_area_resref, &self.new_area_tileset, self.new_area_width, self.new_area_height);
                                self.new_area_resref.clear();
                                self.new_area_tileset.clear();
                                // Load area into viewport and add to open tabs
                                if let Some(area) = module.get_area(&resref) {
                                    self.area_version = self.area_version.wrapping_add(1);
                                    self.viewport.set_area(area.clone(), self.area_version, target_format);
                                    self.current_area = Some(area);
                                    self.selected_object = None;
                                    self.selected_obj_info = None;
                                }
                                if !self.open_areas.contains(&resref) {
                                    self.open_areas.push(resref.clone());
                                }
                                self.active_area_idx = self.open_areas.len() - 1;
                                self.status = format!("Created area '{}'.", resref);
                            }
                        } else {
                            self.status = "Enter a resref and tileset name.".to_string();
                        }
                    }
                });
            if !new_area_open {
                self.new_area_open = false;
            }
        }



        // ===================== NEW OBJECT DIALOG =====================
        if self.new_object_open {
            let mut still_open = true;
            let mut created = false;
            // Map object type to 2DA table name for blueprint listing
            let two_da_name: &str = match self.new_object_type.as_str() {
                "creature" => "creatures",
                "door" => "doortypes",
                "placeable" => "placeables",
                "trigger" => "triggers",
                "waypoint" => "waypoints",
                "encounter" => "encounters",
                _ => "",
            };
            // Refresh blueprint list when type changes
            if self.new_object_blueprints.is_empty() && !two_da_name.is_empty() {
                if let Some(ref module) = self.module {
                    self.new_object_blueprints = module.blueprint_resrefs(two_da_name);
                }
            }
            egui::Window::new("New Object")
                .default_size([400.0, 500.0])
                .open(&mut still_open)
                .show(ctx, |ui| {
                    let prev_type = self.new_object_type.clone();
                    ui.horizontal(|ui| {
                        ui.label("Type:");
                        egui::ComboBox::from_id_salt("new_obj_type")
                            .selected_text(&self.new_object_type)
                            .show_ui(ui, |ui| {
                                for t in &["creature", "door", "placeable", "trigger", "waypoint", "encounter", "sound_emitter"] {
                                    ui.selectable_value(&mut self.new_object_type, t.to_string(), *t);
                                }
                            });
                    });
                    // Refresh blueprint list when type changes
                    if self.new_object_type != prev_type {
                        self.new_object_blueprints.clear();
                        self.new_object_filter.clear();
                        if !two_da_name.is_empty() {
                            if let Some(ref module) = self.module {
                                self.new_object_blueprints = module.blueprint_resrefs(two_da_name);
                            }
                        }
                    }
                    ui.horizontal(|ui| {
                        ui.label("Search:");
                        ui.text_edit_singleline(&mut self.new_object_filter);
                    });
                    ui.horizontal(|ui| {
                        ui.label("ResRef:");
                        if !two_da_name.is_empty() && !self.new_object_blueprints.is_empty() {
                            let current_label = if self.new_object_resref.is_empty() {
                                "Select...".to_string()
                            } else {
                                self.new_object_resref.clone()
                            };
                            if ui.button(current_label).clicked() {
                                self.new_object_resref_browse_open = true;
                            }
                        } else {
                            ui.text_edit_singleline(&mut self.new_object_resref);
                        }
                    });
                    ui.horizontal(|ui| {
                        ui.label("Tag:");
                        ui.text_edit_singleline(&mut self.new_object_tag);
                    });
                    ui.separator();
                    ui.label("Position:");
                    ui.horizontal(|ui| {
                        ui.label("X:");
                        ui.add(egui::DragValue::new(&mut self.new_object_x).speed(0.5));
                        ui.label("Y:");
                        ui.add(egui::DragValue::new(&mut self.new_object_y).speed(0.5));
                        ui.label("Z:");
                        ui.add(egui::DragValue::new(&mut self.new_object_z).speed(0.5));
                    });
                    ui.horizontal(|ui| {
                        ui.label("Bearing:");
                        ui.add(egui::DragValue::new(&mut self.new_object_bearing).speed(0.1));
                    });
                    ui.separator();
                    if ui.button("Create Object").clicked() {
                        let resref = self.new_object_resref.clone();
                        let typ = self.new_object_type.clone();
                        if resref.is_empty() {
                            self.status = "Enter a ResRef for the new object.".to_string();
                        } else {
                            let tag = if self.new_object_tag.is_empty() {
                                format!("{}_{}", typ, resref)
                            } else {
                                self.new_object_tag.clone()
                            };
                            self.push_undo();
                            let (sx, sy) = snap_to_grid_pos(self.new_object_x, self.new_object_y, self.snap_to_grid_enabled, self.snap_to_grid_value);
                            self.new_object_x = sx;
                            self.new_object_y = sy;
                            if let Some(area) = self.current_area.as_mut() {
                                let area = Arc::make_mut(area);
                                match typ.as_str() {
                                    "creature" => {
                                        area.creatures.push(nwn_gamemodel::CreatureInstance {
                                            resref: resref.clone(), tag,
                                            x: self.new_object_x, y: self.new_object_y,
                                            z: self.new_object_z, bearing: self.new_object_bearing,
                                            appearance: 0, model_name: None,
                                            gender: 0, plt_layers: nwn_gamemodel::CreatureInstance::default_plt_layers(),
                                        });
                                    }
                                    "door" => {
                                        area.doors.push(nwn_gamemodel::DoorInstance {
                                            resref: resref.clone(), tag,
                                            x: self.new_object_x, y: self.new_object_y,
                                            z: self.new_object_z, bearing: self.new_object_bearing,
                                            appearance: 0, model_name: None,
                                        });
                                    }
                                    "placeable" => {
                                        area.placeables.push(nwn_gamemodel::PlaceableInstance {
                                            resref: resref.clone(), tag,
                                            x: self.new_object_x, y: self.new_object_y,
                                            z: self.new_object_z, bearing: self.new_object_bearing,
                                            appearance: 0, model_name: None,
                                            has_light: false, light_color: [255, 255, 255, 255], light_radius: 5.0,
                                        });
                                    }
                                    "trigger" => {
                                        area.triggers.push(nwn_gamemodel::TriggerInstance {
                                            resref: resref.clone(), tag,
                                            x: self.new_object_x, y: self.new_object_y,
                                            z: self.new_object_z, bearing: self.new_object_bearing,
                                            geometry: Vec::new(),
                                        });
                                    }
                                    "waypoint" => {
                                        area.waypoints.push(nwn_gamemodel::WayPointInstance {
                                            resref: resref.clone(), tag,
                                            x: self.new_object_x, y: self.new_object_y,
                                            z: self.new_object_z, bearing: self.new_object_bearing,
                                        });
                                    }
                                    "encounter" => {
                                        area.encounters.push(nwn_gamemodel::EncounterInstance {
                                            tag: tag.clone(), name: resref.clone(),
                                            x: self.new_object_x, y: self.new_object_y,
                                            z: self.new_object_z, bearing: self.new_object_bearing,
                                            geometry: Vec::new(), difficulty: 1,
                                            player_only: false, reset: 1,
                                            max_creatures: 6, spawn_option: 0,
                                            on_entered: String::new(), on_exhausted: String::new(),
                                            on_exit: String::new(), on_heartbeat: String::new(),
                                            on_user_defined: String::new(),
                                        });
                                    }
                                    "sound_emitter" => {
                                        area.sound_emitters.push(nwn_gamemodel::SoundEmitterInstance {
                                            tag: tag.clone(),
                                            template_resref: resref.clone(),
                                            x: self.new_object_x, y: self.new_object_y,
                                            z: self.new_object_z, bearing: self.new_object_bearing,
                                            positional: true,
                                            min_distance: 10.0,
                                            max_distance: 40.0,
                                            volume: 100,
                                            sounds: Vec::new(),
                                        });
                                    }
                                    _ => {}
                                }
                                let resref_name = area.resref.clone();
                                if let Some(ref mut module) = self.module {
                                    module.update_area_git(&resref_name, area);
                                }
                                self.area_version = self.area_version.wrapping_add(1);
                                self.status = format!("Created {} '{}'", typ, resref);
                                // Auto-select the newly created object
                                let idx = match typ.as_str() {
                                    "creature" => area.creatures.len().wrapping_sub(1),
                                    "door" => area.doors.len().wrapping_sub(1),
                                    "placeable" => area.placeables.len().wrapping_sub(1),
                                    "trigger" => area.triggers.len().wrapping_sub(1),
                                    "waypoint" => area.waypoints.len().wrapping_sub(1),
                                    "encounter" => area.encounters.len().wrapping_sub(1),
                                    "sound_emitter" => area.sound_emitters.len().wrapping_sub(1),
                                    _ => usize::MAX,
                                };
                                if idx != usize::MAX {
                                    select_single_object(area, self.module.as_ref(), &mut self.selected_object, &mut self.selected_obj_info, &mut self.selected_tile, &typ, idx);
                                }
                            }
                            created = true;
                        }
                    }
                });
            if !still_open || created {
                self.new_object_open = false;
            }
        }
        // Blueprint browser popup (for New Object dialog)
        if self.new_object_resref_browse_open {
            let two_da_name: &str = match self.new_object_type.as_str() {
                "creature" => "creatures",
                "door" => "doortypes",
                "placeable" => "placeables",
                "trigger" => "triggers",
                "waypoint" => "waypoints",
                "encounter" => "encounters",
                _ => "",
            };
            let mut selected = false;
            egui::Window::new("Select Blueprint")
                .id("resref_browse".into())
                .default_size([350.0, 450.0])
                .show(ctx, |ui| {
                    ui.horizontal(|ui| {
                        ui.label("Filter:");
                        ui.text_edit_singleline(&mut self.new_object_filter);
                    });
                    ui.separator();
                    if !two_da_name.is_empty() {
                        if let Some(ref module) = self.module {
                            let blueprints = module.blueprint_resrefs(two_da_name);
                            let filter = self.new_object_filter.to_lowercase();
                            let mut filtered: Vec<&(String, String)> = blueprints.iter()
                                .filter(|(r, n)| {
                                    filter.is_empty()
                                        || r.to_lowercase().contains(&filter)
                                        || n.to_lowercase().contains(&filter)
                                })
                                .collect();
                            filtered.sort_by(|(r1, _), (r2, _)| r1.cmp(r2));
                            egui::ScrollArea::vertical()
                                .show(ui, |ui| {
                                    for (row_label, name) in &filtered {
                                        let display = format!("{} ({})", name, row_label);
                                        if ui.selectable_label(self.new_object_resref == *row_label, &display).clicked() {
                                            self.new_object_resref = row_label.clone();
                                            selected = true;
                                        }
                                    }
                                });
                        }
                    }
                });
            if selected {
                self.new_object_resref_browse_open = false;
            }
        }


        // ===================== EDITOR WINDOWS =====================
        // Faction Editor
        if self.faction_editor_open {
            let mut faction_list: Option<FactionList> = None;
            let mut do_save = false;
            let mut do_close = false;
            egui::Window::new("Faction Editor")
                .default_size([500.0, 400.0])
                .open(&mut self.faction_editor_open)
                .show(ctx, |ui| {
                    let erf = self.module.as_ref().and_then(|m| m.erf.as_ref());
                    let _ = crate::faction_editor::show_faction_editor(ui, erf, &mut faction_list);
                    ui.separator();
                    ui.horizontal(|ui| {
                        if ui.button("Save").clicked() {
                            do_save = true;
                        }
                        if ui.button("Close").clicked() {
                            do_close = true;
                        }
                    });
                });
            if do_close {
                self.faction_editor_open = false;
            }
            if let Some(fl) = &faction_list {
                self.faction_list = fl.clone();
                if do_save || !self.faction_editor_open {
                    let gff = fl.to_gff();
                    let data = gff.to_bytes();
                    if let Some(ref mut module) = self.module {
                        module.update_fac(data);
                        self.status = "Faction data saved to module.".to_string();
                    }
                }
            }
        }
        // Journal Editor
        if self.journal_editor_open {
            let mut journal = self.module.as_ref().and_then(|m| {
                let erf = m.erf.as_ref()?;
                let data = erf.get("journal", nwn_gamemodel::resource_types::JRL)
                    .or_else(|| erf.get("Journal", nwn_gamemodel::resource_types::JRL))
                    .or_else(|| erf.get("module", nwn_gamemodel::resource_types::JRL))
                    .or_else(|| erf.get("Module", nwn_gamemodel::resource_types::JRL))?;
                let gff = nwn_gff::GffFile::from_bytes(&data).ok()?;
                nwn_gamemodel::Journal::from_gff(&gff).ok()
            });
            let mut do_save = false;
            let mut do_close = false;
            egui::Window::new("Journal Editor")
                .default_size([500.0, 400.0])
                .open(&mut self.journal_editor_open)
                .show(ctx, |ui| {
                    let modified = crate::journal_editor::show_journal_editor(ui, &mut journal);
                    ui.separator();
                    ui.horizontal(|ui| {
                        if ui.add_enabled(modified, egui::Button::new("Save")).clicked() {
                            do_save = true;
                        }
                        if ui.button("Close").clicked() {
                            do_close = true;
                        }
                    });
                });
            if do_close {
                self.journal_editor_open = false;
            }
            if (do_save || !self.journal_editor_open) && self.module.is_some() {
                if let Some(j) = &mut journal {
                    let gff = j.to_gff();
                    let data = gff.to_bytes();
                    self.module.as_mut().unwrap().update_jrl(data);
                    self.status = "Journal data saved to module.".to_string();
                }
            }
        }
        // Encounter Editor
        if self.encounter_editor_open {
            let mut do_save = false;
            let mut enc_selected: Option<usize> = None;
            std::mem::swap(&mut enc_selected, &mut self.encounter_editor_selected);
            egui::Window::new("Encounter Editor")
                .default_size([600.0, 450.0])
                .open(&mut self.encounter_editor_open)
                .show(ctx, |ui| {
                    if let Some(ref mut area) = self.current_area {
                        crate::encounter_editor::show_encounter_editor(ui, &mut Arc::make_mut(area).encounters, &mut do_save, &mut enc_selected);
                    } else {
                        ui.label("No area loaded.");
                    }
                });
            self.encounter_editor_selected = enc_selected;
            if do_save {
                if let Some(ref area) = self.current_area {
                    let resref = area.resref.clone();
                    if let Some(ref mut module) = self.module {
                        module.update_area_git(&resref, area);
                    }
                    self.area_version = self.area_version.wrapping_add(1);
                }
            }
        }

        // ===================== PROPERTY INSPECTOR (RIGHT PANEL) =====================
        let mut inspector_modified = false;
        let mut delete_requested = false;
        let mut pos_update: Option<(String, usize, f32, f32, f32, f32)> = None;
        let mut tile_update: Option<(usize, i32, i32, i32, bool)> = None;
        // Use cached names/tags to avoid re-parsing all GIT data every frame
        let cached_resrefs = self.module.as_ref().map(module_resref_names).unwrap_or_default();
        let cached_tags = self.module.as_ref().map(module_tag_names).unwrap_or_default();
        // Tile ID palette data for dropdown (computed inline in the tile panel below)
        egui::SidePanel::right("inspector")
            .resizable(true)
            .default_width(300.0)
            .frame(egui::Frame {
                fill: ctx.style().visuals.panel_fill,
                ..Default::default()
            })
            .show(ctx, |ui| {
                ui.heading("Properties");
                ui.separator();
                if let Some(ref mut obj) = self.selected_object {
                    // Position & bearing controls
                    if let Some((ref obj_type, obj_idx)) = self.selected_obj_info {
                        let obj_type = obj_type.clone();
                        let obj_idx = obj_idx;
                        let sel_count = self.selection_list.len();
                        if sel_count > 1 {
                            ui.label(format!("Type: {}  Index: {}  ({} selected)", obj_type, obj_idx, sel_count));
                        } else {
                            ui.label(format!("Type: {}  Index: {}", obj_type, obj_idx));
                        }
                        ui.separator();
                        let pos = self.current_area.as_ref().and_then(|area| {
                            match obj_type.as_str() {
                                "creature" => area.creatures.get(obj_idx).map(|c| (c.x, c.y, c.z, c.bearing)),
                                "door" => area.doors.get(obj_idx).map(|d| (d.x, d.y, d.z, d.bearing)),
                                "placeable" => area.placeables.get(obj_idx).map(|p| (p.x, p.y, p.z, p.bearing)),
                                "trigger" => area.triggers.get(obj_idx).map(|t| (t.x, t.y, t.z, t.bearing)),
                                "waypoint" => area.waypoints.get(obj_idx).map(|w| (w.x, w.y, w.z, w.bearing)),
                                "encounter" => area.encounters.get(obj_idx).map(|e| (e.x, e.y, e.z, e.bearing)),
                                "sound_emitter" => area.sound_emitters.get(obj_idx).map(|s| (s.x, s.y, s.z, s.bearing)),
                                _ => None,
                            }
                        });
                        if let Some((mut px, mut py, mut pz, mut pb)) = pos {
                            ui.horizontal(|ui| {
                                ui.label("X");
                                if ui.add(egui::DragValue::new(&mut px).speed(0.5).prefix(" ")).changed() {
                                    pos_update = Some((obj_type.clone(), obj_idx, px, py, pz, pb));
                                }
                                ui.label("Y");
                                if ui.add(egui::DragValue::new(&mut py).speed(0.5).prefix(" ")).changed() {
                                    pos_update = Some((obj_type.clone(), obj_idx, px, py, pz, pb));
                                }
                            });
                            ui.horizontal(|ui| {
                                ui.label("Z");
                                if ui.add(egui::DragValue::new(&mut pz).speed(0.2).prefix(" ")).changed() {
                                    pos_update = Some((obj_type.clone(), obj_idx, px, py, pz, pb));
                                }
                                ui.label("Rot");
                                if ui.add(egui::DragValue::new(&mut pb).speed(0.05).prefix(" ").range(-6.28..=6.28)).changed() {
                                    pos_update = Some((obj_type.clone(), obj_idx, px, py, pz, pb));
                                }
                            });
                            ui.separator();
                        }
                        if self.icons.icon_button(ui, "trash-can", "Delete Object", 20.0).clicked() {
                            delete_requested = true;
                        }
                        ui.separator();
                        if let Some((ref obj_type, obj_idx)) = self.selected_obj_info {
                            if self.icons.icon_button(ui, "stack", "Local Variables", 20.0).clicked() {
                                if let Some(ref module) = self.module {
                                    if let Some(ref area) = self.current_area {
                                        let vars = load_local_vars(module, &area.resref, obj_type, obj_idx);
                                        self.local_var_editor = Some(LocalVarEditorState {
                                            obj_type: obj_type.clone(),
                                            obj_idx,
                                            vars,
                                        });
                                    }
                                }
                            }
                            if self.icons.icon_button(ui, "eye-target", "Appearance Picker", 20.0).clicked() {
                                let appearances = self.module.as_ref().and_then(|m| {
                                    let two_da = m.resource_manager.get_2da("appearance")?;
                                    let base_two_da = m.resource_manager.get_2da("appearance_base");
                                    let mut entries = Vec::new();
                                    for i in 0..two_da.row_count() {
                                        let id = i as i32;
                                        if id > 0 {
                                            let label = two_da.get_cell_by_label(i, "Label")
                                                .or_else(|| two_da.get_cell_by_label(i, "NAME"))
                                                .or_else(|| {
                                                    base_two_da.and_then(|b| b.get_cell_by_label(i, "Label"))
                                                })
                                                .unwrap_or("").to_string();
                                            let mut model = two_da.get_cell_by_label(i, "ModelName")
                                                .or_else(|| two_da.get_cell_by_label(i, "model"))
                                                .or_else(|| two_da.get_cell_by_label(i, "Model"))
                                                .or_else(|| two_da.get_cell_by_label(i, "RACE"))
                                                .unwrap_or("").to_string();
                                            if model.is_empty() {
                                                model = base_two_da.and_then(|b| b.get_cell_by_label(i, "ModelName")
                                                    .or_else(|| b.get_cell_by_label(i, "model"))
                                                    .or_else(|| b.get_cell_by_label(i, "Model"))).unwrap_or("").to_string();
                                            }
                                            entries.push(AppearanceEntry { id, label, model });
                                        }
                                    }
                                    Some(entries)
                                }).unwrap_or_default();
                                self.appearance_picker = Some(AppearancePickerState {
                                    obj_type: obj_type.clone(),
                                    obj_idx,
                                    filter: String::new(),
                                    appearances,
                                });
                            }
                            if self.icons.icon_button(ui, "pencil", "Comment", 20.0).clicked() {
                                let resref = self.current_area.as_ref().map(|a| a.resref.clone()).unwrap_or_default();
                                let comment = self.module.as_ref().map(|m| load_object_comment(m, &resref, obj_type, obj_idx)).unwrap_or_default();
                                self.object_comment_edit = Some((obj_type.clone(), obj_idx, comment));
                            }
                            if obj_type == "creature" || obj_type == "placeable" {
                                if self.icons.icon_button(ui, "chest", "Inventory", 20.0).clicked() {
                                    let resref = self.current_area.as_ref().map(|a| a.resref.clone()).unwrap_or_default();
                                    let items = load_item_list(self.module.as_ref(), &resref, obj_type, obj_idx);
                                    self.inventory_editor = Some(InventoryEditorState {
                                        obj_type: obj_type.clone(),
                                        obj_idx,
                                        items,
                                        editing_item: None,
                                        add_blueprint_filter: String::new(),
                                        add_blueprint_results: Vec::new(),
                                    });
                                }
                            }
                        }
                        ui.separator();
                    }
                    inspector_modified = show_inspector(ui, obj, &cached_resrefs, &cached_tags, self.module.as_ref().map(|m| &m.resource_manager));
                } else if self.selected_tile.is_some() {
                    ui.colored_label(egui::Color32::GREEN, "Tile selected — use Tile Properties window");
                } else if matches!(self.placement_state, PlacementState::Pending(..)) {
                    ui.colored_label(egui::Color32::YELLOW, "Placement mode active");
                    ui.label("Click in the viewport to place the object.");
                    ui.label("Press Escape to cancel.");
                } else {
                    ui.colored_label(egui::Color32::GRAY, "Select an object to inspect");
                }
            });
        // ===================== TILE PROPERTIES WINDOW =====================
        if self.selected_tile.is_some() {
            let mut tile_props_open = true;
            egui::Window::new("Tile Properties")
                .id("tile_props_window".into())
                .default_width(280.0)
                .open(&mut tile_props_open)
                .show(ctx, |ui| {
                    if let Some((col, row)) = self.selected_tile {
                        if let Some(ref area) = self.current_area {
                            let tile_idx = row * area.width as usize + col;
                            if let Some(tile) = area.tiles.get(tile_idx) {
                                ui.label(format!("Tile ({}, {})", col, row));
                                if let Some(model_name) = area.tile_models.get(tile_idx).and_then(|m| m.as_ref()) {
                                    ui.label(format!("Model: {}", model_name));
                                }
                                ui.separator();
                                let orig_id = tile.id;
                                let orig_orient = tile.orientation;
                                let orig_h = tile.height;
                                let orig_w = tile.walkable;
                                let mut tid = orig_id;
                                let mut torient = orig_orient;
                                let mut th = orig_h;
                                let mut tw = orig_w;
                                // Tile ID dropdown
                                ui.label("Tile ID");
                                let tile_palette: Vec<(i32, String)> = self.module.as_ref()
                                    .map(|m| get_tile_palette(m, &area.tileset))
                                    .unwrap_or_default();
                                egui::ComboBox::from_id_salt("tile_id_combo")
                                    .selected_text(tile_palette.iter()
                                        .find(|(id, _)| *id == tid)
                                        .map(|(id, name)| format!("{}:{}", id, name))
                                        .unwrap_or_else(|| format!("{}", tid)))
                                    .width(180.0)
                                    .show_ui(ui, |ui| {
                                        for (pid, pname) in &tile_palette {
                                            ui.selectable_value(&mut tid, *pid, format!("{}:{}", pid, pname));
                                        }
                                    });
                                ui.horizontal(|ui| {
                                    ui.label("Orientation");
                                    ui.add(egui::DragValue::new(&mut torient).speed(1).range(0..=3));
                                });
                                ui.horizontal(|ui| {
                                    ui.label("Height");
                                    ui.add(egui::DragValue::new(&mut th).speed(1).range(0..=255));
                                });
                                ui.checkbox(&mut tw, "Walkable");
                                if tid != orig_id || torient != orig_orient || th != orig_h || tw != orig_w {
                                    tile_update = Some((tile_idx, tid, torient, th, tw));
                                }
                            }
                        }
                    }
                });
            if !tile_props_open {
                self.selected_tile = None;
            }
        }

        // Handle position update from inspector
        if let Some((obj_type, obj_idx, px, py, pz, pb)) = pos_update {
            self.update_obj_pos(&obj_type, obj_idx, px, py, pz, pb);
        }
        // Handle delete button
        if delete_requested {
            self.delete_selected_object();
        }
        // Handle tile property updates
        if let Some((tile_idx, tid, torient, th, tw)) = tile_update {
            self.push_undo();
            let needs_rebuild = |area: &nwn_gamemodel::Area| -> bool {
                area.tiles.get(tile_idx).map_or(false, |t| t.id != tid)
            };
            let same_id = self.current_area.as_ref().map_or(true, |a| !needs_rebuild(a));
            if let Some(ref mut area) = self.current_area {
                let area_mut = Arc::make_mut(area);
                if tile_idx < area_mut.tiles.len() {
                    area_mut.tiles[tile_idx].id = tid;
                    area_mut.tiles[tile_idx].orientation = torient;
                    area_mut.tiles[tile_idx].height = th;
                    area_mut.tiles[tile_idx].walkable = tw;
                    // Keep tile_models in sync
                    if let Some(ref module) = self.module {
                        if let Some(ts) = module.tileset_info(&area_mut.tileset) {
                            if tile_idx < area_mut.tile_models.len() {
                                area_mut.tile_models[tile_idx] = ts.tile_model(tid as u32).map(|s| s.to_string());
                            }
                        }
                    }
                    let resref = area_mut.resref.clone();
                    if let Some(ref mut module) = self.module {
                        module.update_area_are(&resref, area_mut);
                    }
                }
            }
            self.area_version = self.area_version.wrapping_add(1);
            if same_id {
                if let Some(ref area) = self.current_area {
                    let col = tile_idx % area.width as usize;
                    let row = tile_idx / area.width as usize;
                    self.viewport.set_tile_transform(col, row, th, torient);
                }
            } else if let Some(ref area) = self.current_area {
                self.viewport.set_area(area.clone(), self.area_version, target_format);
            }
        }
        if inspector_modified {
            let obj_info = self.selected_obj_info.clone();
            let area_resref = self.current_area.as_ref().map(|a| a.resref.clone());
            if let (Some(ref obj), Some((ref obj_type, obj_idx))) = (self.selected_object.as_ref(), obj_info) {
                if let Some(ref mut module) = self.module {
                    if let Some(ref resref) = area_resref {
                        if save_bag_to_git(module, resref, obj_type, obj_idx, &obj.bag) {
                            self.status = "Property saved to GIT.".to_string();
                        }
                    }
                }
            }
            // Reload area from updated GIT (separate borrow scope)
            let resref = area_resref.clone();
            if let (Some(ref mut module), Some(ref resref)) = (self.module.as_mut(), resref) {
                let git_key = resref.trim().to_lowercase();
                if let Some(git_data) = module.raw_git.get(&git_key) {
                    if let Ok(git_gff) = nwn_gff::GffFile::from_bytes(git_data) {
                        if let Some(area) = self.current_area.as_mut() {
                            let area = Arc::make_mut(area);
                            nwn_gamemodel::reload_from_git(area, &git_gff);
                        }
                    }
                }
            }
            self.push_undo();
            self.area_version = self.area_version.wrapping_add(1);
            if let Some(ref area) = self.current_area {
                self.viewport.set_area(area.clone(), self.area_version, target_format);
            }
        }
    }
}

fn current_rss_kb_inline() -> u64 {
    0
}

impl AuroraBorealisApp {
    fn load_module_at_path(&mut self, _p: &str) {
        eprintln!("TRACE: load_module_at_path called with path='{}'", _p);
        #[cfg(not(target_arch = "wasm32"))]
        {
            let path = _p;
            eprintln!("TRACE: before Module::open, RSS={} KB", current_rss_kb_inline());
            match nwn_gamemodel::Module::open(path) {
                Ok(mut module) => {
                    let area_count = module.num_areas();
                    let module_name = module.name.clone();
                    eprintln!("TRACE: after Module::open, before load_hak_2das, RSS={} KB", current_rss_kb_inline());
                    module.load_hak_2das();
                    // Populate PLT palette globals from generated 2DAs
                    {
                        use nwn_tileset::{PltPalette, PLT_PALETTES};
                        let plt_2da_names = ["skin", "hair", "metal", "cloth", "leather", "tattoo"];
                        let mut palettes: [PltPalette; 6] = std::array::from_fn(|_| [[128, 128, 128, 255]; 256]);
                        for (i, name) in plt_2da_names.iter().enumerate() {
                            if let Some(two_da) = module.resource_manager.get_2da(name) {
                                for row in 0..two_da.row_count().min(256) {
                                    let r = two_da.get_cell(row, 0).and_then(|s| s.trim().parse::<u8>().ok()).unwrap_or(128);
                                    let g = two_da.get_cell(row, 1).and_then(|s| s.trim().parse::<u8>().ok()).unwrap_or(128);
                                    let b = two_da.get_cell(row, 2).and_then(|s| s.trim().parse::<u8>().ok()).unwrap_or(128);
                                    palettes[i][row] = [r, g, b, 255];
                                }
                            }
                        }
                        let _ = PLT_PALETTES.set(palettes);
                        eprintln!("PLT: loaded palette 2DAs for creature rendering");
                    }
                    module.preload_tilesets();
                    // Inject game dialog.tlk as lowest-priority fallback
                    if let Some(tlk_path) = nwn_game_tlk_path() {
                        if let Ok(tlk) = nwn_tlk::TlkFile::open(&tlk_path) {
                            eprintln!("TLK: injected game dialog.tlk as fallback ({} strrefs)", tlk.count());
                            module.resource_manager.tlks.push(tlk);
                        }
                    }
                    let data = std::fs::read(path).ok();
                    eprintln!("TRACE: after preload, RSS={} KB", current_rss_kb_inline());
                    self.viewport.set_module_erf(data);
                    let hak_dir = std::path::Path::new(path).parent().map(|p| p.to_path_buf());
                    if let Some(ref hd) = hak_dir {
                        self.viewport.set_hak_info(Some(hd.clone()), module.haks.clone());
                    }
                    self.module = Some(module);
                    self.current_area = None;
                    self.open_areas.clear();
                    self.active_area_idx = 0;
                    self.selected_object = None;
                    self.selected_obj_info = None;
                    self.selection_list.clear();
                    self.new_object_blueprints.clear();
                    self.status = format!("Loaded module '{}' with {} areas.", module_name, area_count);
                    eprintln!("TRACE: module loaded, RSS={} KB", current_rss_kb_inline());
                }
                Err(nwn_gamemodel::ModelError::MissingHaks(haks)) => {
                    self.status = format!("Cannot load module — missing required hak files: {}", haks.join(", "));
                }
                Err(e) => {
                    self.status = format!("Failed to load module: {}", e);
                }
            }
        }
    }

    #[allow(dead_code)]
    fn load_module_from_bytes(&mut self, data: &[u8]) {
        match nwn_gamemodel::Module::from_bytes(data) {
            Ok(mut module) => {
                let area_count = module.num_areas();
                let module_name = module.name.clone();
                module.load_hak_2das();
                module.preload_tilesets();
                self.viewport.set_module_erf(Some(data.to_vec()));

                self.module = Some(module);
                self.current_area = None;
                self.open_areas.clear();
                self.active_area_idx = 0;
                self.selected_object = None;
                self.selected_obj_info = None;
                self.undo_stack.clear();
                self.redo_stack.clear();
                self.new_object_blueprints.clear();
                self.status = format!("Loaded module '{}' with {} areas.", module_name, area_count);
            }
            Err(nwn_gamemodel::ModelError::MissingHaks(haks)) => {
                let list = haks.join(", ");
                self.status = format!("Cannot load module — missing required hak files: {}", list);
            }
            Err(e) => {
                self.status = format!("Failed to load module: {}", e);
            }
        }
    }

    fn save_module(&mut self) {
        if let Some(ref mut module) = self.module {
            if module.path.to_string_lossy().is_empty() {
                if let Some(path) = pick_save_path(&module.name) {
                    self.save_module_as(&path);
                }
                return;
            }
            let path = module.path.to_string_lossy().to_string();
            self.save_module_as(&path);
        }
    }

    fn save_module_as(&mut self, path: &str) {
        if self.pending_save.is_some() { return; }
        let mut module = match self.module.take() {
            Some(m) => m,
            None => { self.status = "No module loaded.".to_string(); return; }
        };
        let p = std::path::PathBuf::from(path);
        module.path = p.clone();
        let (tx, rx) = tokio::sync::oneshot::channel();
        background_tasks::spawn_blocking(move || {
            let result = module.save_to(&p).map_err(|e| e.to_string());
            let _ = tx.send((module, result));
        });
        self.pending_save = Some(rx);
        self.status = format!("Saving module...");
    }

    fn launch_nwn(&mut self) {
        let localvault = nwn_local_vault_dir(&std::path::PathBuf::new());
        let _ = std::fs::create_dir_all(&localvault);
        let select_bic = localvault.join("__.bic");
        let nwn_root = std::env::var("NWN").ok()
            .or_else(|| detect_nwn_install().map(|p| p.to_string_lossy().to_string()))
            .unwrap_or_default();
        let nwn_root_path = std::path::PathBuf::from(&nwn_root);
        let nwn_binary = nwn_binary_path(&nwn_root_path);
        let install_vault = nwn_root_path.join("data/lcv/aluviandarkstar.bic");
        self.create_launch_bic(&select_bic, Some(&install_vault));

        if let Some(ref mut module) = self.module {
            // Set the starting area to the currently open area
            if let Some(ref area) = self.current_area {
                module.entry_area = area.resref.clone();
            }
            // Inject test harness script (godmode, noclip visuals)
            if let Ok(ncs_data) = std::fs::read("/tmp/_ts_test.ncs") {
                module.compiled.insert("_ts_test".to_string(), ncs_data);
                module.on_player_enter = "_ts_test".to_string();
            } else {
                self.status = "Warning: test harness script not found (_ts_test.ncs)".to_string();
            }
            // Save module so IFO is up-to-date, then copy to NWN dir
            let mod_name = format!("{}.mod", module.name);
            if let Err(e) = module.save() {
                self.status = format!("Failed to save module before launch: {}", e);
                return;
            }
            let nwn_modules = nwn_user_dir().join("modules").join(&mod_name);
            if let Err(e) = std::fs::copy(&module.path, &nwn_modules) {
                self.status = format!("Failed to copy module to NWN dir: {}", e);
                return;
            }
            if nwn_binary.exists() {
                let nwn_dir = nwn_binary.parent().unwrap_or(std::path::Path::new("."));
                let mut cmd = std::process::Command::new(&nwn_binary);
                cmd.current_dir(nwn_dir)
                    .arg("+TestNewModule")
                    .arg(&module.name);
                match cmd.spawn() {
                    Ok(child) => {
                        self.nwn_process_handle = Some(child);
                        self.status = format!("Launched NWN:EE with module '{}'", module.name);
                    }
                    Err(e) => {
                        self.status = format!("Failed to launch NWN: {}", e);
                    }
                }
            } else {
                self.status = "NWN binary not found".to_string();
            }
        }
    }

    fn create_launch_bic(&mut self, path: &std::path::Path, install_vault: Option<&std::path::Path>) {
        let template = include_bytes!("test_character.bic");
        match nwn_gff::GffFile::from_bytes(template) {
            Ok(gff) => {
                if let Err(e) = gff.write_to(path) {
                    self.status = format!("Failed to write test character: {}", e);
                }
                if let Some(vault_path) = install_vault {
                    if let Some(dir) = vault_path.parent() {
                        let _ = std::fs::create_dir_all(dir);
                    }
                    // Remove all pregen BICs, then put ours
                    if let Some(vault_dir) = vault_path.parent() {
                        if let Ok(entries) = std::fs::read_dir(vault_dir) {
                            for entry in entries.flatten() {
                                let p = entry.path();
                                if p.extension().is_some_and(|e| e == "bic") {
                                    let _ = std::fs::remove_file(&p);
                                }
                            }
                        }
                    }
                    let _ = std::fs::write(vault_path, template);
                }
            }
            Err(e) => {
                self.status = format!("Failed to parse test character template: {}", e);
            }
        }
    }

    fn compile_script(&mut self, name: &str, source: &str) {
        let nwnsc_path = nwnsc_exe();
        let tmp_dir = std::env::temp_dir().join("aurora_nwnsc");
        let _ = std::fs::remove_dir_all(&tmp_dir);
        let _ = std::fs::create_dir_all(&tmp_dir);
        for (nwnx_name, data) in NWNX_SCRIPTS {
            let _ = std::fs::write(tmp_dir.join(nwnx_name), data);
        }
        // Only embed nwscript.nss when NWN is not installed, otherwise let
        // the game's version (found via -n) take priority.
        if detect_nwn_install().is_none() {
            let _ = std::fs::write(tmp_dir.join("nwscript.nss"), NWSCRIPT_NSS);
        }
        let _ = std::fs::write(tmp_dir.join("_prc_constants.nss"), PRC_CONSTANTS_NSS);
        if let Some(ref module) = self.module {
            let nn_dir = std::path::PathBuf::from(std::env::var("HOME").unwrap_or_default()).join("Documents/Neverwinter Nights");
            let sd_paths = [
                nn_dir.join("development/sd_ai_inc_spawn.nss"),
                nn_dir.join("development_ch2/sd_ai_inc_spawn.nss"),
            ];
            let sd_content = sd_paths.iter().find_map(|p| std::fs::read_to_string(p).ok())
                .or_else(|| {
                    let d = module.get_resource_data("sd_ai_inc_spawn", nwn_gamemodel::resource_types::NSS);
                    d.map(|b| String::from_utf8_lossy(&b).to_string())
                });
            if let Some(c) = sd_content {
                let _ = std::fs::write(tmp_dir.join("sd_ai_inc_spawn.nss"), format!("#include \"x2_inc_switches\"\n{}", c).as_bytes());
            }
        }
        let nss_path = tmp_dir.join(format!("{}.nss", name));
        let ncs_path = tmp_dir.join(format!("{}.ncs", name));
        // Write all NSS files so includes resolve
        if let Some(ref module) = self.module {
            for sn in module.script_names() {
                if ["nwscript", "prc_inc_spells", "nw_i0_generic", "x0_i0_spawncond", "x3_inc_horse", "x2_inc_compon", "se_respawn_inc", "staticspawn", "shardrecovery", "shardrecovery1", "bosskill", "pc_eviladjust", "nw_o2_coninclude", "sd_ai_inc_spawn"].contains(&sn) { continue; }
                if let Some(src) = module.get_script_source(sn) {
                    let filtered: Vec<u8> = if sn == "prc_inc_spells" || sn == "nw_i0_generic" {
                        let s = src.lines()
                            .filter(|line| {
                                let t = line.trim();
                                !t.starts_with("const int EFFECT_TYPE_SLEEP")
                                && !t.starts_with("const int AI_LEVEL_")
                                && !t.starts_with("const int EVENT_")
                            })
                            .collect::<Vec<_>>()
                            .join("\n");
                        s.into_bytes()
                    } else if sn == "mk_inc_body" {
                        src.replace("int MK_SetBodyPart(", "void MK_SetBodyPart(").into_bytes()
                    } else {
                        src.as_bytes().to_vec()
                    };
                    let _ = std::fs::write(tmp_dir.join(format!("{}.nss", sn)), filtered);
                }
            }
            let loose_nss_dirs: Vec<std::path::PathBuf> = {
                let parent = module.path.parent().unwrap_or(std::path::Path::new("."));
                module.area_names().iter().filter_map(|area| {
                    let d = parent.join(area).join("nss");
                    if d.is_dir() { Some(d) } else { None }
                }).collect()
            };
            // Resolve #include "..." from haks/game data
            let user_include_dir = std::path::PathBuf::from(std::env::var("HOME").unwrap_or_default()).join("Documents/Neverwinter Nights/include");
            let mut seen: std::collections::HashSet<String> = std::collections::HashSet::new();
            let mut queue: Vec<String> = module.script_names().into_iter().map(|s| s.to_string()).collect();
            queue.push(name.to_string());
            while let Some(iname) = queue.pop() {
                if seen.contains(&iname) { continue; }
                if ["nwscript", "nwnx_sql"].contains(&iname.as_str()) { seen.insert(iname); continue; }
                let prefer_user_include = ["x0_i0_spawncond", "x3_inc_horse", "x2_inc_compon", "prc_inc_spells", "nw_i0_generic", "se_respawn_inc", "staticspawn", "shardrecovery", "shardrecovery1", "bosskill", "pc_eviladjust", "prc_inc_leadersh", "nw_o2_coninclude"];
                let src = if prefer_user_include.contains(&iname.as_str()) && std::fs::read(user_include_dir.join(format!("{}.nss", iname))).is_ok() {
                    let data = if iname == "prc_inc_spells" {
                        let mut content = std::fs::read_to_string(user_include_dir.join("prc_inc_spells.nss")).unwrap();
                        content = content.lines()
                            .filter(|line| {
                                let t = line.trim();
                                !t.starts_with("const int EFFECT_TYPE_SLEEP")
                                && !t.starts_with("const int AI_LEVEL_")
                                && !t.starts_with("const int EVENT_")
                                && !t.starts_with("#include \"inc_item_props\"")
                            })
                            .collect::<Vec<_>>()
                            .join("\n");
                        content.into_bytes()
                    } else if iname == "nw_i0_generic" {
                        let mut content = std::fs::read_to_string(user_include_dir.join("nw_i0_generic.nss")).unwrap();
                        content = format!("#include \"x0_i0_equip\"\n{}", content);
                        content = content.lines()
                            .filter(|line| {
                                let t = line.trim();
                                !t.starts_with("const int EFFECT_TYPE_SLEEP")
                                && !t.starts_with("const int AI_LEVEL_")
                                && !t.starts_with("const int EVENT_")
                            })
                            .collect::<Vec<_>>()
                            .join("\n");
                        content.into_bytes()
                    } else if iname == "se_respawn_inc" {
                        let mut content = std::fs::read_to_string(user_include_dir.join("se_respawn_inc.nss")).unwrap();
                        content = content.lines()
                            .filter(|line| !line.trim().contains("#include \"se_respawn_inc\""))
                            .collect::<Vec<_>>()
                            .join("\n");
                        content = format!("#include \"_prc_constants\"\n{}", content);
                        content.into_bytes()
                    } else if iname == "prc_inc_leadersh" {
                        let mut content = std::fs::read_to_string(user_include_dir.join("prc_inc_leadersh.nss")).unwrap();
                        content = content.replace("GenerateBossTreasure(oCohort);", "GenerateBossTreasure(oCohort, OBJECT_SELF);");
                        content.into_bytes()
                    } else {
                        std::fs::read(user_include_dir.join(format!("{}.nss", iname))).unwrap()
                    };
                    let _ = std::fs::write(tmp_dir.join(format!("{}.nss", iname)), &data);
                    String::from_utf8_lossy(&data).to_string()
                } else if let Some(s) = module.get_script_source(&iname) {
                    s.to_string()
                } else if iname != "nwscript" && iname != "nwnx_sql" && module.get_resource_data(&iname, nwn_gamemodel::resource_types::NSS).is_some() {
                    let data = module.get_resource_data(&iname, nwn_gamemodel::resource_types::NSS).unwrap();
                    let _ = std::fs::write(tmp_dir.join(format!("{}.nss", iname)), &data);
                    String::from_utf8_lossy(&data).to_string()
                } else if iname != "nwscript" && iname != "nwnx_sql" && std::fs::read(user_include_dir.join(format!("{}.nss", iname))).is_ok() {
                    let data = std::fs::read(user_include_dir.join(format!("{}.nss", iname))).unwrap();
                    let _ = std::fs::write(tmp_dir.join(format!("{}.nss", iname)), &data);
                    String::from_utf8_lossy(&data).to_string()
                } else if let Some(data) = loose_nss_dirs.iter().find_map(|d| std::fs::read(d.join(format!("{}.nss", iname))).ok()) {
                    let _ = std::fs::write(tmp_dir.join(format!("{}.nss", iname)), &data);
                    String::from_utf8_lossy(&data).to_string()
                } else {
                    continue;
                };
                seen.insert(iname);
                for line in src.lines() {
                    let trimmed = line.trim();
                    if trimmed.starts_with("#include") {
                        if let Some(start) = trimmed.find('"') {
                            if let Some(end) = trimmed[start+1..].find('"') {
                                let inc = trimmed[start+1..start+1+end].trim().to_lowercase();
                                if !seen.contains(&inc)
                                    && std::fs::read(tmp_dir.join(format!("{}.nss", inc))).is_err()
                                {
                                    queue.push(inc);
                                }
                            }
                        }
                    }
                }
            }
        }
        let source_with_const = format!("#include \"_prc_constants\"\n{}", source);
        if std::fs::write(&nss_path, &source_with_const).is_err() {
            self.status = format!("Failed to write temp NSS for '{}'", name);
            return;
        }
        let mut include_paths = tmp_dir.to_string_lossy().to_string();
        if let Some(ref module) = self.module {
            let parent = module.path.parent();
            for area in module.area_names() {
                if let Some(p) = parent {
                    let nss_dir = p.join(area).join("nss");
                    if nss_dir.is_dir() {
                        include_paths.push(';');
                        include_paths.push_str(&nss_dir.to_string_lossy());
                    }
                }
            }
        }
        let output = std::process::Command::new(&nwnsc_path)
            .arg("-l")
            .arg("-e")
            .arg("-i").arg(&include_paths)
            .arg("-n").arg(detect_nwn_install().map(|p| p.to_string_lossy().to_string()).unwrap_or_default())
            .arg("-q")
            .arg("-w")
            .arg("-r").arg(&ncs_path)
            .arg(&nss_path)
            .output();
        match output {
            Ok(out) => {
                if !out.status.success() {
                    let stderr = String::from_utf8_lossy(&out.stderr);
                    let stdout = String::from_utf8_lossy(&out.stdout);
                    self.status = format!("Compile failed for '{}': {}{}", name, stdout, stderr);
                    return;
                }
                match std::fs::read(&ncs_path) {
                    Ok(ncs_data) => {
                        if let Some(ref mut module) = self.module {
                            module.update_ncs(name, &ncs_data);
                            module.modified = true;
                            self.status = format!("Compiled '{}' successfully ({})", name, ncs_data.len());
                        }
                    }
                    Err(e) => {
                        self.status = format!("Failed to read NCS output for '{}': {}", name, e);
                    }
                }
            }
            Err(e) => {
                self.status = format!("Failed to run nwnsc for '{}': {}", name, e);
            }
        }
    }

    fn check_pending_tasks(&mut self) {
        if let Some(rx) = &mut self.pending_compile_all {
            match rx.try_recv() {
                Ok(result) => {
                    self.pending_compile_all = None;
                    self.compile_progress = None;
                    let mut compiled = 0;
                    for (name, ncs_data) in &result.results {
                        if let Some(ref mut module) = self.module {
                            module.update_ncs(name, ncs_data);
                            module.modified = true;
                            compiled += 1;
                        }
                    }
                    let error_count = result.errors.len();
                    if error_count > 0 {
                        for (name, msg) in &result.errors {
                            let first_line = msg.lines().next().unwrap_or(msg);
                            eprintln!("[compile_err] {}: {}", name, first_line);
                        }
                        self.status = format!("Compiled {} scripts ({} errors). See terminal for details.", compiled, error_count);
                    } else {
                        self.status = format!("Compiled {} scripts successfully.", compiled);
                    }
                }
                Err(tokio::sync::oneshot::error::TryRecvError::Closed) => {
                    self.pending_compile_all = None;
                    self.compile_progress = None;
                    self.status = "Compile task failed.".to_string();
                }
                Err(tokio::sync::oneshot::error::TryRecvError::Empty) => {}
            }
        }
        if let Some(rx) = &mut self.pending_save {
            match rx.try_recv() {
                Ok((module, Ok(()))) => {
                    self.pending_save = None;
                    self.module = Some(module);
                    self.status = format!("Module saved.");
                }
                Ok((module, Err(msg))) => {
                    self.pending_save = None;
                    self.module = Some(module);
                    self.status = format!("Save failed: {}", msg);
                }
                Err(tokio::sync::oneshot::error::TryRecvError::Closed) => {
                    self.pending_save = None;
                    self.status = "Save task failed.".to_string();
                }
                Err(tokio::sync::oneshot::error::TryRecvError::Empty) => {}
            }
        }
    }

    fn update_obj_pos(&mut self, obj_type: &str, obj_idx: usize, x: f32, y: f32, z: f32, bearing: f32) {
        self.push_undo();
        let (x, y) = snap_to_grid_pos(x, y, self.snap_to_grid_enabled, self.snap_to_grid_value);
        if let Some(area) = self.current_area.as_mut() {
            let area = Arc::make_mut(area);
            match obj_type {
                "creature" => {
                    if let Some(c) = area.creatures.get_mut(obj_idx) {
                        c.x = x; c.y = y; c.z = z; c.bearing = bearing;
                    }
                }
                "door" => {
                    if let Some(d) = area.doors.get_mut(obj_idx) {
                        d.x = x; d.y = y; d.z = z; d.bearing = bearing;
                    }
                }
                "placeable" => {
                    if let Some(p) = area.placeables.get_mut(obj_idx) {
                        p.x = x; p.y = y; p.z = z; p.bearing = bearing;
                    }
                }
                "trigger" => {
                    if let Some(t) = area.triggers.get_mut(obj_idx) {
                        t.x = x; t.y = y; t.z = z; t.bearing = bearing;
                    }
                }
                "waypoint" => {
                    if let Some(w) = area.waypoints.get_mut(obj_idx) {
                        w.x = x; w.y = y; w.z = z; w.bearing = bearing;
                    }
                }
                "encounter" => {
                    if let Some(e) = area.encounters.get_mut(obj_idx) {
                        e.x = x; e.y = y; e.z = z; e.bearing = bearing;
                    }
                }
                "sound_emitter" => {
                    if let Some(s) = area.sound_emitters.get_mut(obj_idx) {
                        s.x = x; s.y = y; s.z = z; s.bearing = bearing;
                    }
                }
                _ => {}
            }
            let resref = area.resref.clone();
            if let Some(ref mut module) = self.module {
                module.update_area_git(&resref, area);
            }
            self.area_version = self.area_version.wrapping_add(1);
            self.selected_object = None;
            self.selected_obj_info = None;
            self.status = format!("Updated {} position", obj_type);
        }
    }

    fn push_undo(&mut self) {
        if let Some(ref area) = self.current_area {
            self.undo_stack.push(Arc::new(area.as_ref().clone()));
            if self.undo_stack.len() > 20 {
                self.undo_stack.remove(0);
            }
            self.redo_stack.clear();
        }
    }

    fn tile_flood_fill(&mut self, col: usize, row: usize, new_id: i32) {
        let (w, h, old_id) = match self.current_area.as_ref() {
            Some(a) => {
                let w = a.width as usize;
                let h = a.height as usize;
                if col >= w || row >= h { return; }
                let idx = row * w + col;
                let old_id = a.tiles[idx].id;
                if old_id == new_id { return; }
                (w, h, old_id)
            }
            None => return,
        };
        self.push_undo();
        let area = Arc::make_mut(self.current_area.as_mut().unwrap());
        let mut changed_indices = Vec::new();
        let mut visited = vec![false; area.tiles.len()];
        let mut stack = vec![(col, row)];
        while let Some((cx, cy)) = stack.pop() {
            if cx >= w || cy >= h { continue; }
            let ci = cy * w + cx;
            if visited[ci] { continue; }
            visited[ci] = true;
            if area.tiles[ci].id != old_id { continue; }
            area.tiles[ci].id = new_id;
            changed_indices.push(ci);
            if cx > 0 { stack.push((cx - 1, cy)); }
            if cx + 1 < w { stack.push((cx + 1, cy)); }
            if cy > 0 { stack.push((cx, cy - 1)); }
            if cy + 1 < h { stack.push((cx, cy + 1)); }
        }
        // Update tile_models for changed tiles
        if let Some(ref module) = self.module {
            if let Some(ts) = module.tileset_info(&area.tileset) {
                for &ci in &changed_indices {
                    if ci < area.tile_models.len() {
                        area.tile_models[ci] = ts.tile_model(new_id as u32).map(|s| s.to_string());
                    }
                }
            }
        }
        let resref = area.resref.clone();
        if let Some(ref mut module) = self.module {
            module.update_area_are(&resref, area);
        }
        self.area_version = self.area_version.wrapping_add(1);
        self.status = format!("Flood filled tile {} at ({},{})", new_id, col, row);
    }

    fn auto_orient_tiles(&mut self) {
        if self.current_area.is_none() { return; }
        self.push_undo();
        let area = Arc::make_mut(self.current_area.as_mut().unwrap());
        let w = area.width as usize;
        let h = area.height as usize;
        let heights: Vec<i32> = area.tiles.iter().map(|t| t.height).collect();
        use rayon::prelude::*;
        area.tiles.par_iter_mut().enumerate().for_each(|(idx, tile)| {
            let y = idx / w;
            let x = idx % w;
            let h_self = heights[idx];
            let mut downhill: Option<u8> = None;
            let mut max_drop: i32 = 0;
            let dirs: [(i32, i32, u8); 4] = [
                (0, -1, 0), (1, 0, 1), (0, 1, 2), (-1, 0, 3),
            ];
            for (dx, dy, dir) in dirs {
                let nx = x as i32 + dx;
                let ny = y as i32 + dy;
                if nx >= 0 && nx < w as i32 && ny >= 0 && ny < h as i32 {
                    let ni = ny as usize * w + nx as usize;
                    let nh = heights[ni];
                    let drop = h_self - nh;
                    if drop > max_drop {
                        max_drop = drop;
                        downhill = Some(dir);
                    }
                }
            }
            if let Some(dir) = downhill {
                tile.orientation = dir as i32;
            }
        });
        let resref = area.resref.clone();
        if let Some(ref mut module) = self.module {
            module.update_area_are(&resref, area);
        }
        self.area_version = self.area_version.wrapping_add(1);
        self.status = "Auto-oriented tiles".to_string();
    }

    fn fill_area_tiles(&mut self, tile_id: i32) {
        if self.current_area.is_none() { return; }
        self.push_undo();
        let area = Arc::make_mut(self.current_area.as_mut().unwrap());
        for tile in area.tiles.iter_mut() {
            tile.id = tile_id;
        }
        // Keep tile_models in sync
        let model_name = if let Some(ref module) = self.module {
            module.tileset_info(&area.tileset).and_then(|ts| ts.tile_model(tile_id as u32).map(|s| s.to_string()))
        } else { None };
        if let Some(ref name) = model_name {
            area.tile_models.iter_mut().for_each(|m| *m = Some(name.clone()));
        }
        let resref = area.resref.clone();
        if let Some(ref mut module) = self.module {
            module.update_area_are(&resref, area);
        }
        self.area_version = self.area_version.wrapping_add(1);
        self.status = format!("Filled area with tile {}", tile_id);
    }

    fn update_visibility_filter(&mut self, target_format: wgpu::TextureFormat) {
        let filter = VisibilityFilter {
            show_tiles: true,
            show_creatures: self.show_creatures,
            show_doors: self.show_doors,
            show_placeables: self.show_placeables,
            show_triggers: self.show_triggers,
            show_waypoints: self.show_waypoints,
            show_encounters: self.show_encounters,
            show_sound_emitters: self.show_sound_emitters,
            show_lights: self.show_lights,
        };
        self.viewport.set_visibility_filter(filter);
        if let Some(ref area) = self.current_area {
            self.area_version = self.area_version.wrapping_add(1);
            self.viewport.set_area(area.clone(), self.area_version, target_format);
        }
    }

    fn switch_to_area(&mut self, name: &str, target_format: wgpu::TextureFormat) {
        if self.current_area.as_ref().map_or(false, |a| a.resref == name) {
            return;
        }
        if let Some(area) = self.module.as_ref().and_then(|m| m.get_area(name)) {
            if let Some(idx) = self.open_areas.iter().position(|r| r == name) {
                self.active_area_idx = idx;
            } else {
                self.open_areas.push(name.to_string());
                self.active_area_idx = self.open_areas.len() - 1;
            }
            self.area_version = self.area_version.wrapping_add(1);
            self.viewport.set_area(area.clone(), self.area_version, target_format);
            self.current_area = Some(area);
            self.selected_object = None;
            self.selected_obj_info = None;
            self.selection_list.clear();
            self.selected_tile = None;
            self.status = format!("Loaded area '{}'.", name);
        }
    }

    fn paste_object(&mut self, target_format: wgpu::TextureFormat) {
        self.push_undo();
        let (cam_x, cam_y, cam_z) = self.viewport.camera_state()
            .map(|cam| (cam.target[0], -cam.target[2], cam.target[1]))
            .unwrap_or((0.0, 0.0, 0.0));
        let snap_enabled = self.snap_to_grid_enabled;
        let snap_value = self.snap_to_grid_value;
        if let Some(ref clip) = self.clipboard.clone() {
            if let Some(area) = self.current_area.as_mut() {
                let area = Arc::make_mut(area);
                let tag = format!("{}_{}", clip.obj_type, clip.resref);
                match clip.obj_type.as_str() {
                    "creature" => {
                        let mut inst = nwn_gamemodel::CreatureInstance::from_property_bag(&clip.bag);
                        inst.tag = tag;
                        let (sx, sy) = snap_to_grid_pos(cam_x, cam_y, snap_enabled, snap_value);
                        inst.x = sx; inst.y = sy; inst.z = cam_z;
                        if inst.model_name.is_none() {
                            if let Some(ref module) = self.module {
                                inst.model_name = module.resolve_creature_model(inst.appearance, &inst.resref);
                            }
                        }
                        area.creatures.push(inst);
                    }
                    "door" => {
                        let mut inst = nwn_gamemodel::DoorInstance::from_property_bag(&clip.bag);
                        inst.tag = tag;
                        let (sx, sy) = snap_to_grid_pos(cam_x, cam_y, snap_enabled, snap_value);
                        inst.x = sx; inst.y = sy; inst.z = cam_z;
                        if inst.model_name.is_none() {
                            if let Some(ref module) = self.module {
                                inst.model_name = module.resolve_door_model(inst.appearance, &inst.resref);
                            }
                        }
                        area.doors.push(inst);
                    }
                    "placeable" => {
                        let mut inst = nwn_gamemodel::PlaceableInstance::from_property_bag(&clip.bag);
                        inst.tag = tag;
                        let (sx, sy) = snap_to_grid_pos(cam_x, cam_y, snap_enabled, snap_value);
                        inst.x = sx; inst.y = sy; inst.z = cam_z;
                        if inst.model_name.is_none() {
                            if let Some(ref module) = self.module {
                                inst.model_name = module.resolve_placeable_model(inst.appearance, &inst.resref);
                            }
                        }
                        area.placeables.push(inst);
                    }
                    "trigger" => {
                        let mut inst = nwn_gamemodel::TriggerInstance::from_property_bag(&clip.bag);
                        inst.tag = tag;
                        let (sx, sy) = snap_to_grid_pos(cam_x, cam_y, snap_enabled, snap_value);
                        inst.x = sx; inst.y = sy; inst.z = cam_z;
                        area.triggers.push(inst);
                    }
                    "waypoint" => {
                        let mut inst = nwn_gamemodel::WayPointInstance::from_property_bag(&clip.bag);
                        inst.tag = tag;
                        let (sx, sy) = snap_to_grid_pos(cam_x, cam_y, snap_enabled, snap_value);
                        inst.x = sx; inst.y = sy; inst.z = cam_z;
                        area.waypoints.push(inst);
                    }
                    "encounter" => {
                        let mut inst = nwn_gamemodel::EncounterInstance::from_property_bag(&clip.bag);
                        inst.tag = tag;
                        let (sx, sy) = snap_to_grid_pos(cam_x, cam_y, snap_enabled, snap_value);
                        inst.x = sx; inst.y = sy; inst.z = cam_z;
                        area.encounters.push(inst);
                    }
                    "sound_emitter" => {
                        let mut inst = nwn_gamemodel::SoundEmitterInstance::from_property_bag(&clip.bag);
                        inst.tag = tag;
                        let (sx, sy) = snap_to_grid_pos(cam_x, cam_y, snap_enabled, snap_value);
                        inst.x = sx; inst.y = sy; inst.z = cam_z;
                        area.sound_emitters.push(inst);
                    }
                    _ => {
                        self.status = format!("Cannot paste {} objects yet", clip.obj_type);
                        return;
                    }
                }
                let resref = area.resref.clone();
                if let Some(ref mut module) = self.module {
                    module.update_area_git(&resref, area);
                }
                self.area_version = self.area_version.wrapping_add(1);
                self.selected_object = None;
                self.selected_obj_info = None;
                self.selection_list.clear();
                self.status = format!("Pasted {} '{}'", clip.obj_type, clip.resref);
            }
            if let Some(ref area) = self.current_area {
                self.viewport.set_area(area.clone(), self.area_version, target_format);
            }
        } else {
            self.status = "Nothing to paste. Copy an object first.".to_string();
        }
    }

    fn delete_selected_object(&mut self) {
        self.push_undo();
        let targets: Vec<(String, usize)> = if self.selection_list.is_empty() {
            self.selected_obj_info.clone().into_iter().collect()
        } else {
            self.selection_list.clone()
        };
        if targets.is_empty() { return; }
        if let Some(area) = self.current_area.as_mut() {
            let area = Arc::make_mut(area);
            let mut to_delete: Vec<(String, usize)> = targets.clone();
            to_delete.sort_by(|a, b| b.1.cmp(&a.1));
            for (ref obj_type, obj_idx) in to_delete {
                match obj_type.as_str() {
                    "creature" => { if obj_idx < area.creatures.len() { area.creatures.remove(obj_idx); } }
                    "door" => { if obj_idx < area.doors.len() { area.doors.remove(obj_idx); } }
                    "placeable" => { if obj_idx < area.placeables.len() { area.placeables.remove(obj_idx); } }
                    "trigger" => { if obj_idx < area.triggers.len() { area.triggers.remove(obj_idx); } }
                    "waypoint" => { if obj_idx < area.waypoints.len() { area.waypoints.remove(obj_idx); } }
                    "encounter" => { if obj_idx < area.encounters.len() { area.encounters.remove(obj_idx); } }
                    "sound_emitter" => { if obj_idx < area.sound_emitters.len() { area.sound_emitters.remove(obj_idx); } }
                    _ => {}
                }
            }
            let resref = area.resref.clone();
            if let Some(ref mut module) = self.module {
                module.update_area_git(&resref, area);
            }
            self.area_version = self.area_version.wrapping_add(1);
        }
        self.selected_object = None;
        self.selected_obj_info = None;
        self.selection_list.clear();
        self.status = format!("Deleted {} object(s)", targets.len());
    }

    fn close_area_tab(&mut self, idx: usize) {
        if idx >= self.open_areas.len() { return; }
        let was_active = idx == self.active_area_idx;
        self.open_areas.remove(idx);
        if self.open_areas.is_empty() {
            self.current_area = None;
            self.active_area_idx = 0;
        } else if was_active {
            let next = if idx > 0 { idx - 1 } else { 0 };
            if next < self.open_areas.len() {
                let name = self.open_areas[next].clone();
                self.switch_to_area(&name, wgpu::TextureFormat::Bgra8UnormSrgb);
            }
        }
    }

    fn undo(&mut self, target_format: wgpu::TextureFormat) {
        if let Some(area) = self.undo_stack.pop() {
            if let Some(ref current) = self.current_area {
                self.redo_stack.push(Arc::new(current.as_ref().clone()));
            }
            self.current_area = Some(area.clone());
            self.viewport.set_area(area.clone(), self.area_version.wrapping_add(1), target_format);
            self.area_version = self.area_version.wrapping_add(1);
        }
    }

    fn redo(&mut self, target_format: wgpu::TextureFormat) {
        if let Some(area) = self.redo_stack.pop() {
            if let Some(ref current) = self.current_area {
                self.undo_stack.push(Arc::new(current.as_ref().clone()));
            }
            self.current_area = Some(area.clone());
            self.viewport.set_area(area.clone(), self.area_version.wrapping_add(1), target_format);
            self.area_version = self.area_version.wrapping_add(1);
        }
    }

    fn sync_area_sounds(&self) {
        self.audio_system.stop_all();
        if !self.sound_enabled { return; }
        let Some(ref module) = self.module else { return };
        let Some(ref area) = self.current_area else { return };
        for emitter in &area.sound_emitters {
            for sound_resref in &emitter.sounds {
                let sound_id = format!("{}:{}", emitter.tag, sound_resref);
                if let Some(data) = module.get_resource_data(sound_resref, resource_types::WAV) {
                    self.audio_system.play_wav(&sound_id, &data, true);
                } else if let Some(data) = module.get_resource_data(sound_resref, resource_types::BMU) {
                    self.audio_system.play_wav(&sound_id, &data, true);
                }
            }
        }
    }

    fn copy_selected_object(&mut self) {
        if let Some((ref obj_type, obj_idx)) = self.selected_obj_info.clone() {
            if let Some(ref area) = self.current_area {
                let copy_data = match obj_type.as_str() {
                    "creature" => area.creatures.get(obj_idx).map(|c| (c.resref.clone(), c.tag.clone(), c.bearing, c.to_property_bag())),
                    "door" => area.doors.get(obj_idx).map(|d| (d.resref.clone(), d.tag.clone(), d.bearing, d.to_property_bag())),
                    "placeable" => area.placeables.get(obj_idx).map(|p| (p.resref.clone(), p.tag.clone(), p.bearing, p.to_property_bag())),
                    "trigger" => area.triggers.get(obj_idx).map(|t| (t.resref.clone(), t.tag.clone(), t.bearing, t.to_property_bag())),
                    "waypoint" => area.waypoints.get(obj_idx).map(|w| (w.resref.clone(), w.tag.clone(), w.bearing, w.to_property_bag())),
                    "encounter" => area.encounters.get(obj_idx).map(|e| (e.name.clone(), e.tag.clone(), e.bearing, Default::default())),
                    "sound_emitter" => area.sound_emitters.get(obj_idx).map(|s| (String::new(), s.tag.clone(), 0.0, Default::default())),
                    _ => None,
                };
                if let Some((resref, tag, bearing, bag)) = copy_data {
                    self.status = format!("Copied {} '{}'", obj_type, resref);
                    self.clipboard = Some(ObjectClipboard {
                        obj_type: obj_type.clone(),
                        resref,
                        tag,
                        bearing,
                        bag,
                    });
                } else {
                    self.status = format!("Cannot copy {} objects yet", obj_type);
                }
            }
        }
    }
}
fn toggle_walkmesh_wall(area: &mut nwn_gamemodel::Area, wall: (usize, u8), status: &mut String) {
    if let Some(pos) = area.walkmesh_walls.iter().position(|&w| w == wall) {
        area.walkmesh_walls.remove(pos);
        *status = "Wall removed.".to_string();
    } else {
        area.walkmesh_walls.push(wall);
        *status = "Wall added.".to_string();
    }
}

fn generate_walkmesh_walls(area: &mut nwn_gamemodel::Area, threshold: i32) -> usize {
    let w = area.width;
    let h = area.height;
    let mut new_walls: Vec<(usize, u8)> = Vec::new();

    for row in 0..h {
        for col in 0..w {
            let idx = (row * w + col) as usize;
            let ht = area.tiles[idx].height;

            // Right edge: perimeter or height diff with neighbor
            if col + 1 < w {
                let ri = idx + 1;
                if (area.tiles[ri].height - ht).abs() >= threshold {
                    new_walls.push((idx, 0));
                }
            }
            // Bottom edge: perimeter or height diff with neighbor
            if row + 1 < h {
                let bi = ((row + 1) * w + col) as usize;
                if (area.tiles[bi].height - ht).abs() >= threshold {
                    new_walls.push((idx, 1));
                }
            }
        }
    }

    let count = new_walls.len();
    area.walkmesh_walls = new_walls;
    count
}

fn recent_files_path() -> std::path::PathBuf {
    let home = std::env::var("HOME").unwrap_or_else(|_| ".".to_string());
    std::path::PathBuf::from(home).join(".nwn_toolset_recent.json")
}

fn load_recent_files() -> Vec<String> {
    let path = recent_files_path();
    if let Ok(data) = std::fs::read_to_string(&path) {
        serde_json::from_str(&data).unwrap_or_default()
    } else {
        Vec::new()
    }
}

fn save_recent_files(files: &[String]) {
    if let Ok(data) = serde_json::to_string(files) {
        let _ = std::fs::write(recent_files_path(), &data);
    }
}

fn add_recent_file(files: &mut Vec<String>, path: &str) {
    files.retain(|f| f != path);
    files.insert(0, path.to_string());
    if files.len() > 10 {
        files.truncate(10);
    }
    save_recent_files(files);
}

fn height_to_color(height: i32) -> (u8, u8, u8) {
    let h = height.clamp(0, 255) as f32 / 255.0;
    // Blue (0,0,128) -> Cyan (0,128,255) -> Green (0,255,0) -> Yellow (255,255,0) -> Red (255,0,0)
    let (r, g, b) = if h < 0.25 {
        let t = h / 0.25;
        (0, (128.0 + t * 127.0) as u8, (128.0 + t * 127.0) as u8)
    } else if h < 0.5 {
        let t = (h - 0.25) / 0.25;
        (0, 255, (255.0 * (1.0 - t)) as u8)
    } else if h < 0.75 {
        let t = (h - 0.5) / 0.25;
        ((255.0 * t) as u8, 255, 0)
    } else {
        let t = (h - 0.75) / 0.25;
        (255, (255.0 * (1.0 - t)) as u8, 0)
    };
    (r, g, b)
}

fn export_minimap_png(area: &nwn_gamemodel::Area, path: &str) -> Result<(), String> {
    let w = area.width.max(1) as usize;
    let h = area.height.max(1) as usize;
    let scale = if w.max(h) > 100 { 1 } else if w.max(h) > 50 { 2 } else { 4 };
    let pw = w * scale;
    let ph = h * scale;
    let mut pixels = vec![0u8; pw * ph * 4];
    for row in 0..h {
        for col in 0..w {
            let ti = row * w + col;
            let tile = area.tiles.get(ti);
            let tint = area.tile_tints.iter().find(|&&(t, _)| t == ti).map(|&(_, c)| c);
            let color = if let Some(c) = tint {
                [c[0], c[1], c[2], 255]
            } else if let Some(t) = tile {
                let id = t.id as u32;
                let r = ((id * 137 + 53) % 200 + 55) as u8;
                let g = ((id * 251 + 97) % 200 + 55) as u8;
                let b = ((id * 199 + 173) % 200 + 55) as u8;
                [r, g, b, 255]
            } else {
                [40, 40, 40, 255]
            };
            for dy in 0..scale {
                for dx in 0..scale {
                    let pi = ((row * scale + dy) * pw + (col * scale + dx)) * 4;
                    pixels[pi..pi + 4].copy_from_slice(&color);
                }
            }
        }
    }
    for obj in &area.creatures {
        let cx = (obj.x / 10.0) as isize * scale as isize + scale as isize / 2;
        let cy = (obj.y / 10.0) as isize * scale as isize + scale as isize / 2;
        if cx >= 0 && cx < pw as isize && cy >= 0 && cy < ph as isize {
            let pi = (cy as usize * pw + cx as usize) * 4;
            pixels[pi..pi + 4].copy_from_slice(&[255, 60, 60, 255]);
        }
    }
    for obj in &area.doors {
        let cx = (obj.x / 10.0) as isize * scale as isize + scale as isize / 2;
        let cy = (obj.y / 10.0) as isize * scale as isize + scale as isize / 2;
        if cx >= 0 && cx < pw as isize && cy >= 0 && cy < ph as isize {
            let pi = (cy as usize * pw + cx as usize) * 4;
            pixels[pi..pi + 4].copy_from_slice(&[255, 200, 50, 255]);
        }
    }
    for obj in &area.placeables {
        let cx = (obj.x / 10.0) as isize * scale as isize + scale as isize / 2;
        let cy = (obj.y / 10.0) as isize * scale as isize + scale as isize / 2;
        if cx >= 0 && cx < pw as isize && cy >= 0 && cy < ph as isize {
            let pi = (cy as usize * pw + cx as usize) * 4;
            pixels[pi..pi + 4].copy_from_slice(&[80, 120, 255, 255]);
        }
    }
    let img = image::RgbaImage::from_raw(pw as u32, ph as u32, pixels)
        .ok_or("failed to create image")?;
    img.save(path).map_err(|e| format!("save error: {}", e))
}

#[allow(dead_code)]
fn move_object_to(area: &mut nwn_gamemodel::Area, obj_type: &str, index: usize, nx: f32, ny: f32) -> bool {
    match obj_type {
        "creature" => {
            if let Some(c) = area.creatures.get_mut(index) { c.x = nx; c.y = ny; true }
            else { false }
        }
        "door" => {
            if let Some(d) = area.doors.get_mut(index) { d.x = nx; d.y = ny; true }
            else { false }
        }
        "placeable" => {
            if let Some(p) = area.placeables.get_mut(index) { p.x = nx; p.y = ny; true }
            else { false }
        }
        "trigger" => {
            if let Some(t) = area.triggers.get_mut(index) { t.x = nx; t.y = ny; true }
            else { false }
        }
        "waypoint" => {
            if let Some(w) = area.waypoints.get_mut(index) { w.x = nx; w.y = ny; true }
            else { false }
        }
        "encounter" => {
            if let Some(e) = area.encounters.get_mut(index) { e.x = nx; e.y = ny; true }
            else { false }
        }
        "sound_emitter" => { if let Some(s) = area.sound_emitters.get_mut(index) { s.x = nx; s.y = ny; true } else { false } }
        _ => false,
    }
}

#[allow(dead_code)]
fn snap_to_grid(val: f32, grid_size: f32) -> f32 {
    if grid_size <= 0.0 { val }
    else { (val / grid_size).round() * grid_size }
}

fn snap_to_grid_pos(x: f32, y: f32, enabled: bool, grid_size: f32) -> (f32, f32) {
    if enabled && grid_size > 0.0 {
        (snap_to_grid(x, grid_size), snap_to_grid(y, grid_size))
    } else {
        (x, y)
    }
}

fn git_struct_id(obj_type: &str) -> u32 {
    match obj_type {
        "creature" => 4,
        "door" => 5,
        "placeable" => 6,
        "trigger" => 7,
        "waypoint" => 8,
        "encounter" => 9,
        "sound_emitter" => 10,
        "light" => 11,
        _ => 0,
    }
}

fn git_list_name(obj_type: &str) -> &'static str {
    match obj_type {
        "creature" => "Creature_List",
        "door" => "Door_List",
        "placeable" => "Placeable_List",
        "trigger" => "Trigger_List",
        "waypoint" => "WaypointList",
        "encounter" => "Encounter_List",
        "sound_emitter" => "SoundList",
        "light" => "LightList",
        _ => "",
    }
}

fn select_single_object(
    area: &nwn_gamemodel::Area,
    module: Option<&nwn_gamemodel::Module>,
    selected_object: &mut Option<SelectedObject>,
    selected_obj_info: &mut Option<(String, usize)>,
    selected_tile: &mut Option<(usize, usize)>,
    obj_type: &str,
    idx: usize,
) {
    *selected_tile = None;
    let bag = match obj_type {
        "creature" => area.creatures.get(idx).map(|c| (format!("Creature: {}", c.resref), c.to_property_bag())),
        "door" => area.doors.get(idx).map(|d| (format!("Door: {}", d.resref), d.to_property_bag())),
        "placeable" => area.placeables.get(idx).map(|p| (format!("Placeable: {}", p.resref), p.to_property_bag())),
        "trigger" => area.triggers.get(idx).map(|t| (format!("Trigger: {}", t.tag), t.to_property_bag())),
        "waypoint" => area.waypoints.get(idx).map(|w| (format!("Waypoint: {}", w.tag), w.to_property_bag())),
        "encounter" => area.encounters.get(idx).map(|e| (format!("Encounter: {}", e.name), e.to_property_bag())),
        "sound_emitter" => area.sound_emitters.get(idx).map(|s| (format!("Sound: {}", s.tag), s.to_property_bag())),
        "light" => area.lights.get(idx).map(|l| (format!("Light: {}", l.tag), LightInstance::to_property_bag(l))),
        _ => None,
    };
    if let Some((title, bag)) = bag {
        let full_bag = module.and_then(|module| {
            let area_key = area.resref.trim().to_lowercase();
            let git_bytes = module.raw_git.get(&area_key)?;
            let gff = nwn_gff::GffFile::from_bytes(git_bytes).ok()?;
            let list_name = git_list_name(obj_type);
            let s = gff.root().find(list_name)?.unwrap_list().get(idx)?;
            Some(PropertyBag::from_gff_struct(s))
        });
        *selected_object = Some(SelectedObject { title, bag: full_bag.unwrap_or(bag) });
        *selected_obj_info = Some((obj_type.to_string(), idx));
    }
}

/// Returns the world position (renderer space) of a selected object, or None.
fn get_object_position(area: &nwn_gamemodel::Area, info: &(String, usize)) -> Option<[f32; 3]> {
    let pos = match info.0.as_str() {
        "creature" => area.creatures.get(info.1).map(|c| (c.x, c.y, c.z)),
        "door" => area.doors.get(info.1).map(|d| (d.x, d.y, d.z)),
        "placeable" => area.placeables.get(info.1).map(|p| (p.x, p.y, p.z)),
        "trigger" => area.triggers.get(info.1).map(|t| (t.x, t.y, t.z)),
        "waypoint" => area.waypoints.get(info.1).map(|w| (w.x, w.y, w.z)),
        "encounter" => area.encounters.get(info.1).map(|e| (e.x, e.y, e.z)),
        "sound_emitter" => area.sound_emitters.get(info.1).map(|s| (s.x, s.y, s.z)),
        "light" => area.lights.get(info.1).map(|l| (l.x, l.y, l.z)),
        _ => None,
    };
    pos.map(|(x, y, z)| [x, z, -y])
}

fn save_bag_to_git(module: &mut nwn_gamemodel::Module, area_resref: &str, obj_type: &str, idx: usize, bag: &PropertyBag) -> bool {
    let key = area_resref.trim().to_lowercase();
    let bytes = match module.raw_git.get(&key) {
        Some(b) => b.clone(),
        None => return false,
    };
    let mut gff = match nwn_gff::GffFile::from_bytes(&bytes) {
        Ok(g) => g,
        Err(_) => return false,
    };
    let list_name = git_list_name(obj_type);
    let struct_id = git_struct_id(obj_type);
    let new_struct = bag.to_gff_struct(struct_id);
    match gff.root_mut().find_mut(list_name) {
        Some(nwn_gff::FieldValue::List(list)) => {
            if idx < list.len() {
                list[idx] = new_struct;
            } else {
                return false;
            }
        }
        _ => return false,
    }
    let data = gff.to_bytes();
    module.raw_git.insert(key, data);
    module.modified = true;
    true
}

#[allow(dead_code)]
fn do_find_replace(
    module: &mut nwn_gamemodel::Module,
    find: &str,
    replace: &str,
    case_sensitive: bool,
) -> (usize, usize) {
    let script_names: Vec<String> = module.script_names().into_iter().map(String::from).collect();
    let mut total_found = 0usize;
    let mut total_replaced = 0usize;
    for sname in &script_names {
        if let Some(source) = module.get_script_source(sname) {
            let mut modified = source.to_string();
            let find_lower = find.to_lowercase();
            let src_lower = modified.to_lowercase();
            if case_sensitive {
                let count = modified.matches(find).count();
                total_found += count;
                if !replace.is_empty() && count > 0 {
                    modified = modified.replace(find, replace);
                    total_replaced += count;
                }
            } else {
                let count = src_lower.matches(&find_lower).count();
                total_found += count;
                if !replace.is_empty() && count > 0 {
                    let mut result = String::new();
                    let mut last = 0;
                    for (idx, _) in src_lower.match_indices(&find_lower) {
                        result.push_str(&modified[last..idx]);
                        result.push_str(replace);
                        last = idx + find.len();
                    }
                    result.push_str(&modified[last..]);
                    modified = result;
                    total_replaced += count;
                }
            }
            if modified != source {
                module.update_script(sname, &modified);
            }
        }
    }
    (total_found, total_replaced)
}

fn load_module_cli(path: &str) -> nwn_gamemodel::Module {
    match nwn_gamemodel::Module::open(path) {
        Ok(m) => m,
        Err(e) => {
            eprintln!("ERROR: Failed to load module '{}': {}", path, e);
            std::process::exit(1);
        }
    }
}

fn get_area_cli(module: &nwn_gamemodel::Module, resref: &str) -> Arc<nwn_gamemodel::Area> {
    match module.get_area(resref) {
        Some(a) => a,
        None => {
            eprintln!("ERROR: Area '{}' not found in module", resref);
            std::process::exit(1);
        }
    }
}

fn cmd_module(args: &[String]) {
    if args.is_empty() {
        eprintln!("ERROR: module requires a path and action. Try: module <path> <action>");
        eprintln!("  actions: info, list-areas, list-resources, list-2das");
        std::process::exit(1);
    }
    let path = &args[0];
    let module = load_module_cli(path);
    let action = args.get(1).map(|s| s.as_str()).unwrap_or("info");

    match action {
        "info" => {
            println!("Module: {}", module.name);
            println!("Path:   {}", path);
            println!("Areas:  {}", module.num_areas());
            println!("Scripts: {}", module.script_names().len());
            println!("Convos: {}", module.conversation_names().len());
            println!("Has FAC: {}", module.has_fac());
            println!("Haks:   {}", module.resource_list().len());
        }
        "list-areas" => {
            for name in module.area_names() {
                println!("{}", name);
            }
        }
        "list-resources" => {
            for (name, restype) in module.resource_list() {
                let ext = nwn_gamemodel::resource_types::type_to_ext(restype).unwrap_or("???");
                println!("{} {}", name, ext);
            }
        }
        "list-2das" => {
            for name in module.area_names() {
                println!("  {}", name);
            }
        }
        _ => {
            eprintln!("ERROR: Unknown module action '{}'", action);
            eprintln!("  actions: info, list-areas, list-resources, list-2das");
            std::process::exit(1);
        }
    }
}

fn cmd_area(args: &[String]) {
    if args.len() < 2 {
        eprintln!("ERROR: area requires <module_path> <resref> [action]");
        eprintln!("  actions: info, export-minimap <out.png>, list-objects, list-tiles");
        std::process::exit(1);
    }
    let path = &args[0];
    let resref = &args[1];
    let module = load_module_cli(path);
    let area = get_area_cli(&module, resref);
    let action = args.get(2).map(|s| s.as_str()).unwrap_or("info");

    match action {
        "info" => {
            println!("Area:      {}", area.resref);
            println!("Tileset:   {}", area.tileset);
            println!("Size:      {} x {} tiles", area.width, area.height);
            println!("Tiles:     {}", area.tiles.len());
            println!("Creatures: {}", area.creatures.len());
            println!("Doors:     {}", area.doors.len());
            println!("Placeables: {}", area.placeables.len());
            println!("Triggers:  {}", area.triggers.len());
            println!("Waypoints: {}", area.waypoints.len());
            println!("Encounters: {}", area.encounters.len());
            println!("Sounds:    {}", area.sound_emitters.len());
            println!("Lights:    {}", area.lights.len());
            println!("Lighting:  ambient={:?} diffuse={:?}", area.sun_ambient_color, area.sun_diffuse_color);
        }
        "export-minimap" => {
            let out = args.get(3).unwrap_or_else(|| {
                eprintln!("ERROR: export-minimap requires <output.png>");
                std::process::exit(1);
            });
            match export_minimap_png(&area, out) {
                Ok(()) => println!("Exported: {}", out),
                Err(e) => {
                    eprintln!("ERROR: {}", e);
                    std::process::exit(1);
                }
            }
        }
        "list-objects" => {
            for obj in &area.creatures {
                println!("creature {:12}  x={:8.1} y={:8.1}  appearance={}", obj.resref, obj.x, obj.y, obj.appearance);
            }
            for obj in &area.doors {
                println!("door     {:12}  x={:8.1} y={:8.1}  appearance={}", obj.resref, obj.x, obj.y, obj.appearance);
            }
            for obj in &area.placeables {
                println!("placeable{:12}  x={:8.1} y={:8.1}  appearance={}", obj.resref, obj.x, obj.y, obj.appearance);
            }
            for obj in &area.triggers {
                println!("trigger  {:12}  x={:8.1} y={:8.1}", obj.resref, obj.x, obj.y);
            }
        }
        "list-tiles" => {
            if area.tiles.is_empty() {
                println!("(no tiles)");
            }
            for (i, tile) in area.tiles.iter().enumerate() {
                let col = i % area.width as usize;
                let row = i / area.width as usize;
                println!("{:4} col={} row={} id={:4} height={} orient={}", i, col, row, tile.id, tile.height, tile.orientation);
            }
        }
        _ => {
            eprintln!("ERROR: Unknown area action '{}'", action);
            std::process::exit(1);
        }
    }
}

fn cmd_resource(args: &[String]) {
    if args.len() < 2 {
        eprintln!("ERROR: resource requires <module_path> <resref> [restype_or_action] [args...]");
        eprintln!("  restype: extension like 'utc', 'dlg', etc.");
        eprintln!("  actions: info (default), extract, dump-json");
        std::process::exit(1);
    }
    let path = &args[0];
    let resref = &args[1];

    // Determine if arg[2] is a restype or action
    let mut restype: Option<u16> = None;
    let mut action_idx = 2;
    if let Some(s) = args.get(2) {
        if let Some(rt) = nwn_gamemodel::resource_types::ext_to_type(s) {
            restype = Some(rt);
            action_idx = 3;
        }
    }
    let action = args.get(action_idx).map(|s| s.as_str()).unwrap_or("info");

    let module = load_module_cli(path);

    let resource_data = if let Some(rt) = restype {
        module.get_resource_data(resref, rt)
    } else {
        // Search for any matching resource by name
        module.resource_list().iter()
            .find(|(name, _)| name.eq_ignore_ascii_case(resref))
            .and_then(|(name, rt)| module.get_resource_data(name, *rt))
    };

    let (found_ext, found_data, found_rt) = match resource_data {
        Some(data) => {
            let ext = restype
                .and_then(|rt| nwn_gamemodel::resource_types::type_to_ext(rt))
                .or_else(|| {
                    module.resource_list().iter()
                        .find(|(name, rt)| name.eq_ignore_ascii_case(resref) && restype.map_or(true, |r| *rt == r))
                        .and_then(|(_, rt)| nwn_gamemodel::resource_types::type_to_ext(*rt))
                })
                .unwrap_or("???")
                .to_string();
            let rt = restype.unwrap_or(
                module.resource_list().iter()
                    .find(|(name, _)| name.eq_ignore_ascii_case(resref))
                    .map(|(_, rt)| *rt)
                    .unwrap_or(0)
            );
            (ext, data, rt)
        }
        None => {
            eprintln!("ERROR: Resource '{}' not found in module", resref);
            std::process::exit(1);
        }
    };

    match action {
        "info" => {
            println!("Resource: {}.{}", resref, found_ext);
            println!("Type:     0x{:04x}", found_rt);
            println!("Size:     {} bytes", found_data.len());
        }
        "extract" => {
            let out = args.iter().skip(action_idx + 1).next().unwrap_or_else(|| {
                eprintln!("ERROR: extract requires <output_path>");
                std::process::exit(1);
            });
            match std::fs::write(out, &found_data) {
                Ok(()) => println!("Extracted {} bytes -> {}", found_data.len(), out),
                Err(e) => {
                    eprintln!("ERROR: Failed to write: {}", e);
                    std::process::exit(1);
                }
            }
        }
        "dump-json" => {
            match nwn_gff::GffFile::from_bytes(&found_data) {
                Ok(gff) => {
                    match serde_json::to_string_pretty(&gff.root()) {
                        Ok(json) => println!("{}", json),
                        Err(e) => {
                            eprintln!("ERROR: JSON serialization failed: {}", e);
                            std::process::exit(1);
                        }
                    }
                }
                Err(_) => {
                    println!("(binary data, {} bytes, not a GFF resource)", found_data.len());
                    for chunk in found_data.chunks(16) {
                        for b in chunk {
                            print!("{:02x} ", b);
                        }
                        println!();
                    }
                }
            }
        }
        _ => {
            eprintln!("ERROR: Unknown resource action '{}'", action);
            eprintln!("  actions: info, extract, dump-json");
            std::process::exit(1);
        }
    }
}

fn cmd_2da(args: &[String]) {
    if args.len() < 2 {
        eprintln!("ERROR: 2da requires <module_path> <table_name> [action] [args]");
        eprintln!("  actions: show (default), query <row> [column]");
        std::process::exit(1);
    }
    let path = &args[0];
    let table = &args[1];
    let action = args.get(2).map(|s| s.as_str()).unwrap_or("show");

    let module = load_module_cli(path);
    let data = module.get_resource_data(table, nwn_gamemodel::resource_types::ext_to_type("2da").unwrap_or(0x0007))
        .unwrap_or_else(|| {
            eprintln!("ERROR: 2DA table '{}' not found", table);
            std::process::exit(1);
        });
    let data_str = String::from_utf8_lossy(&data);
    let two_da = match nwn_2da::TwoDa::from_string(&data_str) {
        Ok(t) => t,
        Err(e) => {
            eprintln!("ERROR: Failed to parse 2DA '{}': {}", table, e);
            std::process::exit(1);
        }
    };

    match action {
        "show" => {
            let cols = two_da.columns();
            println!("Table: {}  ({} rows x {} cols)", table, two_da.row_count(), cols.len());
            println!("Columns: {}", cols.join(" | "));
            let max_rows = 100;
            let rows = two_da.row_count().min(max_rows);
            for r in 0..rows {
                print!("{:4} ", r);
                for c in 0..cols.len() {
                    let val = two_da.get_cell(r, c).unwrap_or("");
                    print!(" {} ", val);
                }
                println!();
            }
            if rows < two_da.row_count() {
                println!("... ({} rows truncated)", two_da.row_count() - rows);
            }
        }
        "query" => {
            let row: usize = args.get(3).and_then(|s| s.parse().ok()).unwrap_or_else(|| {
                eprintln!("ERROR: query requires <row> [column]");
                std::process::exit(1);
            });
            let col_str = args.get(4);
            let cols = two_da.columns();
            if let Some(col_name) = col_str {
                let ci = cols.iter().position(|c| c.eq_ignore_ascii_case(col_name));
                let ci = ci.or_else(|| col_name.parse::<usize>().ok());
                match ci {
                    Some(ci) if ci < cols.len() => {
                        let val = two_da.get_cell(row, ci).unwrap_or("");
                        println!("{}", val);
                    }
                    _ => {
                        eprintln!("ERROR: Column '{}' not found", col_name);
                        std::process::exit(1);
                    }
                }
            } else {
                // Print all columns for this row
                for (ci, col) in cols.iter().enumerate() {
                    let val = two_da.get_cell(row, ci).unwrap_or("");
                    println!("{:20} {}", col, val);
                }
            }
        }
        _ => {
            eprintln!("ERROR: Unknown 2da action '{}'", action);
            std::process::exit(1);
        }
    }
}

fn cmd_faction(args: &[String]) {
    if args.is_empty() {
        eprintln!("ERROR: faction requires <module_path> [action]");
        eprintln!("  actions: list (default), show-rep");
        std::process::exit(1);
    }
    let path = &args[0];
    let action = args.get(1).map(|s| s.as_str()).unwrap_or("list");
    let module = load_module_cli(path);

    let fac_data = module.get_resource_data("faction", nwn_gamemodel::resource_types::ext_to_type("fac").unwrap_or(0x0010))
        .or_else(|| module.get_resource_data("repute", nwn_gamemodel::resource_types::ext_to_type("fac").unwrap_or(0x0010)))
        .unwrap_or_else(|| {
            eprintln!("ERROR: No faction data (faction.fac or repute.fac) found in module");
            std::process::exit(1);
        });

    let gff = match nwn_gff::GffFile::from_bytes(&fac_data) {
        Ok(g) => g,
        Err(e) => {
            eprintln!("ERROR: Failed to parse faction data: {}", e);
            std::process::exit(1);
        }
    };

    match action {
        "list" => {
            if let Some(nwn_gff::FieldValue::List(list)) = gff.root().find("FactionList") {
                for (i, faction) in list.iter().enumerate() {
                    let id = match faction.find("FactionID") {
                        Some(nwn_gff::FieldValue::DWord(d)) => *d as i64,
                        Some(nwn_gff::FieldValue::Int(d)) => *d as i64,
                        _ => -1,
                    };
                    let name = match faction.find("FactionName") {
                        Some(nwn_gff::FieldValue::String(s)) => s.as_str(),
                        Some(nwn_gff::FieldValue::ResRef(s)) => s.as_str(),
                        _ => "(unnamed)",
                    };
                    println!("{:4} id={:4}  {}", i, id, name);
                }
            } else {
                println!("(no factions)");
            }
        }
        "show-rep" | "rep" => {
            println!("(Faction reputation matrix - use dump-json on faction.fac)");
        }
        _ => {
            eprintln!("ERROR: Unknown faction action '{}'", action);
            std::process::exit(1);
        }
    }
}

fn cmd_journal(args: &[String]) {
    if args.is_empty() {
        eprintln!("ERROR: journal requires <module_path>");
        std::process::exit(1);
    }
    let path = &args[0];
    let module = load_module_cli(path);

    let jrl_data = module.get_resource_data("module", nwn_gamemodel::resource_types::ext_to_type("jrl").unwrap_or(0x0012))
        .unwrap_or_else(|| {
            eprintln!("ERROR: No journal data (module.jrl) found in module");
            std::process::exit(1);
        });

    let gff = match nwn_gff::GffFile::from_bytes(&jrl_data) {
        Ok(g) => g,
        Err(e) => {
            eprintln!("ERROR: Failed to parse journal: {}", e);
            std::process::exit(1);
        }
    };

    fn gff_str<'a>(f: Option<&'a nwn_gff::FieldValue>) -> &'a str {
        match f {
            Some(nwn_gff::FieldValue::String(s)) => s.as_str(),
            Some(nwn_gff::FieldValue::ResRef(s)) => s.as_str(),
            _ => "",
        }
    }
    fn gff_int(f: Option<&nwn_gff::FieldValue>) -> i32 {
        match f {
            Some(nwn_gff::FieldValue::Int(v)) => *v,
            Some(nwn_gff::FieldValue::DWord(v)) => *v as i32,
            Some(nwn_gff::FieldValue::Byte(v)) => *v as i32,
            Some(nwn_gff::FieldValue::Short(v)) => *v as i32,
            Some(nwn_gff::FieldValue::Word(v)) => *v as i32,
            _ => 0,
        }
    }
    fn gff_list<'a>(f: Option<&'a nwn_gff::FieldValue>) -> Option<&'a Vec<nwn_gff::Struct>> {
        match f {
            Some(nwn_gff::FieldValue::List(l)) => Some(l),
            _ => None,
        }
    }

    if let Some(nwn_gff::FieldValue::List(categories)) = gff.root().find("Categories") {
        for (i, cat) in categories.iter().enumerate() {
            let name = gff_str(cat.find("Name"));
            let priority = gff_int(cat.find("Priority"));
            let entry_count = gff_list(cat.find("Entries")).map(|l| l.len()).unwrap_or(0);
            println!("{:4} {}  (prio={}, {} entries)", i, name, priority, entry_count);
            if let Some(entries) = gff_list(cat.find("Entries")) {
                for (ei, entry) in entries.iter().enumerate() {
                    let text = gff_str(entry.find("Text"));
                    let tag = gff_str(entry.find("QuestTag"));
                    let truncated: String = text.chars().take(80).collect();
                    println!("        {}: [{}] {}", ei, tag, truncated);
                }
            }
        }
    } else {
        println!("(no journal categories)");
    }
}

fn cmd_conversation(args: &[String]) {
    if args.len() < 2 {
        eprintln!("ERROR: conversation requires <module_path> <resref>");
        eprintln!("  resref: DLG resource name (without .dlg extension)");
        std::process::exit(1);
    }
    let path = &args[0];
    let resref = &args[1];
    let module = load_module_cli(path);

    match module.get_conversation(resref) {
        Some(conv) => {
            println!("Conversation: {}", resref);
            for (i, entry) in conv.entries.iter().enumerate() {
                let is_start = i as i32 == conv.starting_entry;
                let text: String = entry.text.chars().take(100).collect();
                let marker = if is_start { " ★ START" } else { "" };
                println!("  Entry {:3}: {:40}{}", i, text, marker);
                for (ri, reply) in entry.replies.iter().enumerate() {
                    let rtext: String = reply.text.chars().take(80).collect();
                    let next = reply.next_entry.map(|n| n.to_string()).unwrap_or_else(|| "END".to_string());
                    println!("           reply {:2}: {:40} → {}", ri, rtext, next);
                }
            }
        }
        None => {
            eprintln!("ERROR: Conversation '{}' not found in module", resref);
            std::process::exit(1);
        }
    }
}

fn cmd_compile(args: &[String]) {
    if args.is_empty() {
        eprintln!("ERROR: compile requires <nss_path> [output_path]");
        std::process::exit(1);
    }
    let src_path = &args[0];
    let out_path = args.get(1).cloned().unwrap_or_else(|| {
        let p = std::path::Path::new(src_path);
        p.with_extension("ncs").to_string_lossy().to_string()
    });

    let source = match std::fs::read_to_string(src_path) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("ERROR: Could not read '{}': {}", src_path, e);
            std::process::exit(1);
        }
    };

    let processed = match nwn_script::preprocess(&source, Some(src_path), &[]) {
        Ok(s) => s,
        Err(e) => {
            eprintln!("ERROR: Preprocess failed: {}", e);
            std::process::exit(1);
        }
    };
    let tokens = match nwn_script::Lexer::new(&processed).tokenize() {
        Ok(t) => t,
        Err(e) => {
            eprintln!("ERROR: Lex failed: {}", e);
            std::process::exit(1);
        }
    };
    let program = match nwn_script::Parser::new(tokens).parse() {
        Ok(p) => p,
        Err(e) => {
            eprintln!("ERROR: Parse failed: {}", e);
            std::process::exit(1);
        }
    };
    let mut compiler = nwn_script::Compiler::new();
    let ncs_bytes = compiler.compile(&program);
    if let Err(errors) = compiler.finalize() {
        eprintln!("Compilation failed for {}:", src_path);
        for err in &errors {
            eprintln!("  {}", err);
        }
        std::process::exit(1);
    }
    match std::fs::write(&out_path, &ncs_bytes) {
        Ok(()) => println!("Compiled {} -> {} ({} bytes)", src_path, out_path, ncs_bytes.len()),
        Err(e) => {
            eprintln!("ERROR: Could not write '{}': {}", out_path, e);
            std::process::exit(1);
        }
    }
}

fn cmd_compile_all(args: &[String]) {
    let path = args.get(0).unwrap_or_else(|| {
        eprintln!("ERROR: compile-all requires <module_path>");
        std::process::exit(1);
    });
    let mut module = nwn_gamemodel::Module::open(path).unwrap_or_else(|e| {
        eprintln!("ERROR: Could not open module '{}': {}", path, e);
        std::process::exit(1);
    });
    let nwnsc_path = nwnsc_exe();
    let tmp_dir = std::env::temp_dir().join("aurora_nwnsc");
    let _ = std::fs::remove_dir_all(&tmp_dir);
    let _ = std::fs::create_dir_all(&tmp_dir);

    for (nwnx_name, data) in NWNX_SCRIPTS {
        let _ = std::fs::write(tmp_dir.join(nwnx_name), data);
    }
    if detect_nwn_install().is_none() {
        let _ = std::fs::write(tmp_dir.join("nwscript.nss"), NWSCRIPT_NSS);
    }
    let _ = std::fs::write(tmp_dir.join("_prc_constants.nss"), PRC_CONSTANTS_NSS);
    // Write fixed sd_ai_inc_spawn.nss if found anywhere
    let nn_dir = std::path::PathBuf::from(std::env::var("HOME").unwrap_or_default()).join("Documents/Neverwinter Nights");
    let sd_paths = [
        nn_dir.join("development/sd_ai_inc_spawn.nss"),
        nn_dir.join("development_ch2/sd_ai_inc_spawn.nss"),
    ];
    let sd_content = sd_paths.iter().find_map(|p| std::fs::read_to_string(p).ok())
        .or_else(|| {
            let d = module.get_resource_data("sd_ai_inc_spawn", nwn_gamemodel::resource_types::NSS);
            d.map(|b| String::from_utf8_lossy(&b).to_string())
        });
    if let Some(c) = sd_content {
        let _ = std::fs::write(tmp_dir.join("sd_ai_inc_spawn.nss"), format!("#include \"x2_inc_switches\"\n{}", c).as_bytes());
    }

    let user_include_dir = std::path::PathBuf::from(std::env::var("HOME").unwrap_or_default()).join("Documents/Neverwinter Nights/include");
    let skip = ["nwscript", "prc_inc_spells", "nw_i0_generic", "x0_i0_spawncond", "x3_inc_horse", "x2_inc_compon", "se_respawn_inc", "staticspawn", "shardrecovery", "shardrecovery1", "bosskill", "pc_eviladjust", "nw_o2_coninclude", "sd_ai_inc_spawn"];
    let scripts: Vec<(String, String)> = module.script_names().into_iter().filter_map(|name| {
        if skip.contains(&name) { return None; }
        let source = module.get_script_source(name)?;
        let nss_path = tmp_dir.join(format!("{}.nss", name));
        let filtered: String = if name == "prc_inc_spells" || name == "nw_i0_generic" {
            let s = source.lines()
                .filter(|line| {
                    let t = line.trim();
                    !t.starts_with("const int EFFECT_TYPE_SLEEP")
                    && !t.starts_with("const int AI_LEVEL_")
                    && !t.starts_with("const int EVENT_")
                })
                .collect::<Vec<_>>()
                .join("\n");
            s
        } else if name == "mk_inc_body" {
            source.replace("int MK_SetBodyPart(", "void MK_SetBodyPart(")
        } else {
            format!("#include \"_prc_constants\"\n{}", source)
        };
        let _ = std::fs::write(&nss_path, filtered.as_bytes());
        Some((name.to_string(), filtered))
    }).collect();

    for (name, data) in NWNX_SCRIPTS {
        let _ = std::fs::write(tmp_dir.join(name), data);
    }

    let loose_nss_dirs: Vec<std::path::PathBuf> = {
        let parent = module.path.parent().unwrap_or(std::path::Path::new("."));
        module.area_names().iter().filter_map(|area| {
            let d = parent.join(area).join("nss");
            if d.is_dir() { Some(d) } else { None }
        }).collect()
    };

        let mut resolved: std::collections::HashSet<String> = std::collections::HashSet::new();
        let mut queue: Vec<String> = scripts.iter().map(|(n, _)| n.clone()).collect();
        while let Some(name) = queue.pop() {
            if resolved.contains(&name) { continue; }
            if ["nwscript", "nwnx_sql"].contains(&name.as_str()) {
                resolved.insert(name);
                continue;
            }
            // Already in tmp dir (module script with constant), preserve it
            if std::fs::read(tmp_dir.join(format!("{}.nss", name))).is_ok() {
                resolved.insert(name.clone());
                for line in std::fs::read_to_string(tmp_dir.join(format!("{}.nss", name))).unwrap().lines() {
                    let trimmed = line.trim();
                    if trimmed.starts_with("#include") {
                        if let Some(start) = trimmed.find('"') {
                            if let Some(end) = trimmed[start+1..].find('"') {
                                let include_name = trimmed[start+1..start+1+end].trim().to_lowercase();
                                if !resolved.contains(&include_name) && std::fs::read(tmp_dir.join(format!("{}.nss", include_name))).is_err() {
                                    queue.push(include_name);
                                }
                            }
                        }
                    }
                }
                continue;
            }
            let prefer_user_include = ["x0_i0_spawncond", "x3_inc_horse", "x2_inc_compon", "prc_inc_spells", "nw_i0_generic", "se_respawn_inc", "staticspawn", "shardrecovery", "shardrecovery1", "bosskill", "pc_eviladjust", "prc_inc_leadersh", "nw_o2_coninclude"];
            let src = if prefer_user_include.contains(&name.as_str()) && std::fs::read(user_include_dir.join(format!("{}.nss", name))).is_ok() {
            let data = if name == "prc_inc_spells" {
                let mut content = std::fs::read_to_string(user_include_dir.join("prc_inc_spells.nss")).unwrap();
                content = content.lines()
                    .filter(|line| {
                        let t = line.trim();
                        !t.starts_with("const int EFFECT_TYPE_SLEEP")
                        && !t.starts_with("const int AI_LEVEL_")
                        && !t.starts_with("const int EVENT_")
                    && !t.starts_with("#include \"inc_item_props\"")
                })
                .collect::<Vec<_>>()
                .join("\n");
                content.into_bytes()
            } else if name == "nw_i0_generic" {
                let mut content = std::fs::read_to_string(user_include_dir.join("nw_i0_generic.nss")).unwrap();
                content = format!("#include \"x0_i0_equip\"\n{}", content);
                content = content.lines()
                    .filter(|line| {
                        let t = line.trim();
                        !t.starts_with("const int EFFECT_TYPE_SLEEP")
                        && !t.starts_with("const int AI_LEVEL_")
                        && !t.starts_with("const int EVENT_")
                    })
                    .collect::<Vec<_>>()
                    .join("\n");
                content.into_bytes()
            } else if name == "se_respawn_inc" {
                let mut content = std::fs::read_to_string(user_include_dir.join("se_respawn_inc.nss")).unwrap();
                content = content.lines()
                    .filter(|line| !line.trim().contains("#include \"se_respawn_inc\""))
                    .collect::<Vec<_>>()
                    .join("\n");
                content = format!("#include \"_prc_constants\"\n{}", content);
                content.into_bytes()
            } else if name == "prc_inc_leadersh" {
                let mut content = std::fs::read_to_string(user_include_dir.join("prc_inc_leadersh.nss")).unwrap();
                content = content.replace("GenerateBossTreasure(oCohort);", "GenerateBossTreasure(oCohort, OBJECT_SELF);");
                content.into_bytes()
            } else {
                std::fs::read(user_include_dir.join(format!("{}.nss", name))).unwrap()
            };
            let _ = std::fs::write(tmp_dir.join(format!("{}.nss", name)), &data);
            String::from_utf8_lossy(&data).to_string()
        } else if let Some(s) = module.get_script_source(&name) {
            s.to_string()
        } else if !["nwscript", "nwnx_sql"].contains(&name.as_str()) && std::fs::read(user_include_dir.join(format!("{}.nss", name))).is_ok() {
            let data = std::fs::read(user_include_dir.join(format!("{}.nss", name))).unwrap();
            let _ = std::fs::write(tmp_dir.join(format!("{}.nss", name)), &data);
            String::from_utf8_lossy(&data).to_string()
        } else if !["nwscript", "nwnx_sql"].contains(&name.as_str()) && module.get_resource_data(&name, nwn_gamemodel::resource_types::NSS).is_some() {
            let data = module.get_resource_data(&name, nwn_gamemodel::resource_types::NSS).unwrap();
            let _ = std::fs::write(tmp_dir.join(format!("{}.nss", name)), &data);
            String::from_utf8_lossy(&data).to_string()
        } else if let Some(data) = loose_nss_dirs.iter().find_map(|d| std::fs::read(d.join(format!("{}.nss", name))).ok()) {
            let _ = std::fs::write(tmp_dir.join(format!("{}.nss", name)), &data);
            String::from_utf8_lossy(&data).to_string()
        } else {
            continue;
        };
        resolved.insert(name);
        for line in src.lines() {
            let trimmed = line.trim();
            if trimmed.starts_with("#include") {
                if let Some(start) = trimmed.find('"') {
                    if let Some(end) = trimmed[start+1..].find('"') {
                        let include_name = trimmed[start+1..start+1+end].trim().to_lowercase();
                        if !resolved.contains(&include_name)
                            && std::fs::read(tmp_dir.join(format!("{}.nss", include_name))).is_err()
                        {
                            queue.push(include_name);
                        }
                    }
                }
            }
        }
    }

    let out_dir = tmp_dir.join("out");
    let _ = std::fs::create_dir_all(&out_dir);

    let mut include_paths = tmp_dir.to_string_lossy().to_string();
    {
        let parent = module.path.parent().unwrap_or(std::path::Path::new("."));
        for area in module.area_names() {
            let nss_dir = parent.join(area).join("nss");
            if nss_dir.is_dir() {
                include_paths.push(';');
                include_paths.push_str(&nss_dir.to_string_lossy());
            }
        }
    }

    let total = scripts.len();
    let results = std::sync::Mutex::new(Vec::new());
    let errors = std::sync::Mutex::new(Vec::new());

    eprintln!("Compiling {} scripts...", total);
    let pool = rayon::ThreadPoolBuilder::new()
        .num_threads(8)
        .build()
        .unwrap();
    pool.scope(|s| {
        for (name, _) in &scripts {
            let name = name.clone();
            let np = nwnsc_path.clone();
            let ti = tmp_dir.clone();
            let inc_paths = include_paths.clone();
            let out_dir = out_dir.clone();
            let results = &results;
            let errors = &errors;
            s.spawn(move |_| {
                let in_path = ti.join(format!("{}.nss", name));
                let out_path = out_dir.join(format!("{}.ncs", name));
                let mut child = match std::process::Command::new(&np)
                    .arg("-l")
                    .arg("-e")
                    .arg("-i").arg(&inc_paths)
                    .arg("-n").arg(detect_nwn_install().map(|p| p.to_string_lossy().to_string()).unwrap_or_default())
                    .arg("-q")
                    .arg("-w")
                    .arg("-r").arg(&out_path)
                    .arg(&in_path)
                    .stdin(std::process::Stdio::null())
                    .stdout(std::process::Stdio::piped())
                    .stderr(std::process::Stdio::piped())
                    .spawn()
                {
                    Ok(c) => c,
                    Err(e) => {
                        errors.lock().unwrap().push((name, e.to_string()));
                        return;
                    }
                };
                let start = std::time::Instant::now();
                loop {
                    if start.elapsed() > std::time::Duration::from_secs(30) {
                        let _ = child.kill();
                        let _ = child.wait();
                        errors.lock().unwrap().push((name, "Timeout (30s)".to_string()));
                        break;
                    }
                    match child.try_wait() {
                        Ok(Some(_status)) => {
                            let stdout = child.stdout.take().map(|mut s| { let mut b = Vec::new(); let _ = std::io::Read::read_to_end(&mut s, &mut b); b }).unwrap_or_default();
                            let stderr = child.stderr.take().map(|mut s| { let mut b = Vec::new(); let _ = std::io::Read::read_to_end(&mut s, &mut b); b }).unwrap_or_default();
                            let msg = format!("{}{}", String::from_utf8_lossy(&stdout), String::from_utf8_lossy(&stderr));
                            if _status.success() {
                                if let Ok(ncs_data) = std::fs::read(&out_path) {
                                    results.lock().unwrap().push((name, ncs_data));
                                }
                            } else {
                                errors.lock().unwrap().push((name, msg));
                            }
                            break;
                        }
                        Ok(None) => {
                            std::thread::sleep(std::time::Duration::from_millis(100));
                        }
                        Err(e) => {
                            errors.lock().unwrap().push((name, e.to_string()));
                            break;
                        }
                    }
                }
            });
        }
    });

    let results_vec = results.into_inner().unwrap();
    let errors_vec = errors.into_inner().unwrap();

    eprintln!("\n=== COMPILE ALL RESULTS ===");
    eprintln!("Compiled: {}/{}", results_vec.len(), total);
    eprintln!("Errors: {}", errors_vec.len());

    for (name, msg) in &errors_vec {
        let first_line = msg.lines().next().unwrap_or(msg);
        eprintln!("[compile_err] {}: {}", name, first_line);
    }

    // Update the module with compiled scripts
    for (name, ncs_data) in &results_vec {
        module.update_ncs(name, ncs_data);
    }
    module.modified = true;
    module.save().unwrap_or_else(|e| {
        eprintln!("ERROR: Failed to save module: {}", e);
    });
    eprintln!("Module saved.");
}

fn cmd_tlk(args: &[String]) {
    if args.len() < 2 {
        eprintln!("ERROR: tlk requires <module_path> <strref_id>");
        std::process::exit(1);
    }
    let path = &args[0];
    let strref_id: u32 = args.get(1).and_then(|s| s.parse().ok()).unwrap_or_else(|| {
        eprintln!("ERROR: <strref_id> must be a number");
        std::process::exit(1);
    });

    // Try module custom TLK first, then game dialog.tlk
    let module = load_module_cli(path);
    let mut found = String::new();

    // Check module TLK files
    for tlk_idx in 0.. {
        let tlk_data = module.get_resource_data(&format!("dialog{}", tlk_idx), nwn_gamemodel::resource_types::ext_to_type("tlk").unwrap_or(0x0006));
        match tlk_data {
            Some(data) => {
                if let Ok(tlk) = nwn_tlk::TlkFile::from_bytes(&data) {
                    if let Some(text) = tlk.strref(strref_id) {
                        found = text.to_string();
                        break;
                    }
                }
            }
            None => break,
        }
    }

    if found.is_empty() {
        // Try game dialog.tlk
        if let Some(game_tlk_path) = nwn_game_tlk_path() {
            if let Ok(tlk) = nwn_tlk::TlkFile::open(&game_tlk_path) {
                if let Some(text) = tlk.strref(strref_id) {
                    found = text.to_string();
                }
            }
        }
    }

    if found.is_empty() {
        eprintln!("ERROR: StrRef {} not found", strref_id);
        std::process::exit(1);
    }

    println!("{}", found);
}

fn cmd_blueprint(args: &[String]) {
    if args.len() < 2 {
        eprintln!("ERROR: blueprint requires <module_path> <type> [filter]");
        eprintln!("  types: creatures, placeables, doors, items");
        std::process::exit(1);
    }
    let path = &args[0];
    let bp_type = &args[1];
    let filter = args.get(2).map(|s| s.to_lowercase()).unwrap_or_default();
    let module = load_module_cli(path);

    let two_da_name = match bp_type.as_str() {
        "creatures" => "appearance",
        "placeables" => "placeables",
        "doors" => "doortypes",
        "items" => "baseitems",
        _ => {
            eprintln!("ERROR: Unknown blueprint type '{}'", bp_type);
            eprintln!("  types: creatures, placeables, doors, items");
            std::process::exit(1);
        }
    };

    let data = module.get_resource_data(two_da_name, nwn_gamemodel::resource_types::ext_to_type("2da").unwrap_or(0x0007))
        .unwrap_or_else(|| {
            eprintln!("ERROR: 2DA table '{}' not found in game data", two_da_name);
            std::process::exit(1);
        });
    let data_str = String::from_utf8_lossy(&data);
    let two_da = match nwn_2da::TwoDa::from_string(&data_str) {
        Ok(t) => t,
        Err(e) => {
            eprintln!("ERROR: Failed to parse '{}': {}", two_da_name, e);
            std::process::exit(1);
        }
    };

    let cols = two_da.columns();
    let name_col = cols.iter().position(|c| c == "Name").or_else(|| cols.iter().position(|c| c == "Label"));
    let label_col = cols.iter().position(|c| c == "Label");

    for r in 0..two_da.row_count() {
        let name = name_col.and_then(|c| two_da.get_cell(r, c)).unwrap_or("");
        let label = label_col.and_then(|c| two_da.get_cell(r, c)).unwrap_or("");
        let display = if name.is_empty() { label } else { name };
        if !filter.is_empty() && !display.to_lowercase().contains(&filter) {
            continue;
        }
        println!("{:4}  {}", r, display);
    }
}

fn print_cli_help() {
    println!("Aurora Borealis Toolset v{}", env!("CARGO_PKG_VERSION"));
    println!();
    println!("USAGE:");
    println!("  aurora-borealis [COMMAND] [ARGS...]");
    println!("  (no command  →  launch GUI)");
    println!();
    println!("COMMANDS:");
    println!("  module <path> <action>         Module operations");
    println!("    actions: info, list-areas, list-resources");
    println!();
    println!("  area <path> <resref> <action>  Area operations");
    println!("    actions: info, export-minimap <out.png>, list-objects, list-tiles");
    println!();
    println!("  resource <path> <resref> [restype] <action>  Resource operations");
    println!("    actions: info, extract <out>, dump-json");
    println!();
    println!("  2da <path> <table> <action>    2DA table operations");
    println!("    actions: show, query <row> [column]");
    println!();
    println!("  faction <path> <action>        Faction operations");
    println!("    actions: list, show-rep");
    println!();
    println!("  journal <path>                 List journal entries");
    println!();
    println!("  conversation <path> <resref>   Dump conversation tree");
    println!();
    println!("  compile <nss> [output.ncs]     Compile NWScript
  compile-all <module>           Compile all scripts in a module");
    println!();
    println!("  tlk <path> <strref_id>         Look up TLK string");
    println!();
    println!("  blueprint <path> <type> [filter]  Browse blueprints");
    println!("    types: creatures, placeables, doors, items");
    println!();
    println!("  version                        Show version");
    println!("  help                           Show this help");
}

pub fn run_cli(args: &[String]) {
    let cmd = args.get(1).map(|s| s.as_str()).unwrap_or("gui");

    match cmd {
        "gui" | "" => {
            // Launch GUI (with optional --module/--area passthrough)
            let mod_path = args.get(2).filter(|_| args.len() > 2);
            let mut cli = CliArgs::default();
            if let Some(p) = mod_path {
                cli.module = Some(p.clone());
                cli.area = args.get(3).cloned();
            }
            run_native_with_args(cli);
        }
        "module" => cmd_module(&args[2..]),
        "area" => cmd_area(&args[2..]),
        "resource" | "res" => cmd_resource(&args[2..]),
        "2da" | "two-da" => cmd_2da(&args[2..]),
        "faction" => cmd_faction(&args[2..]),
        "journal" | "jrl" => cmd_journal(&args[2..]),
        "conversation" | "dlg" | "convo" => cmd_conversation(&args[2..]),
        "compile" | "nss" | "nwnsc" => cmd_compile(&args[2..]),
        "compile-all" | "compile_all" => cmd_compile_all(&args[2..]),
        "tlk" | "strref" => cmd_tlk(&args[2..]),
        "blueprint" | "bp" => cmd_blueprint(&args[2..]),
        "version" | "-v" | "--version" => {
            println!("Aurora Borealis Toolset v{}", env!("CARGO_PKG_VERSION"));
        }
        "help" | "-h" | "--help" => {
            print_cli_help();
        }
        unknown => {
            eprintln!("ERROR: Unknown command '{}'", unknown);
            eprintln!("Use 'help' for usage information.");
            std::process::exit(1);
        }
    }
}

#[derive(Default)]
pub struct CliArgs {
    pub module: Option<String>,
    pub area: Option<String>,
}

pub fn run_native_with_args(cli: CliArgs) {
    let native_options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default().with_inner_size([1400.0, 900.0]),
        wgpu_options: egui_wgpu::WgpuConfiguration {
            desired_maximum_frame_latency: Some(3),
            present_mode: wgpu::PresentMode::AutoVsync,
            ..Default::default()
        },
        ..Default::default()
    };
    if let Err(e) = eframe::run_native(
        "The Aurora BorealiuS Toolset",
        native_options,
        Box::new(|cc| Ok(Box::new(AuroraBorealisApp::new_with_cli(cc, cli)))),
    ) {
        eprintln!("FATAL: Failed to start: {}", e);
        std::process::exit(1);
    }
}

pub fn run_native() {
    run_native_with_args(CliArgs::default());
}

#[cfg(target_arch = "wasm32")]
#[wasm_bindgen]
pub struct WebHandle {
    runner: eframe::WebRunner,
}

#[cfg(target_arch = "wasm32")]
#[wasm_bindgen]
impl WebHandle {
    #[wasm_bindgen(constructor)]
    pub fn new() -> Self {
        eframe::WebLogger::init(log::LevelFilter::Debug).ok();
        Self {
            runner: eframe::WebRunner::new(),
        }
    }

    pub async fn start(&self, canvas: web_sys::HtmlCanvasElement) -> Result<(), wasm_bindgen::JsValue> {
        self.runner
            .start(
                canvas,
                eframe::WebOptions::default(),
                Box::new(|cc| Ok(Box::new(AuroraBorealisApp::new(cc)))),
            )
            .await
    }

    pub fn destroy(&self) {
        self.runner.destroy();
    }

    pub fn has_panicked(&self) -> bool {
        self.runner.has_panicked()
    }

    pub fn panic_message(&self) -> Option<String> {
        self.runner.panic_summary().map(|s| s.message())
    }

    pub fn load_module(&self, _name: String, data: Vec<u8>) {
        if let Some(mut app) = self.runner.app_mut::<AuroraBorealisApp>() {
            app.load_module_from_bytes(&data);
        }
    }
}
