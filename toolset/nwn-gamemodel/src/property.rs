pub type FieldType = u8;

#[derive(Debug, Clone)]
pub struct Property {
    pub label: String,
    pub value: PropertyValue,
    pub field_type: FieldType,
    pub category: String,
    pub description: String,
}

#[derive(Debug, Clone)]
pub enum PropertyValue {
    Byte(u8),
    Char(i8),
    Word(u16),
    Short(i16),
    DWord(u32),
    Int(i32),
    DWord64(u64),
    Int64(i64),
    Float(f32),
    Double(f64),
    CExoString(String),
    ResRef(String),
    CExoLocString(LocString),
    Void(Vec<u8>),
    Struct(Box<PropertyBag>),
    List(Vec<Box<PropertyBag>>),
}

#[derive(Debug, Clone)]
pub struct LocString {
    pub strref: u32,
    pub substrings: Vec<SubString>,
}

#[derive(Debug, Clone)]
pub struct SubString {
    pub language_id: u32,
    pub gender: u32,
    pub text: String,
}

#[derive(Debug, Clone)]
pub struct PropertyBag {
    pub properties: Vec<Property>,
}

impl PropertyBag {
    pub fn new() -> Self {
        Self { properties: Vec::new() }
    }

    pub fn from_gff_struct(s: &nwn_gff::Struct) -> Self {
        let mut bag = Self::new();
        for field in &s.fields {
            let label = field.label.to_string();
            let (value, ftype) = match &field.value {
                nwn_gff::FieldValue::Byte(v) => (PropertyValue::Byte(*v), 0),
                nwn_gff::FieldValue::Char(v) => (PropertyValue::Char(*v), 1),
                nwn_gff::FieldValue::Word(v) => (PropertyValue::Word(*v), 2),
                nwn_gff::FieldValue::Short(v) => (PropertyValue::Short(*v), 3),
                nwn_gff::FieldValue::DWord(v) => (PropertyValue::DWord(*v), 4),
                nwn_gff::FieldValue::Int(v) => (PropertyValue::Int(*v), 5),
                nwn_gff::FieldValue::DWord64(v) => (PropertyValue::DWord64(*v), 6),
                nwn_gff::FieldValue::Int64(v) => (PropertyValue::Int64(*v), 7),
                nwn_gff::FieldValue::Float(v) => (PropertyValue::Float(*v), 8),
                nwn_gff::FieldValue::Double(v) => (PropertyValue::Double(*v), 9),
                nwn_gff::FieldValue::String(v) => (PropertyValue::CExoString(v.clone()), 10),
                nwn_gff::FieldValue::ResRef(v) => (PropertyValue::ResRef(v.clone()), 11),
                nwn_gff::FieldValue::LocString(ls) => {
                    let substrings = ls.strings.iter().map(|(lang, text)| SubString {
                        language_id: *lang as u32,
                        gender: 0,
                        text: text.clone(),
                    }).collect();
                    (PropertyValue::CExoLocString(LocString {
                        strref: ls.strref,
                        substrings,
                    }), 12)
                }
                nwn_gff::FieldValue::Void(v) => (PropertyValue::Void(v.clone()), 13),
                nwn_gff::FieldValue::Struct(s_inner) => {
                    (PropertyValue::Struct(Box::new(Self::from_gff_struct(s_inner))), 14)
                }
                nwn_gff::FieldValue::List(list) => {
                    let items: Vec<Box<PropertyBag>> = list.iter()
                        .map(|item| Box::new(Self::from_gff_struct(item)))
                        .collect();
                    (PropertyValue::List(items), 15)
                }
            };
            bag.properties.push(Property {
                label,
                value,
                field_type: ftype,
                category: String::new(),
                description: String::new(),
            });
        }
        bag
    }

    pub fn from_gff_file(gff: &nwn_gff::GffFile) -> Self {
        Self::from_gff_struct(gff.root())
    }

    pub fn get_string(&self, label: &str) -> Option<&str> {
        self.properties.iter()
            .find(|p| p.label == label)
            .and_then(|p| match &p.value {
                PropertyValue::CExoString(s) => Some(s.as_str()),
                PropertyValue::ResRef(s) => Some(s.as_str()),
                _ => None,
            })
    }

    pub fn get_int(&self, label: &str) -> Option<i32> {
        self.properties.iter()
            .find(|p| p.label == label)
            .and_then(|p| match &p.value {
                PropertyValue::Int(i) => Some(*i),
                PropertyValue::DWord(i) => Some(*i as i32),
                PropertyValue::Byte(i) => Some(*i as i32),
                PropertyValue::Short(i) => Some(*i as i32),
                PropertyValue::Word(i) => Some(*i as i32),
                _ => None,
            })
    }

    pub fn get_float(&self, label: &str) -> Option<f32> {
        self.properties.iter()
            .find(|p| p.label == label)
            .and_then(|p| match &p.value {
                PropertyValue::Float(f) => Some(*f),
                PropertyValue::Double(f) => Some(*f as f32),
                _ => None,
            })
    }

    pub fn set_string(&mut self, label: &str, value: String) {
        if let Some(p) = self.properties.iter_mut().find(|p| p.label == label) {
            p.value = PropertyValue::CExoString(value);
        }
    }

    pub fn set_int(&mut self, label: &str, value: i32) {
        if let Some(p) = self.properties.iter_mut().find(|p| p.label == label) {
            p.value = PropertyValue::Int(value);
        }
    }

    pub fn set_float(&mut self, label: &str, value: f32) {
        if let Some(p) = self.properties.iter_mut().find(|p| p.label == label) {
            p.value = PropertyValue::Float(value);
        }
    }

    pub fn to_gff_struct(&self, struct_id: u32) -> nwn_gff::Struct {
        use std::rc::Rc;
        use std::str::FromStr;
        let mut fields = Vec::new();
        for prop in &self.properties {
            let fss: nwn_lib_rs::parsing::FixedSizeString<16> = FromStr::from_str(&prop.label).unwrap_or_default();
            let label = Rc::new(fss);
            let value = match &prop.value {
                PropertyValue::Byte(v) => nwn_gff::FieldValue::Byte(*v),
                PropertyValue::Char(v) => nwn_gff::FieldValue::Char(*v),
                PropertyValue::Word(v) => nwn_gff::FieldValue::Word(*v),
                PropertyValue::Short(v) => nwn_gff::FieldValue::Short(*v),
                PropertyValue::DWord(v) => nwn_gff::FieldValue::DWord(*v),
                PropertyValue::Int(v) => nwn_gff::FieldValue::Int(*v),
                PropertyValue::DWord64(v) => nwn_gff::FieldValue::DWord64(*v),
                PropertyValue::Int64(v) => nwn_gff::FieldValue::Int64(*v),
                PropertyValue::Float(v) => nwn_gff::FieldValue::Float(*v),
                PropertyValue::Double(v) => nwn_gff::FieldValue::Double(*v),
                PropertyValue::CExoString(v) => nwn_gff::FieldValue::String(v.clone()),
                PropertyValue::ResRef(v) => nwn_gff::FieldValue::ResRef(v.clone()),
                PropertyValue::CExoLocString(ls) => {
                    let loc = nwn_lib_rs::gff::LocString {
                        strref: ls.strref,
                        strings: ls.substrings.iter().map(|sub| (sub.language_id as i32, sub.text.clone())).collect(),
                    };
                    nwn_gff::FieldValue::LocString(loc)
                }
                PropertyValue::Void(v) => nwn_gff::FieldValue::Void(v.clone()),
                PropertyValue::Struct(inner) => {
                    let inner_gff = inner.to_gff_struct(0);
                    nwn_gff::FieldValue::Struct(inner_gff)
                }
                PropertyValue::List(items) => {
                    let structs: Vec<nwn_gff::Struct> = items.iter()
                        .map(|item| item.to_gff_struct(0))
                        .collect();
                    if let Ok(json_str) = serde_json::to_string(&structs) {
                        if let Ok(list) = serde_json::from_str(&json_str) {
                            nwn_gff::FieldValue::List(list)
                        } else {
                            nwn_gff::FieldValue::List(nwn_gff::list_from_vec(structs))
                        }
                    } else {
                        nwn_gff::FieldValue::List(nwn_gff::list_from_vec(structs))
                    }
                }
            };
            fields.push(nwn_gff::Field {
                label,
                value,
            });
        }
        nwn_gff::Struct {
            id: struct_id,
            fields,
        }
    }

    pub fn to_gff(&self, file_type: &str, file_version: &str, struct_id: u32) -> nwn_gff::GffFile {
        use std::str::FromStr;
        let root = self.to_gff_struct(struct_id);
        nwn_gff::GffFile {
            inner: nwn_lib_rs::gff::Gff {
                file_type: FromStr::from_str(file_type).unwrap_or_default(),
                file_version: FromStr::from_str(file_version).unwrap_or_default(),
                root,
            },
        }
    }
}

impl Default for PropertyBag {
    fn default() -> Self {
        Self::new()
    }
}

pub fn display_value(pv: &PropertyValue) -> String {
    match pv {
        PropertyValue::Byte(v) => format!("{}", v),
        PropertyValue::Char(v) => format!("{}", v),
        PropertyValue::Word(v) => format!("{}", v),
        PropertyValue::Short(v) => format!("{}", v),
        PropertyValue::DWord(v) => format!("{}", v),
        PropertyValue::Int(v) => format!("{}", v),
        PropertyValue::DWord64(v) => format!("{}", v),
        PropertyValue::Int64(v) => format!("{}", v),
        PropertyValue::Float(v) => format!("{:.4}", v),
        PropertyValue::Double(v) => format!("{:.4}", v),
        PropertyValue::CExoString(v) => v.clone(),
        PropertyValue::ResRef(v) => v.clone(),
        PropertyValue::CExoLocString(ls) => {
            if let Some(sub) = ls.substrings.first() {
                sub.text.clone()
            } else {
                format!("[strref={}]", ls.strref)
            }
        }
        PropertyValue::Void(v) => format!("[{} bytes]", v.len()),
        PropertyValue::Struct(_) => "{ ... }".to_string(),
        PropertyValue::List(items) => format!("[{} items]", items.len()),
    }
}

pub fn value_type_name(ftype: FieldType) -> &'static str {
    match ftype {
        0 => "Byte",
        1 => "Char",
        2 => "Word",
        3 => "Short",
        4 => "DWord",
        5 => "Int",
        6 => "DWord64",
        7 => "Int64",
        8 => "Float",
        9 => "Double",
        10 => "String",
        11 => "ResRef",
        12 => "LocString",
        13 => "Void",
        14 => "Struct",
        15 => "List",
        _ => "Unknown",
    }
}
