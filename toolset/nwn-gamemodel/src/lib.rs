#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

pub mod module;
pub mod area;
pub mod creature;
pub mod item;
pub mod door;
pub mod placeable;
pub mod trigger;
pub mod waypoint;
pub mod encounter;
pub mod sound_emitter;
pub mod light;
pub mod conversation;
pub mod faction;
pub mod resource_manager;
pub mod game_data;
pub mod property;
pub mod journal;

pub use module::*;
pub use area::*;
pub use creature::*;
pub use item::*;
pub use door::*;
pub use placeable::*;
pub use trigger::*;
pub use waypoint::*;
pub use encounter::*;
pub use sound_emitter::*;
pub use light::*;
pub use conversation::*;
pub use faction::*;
pub use journal::*;
pub use resource_manager::*;
pub use property::*;

pub type Result<T> = std::result::Result<T, ModelError>;

#[derive(Debug, thiserror::Error)]
pub enum ModelError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Format error: {0}")]
    Format(String),
    #[error("Not found: {0}")]
    NotFound(String),
    #[error("Parse error: {0}")]
    Parse(String),
    #[error("Missing required hak files: {0:?}")]
    MissingHaks(Vec<String>),
}

impl From<nwn_gff::GffError> for ModelError {
    fn from(e: nwn_gff::GffError) -> Self {
        ModelError::Parse(e.to_string())
    }
}

impl From<nwn_erf::ErfError> for ModelError {
    fn from(e: nwn_erf::ErfError) -> Self {
        ModelError::Format(e.to_string())
    }
}

impl From<nwn_tlk::TlkError> for ModelError {
    fn from(e: nwn_tlk::TlkError) -> Self {
        ModelError::Format(e.to_string())
    }
}

impl From<nwn_2da::TwoDaError> for ModelError {
    fn from(e: nwn_2da::TwoDaError) -> Self {
        ModelError::Format(e.to_string())
    }
}

pub trait NwnObject: std::fmt::Debug {
    fn object_type() -> &'static str;
    fn gff_struct_id() -> u32;
    fn load_from_gff(gff: &nwn_gff::GffFile) -> Result<Self> where Self: Sized;
    fn save_to_gff(&self) -> Result<nwn_gff::GffFile>;
}

pub mod resource_types {
    pub fn ext_to_type(ext: &str) -> Option<u16> {
        let rt = nwn_lib_rs::erf::ResourceType::from(ext);
        if rt == nwn_lib_rs::erf::ResourceType::Invalid {
            None
        } else {
            Some(rt as u16)
        }
    }

    pub fn type_to_ext(restype: u16) -> Option<&'static str> {
        let ext = nwn_lib_rs::erf::ResourceType::from(restype).ext();
        if ext.is_empty() { None } else { Some(ext) }
    }

    pub const ARE: u16 = nwn_lib_rs::erf::ResourceType::Are as u16;
    pub const GIT: u16 = nwn_lib_rs::erf::ResourceType::Git as u16;
    pub const GIC: u16 = nwn_lib_rs::erf::ResourceType::Gic as u16;
    pub const IFO: u16 = nwn_lib_rs::erf::ResourceType::Ifo as u16;
    pub const BIC: u16 = nwn_lib_rs::erf::ResourceType::Bic as u16;
    pub const UTC: u16 = nwn_lib_rs::erf::ResourceType::Utc as u16;
    pub const DLG: u16 = nwn_lib_rs::erf::ResourceType::Dlg as u16;
    pub const ITP: u16 = nwn_lib_rs::erf::ResourceType::Itp as u16;
    pub const UTT: u16 = nwn_lib_rs::erf::ResourceType::Utt as u16;
    pub const DDS: u16 = nwn_lib_rs::erf::ResourceType::Dds as u16;
    pub const UTS: u16 = nwn_lib_rs::erf::ResourceType::Uts as u16;
    pub const LTR: u16 = nwn_lib_rs::erf::ResourceType::Ltr as u16;
    pub const GFF: u16 = nwn_lib_rs::erf::ResourceType::Gff as u16;
    pub const FAC: u16 = nwn_lib_rs::erf::ResourceType::Fac as u16;
    pub const UTE: u16 = nwn_lib_rs::erf::ResourceType::Ute as u16;
    pub const UTD: u16 = nwn_lib_rs::erf::ResourceType::Utd as u16;
    pub const UTP: u16 = nwn_lib_rs::erf::ResourceType::Utp as u16;
    pub const TGA: u16 = nwn_lib_rs::erf::ResourceType::Tga as u16;
    pub const WAV: u16 = nwn_lib_rs::erf::ResourceType::Wav as u16;
    pub const BMU: u16 = nwn_lib_rs::erf::ResourceType::Bmu as u16;
    pub const PLT: u16 = nwn_lib_rs::erf::ResourceType::Plt as u16;
    pub const INI: u16 = nwn_lib_rs::erf::ResourceType::Ini as u16;
    pub const BMP: u16 = nwn_lib_rs::erf::ResourceType::Bmp as u16;
    pub const TXI: u16 = nwn_lib_rs::erf::ResourceType::Txi as u16;
    pub const NSS: u16 = nwn_lib_rs::erf::ResourceType::Nss as u16;
    pub const NCS: u16 = nwn_lib_rs::erf::ResourceType::Ncs as u16;
    pub const SET: u16 = nwn_lib_rs::erf::ResourceType::Set as u16;
    pub const TLK: u16 = nwn_lib_rs::erf::ResourceType::Tlk as u16;
    pub const TWO_DA: u16 = nwn_lib_rs::erf::ResourceType::Twoda as u16;
    pub const TXT: u16 = nwn_lib_rs::erf::ResourceType::Txt as u16;
    pub const MDL: u16 = nwn_lib_rs::erf::ResourceType::Mdl as u16;
    pub const PTM: u16 = nwn_lib_rs::erf::ResourceType::Ptm as u16;
    pub const PTT: u16 = nwn_lib_rs::erf::ResourceType::Ptt as u16;
    pub const BAK: u16 = nwn_lib_rs::erf::ResourceType::Bak as u16;
    pub const UTM: u16 = nwn_lib_rs::erf::ResourceType::Utm as u16;
    pub const MDB: u16 = nwn_lib_rs::erf::ResourceType::Mdb as u16;
    pub const GUI: u16 = nwn_lib_rs::erf::ResourceType::Gui as u16;
    pub const PLH: u16 = nwn_lib_rs::erf::ResourceType::Plh as u16;
    pub const PFB: u16 = nwn_lib_rs::erf::ResourceType::Pfb as u16;
    pub const JRL: u16 = nwn_lib_rs::erf::ResourceType::Jrl as u16;
    pub const UTW: u16 = nwn_lib_rs::erf::ResourceType::Utw as u16;
    pub const SSF: u16 = nwn_lib_rs::erf::ResourceType::Ssf as u16;
    pub const PWC: u16 = nwn_lib_rs::erf::ResourceType::Pwc as u16;
    pub const SAV: u16 = nwn_lib_rs::erf::ResourceType::Sav as u16;
    pub const UTI: u16 = nwn_lib_rs::erf::ResourceType::Uti as u16;
    pub const WOK: u16 = nwn_lib_rs::erf::ResourceType::Wok as u16;
    pub const MOD: u16 = nwn_lib_rs::erf::ResourceType::Mod as u16;
    pub const HAK: u16 = nwn_lib_rs::erf::ResourceType::Hak as u16;
    pub const ARE_EXT: u16 = 0xFFFF;
    pub const IFO_EXT: u16 = 0xFFFF;
    pub const BIC_EXT: u16 = 0xFFFF;
    pub const UTC_EXT: u16 = 0xFFFF;
    pub const DLG_EXT: u16 = 0xFFFF;
    pub const DLG_EXT2: u16 = 0xFFFF;
    pub const UTE_EXT: u16 = 0xFFFF;
    pub const UTD_EXT: u16 = 0xFFFF;
    pub const UTP_EXT: u16 = 0xFFFF;
    pub const FAC_EXT: u16 = 0xFFFF;
    pub const UTI_EXT: u16 = 0xFFFF;
    pub const UTS_EXT: u16 = 0xFFFF;
    pub const UTT_EXT: u16 = 0xFFFF;
    pub const GIT_EXT: u16 = 0xFFFF;
    pub const PTM_EXT: u16 = 0xFFFF;
    pub const PTT_EXT: u16 = 0xFFFF;
    pub const NWSYNC_MANIFEST: u16 = 0xFFFF;
    pub const NWSYNC_ARCHIVE: u16 = 0xFFFF;
    pub const FTS: u16 = 0xFFFF;
    pub const WBM: u16 = 0xFFFF;
    pub const TRG: u16 = 0xFFFF;
    pub const UTL: u16 = 0xFFFF;
    pub const MOD_EXT: u16 = 0xFFFF;
    pub const THG: u16 = 0xFFFF;
    pub const MTR: u16 = 0xFFFF;
    pub const DAT: u16 = 0xFFFF;
    pub const NDM: u16 = 0xFFFF;
    pub const NCM: u16 = 0xFFFF;
    pub const NPM: u16 = 0xFFFF;
}
