pub mod lexer;
pub mod parser;
pub mod ast;
pub mod codegen;

pub use lexer::*;
pub use parser::*;
pub use ast::*;
pub use codegen::*;

pub type Result<T> = std::result::Result<T, ScriptError>;

#[derive(Debug, thiserror::Error)]
pub enum ScriptError {
    #[error("Lexer error at {line}:{col}: {msg}")]
    Lexer { line: usize, col: usize, msg: String },
    #[error("Parser error at {line}:{col}: {msg}")]
    Parser { line: usize, col: usize, msg: String },
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
    #[error("Include error: {0}")]
    Include(String),
}

/// Expand `#include "..."` directives in NWScript source text.
///
/// Searches for includes in `include_dirs` (in order). Tracks already-seen
/// filenames to detect circular includes. Returns the expanded source text.
pub fn preprocess(source: &str, source_path: Option<&str>, include_dirs: &[String]) -> std::result::Result<String, ScriptError> {
    let mut seen = std::collections::HashSet::new();
    let mut result = String::new();
    preprocess_inner(source, source_path, include_dirs, &mut seen, &mut result)?;
    Ok(result)
}

fn preprocess_inner(
    source: &str,
    source_path: Option<&str>,
    include_dirs: &[String],
    seen: &mut std::collections::HashSet<String>,
    out: &mut String,
) -> std::result::Result<(), ScriptError> {
    for line in source.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("#include") {
            let rest = trimmed["#include".len()..].trim();
            if let Some(filename) = rest.strip_prefix('"').and_then(|s| s.strip_suffix('"')) {
                let filename = filename.trim();
                if !seen.insert(filename.to_string()) {
                    return Err(ScriptError::Include(format!("circular include: {}", filename)));
                }
                let content = resolve_include(filename, source_path, include_dirs)?;
                preprocess_inner(&content, Some(filename), include_dirs, seen, out)?;
                // Append newline to separate included content from next line
                out.push('\n');
                continue;
            }
        }
        out.push_str(line);
        out.push('\n');
    }
    Ok(())
}

fn resolve_include(filename: &str, source_path: Option<&str>, include_dirs: &[String]) -> std::result::Result<String, ScriptError> {
    // Try relative to including file's directory
    if let Some(sp) = source_path {
        if let Some(parent) = std::path::Path::new(sp).parent() {
            let candidate = parent.join(filename);
            if candidate.exists() {
                return std::fs::read_to_string(&candidate).map_err(ScriptError::from);
            }
        }
    }
    // Try each include dir
    for dir in include_dirs {
        let candidate = std::path::Path::new(dir).join(filename);
        if candidate.exists() {
            return std::fs::read_to_string(&candidate).map_err(ScriptError::from);
        }
    }
    Err(ScriptError::Include(format!("include file not found: {}", filename)))
}
