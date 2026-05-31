use crate::Result;

#[derive(Debug, Clone)]
pub struct JournalEntry {
    pub id: i32,
    pub text: String,
    pub end_text: String,
    pub quest_tag: String,
    pub xp_final: i32,
}

#[derive(Debug, Clone)]
pub struct JournalCategory {
    pub id: i32,
    pub name: String,
    pub priority: i32,
    pub entries: Vec<JournalEntry>,
}

#[derive(Debug, Clone, Default)]
pub struct Journal {
    pub categories: Vec<JournalCategory>,
}

fn get_int_field(s: &nwn_gff::Struct, label: &str) -> i32 {
    s.find(label).and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None }).unwrap_or(0)
}

fn get_string_field(s: &nwn_gff::Struct, label: &str) -> String {
    s.find(label).and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None }).unwrap_or_default()
}

impl Journal {
    pub fn from_gff(gff: &nwn_gff::GffFile) -> Result<Self> {
        let root = gff.root();
        let mut categories = Vec::new();
        if let Some(nwn_gff::FieldValue::List(cat_list)) = root.find("Categories") {
            for cat_struct in cat_list.iter() {
                let mut entries = Vec::new();
                if let Some(nwn_gff::FieldValue::List(entry_list)) = cat_struct.find("EntryList") {
                    for entry_struct in entry_list.iter() {
                        entries.push(JournalEntry {
                            id: get_int_field(entry_struct, "ID"),
                            text: get_string_field(entry_struct, "Text"),
                            end_text: get_string_field(entry_struct, "EndText"),
                            quest_tag: get_string_field(entry_struct, "QuestTag"),
                            xp_final: get_int_field(entry_struct, "XPFinal"),
                        });
                    }
                }
                categories.push(JournalCategory {
                    name: get_string_field(cat_struct, "Name"),
                    id: get_int_field(cat_struct, "CategoryID"),
                    priority: get_int_field(cat_struct, "Priority"),
                    entries,
                });
            }
        }
        Ok(Self { categories })
    }

    pub fn to_gff(&self) -> nwn_gff::GffFile {
        use std::rc::Rc;
        use std::str::FromStr;
        let cat_list: Vec<nwn_gff::Struct> = self.categories.iter().map(|cat| {
            let entry_list: Vec<nwn_gff::Struct> = cat.entries.iter().map(|entry| {
                nwn_gff::Struct {
                    id: 0,
                    fields: vec![
                        nwn_gff::Field { label: Rc::new(FromStr::from_str("ID").unwrap()), value: nwn_gff::FieldValue::Int(entry.id) },
                        nwn_gff::Field { label: Rc::new(FromStr::from_str("Text").unwrap()), value: nwn_gff::FieldValue::String(entry.text.clone()) },
                        nwn_gff::Field { label: Rc::new(FromStr::from_str("EndText").unwrap()), value: nwn_gff::FieldValue::String(entry.end_text.clone()) },
                        nwn_gff::Field { label: Rc::new(FromStr::from_str("QuestTag").unwrap()), value: nwn_gff::FieldValue::String(entry.quest_tag.clone()) },
                        nwn_gff::Field { label: Rc::new(FromStr::from_str("XPFinal").unwrap()), value: nwn_gff::FieldValue::Int(entry.xp_final) },
                    ],
                }
            }).collect();
            let json_str = serde_json::to_string(&entry_list).unwrap();
            let entry_list_gff: nwn_gff::List = serde_json::from_str(&json_str).unwrap();
            nwn_gff::Struct {
                id: 0,
                fields: vec![
                    nwn_gff::Field { label: Rc::new(FromStr::from_str("Name").unwrap()), value: nwn_gff::FieldValue::String(cat.name.clone()) },
                    nwn_gff::Field { label: Rc::new(FromStr::from_str("CategoryID").unwrap()), value: nwn_gff::FieldValue::Int(cat.id) },
                    nwn_gff::Field { label: Rc::new(FromStr::from_str("Priority").unwrap()), value: nwn_gff::FieldValue::Int(cat.priority) },
                    nwn_gff::Field { label: Rc::new(FromStr::from_str("EntryList").unwrap()), value: nwn_gff::FieldValue::List(entry_list_gff) },
                ],
            }
        }).collect();
        let json_str = serde_json::to_string(&cat_list).unwrap();
        let cat_list_gff: nwn_gff::List = serde_json::from_str(&json_str).unwrap();
        let root = nwn_gff::Struct {
            id: u32::MAX,
            fields: vec![
                nwn_gff::Field { label: Rc::new(FromStr::from_str("Categories").unwrap()), value: nwn_gff::FieldValue::List(cat_list_gff) },
            ],
        };
        nwn_gff::GffFile {
            inner: nwn_lib_rs::gff::Gff {
                file_type: FromStr::from_str("JRL ").unwrap(),
                file_version: FromStr::from_str("V3.2").unwrap(),
                root,
            },
        }
    }
}
