use std::rc::Rc;
use std::str::FromStr;
use crate::{Result, PropertyValue, Property, EncounterInstance, SoundEmitterInstance, LightInstance};

#[derive(Debug, Clone)]
pub struct TileInfo {
    pub id: i32,
    pub orientation: i32,
    pub height: i32,
    pub walkable: bool,
}

#[derive(Clone)]
pub struct Area {
    pub resref: String,
    pub name: String,
    pub tag: String,
    pub width: i32,
    pub height: i32,
    pub tileset: String,
    pub tiles: Vec<TileInfo>,
    pub tile_models: Vec<Option<String>>,
    pub creatures: Vec<CreatureInstance>,
    pub doors: Vec<DoorInstance>,
    pub placeables: Vec<PlaceableInstance>,
    pub triggers: Vec<TriggerInstance>,
    pub waypoints: Vec<WayPointInstance>,
    pub encounters: Vec<EncounterInstance>,
    pub sound_emitters: Vec<SoundEmitterInstance>,
    pub lights: Vec<LightInstance>,
    pub walkmesh_walls: Vec<(usize, u8)>,
    pub tile_tints: Vec<(usize, [u8; 4])>,
    // Lighting
    pub sun_ambient_color: [u8; 3],
    pub sun_diffuse_color: [u8; 3],
    pub sun_fog_amount: u8,
    pub sun_fog_color: [u8; 3],
    pub sun_shadows: bool,
    pub moon_ambient_color: [u8; 3],
    pub moon_diffuse_color: [u8; 3],
    pub moon_fog_amount: u8,
    pub moon_fog_color: [u8; 3],
    pub moon_shadows: bool,
    pub fog_clip_dist: f32,
    pub shadow_opacity: u8,
    pub lighting_scheme: u8,
    pub day_night_cycle: bool,
    pub is_night: bool,
}

impl Area {
    pub fn load_from_gff(gff: &nwn_gff::GffFile, resref: String, _erf: &nwn_erf::ErfFile) -> Result<Self> {
        let name = gff.get_string("Area_Name").unwrap_or_default();
        let tag = gff.get_string("Tag").unwrap_or_default();
        let width = gff.get_int("Width").unwrap_or(0);
        let height = gff.get_int("Height").unwrap_or(0);
        let tileset = gff.get_string("Tileset").unwrap_or_default();

        let tiles = parse_tile_list(gff);

        let sun_ambient_color = load_dword_color(gff, "SunAmbientColor");
        let sun_diffuse_color = load_dword_color(gff, "SunDiffuseColor");
        let sun_fog_amount = gff.get_int("SunFogAmount").unwrap_or(0) as u8;
        let sun_fog_color = load_dword_color(gff, "SunFogColor");
        let sun_shadows = gff.get_int("SunShadows").unwrap_or(0) != 0;
        let moon_ambient_color = load_dword_color(gff, "MoonAmbientColor");
        let moon_diffuse_color = load_dword_color(gff, "MoonDiffuseColor");
        let moon_fog_amount = gff.get_int("MoonFogAmount").unwrap_or(0) as u8;
        let moon_fog_color = load_dword_color(gff, "MoonFogColor");
        let moon_shadows = gff.get_int("MoonShadows").unwrap_or(0) != 0;
        let fog_clip_dist = gff.get_float("FogClipDist").unwrap_or(45.0);
        let shadow_opacity = gff.get_int("ShadowOpacity").unwrap_or(60) as u8;
        let lighting_scheme = gff.get_int("LightingScheme").unwrap_or(0) as u8;
        let day_night_cycle = gff.get_int("DayNightCycle").unwrap_or(0) != 0;
        let is_night = gff.get_int("IsNight").unwrap_or(0) != 0;
        let walkmesh_walls = load_walkmesh_walls(gff);
        let tile_tints = load_tile_tints(gff);

        Ok(Self {
            resref,
            name,
            tag,
            width,
            height,
            tileset,
            tiles,
            tile_models: Vec::new(),
            creatures: Vec::new(),
            doors: Vec::new(),
            placeables: Vec::new(),
            triggers: Vec::new(),
            waypoints: Vec::new(),
            encounters: Vec::new(),
            sound_emitters: Vec::new(),
            lights: Vec::new(),
            walkmesh_walls,
            tile_tints,
            sun_ambient_color,
            sun_diffuse_color,
            sun_fog_amount,
            sun_fog_color,
            sun_shadows,
            moon_ambient_color,
            moon_diffuse_color,
            moon_fog_amount,
            moon_fog_color,
            moon_shadows,
            fog_clip_dist,
            shadow_opacity,
            lighting_scheme,
            day_night_cycle,
            is_night,
        })
    }
}

pub fn reload_from_git(area: &mut Area, git: &nwn_gff::GffFile) {
    fn find_list<'a>(root: &'a nwn_gff::Struct, names: &[&str]) -> Option<&'a nwn_gff::List> {
        for name in names {
            if let Some(nwn_gff::FieldValue::List(list)) = root.find(name) {
                return Some(list);
            }
        }
        None
    }

    // Preserve model_name across reload
    let old_models: std::collections::HashMap<(String, usize), String> = {
        let mut m = std::collections::HashMap::new();
        for (i, c) in area.creatures.iter().enumerate() {
            if let Some(ref n) = c.model_name {
                m.insert(("creature".into(), i), n.clone());
            }
        }
        for (i, d) in area.doors.iter().enumerate() {
            if let Some(ref n) = d.model_name {
                m.insert(("door".into(), i), n.clone());
            }
        }
        for (i, p) in area.placeables.iter().enumerate() {
            if let Some(ref n) = p.model_name {
                m.insert(("placeable".into(), i), n.clone());
            }
        }
        m
    };

    if let Some(list) = find_list(git.root(), &["Creature_List", "Creature List"]) {
        area.creatures = list.iter().enumerate().map(|(i, s)| {
            let mut c = CreatureInstance::from_gff_struct(s);
            c.model_name = old_models.get(&("creature".into(), i)).cloned().or(c.model_name);
            c
        }).collect();
    } else {
        area.creatures.clear();
    }
    if let Some(list) = find_list(git.root(), &["Door_List", "Door List"]) {
        area.doors = list.iter().enumerate().map(|(i, s)| {
            let mut d = DoorInstance::from_gff_struct(s);
            d.model_name = old_models.get(&("door".into(), i)).cloned().or(d.model_name);
            d
        }).collect();
    } else {
        area.doors.clear();
    }
    if let Some(list) = find_list(git.root(), &["Placeable_List", "Placeable List"]) {
        area.placeables = list.iter().enumerate().map(|(i, s)| {
            let mut p = PlaceableInstance::from_gff_struct(s);
            p.model_name = old_models.get(&("placeable".into(), i)).cloned().or(p.model_name);
            p
        }).collect();
    } else {
        area.placeables.clear();
    }
    if let Some(list) = find_list(git.root(), &["Trigger_List", "TriggerList"]) {
        area.triggers = list.iter().map(|s| TriggerInstance::from_gff_struct(s)).collect();
    } else {
        area.triggers.clear();
    }
    if let Some(list) = find_list(git.root(), &["Waypoint_List", "WaypointList"]) {
        area.waypoints = list.iter().map(|s| WayPointInstance::from_gff_struct(s)).collect();
    } else {
        area.waypoints.clear();
    }
    if let Some(list) = find_list(git.root(), &["Encounter_List", "Encounter List"]) {
        area.encounters = list.iter().map(|s| EncounterInstance::from_gff_struct(s)).collect();
    } else {
        area.encounters.clear();
    }
    if let Some(list) = find_list(git.root(), &["SoundList", "Sound_List"]) {
        area.sound_emitters = list.iter().map(|s| SoundEmitterInstance::from_gff_struct(s)).collect();
    } else {
        area.sound_emitters.clear();
    }
    if let Some(list) = find_list(git.root(), &["LightList", "Light_List"]) {
        area.lights = list.iter().map(|s| LightInstance::from_gff_struct(s)).collect();
    } else {
        area.lights.clear();
    }
}

pub fn build_git_gff(area: &Area) -> nwn_gff::GffFile {
    use nwn_gff::FieldValue;

    let creature_structs: Vec<nwn_gff::Struct> = area.creatures.iter().map(|c| c.to_gff_struct()).collect();
    let door_structs: Vec<nwn_gff::Struct> = area.doors.iter().map(|d| d.to_gff_struct()).collect();
    let placeable_structs: Vec<nwn_gff::Struct> = area.placeables.iter().map(|p| p.to_gff_struct()).collect();
    let trigger_structs: Vec<nwn_gff::Struct> = area.triggers.iter().map(|t| t.to_gff_struct()).collect();
    let waypoint_structs: Vec<nwn_gff::Struct> = area.waypoints.iter().map(|w| w.to_gff_struct()).collect();
    let encounter_structs: Vec<nwn_gff::Struct> = area.encounters.iter().map(|e| e.to_gff_struct()).collect();
    let sound_emitter_structs: Vec<nwn_gff::Struct> = area.sound_emitters.iter().map(|s| s.to_gff_struct()).collect();

    let mut fields: Vec<nwn_gff::Field> = Vec::new();

    if !creature_structs.is_empty() {
        fields.push(make_field("Creature_List", FieldValue::List(nwn_gff::list_from_vec(creature_structs))));
    }
    if !door_structs.is_empty() {
        fields.push(make_field("Door_List", FieldValue::List(nwn_gff::list_from_vec(door_structs))));
    }
    if !placeable_structs.is_empty() {
        fields.push(make_field("Placeable_List", FieldValue::List(nwn_gff::list_from_vec(placeable_structs))));
    }
    if !trigger_structs.is_empty() {
        fields.push(make_field("Trigger_List", FieldValue::List(nwn_gff::list_from_vec(trigger_structs))));
    }
    if !waypoint_structs.is_empty() {
        fields.push(make_field("WaypointList", FieldValue::List(nwn_gff::list_from_vec(waypoint_structs))));
    }
    if !encounter_structs.is_empty() {
        fields.push(make_field("Encounter_List", FieldValue::List(nwn_gff::list_from_vec(encounter_structs))));
    }
    if !sound_emitter_structs.is_empty() {
        fields.push(make_field("SoundList", FieldValue::List(nwn_gff::list_from_vec(sound_emitter_structs))));
    }
    let light_structs: Vec<nwn_gff::Struct> = area.lights.iter().map(|l| l.to_gff_struct()).collect();
    if !light_structs.is_empty() {
        fields.push(make_field("LightList", FieldValue::List(nwn_gff::list_from_vec(light_structs))));
    }

    let root = nwn_gff::Struct {
        id: u32::MAX,
        fields,
    };

    nwn_gff::GffFile {
        inner: nwn_lib_rs::gff::Gff {
            file_type: FromStr::from_str("GIT ").unwrap_or_default(),
            file_version: FromStr::from_str("V3.2").unwrap_or_default(),
            root,
        },
    }
}

pub fn update_are_tiles(gff: &mut nwn_gff::GffFile, area: &Area) {
    use nwn_gff::FieldValue;

    let root = &mut gff.inner.root;
    // Find existing Tile_List index
    let tile_idx = root.fields.iter().position(|f| {
        let label: String = f.label.to_string();
        label.trim() == "Tile_List"
    });

    let tile_list = nwn_gff::list_from_vec(area.tiles.iter().map(|t| {
        nwn_gff::Struct {
            id: 0,
            fields: vec![
                make_field("Tile_ID", FieldValue::Int(t.id)),
                make_field("Tile_Orientation", FieldValue::Int(t.orientation)),
                make_field("Tile_Height", FieldValue::Int(t.height)),
                make_field("Walkable", FieldValue::Byte(if t.walkable { 1 } else { 0 })),
            ],
        }
    }).collect());

    let tile_field = FieldValue::List(tile_list);

    match tile_idx {
        Some(idx) => root.fields[idx].value = tile_field,
        None => root.fields.push(make_field("Tile_List", tile_field)),
    }
}

pub fn update_are_walkmesh_walls(gff: &mut nwn_gff::GffFile, area: &Area) {
    use nwn_gff::FieldValue;
    let root = &mut gff.inner.root;
    let wall_idx = root.fields.iter().position(|f| {
        let label: String = f.label.to_string();
        label.trim() == "Walkmesh_Walls"
    });
    let wall_structs: Vec<nwn_gff::Struct> = area.walkmesh_walls.iter().map(|&(ti, edge)| {
        nwn_gff::Struct {
            id: 0,
            fields: vec![
                make_field("Tile_Index", FieldValue::Int(ti as i32)),
                make_field("Edge", FieldValue::Byte(edge)),
            ],
        }
    }).collect();
    let wall_field = if wall_structs.is_empty() {
        FieldValue::List(nwn_gff::list_from_vec(Vec::new()))
    } else {
        FieldValue::List(nwn_gff::list_from_vec(wall_structs))
    };
    match wall_idx {
        Some(idx) => root.fields[idx].value = wall_field,
        None => root.fields.push(make_field("Walkmesh_Walls", wall_field)),
    }
}

fn load_walkmesh_walls(gff: &nwn_gff::GffFile) -> Vec<(usize, u8)> {
    let mut walls = Vec::new();
    if let Some(nwn_gff::FieldValue::List(list)) = gff.root().find("Walkmesh_Walls") {
        for entry in list.iter() {
            let ti = entry.find("Tile_Index").and_then(|v| match v {
                nwn_gff::FieldValue::Int(i) => Some(*i as usize),
                _ => None,
            }).unwrap_or(0);
            let edge = entry.find("Edge").and_then(|v| match v {
                nwn_gff::FieldValue::Byte(b) => Some(*b),
                _ => None,
            }).unwrap_or(0);
            walls.push((ti, edge));
        }
    }
    walls
}

fn load_tile_tints(gff: &nwn_gff::GffFile) -> Vec<(usize, [u8; 4])> {
    let mut tints = Vec::new();
    if let Some(nwn_gff::FieldValue::List(list)) = gff.root().find("Tile_Tints") {
        for entry in list.iter() {
            let ti = entry.find("Tile_Index").and_then(|v| match v {
                nwn_gff::FieldValue::Int(i) => Some(*i as usize),
                _ => None,
            }).unwrap_or(0);
            let color = entry.find("Color").and_then(|v| match v {
                nwn_gff::FieldValue::DWord(d) => {
                    Some([(d & 0xFF) as u8, ((d >> 8) & 0xFF) as u8, ((d >> 16) & 0xFF) as u8, ((d >> 24) & 0xFF) as u8])
                }
                _ => None,
            }).unwrap_or([255, 255, 255, 255]);
            tints.push((ti, color));
        }
    }
    tints
}

pub fn update_are_tile_tints(gff: &mut nwn_gff::GffFile, area: &Area) {
    use nwn_gff::FieldValue;
    let root = &mut gff.inner.root;
    let tint_idx = root.fields.iter().position(|f| {
        let label: String = f.label.to_string();
        label.trim() == "Tile_Tints"
    });
    let tint_structs: Vec<nwn_gff::Struct> = area.tile_tints.iter().map(|&(ti, color)| {
        let dword = (color[0] as u32) | ((color[1] as u32) << 8) | ((color[2] as u32) << 16) | ((color[3] as u32) << 24);
        nwn_gff::Struct {
            id: 0,
            fields: vec![
                make_field("Tile_Index", FieldValue::Int(ti as i32)),
                make_field("Color", FieldValue::DWord(dword)),
            ],
        }
    }).collect();
    let tint_field = if tint_structs.is_empty() {
        FieldValue::List(nwn_gff::list_from_vec(Vec::new()))
    } else {
        FieldValue::List(nwn_gff::list_from_vec(tint_structs))
    };
    match tint_idx {
        Some(idx) => root.fields[idx].value = tint_field,
        None => root.fields.push(make_field("Tile_Tints", tint_field)),
    }
}

fn load_dword_color(gff: &nwn_gff::GffFile, field: &str) -> [u8; 3] {
    let dword = gff.root().find(field)
        .and_then(|v| if let nwn_gff::FieldValue::DWord(d) = v { Some(*d) } else { None })
        .unwrap_or(0);
    let r = (dword & 0xFF) as u8;
    let g = ((dword >> 8) & 0xFF) as u8;
    let b = ((dword >> 16) & 0xFF) as u8;
    [r, g, b]
}

fn dword_color_field(label: &str, color: [u8; 3]) -> nwn_gff::Field {
    let dword = (color[0] as u32) | ((color[1] as u32) << 8) | ((color[2] as u32) << 16);
    make_field(label, nwn_gff::FieldValue::DWord(dword))
}

pub fn update_are_lighting(gff: &mut nwn_gff::GffFile, area: &Area) {
    use nwn_gff::FieldValue;
    let root = &mut gff.inner.root;

    fn set_or_add(root: &mut nwn_gff::Struct, field: nwn_gff::Field) {
        let label = field.label.to_string();
        let label_trim = label.trim().to_string();
        if let Some(idx) = root.fields.iter().position(|f| f.label.as_str().trim() == label_trim) {
            root.fields[idx] = field;
        } else {
            root.fields.push(field);
        }
    }

    set_or_add(root, dword_color_field("SunAmbientColor", area.sun_ambient_color));
    set_or_add(root, dword_color_field("SunDiffuseColor", area.sun_diffuse_color));
    set_or_add(root, make_field("SunFogAmount", FieldValue::Byte(area.sun_fog_amount)));
    set_or_add(root, dword_color_field("SunFogColor", area.sun_fog_color));
    set_or_add(root, make_field("SunShadows", FieldValue::Byte(if area.sun_shadows { 1 } else { 0 })));
    set_or_add(root, dword_color_field("MoonAmbientColor", area.moon_ambient_color));
    set_or_add(root, dword_color_field("MoonDiffuseColor", area.moon_diffuse_color));
    set_or_add(root, make_field("MoonFogAmount", FieldValue::Byte(area.moon_fog_amount)));
    set_or_add(root, dword_color_field("MoonFogColor", area.moon_fog_color));
    set_or_add(root, make_field("MoonShadows", FieldValue::Byte(if area.moon_shadows { 1 } else { 0 })));
    set_or_add(root, make_field("FogClipDist", FieldValue::Float(area.fog_clip_dist)));
    set_or_add(root, make_field("ShadowOpacity", FieldValue::Byte(area.shadow_opacity)));
    set_or_add(root, make_field("LightingScheme", FieldValue::Byte(area.lighting_scheme)));
    set_or_add(root, make_field("DayNightCycle", FieldValue::Byte(if area.day_night_cycle { 1 } else { 0 })));
    set_or_add(root, make_field("IsNight", FieldValue::Byte(if area.is_night { 1 } else { 0 })));
}

fn int_from_field(field: &nwn_gff::FieldValue) -> Option<i32> {
    match field {
        nwn_gff::FieldValue::Int(i) => Some(*i),
        nwn_gff::FieldValue::DWord(d) => Some(*d as i32),
        nwn_gff::FieldValue::Byte(b) => Some(*b as i32),
        nwn_gff::FieldValue::Short(s) => Some(*s as i32),
        nwn_gff::FieldValue::Word(w) => Some(*w as i32),
        _ => None,
    }
}

fn parse_tile_list(gff: &nwn_gff::GffFile) -> Vec<TileInfo> {
    let mut tiles = Vec::new();
    if let Some(nwn_gff::FieldValue::List(list)) = gff.root().find("Tile_List") {
        for entry in list.iter() {
            tiles.push(TileInfo {
                id: entry.find("Tile_ID").and_then(int_from_field).unwrap_or(0),
                orientation: entry.find("Tile_Orientation").and_then(int_from_field).unwrap_or(0),
                height: entry.find("Tile_Height").and_then(int_from_field).unwrap_or(0),
                walkable: entry.find("Walkable").and_then(|v| match v {
                    nwn_gff::FieldValue::Byte(b) => Some(*b != 0),
                    _ => None,
                }).unwrap_or(true),
            });
        }
    }
    tiles
}

#[derive(Clone)]
pub struct CreatureInstance {
    pub resref: String,
    pub tag: String,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub bearing: f32,
    pub appearance: i32,
    pub model_name: Option<String>,
}

pub(crate) fn make_field(label: &str, value: nwn_gff::FieldValue) -> nwn_gff::Field {
    let fss: nwn_lib_rs::parsing::FixedSizeString<16> = FromStr::from_str(label).unwrap_or_default();
    nwn_gff::Field { label: Rc::new(fss), value }
}

pub(crate) fn string_field(label: &str, value: &str) -> nwn_gff::Field {
    make_field(label, nwn_gff::FieldValue::String(value.to_string()))
}

pub(crate) fn resref_field(label: &str, value: &str) -> nwn_gff::Field {
    make_field(label, nwn_gff::FieldValue::ResRef(value.to_string()))
}

pub(crate) fn float_field(label: &str, value: f32) -> nwn_gff::Field {
    make_field(label, nwn_gff::FieldValue::Float(value))
}

pub(crate) fn int_field(label: &str, value: i32) -> nwn_gff::Field {
    make_field(label, nwn_gff::FieldValue::Int(value))
}

fn gff_int(s: &nwn_gff::Struct, label: &str, default: i32) -> i32 {
    s.find(label)
        .and_then(|v| match v {
            nwn_gff::FieldValue::Int(i) => Some(*i),
            nwn_gff::FieldValue::DWord(d) => Some(*d as i32),
            nwn_gff::FieldValue::Byte(b) => Some(*b as i32),
            nwn_gff::FieldValue::Short(s) => Some(*s as i32),
            nwn_gff::FieldValue::Word(w) => Some(*w as i32),
            _ => None,
        })
        .unwrap_or(default)
}

pub(crate) fn gff_float(s: &nwn_gff::Struct, primary: &str, fallback: &str) -> f32 {
    s.find(primary)
        .or_else(|| s.find(fallback))
        .and_then(|v| match v {
            nwn_gff::FieldValue::Float(f) => Some(*f),
            nwn_gff::FieldValue::Double(f) => Some(*f as f32),
            _ => None,
        })
        .unwrap_or(0.0)
}

fn gff_float_or(s: &nwn_gff::Struct, primary: &str) -> f32 {
    s.find(primary)
        .and_then(|v| match v {
            nwn_gff::FieldValue::Float(f) => Some(*f),
            nwn_gff::FieldValue::Double(f) => Some(*f as f32),
            _ => None,
        })
        .unwrap_or(0.0)
}

pub(crate) fn gff_bearing(s: &nwn_gff::Struct) -> f32 {
    s.find("Bearing")
        .and_then(|v| match v {
            nwn_gff::FieldValue::Float(f) => Some(*f),
            nwn_gff::FieldValue::Double(f) => Some(*f as f32),
            _ => None,
        })
        .unwrap_or_else(|| {
            let ox = gff_float_or(s, "XOrientation");
            let oy = gff_float_or(s, "YOrientation");
            f32::atan2(ox, oy)
        })
}

fn gff_resref_from_struct(s: &nwn_gff::Struct) -> String {
    s.find("TemplateResRef")
        .or_else(|| s.find("ResRef"))
        .and_then(|v| match v {
            nwn_gff::FieldValue::ResRef(s) => Some(s.clone()),
            nwn_gff::FieldValue::String(s) => Some(s.clone()),
            _ => None,
        })
        .unwrap_or_default()
}

impl CreatureInstance {
    pub fn to_gff_struct(&self) -> nwn_gff::Struct {
        nwn_gff::Struct {
            id: 4,
            fields: vec![
                resref_field("TemplateResRef", &self.resref),
                string_field("Tag", &self.tag),
                float_field("XPosition", self.x),
                float_field("YPosition", self.y),
                float_field("ZPosition", self.z),
                float_field("XOrientation", self.bearing.sin()),
                float_field("YOrientation", self.bearing.cos()),
                int_field("Appearance", self.appearance),
            ],
        }
    }

    pub fn to_property_bag(&self) -> crate::PropertyBag {
        crate::PropertyBag {
            properties: vec![
                Property { label: "TemplateResRef".into(), value: PropertyValue::ResRef(self.resref.clone()), field_type: 11, category: String::new(), description: String::new() },
                Property { label: "Tag".into(), value: PropertyValue::CExoString(self.tag.clone()), field_type: 10, category: String::new(), description: String::new() },
                Property { label: "XPosition".into(), value: PropertyValue::Float(self.x), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "YPosition".into(), value: PropertyValue::Float(self.y), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "ZPosition".into(), value: PropertyValue::Float(self.z), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "Bearing".into(), value: PropertyValue::Float(self.bearing), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "Appearance".into(), value: PropertyValue::Int(self.appearance), field_type: 5, category: String::new(), description: String::new() },
            ],
        }
    }

    pub fn from_property_bag(bag: &crate::PropertyBag) -> Self {
        Self {
            resref: bag.get_string("TemplateResRef").unwrap_or("").to_string(),
            tag: bag.get_string("Tag").unwrap_or("").to_string(),
            x: bag.get_float("XPosition").or_else(|| bag.get_float("X")).unwrap_or(0.0),
            y: bag.get_float("YPosition").or_else(|| bag.get_float("Y")).unwrap_or(0.0),
            z: bag.get_float("ZPosition").or_else(|| bag.get_float("Z")).unwrap_or(0.0),
            bearing: bag.get_float("Bearing").unwrap_or(0.0),
            appearance: bag.get_int("Appearance").unwrap_or(-1),
            model_name: None,
        }
    }

    fn from_gff_struct(s: &nwn_gff::Struct) -> Self {
        let app = gff_int(s, "Appearance", -1);
        Self {
            resref: gff_resref_from_struct(s),
            tag: s.find("Tag").and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None }).unwrap_or_default(),
            x: gff_float(s, "XPosition", "X"),
            y: gff_float(s, "YPosition", "Y"),
            z: gff_float(s, "ZPosition", "Z"),
            bearing: gff_bearing(s),
            appearance: app,
            model_name: None,
        }
    }
}

#[derive(Clone)]
pub struct DoorInstance {
    pub resref: String,
    pub tag: String,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub bearing: f32,
    pub appearance: i32,
    pub model_name: Option<String>,
}

impl DoorInstance {
    pub fn to_gff_struct(&self) -> nwn_gff::Struct {
        nwn_gff::Struct {
            id: 5,
            fields: vec![
                resref_field("TemplateResRef", &self.resref),
                string_field("Tag", &self.tag),
                float_field("XPosition", self.x),
                float_field("YPosition", self.y),
                float_field("ZPosition", self.z),
                float_field("Bearing", self.bearing),
                int_field("Appearance", self.appearance),
            ],
        }
    }

    pub fn to_property_bag(&self) -> crate::PropertyBag {
        crate::PropertyBag {
            properties: vec![
                Property { label: "TemplateResRef".into(), value: PropertyValue::ResRef(self.resref.clone()), field_type: 11, category: String::new(), description: String::new() },
                Property { label: "Tag".into(), value: PropertyValue::CExoString(self.tag.clone()), field_type: 10, category: String::new(), description: String::new() },
                Property { label: "XPosition".into(), value: PropertyValue::Float(self.x), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "YPosition".into(), value: PropertyValue::Float(self.y), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "ZPosition".into(), value: PropertyValue::Float(self.z), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "Bearing".into(), value: PropertyValue::Float(self.bearing), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "Appearance".into(), value: PropertyValue::Int(self.appearance), field_type: 5, category: String::new(), description: String::new() },
            ],
        }
    }

    pub fn from_property_bag(bag: &crate::PropertyBag) -> Self {
        Self {
            resref: bag.get_string("TemplateResRef").unwrap_or("").to_string(),
            tag: bag.get_string("Tag").unwrap_or("").to_string(),
            x: bag.get_float("XPosition").or_else(|| bag.get_float("X")).unwrap_or(0.0),
            y: bag.get_float("YPosition").or_else(|| bag.get_float("Y")).unwrap_or(0.0),
            z: bag.get_float("ZPosition").or_else(|| bag.get_float("Z")).unwrap_or(0.0),
            bearing: bag.get_float("Bearing").unwrap_or(0.0),
            appearance: bag.get_int("Appearance").unwrap_or(-1),
            model_name: None,
        }
    }

    fn from_gff_struct(s: &nwn_gff::Struct) -> Self {
        Self {
            resref: gff_resref_from_struct(s),
            tag: s.find("Tag").and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None }).unwrap_or_default(),
            x: gff_float(s, "XPosition", "X"),
            y: gff_float(s, "YPosition", "Y"),
            z: gff_float(s, "ZPosition", "Z"),
            bearing: gff_bearing(s),
            appearance: gff_int(s, "Appearance", -1),
            model_name: None,
        }
    }
}

#[derive(Clone)]
pub struct PlaceableInstance {
    pub resref: String,
    pub tag: String,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub bearing: f32,
    pub appearance: i32,
    pub model_name: Option<String>,
    pub has_light: bool,
    pub light_color: [u8; 4],
    pub light_radius: f32,
}

impl PlaceableInstance {
    pub fn to_gff_struct(&self) -> nwn_gff::Struct {
        let mut fields = vec![
            resref_field("TemplateResRef", &self.resref),
            string_field("Tag", &self.tag),
            float_field("XPosition", self.x),
            float_field("YPosition", self.y),
            float_field("ZPosition", self.z),
            float_field("Bearing", self.bearing),
            int_field("Appearance", self.appearance),
        ];
        if self.has_light {
            let light_color_dword =
                (self.light_color[3] as u32) << 24 |
                (self.light_color[2] as u32) << 16 |
                (self.light_color[1] as u32) << 8 |
                self.light_color[0] as u32;
            fields.push(make_field("HasLight", nwn_gff::FieldValue::Byte(1)));
            fields.push(make_field("LightColor", nwn_gff::FieldValue::DWord(light_color_dword)));
            fields.push(float_field("LightRadius", self.light_radius));
        }
        nwn_gff::Struct { id: 6, fields }
    }

    pub fn to_property_bag(&self) -> crate::PropertyBag {
        crate::PropertyBag {
            properties: vec![
                Property { label: "TemplateResRef".into(), value: PropertyValue::ResRef(self.resref.clone()), field_type: 11, category: String::new(), description: String::new() },
                Property { label: "Tag".into(), value: PropertyValue::CExoString(self.tag.clone()), field_type: 10, category: String::new(), description: String::new() },
                Property { label: "XPosition".into(), value: PropertyValue::Float(self.x), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "YPosition".into(), value: PropertyValue::Float(self.y), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "ZPosition".into(), value: PropertyValue::Float(self.z), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "Bearing".into(), value: PropertyValue::Float(self.bearing), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "Appearance".into(), value: PropertyValue::Int(self.appearance), field_type: 5, category: String::new(), description: String::new() },
                Property { label: "HasLight".into(), value: PropertyValue::Byte(if self.has_light { 1 } else { 0 }), field_type: 1, category: String::new(), description: String::new() },
                Property { label: "LightColor".into(), value: PropertyValue::DWord(
                    (self.light_color[3] as u32) << 24 |
                    (self.light_color[2] as u32) << 16 |
                    (self.light_color[1] as u32) << 8 |
                    self.light_color[0] as u32
                ), field_type: 7, category: String::new(), description: String::new() },
                Property { label: "LightRadius".into(), value: PropertyValue::Float(self.light_radius), field_type: 8, category: String::new(), description: String::new() },
            ],
        }
    }

    pub fn from_property_bag(bag: &crate::PropertyBag) -> Self {
        let light_color_dword = bag.get_int("LightColor").unwrap_or(-1) as u32;
        Self {
            resref: bag.get_string("TemplateResRef").unwrap_or("").to_string(),
            tag: bag.get_string("Tag").unwrap_or("").to_string(),
            x: bag.get_float("XPosition").or_else(|| bag.get_float("X")).unwrap_or(0.0),
            y: bag.get_float("YPosition").or_else(|| bag.get_float("Y")).unwrap_or(0.0),
            z: bag.get_float("ZPosition").or_else(|| bag.get_float("Z")).unwrap_or(0.0),
            bearing: bag.get_float("Bearing").unwrap_or(0.0),
            appearance: bag.get_int("Appearance").unwrap_or(-1),
            model_name: None,
            has_light: bag.get_int("HasLight").unwrap_or(0) != 0,
            light_color: [
                (light_color_dword & 0xFF) as u8,
                ((light_color_dword >> 8) & 0xFF) as u8,
                ((light_color_dword >> 16) & 0xFF) as u8,
                ((light_color_dword >> 24) & 0xFF) as u8,
            ],
            light_radius: bag.get_float("LightRadius").unwrap_or(5.0),
        }
    }

    fn from_gff_struct(s: &nwn_gff::Struct) -> Self {
        let app = gff_int(s, "Appearance", -1);
        let light_color_dword = s.find("LightColor")
            .and_then(|v| if let nwn_gff::FieldValue::DWord(d) = v { Some(*d) } else { None })
            .unwrap_or(0xFFFFFFFF);
        Self {
            resref: gff_resref_from_struct(s),
            tag: s.find("Tag").and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None }).unwrap_or_default(),
            x: gff_float(s, "XPosition", "X"),
            y: gff_float(s, "YPosition", "Y"),
            z: gff_float(s, "ZPosition", "Z"),
            bearing: gff_bearing(s),
            appearance: app,
            model_name: None,
            has_light: gff_int(s, "HasLight", 0) != 0,
            light_color: [
                (light_color_dword & 0xFF) as u8,
                ((light_color_dword >> 8) & 0xFF) as u8,
                ((light_color_dword >> 16) & 0xFF) as u8,
                ((light_color_dword >> 24) & 0xFF) as u8,
            ],
            light_radius: gff_float(s, "LightRadius", "LightRadius"),
        }
    }
}

#[derive(Clone)]
pub struct TriggerInstance {
    pub resref: String,
    pub tag: String,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub bearing: f32,
    pub geometry: Vec<[f32; 3]>,
}

impl TriggerInstance {
    pub fn to_gff_struct(&self) -> nwn_gff::Struct {
        let mut fields = vec![
            resref_field("TemplateResRef", &self.resref),
            string_field("Tag", &self.tag),
            float_field("XPosition", self.x),
            float_field("YPosition", self.y),
            float_field("ZPosition", self.z),
            float_field("XOrientation", self.bearing.sin()),
            float_field("YOrientation", self.bearing.cos()),
        ];
        if !self.geometry.is_empty() {
            fields.push(make_field("Geometry",
                nwn_gff::FieldValue::List(nwn_gff::list_from_vec(self.geometry.iter().map(|pt| {
                    nwn_gff::Struct {
                        id: 7,
                        fields: vec![
                            float_field("X", pt[0]),
                            float_field("Y", pt[1]),
                            float_field("Z", pt[2]),
                        ],
                    }
                }).collect())),
            ));
        }
        nwn_gff::Struct { id: 7, fields }
    }

    pub fn to_property_bag(&self) -> crate::PropertyBag {
        let mut props = vec![
            Property { label: "TemplateResRef".into(), value: PropertyValue::ResRef(self.resref.clone()), field_type: 11, category: String::new(), description: String::new() },
            Property { label: "Tag".into(), value: PropertyValue::CExoString(self.tag.clone()), field_type: 10, category: String::new(), description: String::new() },
            Property { label: "XPosition".into(), value: PropertyValue::Float(self.x), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "YPosition".into(), value: PropertyValue::Float(self.y), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "ZPosition".into(), value: PropertyValue::Float(self.z), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "Bearing".into(), value: PropertyValue::Float(self.bearing), field_type: 8, category: String::new(), description: String::new() },
        ];
        for (i, pt) in self.geometry.iter().enumerate() {
            props.push(Property { label: format!("Geometry_{}_X", i), value: PropertyValue::Float(pt[0]), field_type: 8, category: "Geometry".into(), description: String::new() });
            props.push(Property { label: format!("Geometry_{}_Y", i), value: PropertyValue::Float(pt[1]), field_type: 8, category: "Geometry".into(), description: String::new() });
            props.push(Property { label: format!("Geometry_{}_Z", i), value: PropertyValue::Float(pt[2]), field_type: 8, category: "Geometry".into(), description: String::new() });
        }
        crate::PropertyBag { properties: props }
    }

    pub fn from_property_bag(bag: &crate::PropertyBag) -> Self {
        let mut geometry = Vec::new();
        for i in 0.. {
            let x = bag.get_float(&format!("Geometry_{}_X", i));
            let y = bag.get_float(&format!("Geometry_{}_Y", i));
            let z = bag.get_float(&format!("Geometry_{}_Z", i));
            match (x, y, z) {
                (Some(x), Some(y), Some(z)) => geometry.push([x, y, z]),
                _ => break,
            }
        }
        Self {
            resref: bag.get_string("TemplateResRef").unwrap_or("").to_string(),
            tag: bag.get_string("Tag").unwrap_or("").to_string(),
            x: bag.get_float("XPosition").unwrap_or(0.0),
            y: bag.get_float("YPosition").unwrap_or(0.0),
            z: bag.get_float("ZPosition").unwrap_or(0.0),
            bearing: bag.get_float("Bearing").unwrap_or(0.0),
            geometry,
        }
    }

    fn from_gff_struct(s: &nwn_gff::Struct) -> Self {
        let geometry = s.find("Geometry")
            .and_then(|v| if let nwn_gff::FieldValue::List(list) = v { Some(list) } else { None })
            .map(|list| {
                list.iter().filter_map(|entry| {
                    let x = gff_float(entry, "X", "XPosition");
                    let y = gff_float(entry, "Y", "YPosition");
                    let z = gff_float(entry, "Z", "ZPosition");
                    Some([x, y, z])
                }).collect()
            })
            .unwrap_or_default();
        Self {
            resref: gff_resref_from_struct(s),
            tag: s.find("Tag").and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None }).unwrap_or_default(),
            x: gff_float(s, "XPosition", "X"),
            y: gff_float(s, "YPosition", "Y"),
            z: gff_float(s, "ZPosition", "Z"),
            bearing: gff_bearing(s),
            geometry,
        }
    }
}

#[derive(Clone)]
pub struct WayPointInstance {
    pub resref: String,
    pub tag: String,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub bearing: f32,
}

impl WayPointInstance {
    pub fn to_gff_struct(&self) -> nwn_gff::Struct {
        nwn_gff::Struct {
            id: 8,
            fields: vec![
                resref_field("TemplateResRef", &self.resref),
                string_field("Tag", &self.tag),
                float_field("XPosition", self.x),
                float_field("YPosition", self.y),
                float_field("ZPosition", self.z),
                float_field("XOrientation", self.bearing.sin()),
                float_field("YOrientation", self.bearing.cos()),
            ],
        }
    }

    pub fn to_property_bag(&self) -> crate::PropertyBag {
        crate::PropertyBag {
            properties: vec![
                Property { label: "TemplateResRef".into(), value: PropertyValue::ResRef(self.resref.clone()), field_type: 11, category: String::new(), description: String::new() },
                Property { label: "Tag".into(), value: PropertyValue::CExoString(self.tag.clone()), field_type: 10, category: String::new(), description: String::new() },
                Property { label: "XPosition".into(), value: PropertyValue::Float(self.x), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "YPosition".into(), value: PropertyValue::Float(self.y), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "ZPosition".into(), value: PropertyValue::Float(self.z), field_type: 8, category: String::new(), description: String::new() },
                Property { label: "Bearing".into(), value: PropertyValue::Float(self.bearing), field_type: 8, category: String::new(), description: String::new() },
            ],
        }
    }

    pub fn from_property_bag(bag: &crate::PropertyBag) -> Self {
        Self {
            resref: bag.get_string("TemplateResRef").unwrap_or("").to_string(),
            tag: bag.get_string("Tag").unwrap_or("").to_string(),
            x: bag.get_float("XPosition").unwrap_or(0.0),
            y: bag.get_float("YPosition").unwrap_or(0.0),
            z: bag.get_float("ZPosition").unwrap_or(0.0),
            bearing: bag.get_float("Bearing").unwrap_or(0.0),
        }
    }

    fn from_gff_struct(s: &nwn_gff::Struct) -> Self {
        Self {
            resref: gff_resref_from_struct(s),
            tag: s.find("Tag").and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None }).unwrap_or_default(),
            x: gff_float(s, "XPosition", "X"),
            y: gff_float(s, "YPosition", "Y"),
            z: gff_float(s, "ZPosition", "Z"),
            bearing: gff_bearing(s),
        }
    }
}
