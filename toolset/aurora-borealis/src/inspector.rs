use eframe::egui;
use nwn_gamemodel::{PropertyBag, PropertyValue, display_value, value_type_name};

#[derive(Debug, Clone)]
pub struct SelectedObject {
    pub title: String,
    pub bag: PropertyBag,
}

pub fn show_inspector(ui: &mut egui::Ui, obj: &mut SelectedObject, resrefs: &[String], tags: &[String]) -> bool {
    let mut modified = false;
    egui::ScrollArea::vertical().show(ui, |ui| {
        ui.heading(&obj.title);
        ui.separator();
        let indices: Vec<usize> = (0..obj.bag.properties.len()).collect();
        for i in indices {
            let prop = &obj.bag.properties[i];
            let type_name = value_type_name(prop.field_type);
            let label = prop.label.clone();
            let value = prop.value.clone();
            ui.horizontal(|ui| {
                ui.label(&label);
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    ui.colored_label(egui::Color32::GRAY, type_name);
                });
            });
            match value {
                PropertyValue::Struct(inner) => {
                    let disp = format!("{{ {} fields }}", inner.properties.len());
                    egui::CollapsingHeader::new(&disp)
                        .default_open(false)
                        .show(ui, |ui| {
                            let mut inner_obj = SelectedObject {
                                title: label,
                                bag: *inner,
                            };
                            modified |= show_inspector(ui, &mut inner_obj, resrefs, tags);
                        });
                }
                PropertyValue::List(items) => {
                    let disp = format!("[{} items]", items.len());
                    egui::CollapsingHeader::new(&disp)
                        .default_open(false)
                        .show(ui, |ui| {
                            for (j, item) in items.iter().enumerate() {
                                let mut item_obj = SelectedObject {
                                    title: format!("[{}]", j),
                                    bag: *item.clone(),
                                };
                                egui::CollapsingHeader::new(format!("#{}", j))
                                    .default_open(false)
                                    .show(ui, |ui| {
                                        modified |= show_inspector(ui, &mut item_obj, resrefs, tags);
                                    });
                            }
                        });
                }
                PropertyValue::CExoString(mut s) => {
                    let mut changed = false;
                    if label == "Tag" {
                        let id = ui.id().with(&label);
                        egui::ComboBox::from_id_salt(id)
                            .selected_text(&s)
                            .show_ui(ui, |ui| {
                                for t in tags {
                                    let selected = *t == s;
                                    if ui.selectable_label(selected, t).clicked() {
                                        s = t.clone();
                                        changed = true;
                                    }
                                }
                                if ui.selectable_label(false, "✏ Type manually...").clicked() {
                                }
                            });
                    } else {
                        if ui.text_edit_singleline(&mut s).changed() {
                            changed = true;
                        }
                    }
                    if changed { set_prop(&mut obj.bag, i, PropertyValue::CExoString(s)); modified = true; }
                }
                PropertyValue::ResRef(mut s) => {
                    let mut changed = false;
                    let id = ui.id().with(&label);
                    egui::ComboBox::from_id_salt(id)
                        .selected_text(&s)
                        .show_ui(ui, |ui| {
                            for r in resrefs {
                                let selected = *r == s;
                                if ui.selectable_label(selected, r).clicked() {
                                    s = r.clone();
                                    changed = true;
                                }
                            }
                            // Also allow typing free-form
                            if ui.selectable_label(false, "✏ Type manually...").clicked() {
                                // Leave current value as-is; user can edit via text field
                            }
                        });
                    if changed { set_prop(&mut obj.bag, i, PropertyValue::ResRef(s)); modified = true; }
                }
                PropertyValue::Int(mut v) => {
                    if ui.add(egui::DragValue::new(&mut v)).changed() {
                        set_prop(&mut obj.bag, i, PropertyValue::Int(v)); modified = true;
                    }
                }
                PropertyValue::Float(mut v) => {
                    if ui.add(egui::DragValue::new(&mut v).speed(0.1)).changed() {
                        set_prop(&mut obj.bag, i, PropertyValue::Float(v)); modified = true;
                    }
                }
                PropertyValue::DWord(v) => {
                    let mut val = v as i32;
                    if ui.add(egui::DragValue::new(&mut val)).changed() {
                        set_prop(&mut obj.bag, i, PropertyValue::DWord(val as u32)); modified = true;
                    }
                }
                PropertyValue::Byte(v) => {
                    let mut val = v as i32;
                    if ui.add(egui::DragValue::new(&mut val).range(0..=255)).changed() {
                        set_prop(&mut obj.bag, i, PropertyValue::Byte(val as u8)); modified = true;
                    }
                }
                PropertyValue::Short(v) => {
                    let mut val = v as i32;
                    if ui.add(egui::DragValue::new(&mut val).range(-32768..=32767)).changed() {
                        set_prop(&mut obj.bag, i, PropertyValue::Short(val as i16)); modified = true;
                    }
                }
                PropertyValue::Word(v) => {
                    let mut val = v as i32;
                    if ui.add(egui::DragValue::new(&mut val).range(0..=65535)).changed() {
                        set_prop(&mut obj.bag, i, PropertyValue::Word(val as u16)); modified = true;
                    }
                }
                PropertyValue::CExoLocString(ls) => {
                    if let Some(sub) = ls.substrings.first() {
                        ui.label(&sub.text);
                    } else {
                        ui.colored_label(egui::Color32::GRAY, format!("[strref={}]", ls.strref));
                    }
                }
                _ => {
                    let disp = display_value(&value);
                    ui.colored_label(egui::Color32::GRAY, &disp);
                }
            }
            ui.separator();
        }
    });
    modified
}

fn set_prop(bag: &mut PropertyBag, i: usize, value: PropertyValue) {
    if let Some(p) = bag.properties.get_mut(i) {
        p.value = value;
    }
}

/// A recursive property bag editor that properly writes back nested changes.
pub fn show_bag_editor(ui: &mut egui::Ui, bag: &mut PropertyBag, resrefs: &[String], tags: &[String]) -> bool {
    let mut modified = false;
    let indices: Vec<usize> = (0..bag.properties.len()).collect();
    for i in indices {
        let prop = &bag.properties[i].clone();
        let type_name = value_type_name(prop.field_type);
        let label = prop.label.clone();
        ui.horizontal(|ui| {
            ui.label(&label);
            ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                ui.colored_label(egui::Color32::GRAY, type_name);
            });
        });
        match &prop.value {
            PropertyValue::Struct(inner) => {
                let disp = format!("{{ {} fields }}", inner.properties.len());
                egui::CollapsingHeader::new(&disp)
                    .default_open(false)
                    .show(ui, |ui| {
                        if let PropertyValue::Struct(inner_bag) = &mut bag.properties[i].value {
                            modified |= show_bag_editor(ui, inner_bag.as_mut(), resrefs, tags);
                        }
                    });
            }
            PropertyValue::List(items) => {
                let disp = format!("[{} items]", items.len());
                egui::CollapsingHeader::new(&disp)
                    .default_open(false)
                    .show(ui, |ui| {
                        if let PropertyValue::List(list) = &mut bag.properties[i].value {
                            for (j, item) in list.iter_mut().enumerate() {
                                egui::CollapsingHeader::new(format!("#{}", j))
                                    .default_open(false)
                                    .show(ui, |ui| {
                                        modified |= show_bag_editor(ui, item.as_mut(), resrefs, tags);
                                    });
                            }
                        }
                    });
            }
            PropertyValue::CExoString(s) => {
                let mut val = s.clone();
                let mut changed = false;
                if label == "Tag" {
                    let id = ui.id().with(&label);
                    egui::ComboBox::from_id_salt(id)
                        .selected_text(&val)
                        .show_ui(ui, |ui| {
                            for t in tags {
                                let selected = *t == val;
                                if ui.selectable_label(selected, t).clicked() {
                                    val = t.clone();
                                    changed = true;
                                }
                            }
                            if ui.selectable_label(false, "✏ Type manually...").clicked() {
                            }
                        });
                } else {
                    if ui.text_edit_singleline(&mut val).changed() {
                        changed = true;
                    }
                }
                if changed {
                    bag.properties[i].value = PropertyValue::CExoString(val);
                    modified = true;
                }
            }
            PropertyValue::ResRef(s) => {
                let mut changed = false;
                let mut val = s.clone();
                let id = ui.id().with(&label);
                egui::ComboBox::from_id_salt(id)
                    .selected_text(&val)
                    .show_ui(ui, |ui| {
                        for r in resrefs {
                            let selected = *r == val;
                            if ui.selectable_label(selected, r).clicked() {
                                val = r.clone();
                                changed = true;
                            }
                        }
                    });
                if changed { bag.properties[i].value = PropertyValue::ResRef(val); modified = true; }
            }
            PropertyValue::Int(v) => {
                let mut val = *v;
                if ui.add(egui::DragValue::new(&mut val)).changed() {
                    bag.properties[i].value = PropertyValue::Int(val);
                    modified = true;
                }
            }
            PropertyValue::Float(v) => {
                let mut val = *v;
                if ui.add(egui::DragValue::new(&mut val).speed(0.1)).changed() {
                    bag.properties[i].value = PropertyValue::Float(val);
                    modified = true;
                }
            }
            PropertyValue::Byte(v) => {
                let mut val = *v as i32;
                if ui.add(egui::DragValue::new(&mut val).range(0..=255)).changed() {
                    bag.properties[i].value = PropertyValue::Byte(val as u8);
                    modified = true;
                }
            }
            PropertyValue::Word(v) => {
                let mut val = *v as i32;
                if ui.add(egui::DragValue::new(&mut val).range(0..=65535)).changed() {
                    bag.properties[i].value = PropertyValue::Word(val as u16);
                    modified = true;
                }
            }
            PropertyValue::Short(v) => {
                let mut val = *v as i32;
                if ui.add(egui::DragValue::new(&mut val)).changed() {
                    bag.properties[i].value = PropertyValue::Short(val as i16);
                    modified = true;
                }
            }
            PropertyValue::DWord(v) => {
                let mut val = *v as i32;
                if ui.add(egui::DragValue::new(&mut val)).changed() {
                    bag.properties[i].value = PropertyValue::DWord(val as u32);
                    modified = true;
                }
            }
            PropertyValue::DWord64(v) => {
                let mut val = *v as i64;
                if ui.add(egui::DragValue::new(&mut val)).changed() {
                    bag.properties[i].value = PropertyValue::DWord64(val as u64);
                    modified = true;
                }
            }
            PropertyValue::Int64(v) => {
                let mut val = *v;
                if ui.add(egui::DragValue::new(&mut val)).changed() {
                    bag.properties[i].value = PropertyValue::Int64(val);
                    modified = true;
                }
            }
            PropertyValue::Double(v) => {
                let mut val = *v;
                if ui.add(egui::DragValue::new(&mut val).speed(0.1)).changed() {
                    bag.properties[i].value = PropertyValue::Double(val);
                    modified = true;
                }
            }
            PropertyValue::CExoLocString(ls) => {
                ui.label(format!("[StrRef={}]", ls.strref));
                if let Some(sub) = ls.substrings.first() {
                    let mut val = sub.text.clone();
                    if ui.text_edit_singleline(&mut val).changed() {
                        if let PropertyValue::CExoLocString(ls_mut) = &mut bag.properties[i].value {
                            if let Some(sub_mut) = ls_mut.substrings.first_mut() {
                                sub_mut.text = val;
                                modified = true;
                            }
                        }
                    }
                }
            }
            PropertyValue::Void(v) => {
                ui.label(format!("[{} bytes hex data]", v.len()));
            }
            PropertyValue::Char(_) => {}
        }
    }
    modified
}
