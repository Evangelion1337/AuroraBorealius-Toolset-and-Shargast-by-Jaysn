#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

use std::path::Path;
use std::io::Read;
use std::collections::HashMap;
use std::str::FromStr;

pub type Result<T> = std::result::Result<T, ErfError>;

#[derive(Debug, thiserror::Error)]
pub enum ErfError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("ERF parse error: {0}")]
    Parse(String),
}

impl From<Box<dyn std::error::Error>> for ErfError {
    fn from(e: Box<dyn std::error::Error>) -> Self {
        ErfError::Parse(e.to_string())
    }
}

pub use nwn_lib_rs::erf;

pub struct ErfResource {
    pub resref: String,
    pub restype: u16,
    pub data: Vec<u8>,
}

pub struct ErfFile {
    pub inner: erf::Erf,
    lookup: HashMap<(String, u16), usize>,
    raw_data: Vec<u8>,
}

/// Returns a byte slice from a resource without cloning when possible.
/// Handles ArchiveOffset (zero-copy from raw_data), Buffer, and File variants.
fn read_resource_slice<'a>(r: &'a erf::Resource, raw_data: &'a [u8]) -> Option<&'a [u8]> {
    match &r.data {
        erf::ResourceData::ArchiveOffset { offset, size } => {
            let start = *offset as usize;
            let end = start + *size as usize;
            raw_data.get(start..end)
        }
        erf::ResourceData::Buffer(buf) => Some(buf.as_slice()),
        erf::ResourceData::File(_) => None,
    }
}

pub fn extract_resource_data(data: &erf::ResourceData) -> Option<Vec<u8>> {
    match data {
        erf::ResourceData::Buffer(buf) => Some(buf.clone()),
        erf::ResourceData::File(path) => std::fs::read(path).ok(),
        _ => None,
    }
}

impl ErfFile {
    pub fn new(file_type: &str, nwn1: bool, description_strref: Option<u32>) -> Self {
        let fss: nwn_lib_rs::parsing::FixedSizeString<4> = FromStr::from_str(file_type).unwrap_or_default();
        let inner = erf::Erf::new(
            fss,
            nwn1,
            chrono::Local::now().date_naive(),
            description_strref,
        );
        Self {
            inner,
            lookup: HashMap::new(),
            raw_data: Vec::new(),
        }
    }

    pub fn add_resource(&mut self, resref: &str, restype: u16, data: Vec<u8>) {
        let name = resref.trim().to_lowercase();
        let fss: nwn_lib_rs::parsing::FixedSizeString<32> = FromStr::from_str(resref.trim()).unwrap_or_default();
        let resource = erf::Resource {
            file_name: fss,
            resource_type: restype,
            data: erf::ResourceData::Buffer(data.clone()),
        };
        let idx = self.inner.resources.len();
        self.inner.resources.push(resource);
        self.lookup.insert((name, restype), idx);
    }

    pub fn open(path: impl AsRef<Path>) -> Result<Self> {
        let mut file = std::fs::File::open(path.as_ref())?;
        let mut raw_data = Vec::new();
        file.read_to_end(&mut raw_data)?;
        let inner = erf::Erf::from_bytes(&raw_data)?;
        let mut lookup = HashMap::new();
        for (i, r) in inner.resources.iter().enumerate() {
            let name = r.file_name.to_string().trim().to_lowercase();
            lookup.insert((name, r.resource_type), i);
        }
        Ok(Self { inner, lookup, raw_data })
    }

    pub fn from_bytes(data: &[u8]) -> Result<Self> {
        let inner = erf::Erf::from_bytes(data)?;
        let mut lookup = HashMap::new();
        for (i, r) in inner.resources.iter().enumerate() {
            let name = r.file_name.to_string().trim().to_lowercase();
            lookup.insert((name, r.resource_type), i);
        }
        Ok(Self { inner, lookup, raw_data: data.to_vec() })
    }

    pub fn to_bytes(&self) -> Result<Vec<u8>> {
        Ok(self.inner.to_bytes()?)
    }

    pub fn write_to(&self, path: impl AsRef<Path>) -> Result<()> {
        let bytes = self.to_bytes()?;
        std::fs::write(path, bytes)?;
        Ok(())
    }

    pub fn resource_count(&self) -> usize {
        self.inner.resources.len()
    }

    pub fn description(&self) -> Option<String> {
        self.inner.description.get(&0).cloned()
    }

    pub fn read_resource_data(&self, r: &erf::Resource) -> Option<Vec<u8>> {
        match &r.data {
            erf::ResourceData::File(path) => std::fs::read(path).ok(),
            erf::ResourceData::Buffer(buf) => Some(buf.clone()),
            erf::ResourceData::ArchiveOffset { offset, size } => {
                let start = *offset as usize;
                let end = start + *size as usize;
                self.raw_data.get(start..end).map(|s| s.to_vec())
            }
        }
    }

    pub fn resources(&self) -> Vec<ErfResource> {
        self.inner.resources.iter().filter_map(|r| {
            self.read_resource_data(r).map(|data| ErfResource {
                resref: r.file_name.to_string(),
                restype: r.resource_type,
                data,
            })
        }).collect()
    }

    pub fn get(&self, resref: &str, restype: u16) -> Option<Vec<u8>> {
        let key = (resref.trim().to_lowercase(), restype);
        let idx = *self.lookup.get(&key)?;
        self.read_resource_data(&self.inner.resources[idx])
    }

    /// Zero-copy access: returns a byte slice without allocating.
    /// Supported for ArchiveOffset and Buffer resources.
    pub fn get_slice(&self, resref: &str, restype: u16) -> Option<&[u8]> {
        let key = (resref.trim().to_lowercase(), restype);
        let idx = *self.lookup.get(&key)?;
        read_resource_slice(&self.inner.resources[idx], &self.raw_data)
    }

    pub fn keys(&self) -> Vec<(String, u16)> {
        self.inner.resources.iter().map(|r| {
            (r.file_name.to_string(), r.resource_type)
        }).collect()
    }
}

pub fn open_erf(path: impl AsRef<Path>) -> Result<ErfFile> {
    ErfFile::open(path)
}
