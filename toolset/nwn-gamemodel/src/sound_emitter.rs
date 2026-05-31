use crate::area::{gff_float, gff_bearing, make_field, float_field, string_field, resref_field};

#[derive(Debug, Clone)]
pub struct SoundEmitterInstance {
    pub tag: String,
    pub template_resref: String,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub bearing: f32,
    pub positional: bool,
    pub min_distance: f32,
    pub max_distance: f32,
    pub volume: i32,
    pub sounds: Vec<String>,
}

impl SoundEmitterInstance {
    pub fn from_gff_struct(s: &nwn_gff::Struct) -> Self {
        let sounds = s.find("Sounds")
            .and_then(|v| if let nwn_gff::FieldValue::List(list) = v { Some(list) } else { None })
            .map(|list| {
                list.iter().filter_map(|entry| {
                    entry.find("Sound")
                        .or_else(|| entry.find("SoundResRef"))
                        .and_then(|v| if let nwn_gff::FieldValue::ResRef(r) = v { Some(r.clone()) }
                                      else if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) }
                                      else { None })
                }).collect()
            })
            .unwrap_or_default();

        Self {
            tag: s.find("Tag").and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None }).unwrap_or_default(),
            template_resref: s.find("TemplateResRef").and_then(|v| if let nwn_gff::FieldValue::ResRef(r) = v { Some(r.clone()) } else { None }).unwrap_or_default(),
            x: gff_float(s, "XPosition", "X"),
            y: gff_float(s, "YPosition", "Y"),
            z: gff_float(s, "ZPosition", "Z"),
            bearing: gff_bearing(s),
            positional: s.find("Positional").and_then(|v| if let nwn_gff::FieldValue::Byte(b) = v { Some(*b != 0) } else { None }).unwrap_or(true),
            min_distance: gff_float(s, "MinDistance", "MinDistance"),
            max_distance: gff_float(s, "MaxDistance", "MaxDistance"),
            volume: s.find("Volume").and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None }).unwrap_or(100),
            sounds,
        }
    }

    pub fn to_gff_struct(&self) -> nwn_gff::Struct {
        use nwn_gff::FieldValue;

        let mut fields: Vec<nwn_gff::Field> = vec![
            string_field("Tag", &self.tag),
            resref_field("TemplateResRef", &self.template_resref),
            float_field("XPosition", self.x),
            float_field("YPosition", self.y),
            float_field("ZPosition", self.z),
            float_field("XOrientation", self.bearing.sin()),
            float_field("YOrientation", self.bearing.cos()),
            make_field("Positional", FieldValue::Byte(if self.positional { 1 } else { 0 })),
            float_field("MinDistance", self.min_distance),
            float_field("MaxDistance", self.max_distance),
            make_field("Volume", FieldValue::Int(self.volume)),
        ];

        if !self.sounds.is_empty() {
            let sound_structs: Vec<nwn_gff::Struct> = self.sounds.iter().map(|snd| {
                nwn_gff::Struct {
                    id: 0,
                    fields: vec![
                        resref_field("Sound", snd),
                    ],
                }
            }).collect();
            fields.push(make_field("Sounds", FieldValue::List(nwn_gff::list_from_vec(sound_structs))));
        }

        nwn_gff::Struct { id: 10, fields }
    }

    pub fn to_property_bag(&self) -> crate::PropertyBag {
        use crate::{Property, PropertyValue};
        let mut props = vec![
            Property { label: "Tag".into(), value: PropertyValue::CExoString(self.tag.clone()), field_type: 10, category: String::new(), description: String::new() },
            Property { label: "TemplateResRef".into(), value: PropertyValue::ResRef(self.template_resref.clone()), field_type: 11, category: String::new(), description: String::new() },
            Property { label: "XPosition".into(), value: PropertyValue::Float(self.x), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "YPosition".into(), value: PropertyValue::Float(self.y), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "ZPosition".into(), value: PropertyValue::Float(self.z), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "Bearing".into(), value: PropertyValue::Float(self.bearing), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "Positional".into(), value: PropertyValue::Byte(if self.positional { 1 } else { 0 }), field_type: 0, category: String::new(), description: String::new() },
            Property { label: "MinDistance".into(), value: PropertyValue::Float(self.min_distance), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "MaxDistance".into(), value: PropertyValue::Float(self.max_distance), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "Volume".into(), value: PropertyValue::Int(self.volume), field_type: 5, category: String::new(), description: String::new() },
        ];

        if !self.sounds.is_empty() {
            let sound_bags: Vec<Box<crate::PropertyBag>> = self.sounds.iter().map(|snd| {
                Box::new(crate::PropertyBag {
                    properties: vec![
                        crate::Property { label: "Sound".into(), value: crate::PropertyValue::ResRef(snd.clone()), field_type: 11, category: String::new(), description: String::new() },
                    ],
                })
            }).collect();
            props.push(Property { label: "Sounds".into(), value: crate::PropertyValue::List(sound_bags), field_type: 15, category: String::new(), description: String::new() });
        }

        crate::PropertyBag { properties: props }
    }

    pub fn from_property_bag(bag: &crate::PropertyBag) -> Self {
        let sounds = bag.properties.iter()
            .find(|p| p.label == "Sounds")
            .and_then(|p| if let crate::PropertyValue::List(items) = &p.value { Some(items) } else { None })
            .map(|items| {
                items.iter().filter_map(|item| {
                    item.properties.iter()
                        .find(|p| p.label == "Sound" || p.label == "SoundResRef")
                        .and_then(|p| match &p.value {
                            crate::PropertyValue::ResRef(r) => Some(r.clone()),
                            crate::PropertyValue::CExoString(s) => Some(s.clone()),
                            _ => None,
                        })
                }).collect()
            })
            .unwrap_or_default();

        Self {
            tag: bag.get_string("Tag").unwrap_or("").to_string(),
            template_resref: bag.get_string("TemplateResRef").unwrap_or("").to_string(),
            x: bag.get_float("XPosition").unwrap_or(0.0),
            y: bag.get_float("YPosition").unwrap_or(0.0),
            z: bag.get_float("ZPosition").unwrap_or(0.0),
            bearing: bag.get_float("Bearing").unwrap_or(0.0),
            positional: bag.properties.iter().find(|p| p.label == "Positional").and_then(|p| if let crate::PropertyValue::Byte(b) = p.value { Some(b != 0) } else { None }).unwrap_or(true),
            min_distance: bag.get_float("MinDistance").unwrap_or(10.0),
            max_distance: bag.get_float("MaxDistance").unwrap_or(40.0),
            volume: bag.get_int("Volume").unwrap_or(100),
            sounds,
        }
    }
}
