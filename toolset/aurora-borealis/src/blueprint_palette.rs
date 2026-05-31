use eframe::egui;
use nwn_gamemodel::ResourceManager;

fn section_with_search(
    ui: &mut egui::Ui,
    label: &str,
    rm: &ResourceManager,
    table_name: &str,
    prefix: &str,
    label_col: &str,
    name_col: &str,
    on_place: &mut Option<(String, String)>,
) {
    let Some(table) = rm.get_2da(table_name) else { return };
    let lc = if table.columns().contains(&label_col.to_string()) { label_col } else { table.columns().first().map(|s| s.as_str()).unwrap_or("") };
    let nc = if table.columns().contains(&name_col.to_string()) { name_col } else { lc };

    let search_id = ui.id().with("_search");
    let mut search = ui.data(|d| d.get_temp::<String>(search_id).unwrap_or_default());

    egui::CollapsingHeader::new(label)
        .default_open(true)
        .show(ui, |ui| {
            ui.horizontal(|ui| {
                ui.label("Filter:");
                ui.text_edit_singleline(&mut search);
            });
            let rows = table.row_count().min(200);
            for r in 0..rows {
                let lbl = table.get_cell_by_label(r, lc).unwrap_or("");
                let name = table.get_cell_by_label(r, nc).unwrap_or(lbl);
                if lbl.is_empty() { continue; }
                if !search.is_empty() && !name.to_lowercase().contains(&search.to_lowercase()) && !lbl.to_lowercase().contains(&search.to_lowercase()) { continue; }
                let id = ui.make_persistent_id(format!("{}_{}", prefix, lbl));
                let resp = ui.dnd_drag_source(id, format!("{}:{}", prefix, lbl), |ui| {
                    ui.button(format!("{} ({})", name, lbl))
                });
                if resp.inner.clicked() {
                    on_place.replace((prefix.to_string(), lbl.to_string()));
                }
            }
            if table.row_count() > 200 {
                ui.colored_label(egui::Color32::GRAY, format!("... and {} more", table.row_count() - 200));
            }
        });

    ui.data_mut(|d| d.insert_temp(search_id, search));
}

pub fn show_blueprint_palette(ui: &mut egui::Ui, rm: &ResourceManager, on_place: &mut Option<(String, String)>) {
    egui::TopBottomPanel::top("palette_toolbar")
        .show_inside(ui, |ui| {
            ui.horizontal(|ui| {
                ui.heading("Blueprint Palette");
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    ui.label("Click or drag into area to place");
                });
            });
        });

    section_with_search(ui, "Creatures", rm, "appearance", "creature", "Label", "Name", on_place);
    section_with_search(ui, "Placeables", rm, "placeables", "placeable", "Label", "Name", on_place);
    section_with_search(ui, "Doors", rm, "doortypes", "door", "Label", "Name", on_place);
    section_with_search(ui, "Items", rm, "baseitems", "item", "Label", "Name", on_place);
}
