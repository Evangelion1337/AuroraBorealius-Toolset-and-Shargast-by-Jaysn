use crate::area::{gff_float, make_field, float_field, string_field};

#[derive(Debug, Clone)]
pub struct LightInstance {
    pub tag: String,
    pub x: f32,
    pub y: f32,
    pub z: f32,
    pub color: [u8; 4],
    pub radius: f32,
    pub shadow_size: i32,
    pub shadow_opacity: u8,
    pub priority: i32,
    pub comment: String,
}

impl LightInstance {
    pub fn from_gff_struct(s: &nwn_gff::Struct) -> Self {
        let color_dword = s.find("Color")
            .and_then(|v| if let nwn_gff::FieldValue::DWord(d) = v { Some(*d) } else { None })
            .unwrap_or(0xFFFFFFFF);
        Self {
            tag: s.find("Tag").and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None }).unwrap_or_default(),
            x: gff_float(s, "XPosition", "X"),
            y: gff_float(s, "YPosition", "Y"),
            z: gff_float(s, "ZPosition", "Z"),
            color: [
                (color_dword & 0xFF) as u8,
                ((color_dword >> 8) & 0xFF) as u8,
                ((color_dword >> 16) & 0xFF) as u8,
                ((color_dword >> 24) & 0xFF) as u8,
            ],
            radius: gff_float(s, "Radius", "Radius"),
            shadow_size: s.find("ShadowSize").and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None }).unwrap_or(0),
            shadow_opacity: s.find("ShadowOpacity").and_then(|v| if let nwn_gff::FieldValue::Byte(b) = v { Some(*b) } else { None }).unwrap_or(0),
            priority: s.find("Priority").and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None }).unwrap_or(0),
            comment: s.find("Comment").and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None }).unwrap_or_default(),
        }
    }

    pub fn to_gff_struct(&self) -> nwn_gff::Struct {
        use nwn_gff::FieldValue;
        let color_dword =
            (self.color[3] as u32) << 24 |
            (self.color[2] as u32) << 16 |
            (self.color[1] as u32) << 8 |
            self.color[0] as u32;

        nwn_gff::Struct {
            id: 11,
            fields: vec![
                string_field("Tag", &self.tag),
                float_field("XPosition", self.x),
                float_field("YPosition", self.y),
                float_field("ZPosition", self.z),
                make_field("Color", FieldValue::DWord(color_dword)),
                float_field("Radius", self.radius),
                make_field("ShadowSize", FieldValue::Int(self.shadow_size)),
                make_field("ShadowOpacity", FieldValue::Byte(self.shadow_opacity)),
                make_field("Priority", FieldValue::Int(self.priority)),
                string_field("Comment", &self.comment),
            ],
        }
    }

    pub fn to_property_bag(&self) -> crate::PropertyBag {
        use crate::{Property, PropertyValue};
        let color_dword =
            (self.color[3] as u32) << 24 |
            (self.color[2] as u32) << 16 |
            (self.color[1] as u32) << 8 |
            self.color[0] as u32;
        let props = vec![
            Property { label: "Tag".into(), value: PropertyValue::CExoString(self.tag.clone()), field_type: 10, category: String::new(), description: String::new() },
            Property { label: "XPosition".into(), value: PropertyValue::Float(self.x), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "YPosition".into(), value: PropertyValue::Float(self.y), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "ZPosition".into(), value: PropertyValue::Float(self.z), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "Color".into(), value: PropertyValue::DWord(color_dword), field_type: 6, category: String::new(), description: String::new() },
            Property { label: "Radius".into(), value: PropertyValue::Float(self.radius), field_type: 8, category: String::new(), description: String::new() },
            Property { label: "ShadowSize".into(), value: PropertyValue::Int(self.shadow_size), field_type: 5, category: String::new(), description: String::new() },
            Property { label: "ShadowOpacity".into(), value: PropertyValue::Byte(self.shadow_opacity), field_type: 0, category: String::new(), description: String::new() },
            Property { label: "Priority".into(), value: PropertyValue::Int(self.priority), field_type: 5, category: String::new(), description: String::new() },
            Property { label: "Comment".into(), value: PropertyValue::CExoString(self.comment.clone()), field_type: 10, category: String::new(), description: String::new() },
        ];
        crate::PropertyBag { properties: props }
    }

    pub fn from_property_bag(bag: &crate::PropertyBag) -> Self {
        let color_dword = bag.get_int("Color").unwrap_or(-1) as u32;
        Self {
            tag: bag.get_string("Tag").unwrap_or("").to_string(),
            x: bag.get_float("XPosition").unwrap_or(0.0),
            y: bag.get_float("YPosition").unwrap_or(0.0),
            z: bag.get_float("ZPosition").unwrap_or(0.0),
            color: [
                (color_dword & 0xFF) as u8,
                ((color_dword >> 8) & 0xFF) as u8,
                ((color_dword >> 16) & 0xFF) as u8,
                ((color_dword >> 24) & 0xFF) as u8,
            ],
            radius: bag.get_float("Radius").unwrap_or(5.0),
            shadow_size: bag.get_int("ShadowSize").unwrap_or(0),
            shadow_opacity: bag.properties.iter().find(|p| p.label == "ShadowOpacity").and_then(|p| if let crate::PropertyValue::Byte(b) = p.value { Some(b) } else { None }).unwrap_or(0),
            priority: bag.get_int("Priority").unwrap_or(0),
            comment: bag.get_string("Comment").unwrap_or("").to_string(),
        }
    }
}
