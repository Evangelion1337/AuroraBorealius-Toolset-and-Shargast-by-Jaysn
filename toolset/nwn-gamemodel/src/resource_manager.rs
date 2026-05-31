use std::collections::HashMap;
use std::path::Path;
use crate::Result;

pub struct ResourceManager {
    pub tlks: Vec<nwn_tlk::TlkFile>,
    pub two_das: HashMap<String, nwn_2da::TwoDa>,
}

impl ResourceManager {
    pub fn new() -> Self {
        Self {
            tlks: Vec::new(),
            two_das: HashMap::new(),
        }
    }

    pub fn load_tlk(&mut self, path: impl AsRef<Path>) -> Result<()> {
        let tlk = nwn_tlk::TlkFile::open(path)?;
        self.tlks.push(tlk);
        Ok(())
    }

    pub fn load_2da(&mut self, name: &str, data: &str) -> Result<()> {
        let two_da = nwn_2da::TwoDa::from_string(data)?;
        self.two_das.insert(name.to_lowercase(), two_da);
        Ok(())
    }

    pub fn resolve_string(&self, strref: u32) -> Option<String> {
        for tlk in &self.tlks {
            if let Some(s) = tlk.strref(strref) {
                return Some(s.to_string());
            }
        }
        None
    }

    pub fn get_2da(&self, name: &str) -> Option<&nwn_2da::TwoDa> {
        self.two_das.get(&name.to_lowercase())
    }

    pub fn resolve_2da_string(&self, two_da_name: &str, row: u32, column: &str) -> Option<String> {
        let two_da = self.get_2da(two_da_name)?;
        let col_vals = two_da.column(column)?;
        col_vals.get(row as usize).map(|s| s.to_string())
    }
}

impl Default for ResourceManager {
    fn default() -> Self {
        Self::new()
    }
}
