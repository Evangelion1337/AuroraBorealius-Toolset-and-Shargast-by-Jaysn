use crate::area::{gff_float, gff_bearing, make_field, float_field, string_field, resref_field};

#[derive(Debug, Clone)]
pub struct EncounterInstance {
    pub tag: String,
    pub name: String,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub bearing: f32,
    pub geometry: Vec<[f32; 3]>,
    pub difficulty: i32,
    pub player_only: bool,
    pub reset: i32,
    pub max_creatures: i32,
    pub spawn_option: i32,
    pub on_entered: String,
    pub on_exhausted: String,
    pub on_exit: String,
    pub on_heartbeat: String,
    pub on_user_defined: String,
}

impl EncounterInstance {
    pub fn from_gff_struct(s: &nwn_gff::Struct) -> Self {
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
            tag: s.find("Tag").and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None }).unwrap_or_default(),
            name: s.find("LocName").and_then(|v| if let nwn_gff::FieldValue::LocString(ls) = v { ls.strings.iter().find(|(id, _)| *id == 0).map(|(_, t)| t.clone()) } else { None }).unwrap_or_default(),
            x: gff_float(s, "XPosition", "X"),
            y: gff_float(s, "YPosition", "Y"),
            z: gff_float(s, "ZPosition", "Z"),
            bearing: gff_bearing(s),
            geometry,
            difficulty: s.find("Difficulty").and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None }).unwrap_or(0),
            player_only: s.find("Player_Only").and_then(|v| if let nwn_gff::FieldValue::Byte(b) = v { Some(*b != 0) } else { None }).unwrap_or(false),
            reset: s.find("Reset").and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None }).unwrap_or(0),
            max_creatures: s.find("Max_Creatures").and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None }).unwrap_or(0),
            spawn_option: s.find("SpawnOption").and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None }).unwrap_or(0),
            on_entered: s.find("OnEntered").and_then(|v| if let nwn_gff::FieldValue::ResRef(r) = v { Some(r.clone()) } else { None }).unwrap_or_default(),
            on_exhausted: s.find("OnExhausted").and_then(|v| if let nwn_gff::FieldValue::ResRef(r) = v { Some(r.clone()) } else { None }).unwrap_or_default(),
            on_exit: s.find("OnExit").and_then(|v| if let nwn_gff::FieldValue::ResRef(r) = v { Some(r.clone()) } else { None }).unwrap_or_default(),
            on_heartbeat: s.find("OnHeartbeat").and_then(|v| if let nwn_gff::FieldValue::ResRef(r) = v { Some(r.clone()) } else { None }).unwrap_or_default(),
            on_user_defined: s.find("OnUserDefined").and_then(|v| if let nwn_gff::FieldValue::ResRef(r) = v { Some(r.clone()) } else { None }).unwrap_or_default(),
        }
    }

    pub fn to_gff_struct(&self) -> nwn_gff::Struct {
        use nwn_gff::FieldValue;

        let mut fields: Vec<nwn_gff::Field> = vec![
            string_field("Tag", &self.tag),
            float_field("XPosition", self.x),
            float_field("YPosition", self.y),
            float_field("ZPosition", self.z),
            float_field("XOrientation", self.bearing.sin()),
            float_field("YOrientation", self.bearing.cos()),
            make_field("Difficulty", FieldValue::Int(self.difficulty)),
            make_field("Max_Creatures", FieldValue::Int(self.max_creatures)),
            make_field("SpawnOption", FieldValue::Int(self.spawn_option)),
            make_field("Reset", FieldValue::Int(self.reset)),
            make_field("Player_Only", FieldValue::Byte(if self.player_only { 1 } else { 0 })),
        ];

        if !self.name.is_empty() {
            fields.push(make_field("LocName", FieldValue::LocString(nwn_lib_rs::gff::LocString { strref: 0, strings: vec![(0i32, self.name.clone())] })));
        }
        if !self.on_entered.is_empty() {
            fields.push(resref_field("OnEntered", &self.on_entered));
        }
        if !self.on_exhausted.is_empty() {
            fields.push(resref_field("OnExhausted", &self.on_exhausted));
        }
        if !self.on_exit.is_empty() {
            fields.push(resref_field("OnExit", &self.on_exit));
        }
        if !self.on_heartbeat.is_empty() {
            fields.push(resref_field("OnHeartbeat", &self.on_heartbeat));
        }
        if !self.on_user_defined.is_empty() {
            fields.push(resref_field("OnUserDefined", &self.on_user_defined));
        }
        if !self.geometry.is_empty() {
            let point_structs: Vec<nwn_gff::Struct> = self.geometry.iter().map(|pt| {
                nwn_gff::Struct {
                    id: 0,
                    fields: vec![
                        float_field("X", pt[0]),
                        float_field("Y", pt[1]),
                        float_field("Z", pt[2]),
                    ],
                }
            }).collect();
            fields.push(make_field("Geometry", FieldValue::List(nwn_gff::list_from_vec(point_structs))));
        }

        nwn_gff::Struct { id: 9, fields }
    }

    pub fn to_property_bag(&self) -> crate::PropertyBag {
        use crate::{Property, PropertyValue};
        let mut props = vec![
            Property { label: "Tag".into(), value: PropertyValue::CExoString(self.tag.clone()), field_type: 10, category: String::new(), description: String::new() },
            Property { label: "LocName".into(), value: PropertyValue::CExoLocString(crate::LocString { strref: 0, substrings: vec![crate::SubString { language_id: 0, gender: 0, text: self.name.clone() }] }), field_type: 12, category: String::new(), description: String::new() },
            Property { label: "XPosition".into(), value: PropertyValue::Float(self.x), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "YPosition".into(), value: PropertyValue::Float(self.y), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "ZPosition".into(), value: PropertyValue::Float(self.z), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "Bearing".into(), value: PropertyValue::Float(self.bearing), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "Difficulty".into(), value: PropertyValue::Int(self.difficulty), field_type: 5, category: String::new(), description: String::new() },
            Property { label: "Player_Only".into(), value: PropertyValue::Byte(if self.player_only { 1 } else { 0 }), field_type: 0, category: String::new(), description: String::new() },
            Property { label: "Reset".into(), value: PropertyValue::Int(self.reset), field_type: 5, category: String::new(), description: String::new() },
            Property { label: "Max_Creatures".into(), value: PropertyValue::Int(self.max_creatures), field_type: 5, category: String::new(), description: String::new() },
            Property { label: "SpawnOption".into(), value: PropertyValue::Int(self.spawn_option), field_type: 5, category: String::new(), description: String::new() },
            Property { label: "OnEntered".into(), value: PropertyValue::ResRef(self.on_entered.clone()), field_type: 11, category: String::new(), description: String::new() },
            Property { label: "OnExhausted".into(), value: PropertyValue::ResRef(self.on_exhausted.clone()), field_type: 11, category: String::new(), description: String::new() },
            Property { label: "OnExit".into(), value: PropertyValue::ResRef(self.on_exit.clone()), field_type: 11, category: String::new(), description: String::new() },
            Property { label: "OnHeartbeat".into(), value: PropertyValue::ResRef(self.on_heartbeat.clone()), field_type: 11, category: String::new(), description: String::new() },
            Property { label: "OnUserDefined".into(), value: PropertyValue::ResRef(self.on_user_defined.clone()), field_type: 11, category: String::new(), description: String::new() },
        ];

        if !self.geometry.is_empty() {
            let geo_bags: Vec<Box<crate::PropertyBag>> = self.geometry.iter().map(|pt| {
                Box::new(crate::PropertyBag {
                    properties: vec![
                        crate::Property { label: "X".into(), value: crate::PropertyValue::Float(pt[0]), field_type: 8, category: String::new(), description: String::new() },
                        crate::Property { label: "Y".into(), value: crate::PropertyValue::Float(pt[1]), field_type: 8, category: String::new(), description: String::new() },
                        crate::Property { label: "Z".into(), value: crate::PropertyValue::Float(pt[2]), field_type: 8, category: String::new(), description: String::new() },
                    ],
                })
            }).collect();
            props.push(Property { label: "Geometry".into(), value: crate::PropertyValue::List(geo_bags), field_type: 15, category: String::new(), description: String::new() });
        }

        crate::PropertyBag { properties: props }
    }

    pub fn from_property_bag(bag: &crate::PropertyBag) -> Self {
        let geometry = bag.properties.iter()
            .find(|p| p.label == "Geometry")
            .and_then(|p| if let crate::PropertyValue::List(items) = &p.value { Some(items) } else { None })
            .map(|items| {
                items.iter().filter_map(|item| {
                    let x = item.properties.iter().find(|p| p.label == "X").and_then(|p| if let crate::PropertyValue::Float(f) = p.value { Some(f) } else { None }).unwrap_or(0.0);
                    let y = item.properties.iter().find(|p| p.label == "Y").and_then(|p| if let crate::PropertyValue::Float(f) = p.value { Some(f) } else { None }).unwrap_or(0.0);
                    let z = item.properties.iter().find(|p| p.label == "Z").and_then(|p| if let crate::PropertyValue::Float(f) = p.value { Some(f) } else { None }).unwrap_or(0.0);
                    Some([x, y, z])
                }).collect()
            })
            .unwrap_or_default();

        Self {
            tag: bag.get_string("Tag").unwrap_or("").to_string(),
            name: bag.properties.iter().find(|p| p.label == "LocName").and_then(|p| if let crate::PropertyValue::CExoLocString(ls) = &p.value { ls.substrings.first().map(|s| s.text.clone()) } else { None }).unwrap_or_default(),
            x: bag.get_float("XPosition").unwrap_or(0.0),
            y: bag.get_float("YPosition").unwrap_or(0.0),
            z: bag.get_float("ZPosition").unwrap_or(0.0),
            bearing: bag.get_float("Bearing").unwrap_or(0.0),
            geometry,
            difficulty: bag.get_int("Difficulty").unwrap_or(0),
            player_only: bag.properties.iter().find(|p| p.label == "Player_Only").and_then(|p| if let crate::PropertyValue::Byte(b) = p.value { Some(b != 0) } else { None }).unwrap_or(false),
            reset: bag.get_int("Reset").unwrap_or(0),
            max_creatures: bag.get_int("Max_Creatures").unwrap_or(0),
            spawn_option: bag.get_int("SpawnOption").unwrap_or(0),
            on_entered: bag.get_string("OnEntered").unwrap_or("").to_string(),
            on_exhausted: bag.get_string("OnExhausted").unwrap_or("").to_string(),
            on_exit: bag.get_string("OnExit").unwrap_or("").to_string(),
            on_heartbeat: bag.get_string("OnHeartbeat").unwrap_or("").to_string(),
            on_user_defined: bag.get_string("OnUserDefined").unwrap_or("").to_string(),
        }
    }
}
