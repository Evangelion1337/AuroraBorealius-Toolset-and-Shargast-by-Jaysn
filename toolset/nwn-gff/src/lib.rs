#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

use std::path::Path;

pub type Result<T> = std::result::Result<T, GffError>;

#[derive(Debug, thiserror::Error)]
pub enum GffError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("GFF parse error: {0}")]
    Parse(String),
    #[error("Field not found: {0}")]
    FieldNotFound(String),
    #[error("Type mismatch for field '{field}': expected {expected}, got {actual}")]
    TypeMismatch { field: String, expected: String, actual: String },
    #[error("Serde error: {0}")]
    Serde(#[from] serde_json::Error),
    #[error("{0}")]
    Other(String),
}

impl From<nwn_lib_rs::parsing::NWNParseError> for GffError {
    fn from(e: nwn_lib_rs::parsing::NWNParseError) -> Self {
        GffError::Parse(e.to_string())
    }
}

impl From<Box<dyn std::error::Error>> for GffError {
    fn from(e: Box<dyn std::error::Error>) -> Self {
        GffError::Other(e.to_string())
    }
}

pub use nwn_lib_rs::gff::{
    Gff, Struct, Field, FieldValue, LocString, List,
};

pub struct GffFile {
    pub inner: Gff,
}

impl GffFile {
    pub fn from_bytes(data: &[u8]) -> Result<Self> {
        let prev_hook = std::panic::take_hook();
        std::panic::set_hook(Box::new(|_| {}));
        let result = std::panic::catch_unwind(std::panic::AssertUnwindSafe(|| {
            match Gff::from_bytes(data) {
                Ok((_, inner)) => Ok(Self { inner }),
                Err(e) => Err(match e {
                    nom::Err::Error(e) | nom::Err::Failure(e) => GffError::Parse(e.to_string()),
                    nom::Err::Incomplete(_) => GffError::Parse("incomplete input".into()),
                }),
            }
        }));
        std::panic::set_hook(prev_hook);
        match result {
            Ok(r) => r,
            Err(_) => Err(GffError::Parse("nwn-lib-rs panic during GFF parse".into())),
        }
    }

    pub fn from_path(path: impl AsRef<Path>) -> Result<Self> {
        let data = std::fs::read(path.as_ref())?;
        Self::from_bytes(&data)
    }

    pub fn to_bytes(&self) -> Vec<u8> {
        self.inner.to_bytes()
    }

    pub fn write_to(&self, path: impl AsRef<Path>) -> Result<()> {
        std::fs::write(path, self.to_bytes())?;
        Ok(())
    }

    pub fn root(&self) -> &Struct {
        &self.inner.root
    }

    pub fn root_mut(&mut self) -> &mut Struct {
        &mut self.inner.root
    }

    pub fn to_json_pretty(&self) -> Result<String> {
        Ok(serde_json::to_string_pretty(&self.inner)?)
    }

    pub fn get_string(&self, field: &str) -> Result<String> {
        match self.inner.root.find(field) {
            Some(FieldValue::String(s)) => Ok(s.clone()),
            Some(FieldValue::ResRef(s)) => Ok(s.clone()),
            Some(FieldValue::LocString(ls)) => {
                Ok(ls.strings.first().map(|(_, s)| s.clone()).unwrap_or_default())
            }
            Some(v) => Err(GffError::TypeMismatch {
                field: field.to_string(),
                expected: "String/ResRef".into(),
                actual: v.get_type_str().into(),
            }),
            None => Err(GffError::FieldNotFound(field.to_string())),
        }
    }

    pub fn get_locstring(&self, field: &str) -> Result<(u32, Vec<(i32, String)>)> {
        match self.inner.root.find(field) {
            Some(FieldValue::LocString(ls)) => Ok((ls.strref, ls.strings.clone())),
            Some(v) => Err(GffError::TypeMismatch {
                field: field.to_string(),
                expected: "LocString".into(),
                actual: v.get_type_str().into(),
            }),
            None => Err(GffError::FieldNotFound(field.to_string())),
        }
    }

    pub fn get_int(&self, field: &str) -> Result<i32> {
        match self.inner.root.find(field) {
            Some(FieldValue::Int(i)) => Ok(*i),
            Some(FieldValue::DWord(d)) => Ok(*d as i32),
            Some(FieldValue::Byte(b)) => Ok(*b as i32),
            Some(FieldValue::Short(s)) => Ok(*s as i32),
            Some(FieldValue::Word(w)) => Ok(*w as i32),
            Some(v) => Err(GffError::TypeMismatch {
                field: field.to_string(),
                expected: "int".into(),
                actual: v.get_type_str().into(),
            }),
            None => Err(GffError::FieldNotFound(field.to_string())),
        }
    }

    pub fn get_float(&self, field: &str) -> Result<f32> {
        match self.inner.root.find(field) {
            Some(FieldValue::Float(f)) => Ok(*f),
            Some(FieldValue::Double(f)) => Ok(*f as f32),
            Some(v) => Err(GffError::TypeMismatch {
                field: field.to_string(),
                expected: "float".into(),
                actual: v.get_type_str().into(),
            }),
            None => Err(GffError::FieldNotFound(field.to_string())),
        }
    }
}

pub fn open_gff(path: impl AsRef<Path>) -> Result<GffFile> {
    GffFile::from_path(path)
}

pub fn list_from_vec(items: Vec<Struct>) -> List {
    use std::mem;
    // SAFETY: List is a newtype over Vec<Struct> with repr(transparent)-compatible layout
    unsafe { mem::transmute::<Vec<Struct>, List>(items) }
}
