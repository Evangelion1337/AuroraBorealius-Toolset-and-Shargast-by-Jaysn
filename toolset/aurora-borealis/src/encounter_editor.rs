use eframe::egui;
use nwn_gamemodel::EncounterInstance;

#[allow(dead_code)]
pub fn show_encounter_editor(
    ui: &mut egui::Ui,
    area_encounters: &mut Vec<EncounterInstance>,
    on_save: &mut bool,
    selected_idx: &mut Option<usize>,
) {
    egui::SidePanel::left("encounter_list")
        .resizable(true)
        .default_width(220.0)
        .show_inside(ui, |ui| {
            ui.strong("Encounters");
            ui.separator();
            ui.label(format!("{} encounters", area_encounters.len()));
            ui.add_space(4.0);

            if ui.button("+ Add Encounter").clicked() {
                area_encounters.push(EncounterInstance {
                    tag: format!("ENCOUNTER_{}", area_encounters.len()),
                    name: String::new(),
                    x: 0.0, y: 0.0, z: 0.0,
                    bearing: 0.0,
                    geometry: Vec::new(),
                    difficulty: 0,
                    player_only: false,
                    reset: 0,
                    max_creatures: 0,
                    spawn_option: 0,
                    on_entered: String::new(),
                    on_exhausted: String::new(),
                    on_exit: String::new(),
                    on_heartbeat: String::new(),
                    on_user_defined: String::new(),
                });
                *on_save = true;
            }
            ui.add_space(4.0);

            let indices: Vec<usize> = (0..area_encounters.len()).collect();
            let mut delete_idx = None;
            for i in indices {
                let enc = &area_encounters[i];
                let label = if enc.tag.is_empty() {
                    format!("Encounter {}", i)
                } else if !enc.name.is_empty() {
                    format!("{} <{}>", enc.name, enc.tag)
                } else {
                    enc.tag.clone()
                };
                ui.horizontal(|ui| {
                    if ui.selectable_label(*selected_idx == Some(i), &label).clicked() {
                        *selected_idx = Some(i);
                    }
                    if ui.button("🗑").clicked() {
                        delete_idx = Some(i);
                    }
                });
            }
            if let Some(idx) = delete_idx {
                area_encounters.remove(idx);
                *on_save = true;
            }
        });

    egui::CentralPanel::default().show_inside(ui, |ui| {
        if let Some(idx) = selected_idx {
            if *idx < area_encounters.len() {
                let enc = &mut area_encounters[*idx];
                egui::ScrollArea::vertical().show(ui, |ui| {
                    ui.heading(format!("Encounter: {}", enc.tag));
                    ui.separator();

                    let mut changed = false;

                    ui.horizontal(|ui| {
                        ui.label("Tag:");
                        let mut tag = enc.tag.clone();
                        if ui.add(egui::TextEdit::singleline(&mut tag).desired_width(200.0)).lost_focus() {
                            enc.tag = tag;
                            changed = true;
                        }
                    });

                    ui.horizontal(|ui| {
                        ui.label("Name:");
                        let mut name = enc.name.clone();
                        if ui.add(egui::TextEdit::singleline(&mut name).desired_width(200.0)).lost_focus() {
                            enc.name = name;
                            changed = true;
                        }
                    });

                    ui.separator();
                    ui.strong("Position");
                    let (mut x, mut y, mut z) = (enc.x, enc.y, enc.z);
                    ui.horizontal(|ui| {
                        ui.label("X:"); changed |= ui.add(egui::DragValue::new(&mut x).speed(0.1)).changed();
                        ui.label("Y:"); changed |= ui.add(egui::DragValue::new(&mut y).speed(0.1)).changed();
                        ui.label("Z:"); changed |= ui.add(egui::DragValue::new(&mut z).speed(0.1)).changed();
                    });
                    if changed { enc.x = x; enc.y = y; enc.z = z; }

                    let mut bearing = enc.bearing;
                    ui.horizontal(|ui| {
                        ui.label("Bearing:");
                        changed |= ui.add(egui::DragValue::new(&mut bearing).speed(0.05).range(0.0..=6.2832)).changed();
                    });
                    if changed { enc.bearing = bearing; }

                    ui.separator();
                    ui.strong("Encounter Settings");
                    let mut diff = enc.difficulty;
                    ui.horizontal(|ui| {
                        ui.label("Difficulty:");
                        changed |= ui.add(egui::Slider::new(&mut diff, 0..=3)).changed();
                    });
                    if changed { enc.difficulty = diff; }

                    let mut max_c = enc.max_creatures;
                    ui.horizontal(|ui| {
                        ui.label("Max Creatures:");
                        changed |= ui.add(egui::DragValue::new(&mut max_c).speed(1).range(0..=100)).changed();
                    });
                    if changed { enc.max_creatures = max_c; }

                    let mut spawn_opt = enc.spawn_option;
                    ui.horizontal(|ui| {
                        ui.label("Spawn Option:");
                        changed |= ui.add(egui::DragValue::new(&mut spawn_opt).speed(1)).changed();
                    });
                    if changed { enc.spawn_option = spawn_opt; }

                    let mut reset_val = enc.reset;
                    ui.horizontal(|ui| {
                        ui.label("Reset:");
                        changed |= ui.add(egui::DragValue::new(&mut reset_val).speed(1)).changed();
                    });
                    if changed { enc.reset = reset_val; }

                    let mut player_only = enc.player_only;
                    ui.horizontal(|ui| {
                        ui.label("Player Only:");
                        changed |= ui.checkbox(&mut player_only, "").changed();
                    });
                    if changed { enc.player_only = player_only; }

                    ui.separator();
                    ui.strong("Scripts");
                    let mut on_entered = enc.on_entered.clone();
                    ui.horizontal(|ui| { ui.label("OnEntered:"); changed |= ui.add(egui::TextEdit::singleline(&mut on_entered).desired_width(200.0)).lost_focus(); });
                    if changed { enc.on_entered = on_entered; }

                    let mut on_exit = enc.on_exit.clone();
                    ui.horizontal(|ui| { ui.label("OnExit:"); changed |= ui.add(egui::TextEdit::singleline(&mut on_exit).desired_width(200.0)).lost_focus(); });
                    if changed { enc.on_exit = on_exit; }

                    let mut on_exhausted = enc.on_exhausted.clone();
                    ui.horizontal(|ui| { ui.label("OnExhausted:"); changed |= ui.add(egui::TextEdit::singleline(&mut on_exhausted).desired_width(200.0)).lost_focus(); });
                    if changed { enc.on_exhausted = on_exhausted; }

                    let mut on_heartbeat = enc.on_heartbeat.clone();
                    ui.horizontal(|ui| { ui.label("OnHeartbeat:"); changed |= ui.add(egui::TextEdit::singleline(&mut on_heartbeat).desired_width(200.0)).lost_focus(); });
                    if changed { enc.on_heartbeat = on_heartbeat; }

                    let mut on_user = enc.on_user_defined.clone();
                    ui.horizontal(|ui| { ui.label("OnUserDefined:"); changed |= ui.add(egui::TextEdit::singleline(&mut on_user).desired_width(200.0)).lost_focus(); });
                    if changed { enc.on_user_defined = on_user; }

                    ui.separator();
                    ui.strong("Geometry");
                    ui.label(format!("{} polygon points", enc.geometry.len()));
                    if ui.button("+ Add Point").clicked() {
                        enc.geometry.push([0.0, 0.0, 0.0]);
                        changed = true;
                    }

                    let geo_len = enc.geometry.len();
                    let mut del_pt = None;
                    for gi in 0..geo_len {
                        ui.horizontal(|ui| {
                            ui.label(format!("#{}", gi));
                            let mut gx = enc.geometry[gi][0];
                            let mut gy = enc.geometry[gi][1];
                            let mut gz = enc.geometry[gi][2];
                            if ui.add(egui::DragValue::new(&mut gx).speed(0.1).prefix("X:")).changed() { changed = true; }
                            if ui.add(egui::DragValue::new(&mut gy).speed(0.1).prefix("Y:")).changed() { changed = true; }
                            if ui.add(egui::DragValue::new(&mut gz).speed(0.1).prefix("Z:")).changed() { changed = true; }
                            if changed { enc.geometry[gi] = [gx, gy, gz]; }
                            if ui.button("X").clicked() { del_pt = Some(gi); }
                        });
                    }
                    if let Some(di) = del_pt {
                        enc.geometry.remove(di);
                        changed = true;
                    }

                    if changed {
                        *on_save = true;
                    }
                });
            } else {
                ui.vertical_centered(|ui| {
                    ui.add_space(40.0);
                    ui.label("Select an encounter from the list.");
                });
            }
        } else {
            ui.vertical_centered(|ui| {
                ui.add_space(40.0);
                ui.label("Select or add an encounter to edit.");
            });
        }
    });
}
