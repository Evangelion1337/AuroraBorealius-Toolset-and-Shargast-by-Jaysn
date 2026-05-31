use crate::Result;

pub struct ItemBp {
    pub resref: String,
    pub tag: String,
    pub name: String,
    pub description: String,
    pub cost: i32,
    pub charges: i32,
}

impl ItemBp {
    pub fn from_gff(gff: &nwn_gff::GffFile) -> Result<Self> {
        Ok(Self {
            resref: gff.get_string("TemplateResRef").unwrap_or_default(),
            tag: gff.get_string("Tag").unwrap_or_default(),
            name: gff.get_string("LocalizedName").unwrap_or_default(),
            description: gff.get_string("Description").unwrap_or_default(),
            cost: gff.get_int("Cost").unwrap_or(0),
            charges: gff.get_int("Charges").unwrap_or(0),
        })
    }
}
