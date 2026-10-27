use std::sync::Arc;
use eframe::egui::{self, Color32, Pos2, Rect, Stroke, Vec2, Shape};
use nwn_gamemodel::Area;

#[derive(Default)]
pub struct GeometryEditorState {
    pub open: bool,
    selected_type: Option<String>,
    selected_idx: Option<usize>,
    selected_vertex: Option<usize>,
    pan_x: f32,
    pan_y: f32,
    zoom: f32,
    pub mode: GeometryMode,
    pub commit: Option<(String, usize, Vec<[f32; 3]>)>,
}

#[derive(Default, PartialEq)]
pub enum GeometryMode {
    #[default]
    Triggers,
    Encounters,
}

impl GeometryEditorState {
    pub fn reset_view(&mut self) {
        self.pan_x = 0.0;
        self.pan_y = 0.0;
        self.zoom = 10.0;
    }
}

fn draw_grid(painter: &egui::Painter, rect: Rect, to_screen: &dyn Fn(f32, f32) -> Pos2, zoom: f32) {
    let grid_size = 10.0;
    let left = rect.left();
    let right = rect.right();
    let top = rect.top();
    let bottom = rect.bottom();
    let start_wx = ((left - rect.center().x) / zoom + rect.width() / 2.0 / grid_size).floor() as i32 - 1;
    let end_wx = ((right - rect.center().x) / zoom + rect.width() / 2.0 / grid_size).ceil() as i32 + 1;
    let start_wy = (-(bottom - rect.center().y) / zoom + rect.height() / 2.0 / grid_size).floor() as i32 - 1;
    let end_wy = (-(top - rect.center().y) / zoom + rect.height() / 2.0 / grid_size).ceil() as i32 + 1;
    for gx in start_wx..=end_wx {
        let p = to_screen(gx as f32 * grid_size, 0.0);
        painter.line_segment([Pos2::new(p.x, top), Pos2::new(p.x, bottom)], Stroke::new(0.5_f32, Color32::from_gray(50)));
    }
    for gy in start_wy..=end_wy {
        let p = to_screen(0.0, gy as f32 * grid_size);
        painter.line_segment([Pos2::new(left, p.y), Pos2::new(right, p.y)], Stroke::new(0.5_f32, Color32::from_gray(50)));
    }
}

pub fn show_geometry_editor(state: &mut GeometryEditorState, ctx: &egui::Context, area_option: Option<&Arc<Area>>) {
    let mut open = true;

    egui::Window::new("Area Geometry Editor")
        .default_size([700.0, 450.0])
        .open(&mut open)
        .show(ctx, |ui| {
            let area = match area_option {
                Some(a) => a,
                None => {
                    ui.label("No area loaded. Open an area first.");
                    return;
                }
            };

            ui.horizontal(|ui| {
                ui.selectable_value(&mut state.mode, GeometryMode::Triggers, "Triggers");
                ui.selectable_value(&mut state.mode, GeometryMode::Encounters, "Encounters");
                if ui.button("Reset View").clicked() {
                    state.reset_view();
                }
            });
            ui.separator();

            ui.horizontal(|ui| {
                ui.vertical(|ui| {
                    ui.strong("Objects");
                    ui.separator();
                    egui::ScrollArea::vertical().max_height(300.0).show(ui, |ui| {
                        let iter: Vec<(usize, String)> = match state.mode {
                            GeometryMode::Triggers => area.triggers.iter().enumerate().map(|(i, t)| (i, format!("{} [{}]", t.tag, i))).collect(),
                            GeometryMode::Encounters => area.encounters.iter().enumerate().map(|(i, e)| (i, format!("{} [{}]", e.tag, i))).collect(),
                        };
                        let obj_type = match state.mode {
                            GeometryMode::Triggers => "trigger",
                            GeometryMode::Encounters => "encounter",
                        };
                        for (i, label) in &iter {
                            let selected = state.selected_type.as_deref() == Some(obj_type) && state.selected_idx == Some(*i);
                            if ui.selectable_label(selected, label).clicked() {
                                state.selected_type = Some(obj_type.to_string());
                                state.selected_idx = Some(*i);
                                state.selected_vertex = None;
                            }
                        }
                    });
                });
                ui.separator();

                let (resp, painter) = ui.allocate_painter(
                    Vec2::new(ui.available_width().max(200.0), 400.0),
                    egui::Sense::click_and_drag(),
                );
                let rect = resp.rect;
                let cx = rect.center().x;
                let cy = rect.center().y;
                let zoom = state.zoom.max(1.0);
                let pan_x = state.pan_x;
                let pan_y = state.pan_y;

                let to_screen = |wx: f32, wy: f32| -> Pos2 {
                    Pos2::new(
                        cx + (wx + pan_x) * zoom,
                        cy - (wy + pan_y) * zoom,
                    )
                };

                draw_grid(&painter, rect, &to_screen, zoom);

                match state.mode {
                    GeometryMode::Triggers => {
                        for (i, t) in area.triggers.iter().enumerate() {
                            let is_sel = state.selected_idx == Some(i) && state.selected_type.as_deref() == Some("trigger");
                            let sp = to_screen(t.x, t.y);
                            let color = if is_sel { Color32::WHITE } else { Color32::GREEN };
                            painter.circle_filled(sp, if is_sel { 6.0 } else { 4.0 }, color);
                            if is_sel {
                                painter.circle_stroke(sp, 8.0, Stroke::new(2.0_f32, Color32::WHITE));
                                if !t.geometry.is_empty() {
                                    let pts: Vec<Pos2> = t.geometry.iter().map(|pt| to_screen(pt[0], pt[1])).collect();
                                    if pts.len() >= 3 {
                                        painter.add(Shape::convex_polygon(pts.clone(), Color32::from_rgba_premultiplied(0, 255, 0, 60), Stroke::new(2.0_f32, Color32::GREEN)));
                                    } else {
                                        for pair in pts.windows(2) {
                                            painter.line_segment([pair[0], pair[1]], Stroke::new(2.0_f32, Color32::GREEN));
                                        }
                                    }
                                    for (vi, pt) in t.geometry.iter().enumerate() {
                                        let vp = to_screen(pt[0], pt[1]);
                                        let vsel = state.selected_vertex == Some(vi);
                                        painter.circle_filled(vp, if vsel { 5.0 } else { 3.5 }, Color32::YELLOW);
                                        painter.circle_stroke(vp, if vsel { 7.0 } else { 5.0 }, Stroke::new(1.0_f32, Color32::WHITE));
                                    }
                                }
                            }
                        }
                    }
                    GeometryMode::Encounters => {
                        for (i, e) in area.encounters.iter().enumerate() {
                            let is_sel = state.selected_idx == Some(i) && state.selected_type.as_deref() == Some("encounter");
                            let sp = to_screen(e.x, e.y);
                            let color = if is_sel { Color32::WHITE } else { Color32::from_rgb(255, 128, 0) };
                            painter.circle_filled(sp, if is_sel { 6.0 } else { 4.0 }, color);
                            if is_sel {
                                painter.circle_stroke(sp, 8.0, Stroke::new(2.0_f32, Color32::WHITE));
                                if !e.geometry.is_empty() {
                                    let pts: Vec<Pos2> = e.geometry.iter().map(|pt| to_screen(pt[0], pt[1])).collect();
                                    if pts.len() >= 3 {
                                        painter.add(Shape::convex_polygon(pts.clone(), Color32::from_rgba_premultiplied(255, 128, 0, 60), Stroke::new(2.0_f32, Color32::from_rgb(255, 128, 0))));
                                    } else {
                                        for pair in pts.windows(2) {
                                            painter.line_segment([pair[0], pair[1]], Stroke::new(2.0_f32, Color32::from_rgb(255, 128, 0)));
                                        }
                                    }
                                    for (vi, pt) in e.geometry.iter().enumerate() {
                                        let vp = to_screen(pt[0], pt[1]);
                                        let vsel = state.selected_vertex == Some(vi);
                                        painter.circle_filled(vp, if vsel { 5.0 } else { 3.5 }, Color32::YELLOW);
                                        painter.circle_stroke(vp, if vsel { 7.0 } else { 5.0 }, Stroke::new(1.0_f32, Color32::WHITE));
                                    }
                                }
                            }
                        }
                    }
                }

                let hover_pos = resp.hover_pos();
                let scroll = ui.input(|i| i.raw_scroll_delta);
                let clicked = resp.clicked();
                let drag_delta = resp.drag_delta();

                if resp.hovered() && scroll.y != 0.0 {
                    let old_zoom = state.zoom;
                    state.zoom = (state.zoom * (1.0 + scroll.y * 0.002)).clamp(1.0, 200.0);
                    if let Some(hp) = hover_pos {
                        let factor = state.zoom / old_zoom;
                        let mx = hp.x - cx;
                        let my = hp.y - cy;
                        state.pan_x = state.pan_x * factor - mx * (factor - 1.0) / state.zoom;
                        state.pan_y = state.pan_y * factor - my * (factor - 1.0) / state.zoom;
                    }
                }

                // Vertex click detection
                if clicked {
                    let obj_type = match state.mode {
                        GeometryMode::Triggers => "trigger",
                        GeometryMode::Encounters => "encounter",
                    };
                    if let Some(hp) = hover_pos {
                        let geom = match state.mode {
                            GeometryMode::Triggers => state.selected_idx.and_then(|i| area.triggers.get(i)).map(|t| &t.geometry),
                            GeometryMode::Encounters => state.selected_idx.and_then(|i| area.encounters.get(i)).map(|e| &e.geometry),
                        };
                        if let Some(geometry) = geom {
                            let mut found = None;
                            for (vi, pt) in geometry.iter().enumerate() {
                                let vp = to_screen(pt[0], pt[1]);
                                if hp.distance(vp) < 10.0 {
                                    found = Some(vi);
                                    break;
                                }
                            }
                            if let Some(vi) = found {
                                state.selected_vertex = Some(vi);
                            } else {
                                let objects: Vec<(usize, f32, f32)> = match state.mode {
                                    GeometryMode::Triggers => area.triggers.iter().enumerate().map(|(i, t)| (i, t.x, t.y)).collect(),
                                    GeometryMode::Encounters => area.encounters.iter().enumerate().map(|(i, e)| (i, e.x, e.y)).collect(),
                                };
                                let mut closest: Option<(usize, f32)> = None;
                                for (i, ox, oy) in objects {
                                    let op = to_screen(ox, oy);
                                    let d = hp.distance(op);
                                    if d < 12.0 && closest.as_ref().map_or(true, |(_, cd)| d < *cd) {
                                        closest = Some((i, d));
                                    }
                                }
                                if let Some((i, _)) = closest {
                                    state.selected_type = Some(obj_type.to_string());
                                    state.selected_idx = Some(i);
                                    state.selected_vertex = None;
                                }
                            }
                        } else {
                            let objects: Vec<(usize, f32, f32)> = match state.mode {
                                GeometryMode::Triggers => area.triggers.iter().enumerate().map(|(i, t)| (i, t.x, t.y)).collect(),
                                GeometryMode::Encounters => area.encounters.iter().enumerate().map(|(i, e)| (i, e.x, e.y)).collect(),
                            };
                            let mut closest: Option<(usize, f32)> = None;
                            for (i, ox, oy) in objects {
                                let op = to_screen(ox, oy);
                                let d = hp.distance(op);
                                if d < 12.0 && closest.as_ref().map_or(true, |(_, cd)| d < *cd) {
                                    closest = Some((i, d));
                                }
                            }
                            if let Some((i, _)) = closest {
                                state.selected_type = Some(obj_type.to_string());
                                state.selected_idx = Some(i);
                                state.selected_vertex = None;
                            }
                        }
                    }
                }

                // Pan
                if resp.dragged_by(egui::PointerButton::Secondary) || resp.dragged_by(egui::PointerButton::Middle) {
                    state.pan_x += drag_delta.x / state.zoom;
                    state.pan_y -= drag_delta.y / state.zoom;
                }
            });

            // Editor controls below the 2D view
            ui.separator();
            if let (Some(ref typ), Some(idx)) = (state.selected_type.clone(), state.selected_idx) {
                let geom = match typ.as_str() {
                    "trigger" => area.triggers.get(idx).map(|t| t.geometry.clone()),
                    "encounter" => area.encounters.get(idx).map(|e| e.geometry.clone()),
                    _ => None,
                };
                let obj_name = match typ.as_str() {
                    "trigger" => area.triggers.get(idx).map(|t| format!("Trigger: {}", t.tag)),
                    "encounter" => area.encounters.get(idx).map(|e| format!("Encounter: {}", e.tag)),
                    _ => None,
                };
                if let Some(name) = obj_name {
                    let geom = geom.unwrap_or_default();
                    ui.strong(format!("{} — {} vertices", name, geom.len()));
                    ui.horizontal(|ui| {
                        if ui.button("+ Add Point (0,0)").clicked() {
                            let mut new_geom = geom.clone();
                            new_geom.push([0.0, 0.0, 0.0]);
                            state.commit = Some((typ.clone(), idx, new_geom));
                        }
                        if ui.button("Delete Selected Vertex").clicked() {
                            if let Some(vi) = state.selected_vertex {
                                if vi < geom.len() {
                                    let mut new_geom = geom.clone();
                                    new_geom.remove(vi);
                                    state.selected_vertex = None;
                                    state.commit = Some((typ.clone(), idx, new_geom));
                                }
                            }
                        }
                    });
                    ui.separator();
                    let mut any_edited = false;
                    let mut new_geom = geom.clone();
                    for (vi, pt) in geom.iter().enumerate() {
                        let is_sel = state.selected_vertex == Some(vi);
                        ui.horizontal(|ui| {
                            let label = if is_sel { format!("→ V{}", vi) } else { format!("  V{}", vi) };
                            ui.label(label);
                            let mut pt_copy = *pt;
                            let mut changed = false;
                            changed |= ui.add(egui::DragValue::new(&mut pt_copy[0]).speed(0.1).prefix("X: ")).changed();
                            changed |= ui.add(egui::DragValue::new(&mut pt_copy[1]).speed(0.1).prefix("Y: ")).changed();
                            changed |= ui.add(egui::DragValue::new(&mut pt_copy[2]).speed(0.1).prefix("Z: ")).changed();
                            if changed {
                                new_geom[vi] = pt_copy;
                                any_edited = true;
                            }
                            if ui.selectable_label(is_sel, "").clicked() {
                                state.selected_vertex = Some(vi);
                            }
                        });
                    }
                    if any_edited {
                        state.commit = Some((typ.clone(), idx, new_geom));
                    }
                }
            }
        });

    if !open {
        state.open = false;
    }
}
