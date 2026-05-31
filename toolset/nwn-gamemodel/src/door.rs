use crate::Result;

pub struct DoorBp {
    pub resref: String,
    pub tag: String,
    pub name: String,
    pub generic_type: i32,
    pub has_inventory: bool,
    pub lockable: bool,
    pub locked: bool,
}

impl DoorBp {
    pub fn from_gff(gff: &nwn_gff::GffFile) -> Result<Self> {
        Ok(Self {
            resref: gff.get_string("TemplateResRef").unwrap_or_default(),
            tag: gff.get_string("Tag").unwrap_or_default(),
            name: gff.get_string("LocalizedName").unwrap_or_default(),
            generic_type: gff.get_int("GenericType").unwrap_or(0),
            has_inventory: gff.get_int("HasInventory").unwrap_or(0) != 0,
            lockable: gff.get_int("Lockable").unwrap_or(0) != 0,
            locked: gff.get_int("Locked").unwrap_or(0) != 0,
        })
    }
}
