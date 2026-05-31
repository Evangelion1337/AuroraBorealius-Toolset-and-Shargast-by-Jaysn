use eframe::egui;
use nwnrs_types::resman::ResContainer;
use std::path::Path;

fn game_data_dir() -> Option<std::path::PathBuf> {
    let home = std::env::var("HOME").ok()?;
    let data_dir = Path::new(&home)
        .join(".local/share/Steam/steamapps/common/Neverwinter Nights/data");
    if data_dir.is_dir() { Some(data_dir) } else { None }
}

fn load_2da_from_game_data(name: &str) -> Option<nwn_2da::TwoDa> {
    let data_dir = game_data_dir()?;
    let name_lower = name.to_lowercase();
    for key_name in &["nwn_base.key", "nwn_retail.key", "nwn_expn.key"] {
        let key_path = data_dir.join(key_name);
        if !key_path.exists() { continue; }
        let Ok(key_table) = nwnrs_types::key::read_key_table_from_file(&key_path) else { continue };
        let rr = nwnrs_types::resman::ResRef::new(&name_lower, nwnrs_types::resman::ResType(2012)).ok()?;
        if !key_table.contains(&rr) { continue; }
        let Ok(res) = key_table.demand(&rr) else { continue };
        if let Ok(data) = res.read_all(nwnrs_types::resman::CachePolicy::Bypass) {
            let s = String::from_utf8_lossy(&data);
            return nwn_2da::TwoDa::from_string(&s).ok();
        }
    }
    None
}

fn scan_game_2da_names() -> Vec<String> {
    let data_dir = match game_data_dir() {
        Some(d) => d,
        None => return Vec::new(),
    };
    let mut names = std::collections::BTreeSet::new();
    for key_name in &["nwn_base.key", "nwn_retail.key", "nwn_expn.key"] {
        let key_path = data_dir.join(key_name);
        if !key_path.exists() { continue; }
        let Ok(key_table) = nwnrs_types::key::read_key_table_from_file(&key_path) else { continue };
        for rr in key_table.contents() {
            if rr.res_type().0 == 2012 {
                names.insert(rr.res_ref().to_lowercase());
            }
        }
    }
    names.into_iter().collect()
}

#[derive(Default)]
pub struct TwoDaEditorState {
    pub game_2da_list: Vec<String>,
    pub game_2da_scanned: bool,
    pub edit_name: Option<String>,
    pub edit_data: Option<nwn_2da::TwoDa>,
    pub search: String,
}

impl TwoDaEditorState {
    fn ensure_scanned(&mut self) {
        if !self.game_2da_scanned {
            self.game_2da_list = scan_game_2da_names();
            self.game_2da_list.sort();
            self.game_2da_scanned = true;
        }
    }

    fn load_2da(&mut self, name: &str) {
        if let Some(table) = load_2da_from_game_data(name) {
            self.edit_name = Some(name.to_string());
            self.edit_data = Some(table);
            self.search.clear();
        }
    }

    #[allow(dead_code)]
    pub fn load_from_module(&mut self, name: String, data: nwn_2da::TwoDa) {
        self.edit_name = Some(name);
        self.edit_data = Some(data);
        self.search.clear();
    }
}

pub fn show_two_da_editor(
    ui: &mut egui::Ui,
    state: &mut TwoDaEditorState,
    on_save: &mut Option<(String, String)>,
) {
    state.ensure_scanned();

    ui.horizontal(|ui| {
        ui.heading("2DA Editor");
        if state.edit_name.is_some() {
            if let Some(ref table) = state.edit_data {
                ui.label(format!("{} x {}", table.row_count(), table.col_count()));
            }
            if ui.button("Close").clicked() {
                state.edit_name = None;
                state.edit_data = None;
            }
        }
    });

    egui::SidePanel::left("2da_file_list")
        .resizable(true)
        .default_width(200.0)
        .show_inside(ui, |ui| {
            ui.strong("Game Data 2DAs");
            ui.separator();
            ui.label(format!("{} files", state.game_2da_list.len()));
            ui.add_space(4.0);

            ui.add(egui::TextEdit::singleline(&mut state.search)
                .hint_text("Filter...")
                .desired_width(f32::INFINITY));

            let names: Vec<String> = {
                let q = state.search.to_lowercase();
                state.game_2da_list.iter()
                    .filter(|n| q.is_empty() || n.contains(&q))
                    .cloned()
                    .collect()
            };
            egui::ScrollArea::vertical().show(ui, |ui| {
                for name in &names {
                    let selected = state.edit_name.as_deref() == Some(name);
                    if ui.selectable_label(selected, name).clicked() {
                        state.load_2da(name);
                    }
                }
            });
        });

    egui::CentralPanel::default().show_inside(ui, |ui| {
        if let Some(ref mut table) = state.edit_data {
            let cols = table.columns().to_vec();
            let rows = table.row_count();

            // Toolbar
            ui.horizontal(|ui| {
                if ui.button("+ Add Row").clicked() {
                    table.add_row();
                }
                if ui.button("- Delete Last Row").clicked() && rows > 0 {
                    table.inner.resize_rows(rows - 1);
                }
                ui.separator();
                let s = table.to_2da_string();
                if ui.button("Save to Module").clicked() {
                    if let Some(ref name) = state.edit_name {
                        *on_save = Some((name.clone(), s));
                    }
                }
            });

            ui.separator();
            ui.label(format!("{} rows", rows));
            ui.separator();

            egui::ScrollArea::both()
                .auto_shrink([false, false])
                .show(ui, |ui| {
                    egui::Grid::new("2da_grid")
                        .striped(true)
                        .spacing([1.0, 1.0])
                        .min_col_width(70.0)
                        .show(ui, |ui| {
                            // Header row
                            ui.strong("#");
                            for col in &cols {
                                ui.strong(col);
                            }
                            ui.end_row();

                            // Data rows
                            for r in 0..rows {
                                ui.label(format!("{}", r));
                                for c in 0..cols.len() {
                                    let cell_val = table.get_cell(r, c).unwrap_or("").to_string();
                                    let mut val = cell_val.clone();
                                    if ui.add(
                                        egui::TextEdit::singleline(&mut val)
                                            .desired_width(55.0)
                                            .font(egui::TextStyle::Monospace)
                                    ).lost_focus() && val != cell_val {
                                        let _ = table.set_cell(r, c, val);
                                    }
                                }
                                ui.end_row();
                            }
                        });
                });
        } else {
            ui.vertical_centered(|ui| {
                ui.add_space(40.0);
                ui.label("Select a 2DA from the file list, or open from Resource Viewer.");
            });
        }
    });
}
