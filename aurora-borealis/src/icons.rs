use std::collections::HashMap;
use eframe::egui;
use egui::load::SizedTexture;

const ICON_SIZE: u32 = 24;

pub struct Icons {
    textures: HashMap<String, egui::TextureHandle>,
}

impl Icons {
    pub fn new(ctx: &egui::Context) -> Self {
        let mut textures = HashMap::new();
        let icon_dir = std::path::Path::new(env!("CARGO_MANIFEST_DIR")).join("assets").join("icons");
        if !icon_dir.exists() {
            return Self { textures };
        }
        let entries = match std::fs::read_dir(&icon_dir) {
            Ok(e) => e,
            Err(_) => return Self { textures },
        };
        for entry in entries.flatten() {
            let path = entry.path();
            if path.extension().and_then(|s| s.to_str()) != Some("png") {
                continue;
            }
            let name = match path.file_stem().and_then(|s| s.to_str()) {
                Some(n) => n.to_string(),
                None => continue,
            };
            let bytes = match std::fs::read(&path) {
                Ok(b) => b,
                Err(_) => continue,
            };
            let img = match image::load_from_memory(&bytes) {
                Ok(i) => i,
                Err(_) => continue,
            };
            let gray = img.to_luma8();
            let img = image::imageops::resize(
                &gray, ICON_SIZE, ICON_SIZE,
                image::imageops::FilterType::Lanczos3,
            );
            let (w, h) = img.dimensions();
            let mut rgba = Vec::with_capacity((w * h * 4) as usize);
            for y in 0..h {
                for x in 0..w {
                    let a = img.get_pixel(x, y)[0];
                    rgba.push(255);
                    rgba.push(255);
                    rgba.push(255);
                    rgba.push(a);
                }
            }
            let color_image = egui::ColorImage::from_rgba_unmultiplied(
                [w as usize, h as usize],
                &rgba,
            );
            let handle = ctx.load_texture(
                &format!("icon_{}", name),
                color_image,
                egui::TextureOptions::LINEAR,
            );
            textures.insert(name, handle);
        }
        Self { textures }
    }

    pub fn get(&self, name: &str) -> Option<&egui::TextureHandle> {
        self.textures.get(name)
    }

    #[allow(dead_code)]
    pub fn icon_toggle(&self, ui: &mut egui::Ui, name: &str, tooltip: &str, selected: bool, size: f32) -> egui::Response {
        if let Some(tex) = self.get(name) {
            let sized = SizedTexture::new(tex.id(), egui::vec2(size, size));
            let img = egui::Image::from_texture(sized);
            let btn = egui::ImageButton::new(img)
                .frame(selected)
                .selected(selected);
            ui.add(btn).on_hover_text(tooltip)
        } else {
            ui.selectable_label(selected, tooltip)
        }
    }

    fn text_icon_layout(&self, ui: &mut egui::Ui, label: &str, icon: &str, selected: bool, size: f32) -> egui::Response {
        let font_id = egui::FontId::proportional(9.0);
        let text_w = ui.fonts(|f| {
            let g = f.layout_no_wrap(label.to_string(), font_id.clone(), egui::Color32::WHITE);
            g.size().x
        });
        let icon_gap = if icon.is_empty() { 0.0 } else { 12.0 };
        let total_w = text_w + 4.0 + icon_gap;
        let height = (size + 2.0).max(14.0);
        let (id, rect) = ui.allocate_space(egui::vec2(total_w.max(18.0), height));
        let resp = ui.interact(rect, id, egui::Sense::click());
        let painter = ui.painter_at(rect);
        if selected || resp.hovered() {
            let bg = if selected { egui::Color32::from_rgb(60, 100, 180) } else { egui::Color32::from_rgb(50, 50, 60) };
            painter.rect_filled(rect, 2.0, bg);
        }
        painter.text(egui::pos2(rect.min.x + 4.0, rect.center().y), egui::Align2::LEFT_CENTER, label, font_id, egui::Color32::WHITE);
        if let Some(tex) = self.get(icon) {
            let ix = rect.min.x + 4.0 + text_w + 4.0;
            let ir = egui::Rect::from_min_size(egui::pos2(ix, rect.min.y + (height - size) / 2.0), egui::vec2(size, size));
            let uv = egui::Rect::from_min_max(egui::pos2(0.0, 0.0), egui::pos2(1.0, 1.0));
            painter.image(tex.id(), ir, uv, egui::Color32::WHITE);
        }
        resp.on_hover_text(label)
    }

    pub fn label_toggle(&self, ui: &mut egui::Ui, label: &str, icon: &str, selected: bool, size: f32) -> egui::Response {
        self.text_icon_layout(ui, label, icon, selected, size)
    }

    pub fn label_button(&self, ui: &mut egui::Ui, label: &str, icon: &str, size: f32) -> egui::Response {
        self.text_icon_layout(ui, label, icon, false, size)
    }

    pub fn big_label_button(&self, ui: &mut egui::Ui, label: &str, icon: &str) -> egui::Response {
        let font_id = egui::FontId::proportional(11.0);
        let text_w = ui.fonts(|f| {
            let g = f.layout_no_wrap(label.to_string(), font_id.clone(), egui::Color32::WHITE);
            g.size().x
        });
        let icon_gap = if icon.is_empty() { 0.0 } else { 12.0 };
        let total_w = text_w + 6.0 + icon_gap;
        let height = 18.0;
        let (id, rect) = ui.allocate_space(egui::vec2(total_w.max(48.0), height));
        let resp = ui.interact(rect, id, egui::Sense::click());
        let painter = ui.painter_at(rect);
        let bg = if resp.hovered() {
            egui::Color32::from_rgb(70, 120, 200)
        } else {
            egui::Color32::from_rgb(50, 80, 160)
        };
        painter.rect_filled(rect, 3.0, bg);
        if resp.hovered() {
            painter.rect_stroke(rect, 3.0, egui::Stroke::new(1.0_f32, egui::Color32::from_rgb(120, 170, 255)), egui::StrokeKind::Inside);
        }
        painter.text(egui::pos2(rect.min.x + 6.0, rect.center().y), egui::Align2::LEFT_CENTER, label, font_id, egui::Color32::WHITE);
        if let Some(tex) = self.get(icon) {
            let ix = rect.min.x + 6.0 + text_w + 6.0;
            let ir = egui::Rect::from_min_size(egui::pos2(ix, rect.min.y + (height - 18.0) / 2.0), egui::vec2(18.0, 18.0));
            let uv = egui::Rect::from_min_max(egui::pos2(0.0, 0.0), egui::pos2(1.0, 1.0));
            painter.image(tex.id(), ir, uv, egui::Color32::WHITE);
        }
        resp.on_hover_text(label)
    }

    pub fn icon_button(&self, ui: &mut egui::Ui, name: &str, tooltip: &str, size: f32) -> egui::Response {
        if let Some(tex) = self.get(name) {
            let sized = SizedTexture::new(tex.id(), egui::vec2(size, size));
            let img = egui::Image::from_texture(sized);
            let btn = egui::ImageButton::new(img)
                .frame(false)
                .selected(false);
            ui.add(btn).on_hover_text(tooltip)
        } else {
            ui.button(tooltip)
        }
    }

    #[allow(dead_code)]
    pub fn icon_image(&self, ui: &mut egui::Ui, name: &str, size: f32) -> egui::Response {
        if let Some(tex) = self.get(name) {
            let sized = SizedTexture::new(tex.id(), egui::vec2(size, size));
            ui.image(sized)
        } else {
            ui.label("?")
        }
    }
}
