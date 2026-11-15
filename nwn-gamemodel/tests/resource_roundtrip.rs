#![allow(incomplete_features)]
#![feature(generic_const_exprs)]

use nwn_erf::ErfFile;
use nwn_gamemodel::module::Module;
use nwn_gamemodel::resource_types;
use std::collections::BTreeMap;

fn inventory(erf: &ErfFile) -> BTreeMap<(String, u16), Vec<u8>> {
    erf.inner.resources.iter().map(|r| {
        let name = r.file_name.to_string().trim().to_lowercase();
        let data = erf.read_resource_data(r)
            .expect("Resource must be readable");
        ((name, r.resource_type), data)
    }).collect()
}

#[test]
fn archive_backed_resources_survive_module_save() {
    let mut original = ErfFile::new("MOD ", true, None);
    original.add_resource("testscript", resource_types::NCS, vec![1, 2, 3, 4]);
    original.add_resource("testgit", resource_types::GIT, vec![5, 6, 7]);
    original.add_resource("custom", 65000, vec![0, 255, 42, 99]);

    // Deserialize to exercise the archive-backed resource path.
    let source = ErfFile::from_bytes(
        &original.to_bytes().expect("Serialize source ERF")
    ).expect("Deserialize source ERF");

    let expected = inventory(&source);
    let mut module = Module::new("Resource preservation test");
    module.erf = Some(source);

    let unique = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    let path = std::env::temp_dir().join(format!(
        "aurora-roundtrip-{}-{unique}.mod",
        std::process::id()
    ));

    module.save_to(&path).expect("Save module");
    let saved = ErfFile::open(&path).expect("Reopen saved module");
    let actual = inventory(&saved);

    let _ = std::fs::remove_file(&path);

    // Module IFO is intentionally created during saving.
    for (key, bytes) in &expected {
        assert_eq!(
            actual.get(key), Some(bytes),
            "Original resource lost or changed: {:?}", key
        );
    }
}

#[test]
fn newly_compiled_script_replaces_original() {
    let mut original = ErfFile::new("MOD ", true, None);
    original.add_resource("testscript", resource_types::NCS, vec![1, 2, 3]);

    let source = ErfFile::from_bytes(
        &original.to_bytes().unwrap()
    ).unwrap();

    let mut module = Module::new("Compiled script test");
    module.erf = Some(source);
    module.compiled.insert("testscript".into(), vec![9, 8, 7]);

    let unique = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap()
        .as_nanos();
    let path = std::env::temp_dir().join(format!(
        "aurora-compiled-{}-{unique}.mod",
        std::process::id()
    ));

    module.save_to(&path).expect("Save compiled script");
    let saved = ErfFile::open(&path).expect("Reopen compiled script");
    let data = saved.get("testscript", resource_types::NCS);

    let _ = std::fs::remove_file(&path);

    assert_eq!(data, Some(vec![9, 8, 7]));
    assert_eq!(
        saved.keys().iter().filter(|(name, kind)|
            name.trim().eq_ignore_ascii_case("testscript")
                && *kind == resource_types::NCS
        ).count(),
        1,
        "Compiled script must appear exactly once"
    );
}

#[test]
fn missing_area_does_not_truncate_existing_destination() {
    let mut module = Module::new("Missing area test");
    module.area_names_list.push("missing".to_owned());
    let unique = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos();
    let path = std::env::temp_dir().join(format!(
        "aurora-preserve-destination-{}-{unique}.mod", std::process::id()
    ));
    let original = b"Existing destination must survive validation failure";
    std::fs::write(&path, original).unwrap();
    let result = module.save_to(&path);
    let actual = std::fs::read(&path).unwrap();
    std::fs::remove_file(&path).unwrap();
    assert!(result.is_err(), "Missing ARE data must fail explicitly");
    assert_eq!(actual, original);
}
