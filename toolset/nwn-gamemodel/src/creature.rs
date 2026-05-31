use crate::Result;

pub struct CreatureBp {
    pub resref: String,
    pub tag: String,
    pub first_name: String,
    pub last_name: String,
    pub challenge_rating: f32,
    pub race: String,
    pub gender: i32,
    pub faction_id: i32,
    pub hit_points: i32,
}

impl CreatureBp {
    pub fn from_gff(gff: &nwn_gff::GffFile) -> Result<Self> {
        Ok(Self {
            resref: gff.get_string("TemplateResRef").unwrap_or_default(),
            tag: gff.get_string("Tag").unwrap_or_default(),
            first_name: gff.get_string("FirstName").unwrap_or_default(),
            last_name: gff.get_string("LastName").unwrap_or_default(),
            challenge_rating: gff.get_float("CR").unwrap_or(0.0),
            race: String::new(),
            gender: gff.get_int("Gender").unwrap_or(0),
            faction_id: gff.get_int("FactionID").unwrap_or(0),
            hit_points: gff.get_int("HitPoints").unwrap_or(0),
        })
    }
}
