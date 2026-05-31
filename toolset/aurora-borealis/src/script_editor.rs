use eframe::egui;
use eframe::egui::text::LayoutJob;

fn highlight_line(line: &str, base_offset: usize, job: &mut LayoutJob) {
    let keywords = [
        "int", "float", "string", "object", "void", "vector", "action",
        "struct", "talent", "effect", "itemproperty", "location",
        "if", "else", "switch", "case", "default", "break",
        "while", "for", "do", "continue", "return",
        "const", "extern", "static",
    ];
    let constants = ["TRUE", "FALSE", "true", "false"];
    let mut i = 0;
    while i < line.len() {
        let c = line[i..].chars().next().unwrap();
        let c_len = c.len_utf8();
        if c.is_ascii_digit() {
            let start = i;
            while i < line.len() {
                let ch = line[i..].chars().next().unwrap();
                if ch.is_ascii_digit() || ch == '.' { i += ch.len_utf8(); } else { break; }
            }
            append_section(job, base_offset + start, base_offset + i, egui::Color32::from_rgb(181, 137, 0));
        } else if c.is_ascii_alphabetic() || c == '_' {
            let start = i;
            while i < line.len() {
                let ch = line[i..].chars().next().unwrap();
                if ch.is_alphanumeric() || ch == '_' { i += ch.len_utf8(); } else { break; }
            }
            let word = &line[start..i];
            let color = if keywords.contains(&word) {
                egui::Color32::from_rgb(86, 156, 214)
            } else if constants.contains(&word) {
                egui::Color32::from_rgb(78, 201, 176)
            } else {
                egui::Color32::from_rgb(212, 212, 212)
            };
            append_section(job, base_offset + start, base_offset + i, color);
        } else if c == '/' && i + 1 < line.len() && line.as_bytes()[i + 1] == b'/' {
            append_section(job, base_offset + i, base_offset + line.len(), egui::Color32::from_rgb(106, 153, 85));
            break;
        } else if c == '"' {
            let start = i;
            i += c_len;
            while i < line.len() {
                let ch = line[i..].chars().next().unwrap();
                i += ch.len_utf8();
                if ch == '"' { break; }
                if ch == '\\' && i < line.len() { i += line[i..].chars().next().unwrap().len_utf8(); }
            }
            append_section(job, base_offset + start, base_offset + i, egui::Color32::from_rgb(206, 145, 120));
        } else if c == '\'' {
            let start = i;
            i += c_len;
            if i < line.len() { i += line[i..].chars().next().unwrap().len_utf8(); }
            if i < line.len() && line.as_bytes()[i] == b'\'' { i += 1; }
            append_section(job, base_offset + start, base_offset + i, egui::Color32::from_rgb(206, 145, 120));
        } else {
            let color = match c {
                '(' | ')' | '{' | '}' | '[' | ']' => egui::Color32::from_rgb(255, 215, 0),
                '+' | '-' | '*' | '/' | '%' | '=' | '!' | '<' | '>' | '&' | '|' | '~' | '^' | '?' => egui::Color32::from_rgb(220, 220, 220),
                ';' | ',' | '.' | ':' => egui::Color32::from_rgb(180, 180, 180),
                '#' => egui::Color32::from_rgb(106, 153, 85),
                _ => egui::Color32::from_rgb(212, 212, 212),
            };
            append_section(job, base_offset + i, base_offset + i + c_len, color);
            i += c_len;
        }
    }
}

fn append_section(job: &mut LayoutJob, start: usize, end: usize, color: egui::Color32) {
    if end <= start { return; }
    job.sections.push(egui::text::LayoutSection {
        leading_space: 0.0,
        byte_range: start..end,
        format: egui::text::TextFormat {
            color,
            ..Default::default()
        },
    });
}

pub fn highlight_code(text: &str) -> LayoutJob {
    let mut job = LayoutJob {
        text: String::new(),
        sections: Vec::new(),
        wrap: egui::text::TextWrapping {
            max_width: f32::INFINITY,
            max_rows: usize::MAX,
            overflow_character: None,
            break_anywhere: true,
            ..Default::default()
        },
        ..Default::default()
    };
    for line in text.lines() {
        let base = job.text.len();
        job.text.push_str(line);
        job.text.push('\n');
        if line.is_empty() {
            append_section(&mut job, base, base + 1, egui::Color32::from_rgb(212, 212, 212));
        } else {
            highlight_line(line, base, &mut job);
            // Fill remaining gap (after last span to newline)
            let last_end = job.sections.last().map(|s| s.byte_range.end).unwrap_or(base);
            let line_end = base + line.len();
            if last_end < line_end {
                append_section(&mut job, last_end, line_end, egui::Color32::from_rgb(212, 212, 212));
            }
        }
    }
    job
}

pub fn show_script_editor(ui: &mut egui::Ui, name: &str, source: &mut String, modified: &mut bool) -> bool {
    let mut compile = false;
    egui::TopBottomPanel::top("script_toolbar")
        .show_inside(ui, |ui| {
            ui.horizontal(|ui| {
                ui.heading(format!("Script: {}", name));
                ui.with_layout(egui::Layout::right_to_left(egui::Align::Center), |ui| {
                    let save_label = if *modified { "Save *" } else { "Save" };
                    if ui.button(save_label).clicked() {
                        *modified = false;
                    }
                    if ui.button("Compile to NCS").on_hover_text("Compile script to NCS bytecode").clicked() {
                        compile = true;
                    }
                });
            });
        });

    let theme = egui::style::Visuals::dark();
    *ui.visuals_mut() = theme;

    let mut layouter = |ui: &egui::Ui, text: &str, wrap_width: f32| {
        let mut layout_job = highlight_code(text);
        layout_job.wrap.max_width = wrap_width;
        ui.fonts(|f| f.layout_job(layout_job))
    };

    let resp = egui::TextEdit::multiline(source)
        .font(egui::TextStyle::Monospace)
        .code_editor()
        .desired_width(f32::INFINITY)
        .desired_rows(40)
        .layouter(&mut layouter)
        .show(ui);

    if resp.response.changed() {
        *modified = true;
    }

    compile
}
