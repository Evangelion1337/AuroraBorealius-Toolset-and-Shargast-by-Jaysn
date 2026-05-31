use std::collections::HashMap;
use std::str::FromStr;
use std::rc::Rc;
use crate::Result;

#[derive(Debug, Clone)]
pub struct Faction {
    pub id: i32,
    pub name: String,
    pub reputation: HashMap<i32, i32>,
}

#[derive(Debug, Clone)]
pub struct FactionList {
    pub factions: Vec<Faction>,
}

fn make_field(label: &str, value: nwn_gff::FieldValue) -> nwn_gff::Field {
    let fss: nwn_lib_rs::parsing::FixedSizeString<16> = FromStr::from_str(label).unwrap_or_default();
    nwn_gff::Field { label: Rc::new(fss), value }
}

impl FactionList {
    pub fn from_gff(gff: &nwn_gff::GffFile) -> Result<Self> {
        let mut factions = Vec::new();

        if let Some(nwn_gff::FieldValue::List(faction_list)) = gff.root().find("FactionList") {
            for faction_struct in faction_list.iter() {
                let id = faction_struct.find("FactionID")
                    .and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None })
                    .unwrap_or(0);
                let name = faction_struct.find("FactionName")
                    .and_then(|v| if let nwn_gff::FieldValue::String(s) = v { Some(s.clone()) } else { None })
                    .unwrap_or_default();

                let mut reputation = HashMap::new();
                if let Some(nwn_gff::FieldValue::List(rep_list)) = faction_struct.find("RepList") {
                    for rep_struct in rep_list.iter() {
                        let rep_id = rep_struct.find("FactionID")
                            .and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None })
                            .unwrap_or(0);
                        let rep_value = rep_struct.find("Rep")
                            .and_then(|v| if let nwn_gff::FieldValue::Int(i) = v { Some(*i) } else { None })
                            .unwrap_or(0);
                        reputation.insert(rep_id, rep_value);
                    }
                }

                factions.push(Faction { id, name, reputation });
            }
        }

        Ok(Self { factions })
    }

    pub fn to_gff(&self) -> nwn_gff::GffFile {
        use nwn_gff::FieldValue;

        let faction_structs: Vec<nwn_gff::Struct> = self.factions.iter().map(|f| {
            let rep_structs: Vec<nwn_gff::Struct> = f.reputation.iter().map(|(&rep_id, &rep_value)| {
                nwn_gff::Struct {
                    id: 0,
                    fields: vec![
                        make_field("FactionID", FieldValue::Int(rep_id)),
                        make_field("Rep", FieldValue::Int(rep_value)),
                    ],
                }
            }).collect();

            nwn_gff::Struct {
                id: 0,
                fields: vec![
                    make_field("FactionID", FieldValue::Int(f.id)),
                    make_field("FactionName", FieldValue::String(f.name.clone())),
                    make_field("RepList", FieldValue::List(nwn_gff::list_from_vec(rep_structs))),
                ],
            }
        }).collect();

        let root = nwn_gff::Struct {
            id: u32::MAX,
            fields: vec![
                make_field("FactionList", FieldValue::List(nwn_gff::list_from_vec(faction_structs))),
            ],
        };

        nwn_gff::GffFile {
            inner: nwn_lib_rs::gff::Gff {
                file_type: FromStr::from_str("FAC ").unwrap_or_default(),
                file_version: FromStr::from_str("V3.2").unwrap_or_default(),
                root,
            },
        }
    }
}
