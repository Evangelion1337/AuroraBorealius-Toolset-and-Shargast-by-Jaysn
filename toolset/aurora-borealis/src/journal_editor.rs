use eframe::egui;
use nwn_gamemodel::Journal;

#[allow(dead_code)]
pub fn show_journal_editor(ui: &mut egui::Ui, journal: &mut Option<Journal>) -> bool {
    let mut modified = false;
    egui::TopBottomPanel::top("journal_toolbar")
        .show_inside(ui, |ui| {
            ui.horizontal(|ui| {
                ui.heading("Journal Editor");
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    ui.label("Edit quest journal categories and entries");
                });
            });
        });
    if let Some(j) = journal {
        egui::ScrollArea::vertical()
            .show(ui, |ui| {
                let cat_indices: Vec<usize> = (0..j.categories.len()).collect();
                for ci in cat_indices {
                    let cat_name = j.categories[ci].name.clone();
                    let header = format!("Cat #{}: {}", j.categories[ci].id, &cat_name);
                    egui::CollapsingHeader::new(&header)
                        .default_open(false)
                        .show(ui, |ui| {
                            let mut new_name = cat_name.clone();
                            if ui.text_edit_singleline(&mut new_name).changed() && new_name != cat_name {
                                j.categories[ci].name = new_name;
                                modified = true;
                            }
                            // Entries
                            let entry_indices: Vec<usize> = (0..j.categories[ci].entries.len()).collect();
                            for ei in entry_indices {
                                let entry_text = j.categories[ci].entries[ei].text.clone();
                                let short = if entry_text.len() > 60 {
                                    format!("{}...", &entry_text[..57])
                                } else if entry_text.is_empty() {
                                    "(empty)".to_string()
                                } else {
                                    entry_text.clone()
                                };
                                egui::CollapsingHeader::new(format!("#{}: {}", j.categories[ci].entries[ei].id, short))
                                    .default_open(false)
                                    .show(ui, |ui| {
                                        let mut text = entry_text.clone();
                                        if ui.text_edit_multiline(&mut text).changed() && text != entry_text {
                                            j.categories[ci].entries[ei].text = text;
                                            modified = true;
                                        }
                                        let mut end_text = j.categories[ci].entries[ei].end_text.clone();
                                        ui.label("End Text:");
                                        if ui.text_edit_multiline(&mut end_text).changed() {
                                            j.categories[ci].entries[ei].end_text = end_text;
                                            modified = true;
                                        }
                                        let mut quest_tag = j.categories[ci].entries[ei].quest_tag.clone();
                                        ui.label("Quest Tag:");
                                        if ui.text_edit_singleline(&mut quest_tag).changed() {
                                            j.categories[ci].entries[ei].quest_tag = quest_tag;
                                            modified = true;
                                        }
                                        let mut xp = j.categories[ci].entries[ei].xp_final;
                                        ui.label("XP Final:");
                                        if ui.add(egui::DragValue::new(&mut xp)).changed() {
                                            j.categories[ci].entries[ei].xp_final = xp;
                                            modified = true;
                                        }
                                    });
                            }
                            // Add entry button
                            if ui.button("+ Add Entry").clicked() {
                                let next_id = j.categories[ci].entries.iter().map(|e| e.id).max().unwrap_or(-1) + 1;
                                j.categories[ci].entries.push(nwn_gamemodel::JournalEntry {
                                    id: next_id,
                                    text: String::new(),
                                    end_text: String::new(),
                                    quest_tag: String::new(),
                                    xp_final: 0,
                                });
                                modified = true;
                            }
                        });
                }
                // Add category button
                if ui.button("+ Add Category").clicked() {
                    let next_id = j.categories.iter().map(|c| c.id).max().unwrap_or(-1) + 1;
                    j.categories.push(nwn_gamemodel::JournalCategory {
                        id: next_id,
                        name: "New Category".to_string(),
                        priority: 0,
                        entries: Vec::new(),
                    });
                    modified = true;
                }
            });
    } else {
        ui.label("No journal data found.");
    }
    modified
}
