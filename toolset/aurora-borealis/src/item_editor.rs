use eframe::egui;
use nwn_gamemodel::ResourceManager;

pub fn show_item_browser(ui: &mut egui::Ui, rm: &ResourceManager) {
    egui::TopBottomPanel::top("item_toolbar")
        .show_inside(ui, |ui| {
            ui.horizontal(|ui| {
                ui.heading("Item Blueprint Browser");
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    ui.label(format!("2DA tables: {}", rm.two_das.len()));
                });
            });
        });

    if let Some(items_2da) = rm.get_2da("baseitems") {
        egui::CollapsingHeader::new("Base Items")
            .default_open(true)
            .show(ui, |ui| {
                let rows = items_2da.row_count().min(100);
                for r in 0..rows {
                    let label = items_2da.get_cell_by_label(r, "Label").unwrap_or("");
                    let name = items_2da.get_cell_by_label(r, "Name").unwrap_or(label);
                    if !label.is_empty() {
                        ui.label(format!("[{}] {} ({})", r, name, label));
                    }
                }
                if items_2da.row_count() > 100 {
                    ui.colored_label(egui::Color32::GRAY, format!("... and {} more", items_2da.row_count() - 100));
                }
            });
    } else {
        ui.colored_label(egui::Color32::GRAY, "No baseitems.2da loaded");
    }

    ui.separator();

    if let Some(iprp_2da) = rm.get_2da("iprp") {
        egui::CollapsingHeader::new("Item Properties")
            .default_open(false)
            .show(ui, |ui| {
                let rows = iprp_2da.row_count().min(50);
                for r in 0..rows {
                    let label = iprp_2da.get_cell_by_label(r, "Label").unwrap_or("");
                    let name = iprp_2da.get_cell_by_label(r, "Name").unwrap_or(label);
                    if !label.is_empty() {
                        ui.label(format!("[{}] {} ({})", r, name, label));
                    }
                }
            });
    }

    ui.separator();

    egui::CollapsingHeader::new("Armor/Clothing")
        .default_open(false)
        .show(ui, |ui| {
            if let Some(armor_2da) = rm.get_2da("armor") {
                let rows = armor_2da.row_count().min(50);
                for r in 0..rows {
                    let label = armor_2da.get_cell_by_label(r, "Label").unwrap_or("");
                    let name = armor_2da.get_cell_by_label(r, "Name").unwrap_or(label);
                    if !label.is_empty() {
                        ui.label(format!("[{}] {} ({})", r, name, label));
                    }
                }
            } else {
                ui.colored_label(egui::Color32::GRAY, "No armor.2da loaded");
            }
        });

    egui::CollapsingHeader::new("Weapons")
        .default_open(false)
        .show(ui, |ui| {
            if let Some(weapons_2da) = rm.get_2da("weapons") {
                let rows = weapons_2da.row_count().min(50);
                for r in 0..rows {
                    let label = weapons_2da.get_cell_by_label(r, "Label").unwrap_or("");
                    let name = weapons_2da.get_cell_by_label(r, "Name").unwrap_or(label);
                    if !label.is_empty() {
                        ui.label(format!("[{}] {} ({})", r, name, label));
                    }
                }
            } else {
                ui.colored_label(egui::Color32::GRAY, "No weapons.2da loaded");
            }
        });
}
