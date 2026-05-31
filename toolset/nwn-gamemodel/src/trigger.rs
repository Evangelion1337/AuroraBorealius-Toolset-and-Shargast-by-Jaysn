use crate::Result;

pub struct TriggerBp {
    pub resref: String,
    pub tag: String,
    pub trap_detectable: bool,
    pub trap_detected: bool,
    pub trap_disarmable: bool,
    pub trap_recoverable: bool,
}

impl TriggerBp {
    pub fn from_gff(gff: &nwn_gff::GffFile) -> Result<Self> {
        Ok(Self {
            resref: gff.get_string("TemplateResRef").unwrap_or_default(),
            tag: gff.get_string("Tag").unwrap_or_default(),
            trap_detectable: gff.get_int("TrapDetectable").unwrap_or(0) != 0,
            trap_detected: gff.get_int("TrapDetected").unwrap_or(0) != 0,
            trap_disarmable: gff.get_int("TrapDisarmable").unwrap_or(0) != 0,
            trap_recoverable: gff.get_int("TrapRecoverable").unwrap_or(0) != 0,
        })
    }
}
