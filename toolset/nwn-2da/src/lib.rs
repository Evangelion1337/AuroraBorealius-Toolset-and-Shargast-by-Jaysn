#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

use std::path::Path;

pub type Result<T> = std::result::Result<T, TwoDaError>;

#[derive(Debug, thiserror::Error)]
pub enum TwoDaError {
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("2DA parse error: {0}")]
    Parse(String),
}

impl From<Box<dyn std::error::Error>> for TwoDaError {
    fn from(e: Box<dyn std::error::Error>) -> Self {
        TwoDaError::Parse(e.to_string())
    }
}

#[derive(Clone)]
pub struct TwoDa {
    pub inner: nwn_lib_rs::twoda::TwoDA,
}

impl TwoDa {
    pub fn open(path: impl AsRef<Path>) -> Result<Self> {
        let data = std::fs::read_to_string(path.as_ref())?;
        Self::from_string(&data)
    }

    pub fn from_string(data: &str) -> Result<Self> {
        match nwn_lib_rs::twoda::TwoDA::from_str(data, false) {
            Ok((_, inner)) => Ok(Self { inner }),
            Err(e) => Err(TwoDaError::Parse(e.to_string())),
        }
    }

    pub fn columns(&self) -> &[String] {
        self.inner.get_columns()
    }

    pub fn row_count(&self) -> usize {
        self.inner.len_rows()
    }

    pub fn col_count(&self) -> usize {
        self.inner.len_cols()
    }

    pub fn get_cell(&self, row: usize, col: usize) -> Option<&str> {
        self.inner.get_row(row)
            .and_then(|r| r.get(col))
            .and_then(|v| v.as_deref())
    }

    pub fn get_cell_by_label(&self, row: usize, label: &str) -> Option<&str> {
        let val = self.inner.get_row_label(row, label);
        val.as_deref()
    }

    pub fn column(&self, header: &str) -> Option<Vec<&str>> {
        let col_idx = self.columns().iter().position(|h| h == header)?;
        let mut results = Vec::new();
        for row in 0..self.row_count() {
            if let Some(val) = self.get_cell(row, col_idx) {
                results.push(val);
            } else {
                results.push("");
            }
        }
        Some(results)
    }

    pub fn set_cell(&mut self, row: usize, col: usize, value: String) -> Result<()> {
        if let Some(row_data) = self.inner.get_row_mut(row) {
            if col < row_data.len() {
                row_data[col] = Some(value);
                Ok(())
            } else {
                Err(TwoDaError::Parse(format!("column index {} out of bounds", col)))
            }
        } else {
            Err(TwoDaError::Parse(format!("row index {} out of bounds", row)))
        }
    }

    pub fn add_row(&mut self) -> usize {
        let row = self.row_count();
        self.inner.resize_rows(row + 1);
        row
    }

    pub fn to_2da_string(&self) -> String {
        self.inner.to_string(false)
    }

    pub fn save_to(&self, path: impl AsRef<Path>) -> Result<()> {
        std::fs::write(path.as_ref(), self.to_2da_string())?;
        Ok(())
    }
}

pub fn open_2da(path: impl AsRef<Path>) -> Result<TwoDa> {
    TwoDa::open(path)
}
