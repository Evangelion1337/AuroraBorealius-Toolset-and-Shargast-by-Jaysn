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

fn saved_ifo(module: &mut Module) -> Vec<u8> {
    let unique = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH).unwrap().as_nanos();
    let path = std::env::temp_dir().join(format!(
        "aurora-ifo-{}-{unique}.mod", std::process::id()
    ));
    module.save_to(&path).expect("Save synthetic module");
    let result = ErfFile::open(&path).unwrap().get("module", resource_types::IFO).unwrap();
    std::fs::remove_file(path).unwrap();
    result
}

fn with_archived_ifo(module: &mut Module) -> Vec<u8> {
    let bytes = module.ifo.to_bytes();
    let mut original = ErfFile::new("MOD ", true, None);
    original.add_resource("module", resource_types::IFO, bytes.clone());
    module.erf = Some(ErfFile::from_bytes(&original.to_bytes().unwrap()).unwrap());
    bytes
}

#[test]
fn unchanged_ifo_is_preserved_byte_for_byte() {
    let mut module = Module::new("Original metadata");
    let expected = with_archived_ifo(&mut module);
    assert_eq!(saved_ifo(&mut module), expected);
    assert!(module.ifo.root().find("Mod_OnPlayerEnter").is_none());
}

#[test]
fn localized_name_edit_preserves_other_languages_and_strref() {
    let mut module = Module::new("Original English");
    *module.ifo.root_mut().find_mut("Mod_Name").unwrap() =
        nwn_gff::FieldValue::LocString(nwn_lib_rs::gff::LocString {
            strref: 123,
            strings: vec![(0, "Original English".to_owned()), (2, "Autre nom".to_owned())],
        });
    with_archived_ifo(&mut module);
    module.name = "Changed English".to_owned();
    let saved = nwn_gff::GffFile::from_bytes(&saved_ifo(&mut module)).unwrap();
    let (strref, strings) = saved.get_locstring("Mod_Name").unwrap();
    assert_eq!(strref, 123);
    assert_eq!(strings, vec![(0, "Changed English".to_owned()), (2, "Autre nom".to_owned())]);
}

#[test]
fn localized_name_edit_adds_missing_english_without_removing_translation() {
    let mut module = Module::new("Autre nom");
    *module.ifo.root_mut().find_mut("Mod_Name").unwrap() =
        nwn_gff::FieldValue::LocString(nwn_lib_rs::gff::LocString {
            strref: u32::MAX,
            strings: vec![(2, "Autre nom".to_owned())],
        });
    with_archived_ifo(&mut module);
    module.name = "Added English".to_owned();
    let saved = nwn_gff::GffFile::from_bytes(&saved_ifo(&mut module)).unwrap();
    let (_, strings) = saved.get_locstring("Mod_Name").unwrap();
    assert_eq!(strings, vec![(2, "Autre nom".to_owned()), (0, "Added English".to_owned())]);
}
