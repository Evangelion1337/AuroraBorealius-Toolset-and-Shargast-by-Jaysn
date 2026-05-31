use std::cell::RefCell;
use eframe::egui;
use nwn_gamemodel::Conversation;

pub struct ConversationEditor {
    #[allow(dead_code)]
    pub name: String,
    pub convo: Conversation,
    pub modified: bool,
}

impl ConversationEditor {
    pub fn new(name: String, convo: Conversation) -> Self {
        Self { name, convo, modified: false }
    }
}

struct ConvoEditState {
    next_id: i32,
    new_entry_text: String,
}

thread_local! {
    static EDIT_STATE: RefCell<ConvoEditState> = const { RefCell::new(ConvoEditState {
        next_id: 10000,
        new_entry_text: String::new(),
    }) };
}

pub fn show_conversation_editor(ui: &mut egui::Ui, name: &str, convo: &mut Conversation) -> bool {
    let mut modified = false;
    EDIT_STATE.with(|st_cell| {
        let mut st = st_cell.borrow_mut();

        egui::TopBottomPanel::top("convo_toolbar")
            .show_inside(ui, |ui| {
                ui.horizontal(|ui| {
                    ui.heading(format!("Conversation: {}", name));
                    ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                        ui.label(format!("{} entries", convo.entries.len()));
                        if ui.button("+ Entry").clicked() {
                            let id = st.next_id;
                            st.next_id += 1;
                            let text = if st.new_entry_text.is_empty() {
                                format!("New Entry {}", id)
                            } else {
                                st.new_entry_text.clone()
                            };
                            convo.entries.push(nwn_gamemodel::EntryNode {
                                text,
                                id,
                                replies: Vec::new(),
                            });
                            st.new_entry_text.clear();
                            modified = true;
                        }
                        ui.text_edit_singleline(&mut st.new_entry_text);
                    });
                });
            });

        egui::ScrollArea::vertical().show(ui, |ui| {
            let start_idx = convo.entries.iter().position(|e| e.id == convo.starting_entry);
            if let Some(idx) = start_idx {
                modified |= draw_entry_tree(ui, convo, idx, 0, &mut Vec::new(), &mut st);
            } else if !convo.entries.is_empty() {
                ui.colored_label(
                    egui::Color32::GRAY,
                    format!("(starting entry {} not found, showing first)", convo.starting_entry),
                );
                modified |= draw_entry_tree(ui, convo, 0, 0, &mut Vec::new(), &mut st);
            }
        });
    });
    modified
}

fn draw_entry_tree(
    ui: &mut egui::Ui,
    convo: &mut Conversation,
    idx: usize,
    depth: usize,
    visited: &mut Vec<i32>,
    st: &mut ConvoEditState,
) -> bool {
    let mut modified = false;
    if depth > 20 || idx >= convo.entries.len() {
        return modified;
    }
    let entry_id = convo.entries[idx].id;
    if visited.contains(&entry_id) {
        return modified;
    }
    visited.push(entry_id);

    let header_text = if entry_id == convo.starting_entry {
        format!("[★ {}] {}", entry_id, convo.entries[idx].text)
    } else {
        format!("[{}] {}", entry_id, convo.entries[idx].text)
    };

    egui::CollapsingHeader::new(header_text)
        .default_open(depth < 2)
        .show(ui, |ui| {
            if idx >= convo.entries.len() {
                return;
            }

            let mut edit_text = convo.entries[idx].text.clone();
            if ui.text_edit_singleline(&mut edit_text).changed() {
                convo.entries[idx].text = edit_text;
                modified = true;
            }
            ui.horizontal(|ui| {
                if entry_id == convo.starting_entry {
                    ui.colored_label(egui::Color32::GREEN, "Starting Entry");
                } else if ui.button("Set as Start").clicked() {
                    convo.starting_entry = entry_id;
                    modified = true;
                }
                if ui.button("Delete Entry").clicked() {
                    convo.entries.remove(idx);
                    modified = true;
                    return;
                }
            });

            if idx >= convo.entries.len() {
                return;
            }
            ui.separator();

            // Replies
            let mut to_delete: Option<usize> = None;
            for r_idx in 0..convo.entries[idx].replies.len() {
                if r_idx >= convo.entries[idx].replies.len() {
                    break;
                }
                let reply_id = convo.entries[idx].replies[r_idx].id;
                let reply_text = convo.entries[idx].replies[r_idx].text.clone();
                let reply_next = convo.entries[idx].replies[r_idx].next_entry;

                let mut rt = reply_text;
                ui.horizontal(|ui| {
                    ui.label("Reply:");
                    ui.text_edit_singleline(&mut rt);
                    if ui.button("Apply").clicked() && !rt.is_empty() {
                        convo.entries[idx].replies[r_idx].text = rt.clone();
                        modified = true;
                    }
                    if ui.button("✕").clicked() {
                        to_delete = Some(r_idx);
                        modified = true;
                    }
                });

                let script = convo.entries[idx].replies[r_idx].script.clone();
                if !script.is_empty() {
                    ui.label(
                        egui::RichText::new(format!("    script: {}", script))
                            .color(egui::Color32::from_rgb(86, 156, 214))
                            .italics(),
                    );
                }

                let entry_options: Vec<String> = convo
                    .entries
                    .iter()
                    .map(|e| format!("[{}] {}", e.id, e.text))
                    .collect();
                let current_idx = reply_next
                    .and_then(|id| convo.entries.iter().position(|e| e.id == id))
                    .map(|i| i + 1)
                    .unwrap_or(0);
                let mut selected = current_idx;

                let mut options = vec!["(none)".to_string()];
                options.extend(entry_options);

                egui::ComboBox::from_id_salt(format!("next_entry_{}", reply_id))
                    .selected_text(if current_idx == 0 {
                        "(none)".to_string()
                    } else {
                        options[current_idx].clone()
                    })
                    .show_ui(ui, |ui| {
                        for (opt_idx, opt_text) in options.iter().enumerate() {
                            ui.selectable_value(&mut selected, opt_idx, opt_text);
                        }
                    });

                if selected != current_idx {
                    if selected == 0 {
                        convo.entries[idx].replies[r_idx].next_entry = None;
                    } else if let Some(target_entry) = convo.entries.get(selected - 1) {
                        convo.entries[idx].replies[r_idx].next_entry = Some(target_entry.id);
                    }
                    modified = true;
                }

                if let Some(next_id) = reply_next {
                    if next_id >= 0 {
                        if let Some(next_idx) = convo.entries.iter().position(|e| e.id == next_id) {
                            ui.group(|ui| {
                                modified |= draw_entry_tree(ui, convo, next_idx, depth + 1, visited, st);
                            });
                        } else {
                            ui.label(
                                egui::RichText::new(format!("    -> entry {} (not found)", next_id))
                                    .color(egui::Color32::RED),
                            );
                        }
                    }
                }
            }

            if let Some(r_idx) = to_delete {
                if r_idx < convo.entries[idx].replies.len() {
                    convo.entries[idx].replies.remove(r_idx);
                    modified = true;
                }
            }

            // Add reply button
            ui.horizontal(|ui| {
                let mut rt = String::new();
                ui.text_edit_singleline(&mut rt);
                if ui.button("+ Reply").clicked() {
                    let rid = st.next_id;
                    st.next_id += 1;
                    let rtext = if rt.is_empty() {
                        format!("Reply {}", rid)
                    } else {
                        rt
                    };
                    convo.entries[idx].replies.push(nwn_gamemodel::ReplyNode {
                        text: rtext,
                        id: rid,
                        next_entry: None,
                        script: String::new(),
                    });
                    modified = true;
                }
            });
        });
    modified
}
