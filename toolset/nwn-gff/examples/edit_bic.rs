#![feature(generic_const_exprs)]
#![allow(incomplete_features)]

use std::rc::Rc;
use nwn_lib_rs::parsing::FixedSizeString;

fn fss(label: &str) -> Rc<FixedSizeString<16>> {
    Rc::new(FixedSizeString::from_str(label).unwrap())
}

fn make_field(label: &str, value: nwn_gff::FieldValue) -> nwn_gff::Field {
    nwn_gff::Field { label: fss(label), value }
}

fn set_or_add(gff: &mut nwn_gff::Struct, label: &str, value: nwn_gff::FieldValue) {
    if let Some(existing) = gff.find_mut(label) {
        *existing = value;
    } else {
        gff.fields.push(make_field(label, value));
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 3 {
        eprintln!("Usage: edit_bic <input.bic> <output.bic>");
        return;
    }

    let mut gff = nwn_gff::GffFile::from_path(&args[1]).unwrap();
    let root = gff.root_mut();

    // Rename
    set_or_add(root, "FirstName", nwn_gff::FieldValue::LocString(nwn_gff::LocString {
        strref: u32::MAX,
        strings: vec![(0, "Aurora".to_string())],
    }));
    set_or_add(root, "LastName", nwn_gff::FieldValue::LocString(nwn_gff::LocString {
        strref: u32::MAX,
        strings: vec![(0, "Borealius".to_string())],
    }));
    set_or_add(root, "Tag", nwn_gff::FieldValue::String("Aurora_Borealius".to_string()));

    // Starting Package = Paladin (5)
    set_or_add(root, "StartingPackage", nwn_gff::FieldValue::Byte(5));

    // Max Stats
    set_or_add(root, "Str", nwn_gff::FieldValue::Byte(255));
    set_or_add(root, "Dex", nwn_gff::FieldValue::Byte(255));
    set_or_add(root, "Con", nwn_gff::FieldValue::Byte(255));
    set_or_add(root, "Int", nwn_gff::FieldValue::Byte(255));
    set_or_add(root, "Wis", nwn_gff::FieldValue::Byte(255));
    set_or_add(root, "Cha", nwn_gff::FieldValue::Byte(255));

    // HP
    set_or_add(root, "HitPoints", nwn_gff::FieldValue::Short(2000));
    set_or_add(root, "CurrentHitPoints", nwn_gff::FieldValue::Short(2000));
    set_or_add(root, "MaxHitPoints", nwn_gff::FieldValue::Short(2000));
    set_or_add(root, "PregameCurrent", nwn_gff::FieldValue::Short(2000));

    // XP, Gold
    set_or_add(root, "Experience", nwn_gff::FieldValue::DWord(99999999));
    set_or_add(root, "Gold", nwn_gff::FieldValue::DWord(99999));

    // BAB (paladin = full BAB)
    set_or_add(root, "BaseAttackBonus", nwn_gff::FieldValue::Short(40));

    // Saves
    set_or_add(root, "FortSaveThrow", nwn_gff::FieldValue::Short(255));
    set_or_add(root, "RefSaveThrow", nwn_gff::FieldValue::Short(255));
    set_or_add(root, "WillSaveThrow", nwn_gff::FieldValue::Short(255));

    // AC
    set_or_add(root, "ArmorClass", nwn_gff::FieldValue::Short(200));

    // Modify ClassList - find and update the first class entry to Paladin 40
    if let Some(nwn_gff::FieldValue::List(class_list)) = root.find_mut("ClassList") {
        if let Some(first_class) = class_list.get_mut(0) {
            // Change class to Paladin (5) and level to 40
            set_or_add(first_class, "Class", nwn_gff::FieldValue::Int(5));
            set_or_add(first_class, "ClassLevel", nwn_gff::FieldValue::Short(40));
            // Remove wizard spell lists
            first_class.fields.retain(|f| {
                let label: &str = f.label.as_str();
                !label.starts_with("KnownList") && !label.starts_with("SpellList") && !label.starts_with("MemorizedList")
            });
        }
    }

    // Update LvlStatList entries
    if let Some(nwn_gff::FieldValue::List(lvl_list)) = root.find_mut("LvlStatList") {
        for entry in lvl_list.iter_mut() {
            set_or_add(entry, "LvlStatClass", nwn_gff::FieldValue::Byte(5));
            set_or_add(entry, "LvlStatHP", nwn_gff::FieldValue::Byte(10));
            set_or_add(entry, "LvlStatHitDie", nwn_gff::FieldValue::Byte(10));
            // Remove wizard spell data from level entries
            entry.fields.retain(|f| {
                let label: &str = f.label.as_str();
                !label.starts_with("KnownList")
                    && !label.starts_with("SpellList")
                    && !label.starts_with("MemorizedList")
            });
        }
    }

    // Save
    gff.write_to(&args[2]).unwrap();
    println!("Written {} ({} bytes)", args[2], std::fs::metadata(&args[2]).unwrap().len());
}
