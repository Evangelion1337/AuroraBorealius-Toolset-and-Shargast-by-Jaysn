#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

use std::path::Path;

pub type Result<T> = std::result::Result<T, TlkError>;

#[derive(Debug, thiserror::Error)]
pub enum TlkError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("TLK parse error: {0}")]
    Parse(String),
}

impl From<Box<dyn std::error::Error>> for TlkError {
    fn from(e: Box<dyn std::error::Error>) -> Self {
        TlkError::Parse(e.to_string())
    }
}

pub use nwn_lib_rs::tlk;

pub struct TlkFile {
    pub inner: tlk::Tlk,
}

impl TlkFile {
    pub fn open(path: impl AsRef<Path>) -> Result<Self> {
        let data = std::fs::read(path.as_ref())?;
        Self::from_bytes(&data)
    }

    pub fn from_bytes(data: &[u8]) -> Result<Self> {
        match tlk::Tlk::from_bytes(data, false) {
            Ok((_, inner)) => Ok(Self { inner }),
            Err(e) => Err(TlkError::Parse(match e {
                nom::Err::Error(e) | nom::Err::Failure(e) => e.to_string(),
                nom::Err::Incomplete(_) => "incomplete input".into(),
            })),
        }
    }

    pub fn strref(&self, id: u32) -> Option<&str> {
        self.inner.get_str(id)
    }

    pub fn count(&self) -> usize {
        self.inner.len() as usize
    }

    pub fn get_entry(&self, id: u32) -> Option<&tlk::Entry> {
        self.inner.get_entry(id)
    }

    pub fn get_entry_mut(&mut self, id: u32) -> &mut tlk::Entry {
        self.inner.get_entry_mut(id)
    }

    pub fn set_string(&mut self, id: u32, text: Option<String>) {
        self.inner.set_string(id, text);
    }

    pub fn to_bytes(&self) -> Vec<u8> {
        self.inner.to_bytes()
    }

    pub fn into_owned(self) -> Self {
        Self { inner: self.inner.into_owned() }
    }

    pub fn shrink_to_fit(&mut self) {
        self.inner.shrink_to_fit();
    }

    pub fn resize(&mut self, new_len: u32) {
        self.inner.resize(new_len);
    }
}

pub fn open_tlk(path: impl AsRef<Path>) -> Result<TlkFile> {
    TlkFile::open(path)
}
