use crate::Result;

pub struct WayPointBp {
    pub tag: String,
    pub map_note: String,
    pub map_note_enabled: bool,
    pub appearance: i32,
}

impl WayPointBp {
    pub fn from_gff(gff: &nwn_gff::GffFile) -> Result<Self> {
        Ok(Self {
            tag: gff.get_string("Tag").unwrap_or_default(),
            map_note: gff.get_string("MapNote").unwrap_or_default(),
            map_note_enabled: gff.get_int("MapNoteEnabled").unwrap_or(0) != 0,
            appearance: gff.get_int("Appearance").unwrap_or(0),
        })
    }
}
