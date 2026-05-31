use std::str::FromStr;
use std::rc::Rc;
use crate::Result;

pub struct Conversation {
    pub entries: Vec<EntryNode>,
    pub starting_entry: i32,
}

pub struct EntryNode {
    pub text: String,
    pub id: i32,
    pub replies: Vec<ReplyNode>,
}

pub struct ReplyNode {
    pub text: String,
    pub id: i32,
    pub next_entry: Option<i32>,
    pub script: String,
}

fn make_field(label: &str, value: nwn_gff::FieldValue) -> nwn_gff::Field {
    let fss: nwn_lib_rs::parsing::FixedSizeString<16> = FromStr::from_str(label).unwrap_or_default();
    nwn_gff::Field { label: Rc::new(fss), value }
}

impl Conversation {
    pub fn from_gff(gff: &nwn_gff::GffFile) -> Result<Self> {
        let mut entries = Vec::new();

        if let Some(nwn_gff::FieldValue::List(entry_list)) = gff.root().find("EntryList") {
            for entry_struct in entry_list.iter() {
                let text = entry_struct.find("Text")
                    .and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None })
                    .unwrap_or_default();
                let id = entry_struct.find("ID")
                    .and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None })
                    .unwrap_or(0);

                let mut replies = Vec::new();
                if let Some(nwn_gff::FieldValue::List(reply_list)) = entry_struct.find("RepliesList") {
                    for reply_struct in reply_list.iter() {
                        let reply_text = reply_struct.find("Text")
                            .and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None })
                            .unwrap_or_default();
                        let reply_id = reply_struct.find("ID")
                            .and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None })
                            .unwrap_or(0);
                        let next_entry = reply_struct.find("NextEntry")
                            .and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None });
                        let script = reply_struct.find("Script")
                            .and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None })
                            .unwrap_or_default();

                        replies.push(ReplyNode {
                            text: reply_text,
                            id: reply_id,
                            next_entry,
                            script,
                        });
                    }
                }
                entries.push(EntryNode { text, id, replies });
            }
        }

        let starting_entry = gff.get_int("StartingEntry").unwrap_or(0);

        Ok(Self { entries, starting_entry })
    }

    pub fn to_gff(&self) -> nwn_gff::GffFile {
        use nwn_gff::FieldValue;

        let entry_structs: Vec<nwn_gff::Struct> = self.entries.iter().map(|entry| {
            let reply_structs: Vec<nwn_gff::Struct> = entry.replies.iter().map(|reply| {
                let mut fields = vec![
                    make_field("Text", FieldValue::String(reply.text.clone())),
                    make_field("ID", FieldValue::Int(reply.id)),
                    make_field("Script", FieldValue::String(reply.script.clone())),
                ];
                if let Some(next) = reply.next_entry {
                    fields.push(make_field("NextEntry", FieldValue::Int(next)));
                }
                nwn_gff::Struct { id: 0, fields }
            }).collect();

            nwn_gff::Struct {
                id: 0,
                fields: vec![
                    make_field("Text", FieldValue::String(entry.text.clone())),
                    make_field("ID", FieldValue::Int(entry.id)),
                    make_field("RepliesList", FieldValue::List(nwn_gff::list_from_vec(reply_structs))),
                ],
            }
        }).collect();

        let root = nwn_gff::Struct {
            id: u32::MAX,
            fields: vec![
                make_field("EntryList", FieldValue::List(nwn_gff::list_from_vec(entry_structs))),
                make_field("StartingEntry", FieldValue::Int(self.starting_entry)),
            ],
        };

        nwn_gff::GffFile {
            inner: nwn_lib_rs::gff::Gff {
                file_type: FromStr::from_str("DLG ").unwrap_or_default(),
                file_version: FromStr::from_str("V3.2").unwrap_or_default(),
                root,
            },
        }
    }
}
