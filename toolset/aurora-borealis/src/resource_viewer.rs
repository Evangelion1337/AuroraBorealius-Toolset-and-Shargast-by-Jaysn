use eframe::egui;
use nwn_gamemodel::{Module, resource_types};

fn resource_category_label(restype: u16) -> &'static str {
    use nwn_gamemodel::resource_types as rt;
    match restype {
        t if t == rt::ARE => "Areas (ARE)",
        t if t == rt::GIT => "Area Instances (GIT)",
        t if t == rt::GIC => "Area Instance Cache (GIC)",
        t if t == rt::IFO => "Module (IFO)",
        t if t == rt::FAC => "Factions (FAC)",
        t if t == rt::JRL => "Journals (JRL)",
        t if t == rt::TLK => "Talk Tables (TLK)",
        t if t == rt::TWO_DA => "2DA Tables",
        t if t == rt::NSS => "Scripts (NSS)",
        t if t == rt::NCS => "Compiled Scripts (NCS)",
        t if t == rt::DLG => "Conversations (DLG)",
        t if t == rt::UTC => "Creatures (UTC)",
        t if t == rt::UTD => "Doors (UTD)",
        t if t == rt::UTP => "Placeables (UTP)",
        t if t == rt::UTI => "Items (UTI)",
        t if t == rt::UTT => "Triggers (UTT)",
        t if t == rt::UTW => "Waypoints (UTW)",
        t if t == rt::UTE => "Encounters (UTE)",
        t if t == rt::UTS => "Sounds (UTS)",
        t if t == rt::UTM => "Merchants (UTM)",
        t if t == rt::BIC => "Characters (BIC)",
        t if t == rt::SSF => "Sound SFX (SSF)",
        t if t == rt::ITP => "Tile Properties (ITP)",
        t if t == rt::LTR => "Letters (LTR)",
        t if t == rt::GUI => "GUI (GUI)",
        t if t == rt::MDL => "Models (MDL)",
        t if t == rt::MDB => "Model Data (MDB)",
        t if t == rt::DDS => "Textures (DDS)",
        t if t == rt::TGA => "Textures (TGA)",
        t if t == rt::BMP => "Bitmaps (BMP)",
        t if t == rt::PLT => "Palettes (PLT)",
        t if t == rt::PLH => "Palette Hires (PLH)",
        t if t == rt::PFB => "PFB (PFB)",
        t if t == rt::TXI => "Texture TXI (TXI)",
        t if t == rt::WAV => "Audio (WAV)",
        t if t == rt::SET => "Tileset (SET)",
        t if t == rt::PTM => "Tile Min (PTM)",
        t if t == rt::PTT => "Tile TGA (PTT)",
        t if t == rt::WOK => "Walkmesh (WOK)",
        t if t == rt::PWC => "PWC (PWC)",
        t if t == rt::SAV => "Save (SAV)",
        t if t == rt::INI => "Config (INI)",
        t if t == rt::TXT => "Text (TXT)",
        t if t == rt::BAK => "Backup (BAK)",
        _ => {
            let ext = nwn_gamemodel::resource_types::type_to_ext(restype)
                .unwrap_or("???");
            if ext == "???" { "Other" } else { ext }
        }
    }
}

pub fn show_resource_viewer(
    ui: &mut egui::Ui,
    module: &Module,
    on_open_script: &mut Option<String>,
    on_open_conversation: &mut Option<String>,
    on_edit_blueprint: &mut Option<(String, u16, Vec<u8>)>,
    on_open_faction: &mut Option<String>,
    on_open_journal: &mut Option<String>,
) {
    let res_list = module.resource_list();
    let total = res_list.len();

    let mut groups: std::collections::BTreeMap<String, Vec<(String, u16)>> = std::collections::BTreeMap::new();
    for (resref, restype) in &res_list {
        let group = resource_category_label(*restype).to_string();
        groups.entry(group).or_default().push((resref.clone(), *restype));
    }

    egui::TopBottomPanel::top("resource_toolbar")
        .show_inside(ui, |ui| {
            ui.horizontal(|ui| {
                ui.heading("Resources");
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    ui.label(format!("{} resources", total));
                });
            });
        });

    egui::ScrollArea::vertical()
        .id_salt("resource_scroll")
        .show(ui, |ui| {
            for (cat, entries) in &groups {
                let count = entries.len();
                let header_label = format!("{} [{}]", cat, count);
                egui::CollapsingHeader::new(header_label)
                    .default_open(count < 100)
                    .show(ui, |ui| {
                        let max_show = count.min(200);
                        for (resref, restype) in entries.iter().take(max_show) {
                            let ext = resource_types::type_to_ext(*restype).unwrap_or("???");
                            let label = format!("{}.{}", resref, ext.to_lowercase());
                            ui.horizontal(|ui| {
                                ui.label(&label);
                                match *restype {
                                    t if t == resource_types::NSS => {
                                        if ui.button("Edit Script").clicked() {
                                            *on_open_script = Some(resref.clone());
                                        }
                                    }
                                    t if t == resource_types::DLG => {
                                        if ui.button("Edit Convo").clicked() {
                                            *on_open_conversation = Some(resref.clone());
                                        }
                                    }
                                    t if t == resource_types::FAC => {
                                        if ui.button("Edit Factions").clicked() {
                                            *on_open_faction = Some(resref.clone());
                                        }
                                    }
                                    t if t == resource_types::JRL => {
                                        if ui.button("Edit Journal").clicked() {
                                            *on_open_journal = Some(resref.clone());
                                        }
                                    }
                                    _ if is_gff_type(*restype) && !is_special_type(*restype) => {
                                        if ui.button("Edit").clicked() {
                                            if let Some(bytes) = module.get_resource_data(resref, *restype) {
                                                *on_edit_blueprint = Some((resref.clone(), *restype, bytes));
                                            }
                                        }
                                    }
                                    _ => {}
                                }
                            });
                        }
                        if count > 200 {
                            ui.colored_label(egui::Color32::GRAY, format!("... and {} more", count - 200));
                        }
                    });
            }
        });
}

fn is_gff_type(restype: u16) -> bool {
    matches!(restype,
        resource_types::IFO | resource_types::ARE | resource_types::GIT | resource_types::GIC |
        resource_types::UTC | resource_types::UTD | resource_types::UTP | resource_types::UTT |
        resource_types::UTW | resource_types::UTE | resource_types::UTS | resource_types::UTM |
        resource_types::UTI | resource_types::FAC | resource_types::BIC | resource_types::JRL |
        resource_types::LTR | resource_types::ITP | resource_types::SSF | resource_types::GUI
    )
}

fn is_special_type(restype: u16) -> bool {
    matches!(restype, resource_types::FAC | resource_types::JRL)
}
