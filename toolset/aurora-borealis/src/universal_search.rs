use eframe::egui;
use nwn_gamemodel::ResourceManager;

struct SearchableTable {
    name: &'static str,
    table_name: &'static str,
    prefix: &'static str,
    label_col: &'static str,
    name_col: &'static str,
}

const SEARCHABLE_TABLES: &[SearchableTable] = &[
    SearchableTable { name: "Creatures", table_name: "appearance", prefix: "creature", label_col: "Label", name_col: "Name" },
    SearchableTable { name: "Placeables", table_name: "placeables", prefix: "placeable", label_col: "Label", name_col: "Name" },
    SearchableTable { name: "Doors", table_name: "doortypes", prefix: "door", label_col: "Label", name_col: "Name" },
    SearchableTable { name: "Items", table_name: "baseitems", prefix: "item", label_col: "Label", name_col: "Name" },
    SearchableTable { name: "Item Properties", table_name: "iprp", prefix: "itemprop", label_col: "Label", name_col: "Name" },
    SearchableTable { name: "Armor/Clothing", table_name: "armor", prefix: "armor", label_col: "Label", name_col: "Name" },
    SearchableTable { name: "Weapons", table_name: "weapons", prefix: "weapon", label_col: "Label", name_col: "Name" },
];

pub fn show_universal_search(ui: &mut egui::Ui, rm: &ResourceManager, on_place: &mut Option<(String, String)>) {
    let filter_id = ui.id().with("_filter");
    let mut filter = ui.data(|d| d.get_temp::<String>(filter_id).unwrap_or_default());

    egui::TopBottomPanel::top("univ_search_toolbar")
        .show_inside(ui, |ui| {
            ui.horizontal(|ui| {
                ui.label("Search:");
                let resp = ui.add(
                    egui::TextEdit::singleline(&mut filter)
                        .hint_text("Type to filter all categories...")
                        .desired_width(f32::INFINITY)
                );
                resp.request_focus();
                if !filter.is_empty() {
                    if ui.button("✕").clicked() {
                        filter.clear();
                    }
                }
            });
        });

    let filter_lower = filter.to_lowercase();
    let mut any_match = false;

    egui::ScrollArea::vertical()
        .id_salt("univ_search_scroll")
        .show(ui, |ui| {
            for tbl in SEARCHABLE_TABLES {
                let Some(table) = rm.get_2da(tbl.table_name) else { continue };
                let lc = if table.columns().contains(&tbl.label_col.to_string()) { tbl.label_col } else { table.columns().first().map(|s| s.as_str()).unwrap_or("") };
                let nc = if table.columns().contains(&tbl.name_col.to_string()) { tbl.name_col } else { lc };

                let mut matches: Vec<(String, String)> = Vec::new();
                let max_rows = table.row_count().min(500);
                for r in 0..max_rows {
                    let lbl = table.get_cell_by_label(r, lc).unwrap_or("");
                    let name = table.get_cell_by_label(r, nc).unwrap_or(lbl);
                    if lbl.is_empty() { continue; }
                    if !filter_lower.is_empty()
                        && !name.to_lowercase().contains(&filter_lower)
                        && !lbl.to_lowercase().contains(&filter_lower)
                    {
                        continue;
                    }
                    matches.push((lbl.to_string(), name.to_string()));
                }

                if matches.is_empty() && !filter_lower.is_empty() {
                    continue;
                }
                any_match = true;

                let count = matches.len();
                let header = if filter_lower.is_empty() {
                    format!("{} [{}]", tbl.name, count.min(max_rows))
                } else {
                    format!("{} [{}]", tbl.name, count)
                };

                egui::CollapsingHeader::new(header)
                    .default_open(!filter_lower.is_empty())
                    .show(ui, |ui| {
                        for (lbl, name) in &matches {
                            let label_text = format!("{} ({})", name, lbl);
                            if ui.button(label_text).clicked() {
                                on_place.replace((tbl.prefix.to_string(), lbl.clone()));
                            }
                        }
                        if count >= 500 {
                            ui.colored_label(egui::Color32::GRAY, format!("... and {} more", table.row_count().saturating_sub(500)));
                        }
                    });
            }
        });

    if !any_match && !filter_lower.is_empty() {
        ui.colored_label(egui::Color32::GRAY, "No matching items found.");
    }

    ui.data_mut(|d| d.insert_temp(filter_id, filter));
}
