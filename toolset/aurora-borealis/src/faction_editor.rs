use eframe::egui;
use nwn_gamemodel::FactionList;

#[allow(dead_code)]
pub fn show_faction_editor(ui: &mut egui::Ui, erf: Option<&nwn_erf::ErfFile>, list: &mut Option<FactionList>) -> bool {
    egui::TopBottomPanel::top("faction_toolbar")
        .show_inside(ui, |ui| {
            ui.horizontal(|ui| {
                ui.heading("Faction Editor");
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    ui.label("Edit faction names, IDs, and reputation values");
                });
            });
        });

    // Load faction data once
    if list.is_none() {
        if let Some(erf) = erf {
            let fac = erf.get("faction", nwn_gamemodel::resource_types::FAC)
                .or_else(|| erf.get("Faction", nwn_gamemodel::resource_types::FAC))
                .or_else(|| erf.get("factions", nwn_gamemodel::resource_types::FAC))
                .or_else(|| erf.get("Factions", nwn_gamemodel::resource_types::FAC))
                .or_else(|| erf.get("repute", nwn_gamemodel::resource_types::FAC))
                .or_else(|| erf.get("Repute", nwn_gamemodel::resource_types::FAC));
            if let Some(data) = fac {
                if let Ok(gff) = nwn_gff::GffFile::from_bytes(&data) {
                    if let Ok(fl) = FactionList::from_gff(&gff) {
                        *list = Some(fl);
                    } else {
                        ui.colored_label(egui::Color32::RED, "Failed to parse faction GFF.");
                    }
                } else {
                    ui.colored_label(egui::Color32::RED, "Failed to parse faction GFF file.");
                }
            } else {
                ui.label("No faction resource (faction.fac) found in ERF.");
            }
        } else {
            ui.colored_label(egui::Color32::RED, "No ERF data available.");
        }
    }

    let mut modified = false;

    if let Some(list) = list {
        modified |= display_faction_list(ui, list);
    } else {
        ui.label("No faction data found in module.");
        ui.colored_label(egui::Color32::GRAY, "Factions control how different groups (creatures, NPCs) interact.");
    }

    modified
}

#[allow(dead_code)]
fn display_faction_list(ui: &mut egui::Ui, list: &mut FactionList) -> bool {
    let mut modified = false;

    egui::ScrollArea::vertical()
        .show(ui, |ui| {
            ui.label("Factions:");
            for faction in list.factions.iter_mut() {
                let id = faction.id;
                let mut name = faction.name.clone();
                egui::CollapsingHeader::new(format!("#{} {}", id, &name))
                    .default_open(false)
                    .show(ui, |ui| {
                        ui.horizontal(|ui| {
                            ui.label("Name:");
                            if ui.text_edit_singleline(&mut name).changed() {
                                faction.name = name;
                                modified = true;
                            }
                        });
                        ui.horizontal(|ui| {
                            ui.label("ID:");
                            let mut edit_id = id;
                            if ui.add(egui::DragValue::new(&mut edit_id).speed(1).range(0..=255)).changed() {
                                faction.id = edit_id;
                                modified = true;
                            }
                        });
                    });
                ui.separator();
            }
        });

    ui.separator();
    ui.label("Reputation Matrix:");
    ui.colored_label(egui::Color32::GRAY, "Rows: source faction, Cols: target faction. Value: -100 (hostile) to 100 (friendly)");

    let n = list.factions.len();
    if n > 0 {
        egui::ScrollArea::both()
            .show(ui, |ui| {
                ui.horizontal(|ui| {
                    ui.label("");
                    for f2 in list.factions.iter() {
                        ui.vertical(|ui| {
                            ui.label(format!("#{}", f2.id));
                            ui.colored_label(egui::Color32::LIGHT_BLUE, &f2.name);
                        });
                    }
                });

                for fi in 0..n {
                    let f1_id = list.factions[fi].id;
                    ui.horizontal(|ui| {
                        ui.vertical(|ui| {
                            ui.label(format!("#{}", f1_id));
                            ui.colored_label(egui::Color32::LIGHT_BLUE, &list.factions[fi].name);
                        });
                        for fj in 0..n {
                            let f2_id = list.factions[fj].id;
                            let rep = *list.factions[fi].reputation.get(&f2_id).unwrap_or(&0);
                            let mut rep_val = rep;
                            if ui.add(egui::DragValue::new(&mut rep_val).speed(1.0).range(-100..=100))
                                .changed()
                            {
                                list.factions[fi].reputation.insert(f2_id, rep_val);
                                modified = true;
                            }
                            ui.label("");
                        }
                    });
                }
            });
    }

    ui.separator();
    if modified {
        ui.colored_label(egui::Color32::GREEN, "Edits pending — save module to persist.");
    }

    modified
}
