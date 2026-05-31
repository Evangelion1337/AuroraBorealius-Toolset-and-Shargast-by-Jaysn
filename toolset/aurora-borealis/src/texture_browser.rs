use std::io::Cursor;
use eframe::egui;
use eframe::egui::load::SizedTexture;
use nwn_gamemodel::Module;
use nwn_gamemodel::resource_types;
use nwnrs_types::dds::DdsTexture;
use nwnrs_types::tga;
use nwnrs_types::mdl::parse_scene_model_auto;

struct TextureEntry {
    resref: String,
    ext: String,
    restype: u16,
}

#[derive(PartialEq)]
enum ResCategory {
    All,
    Textures,
    Models,
}

pub struct TextureBrowserState {
    pub open: bool,
    textures: Vec<TextureEntry>,
    filter: String,
    category: ResCategory,
    selected: Option<usize>,
    preview_texture: Option<egui::TextureHandle>,
    preview_width: u32,
    preview_height: u32,
    zoom: f32,
    model_info: Option<String>,
}

impl Default for TextureBrowserState {
    fn default() -> Self {
        Self {
            open: false,
            textures: Vec::new(),
            filter: String::new(),
            category: ResCategory::Textures,
            selected: None,
            preview_texture: None,
            preview_width: 0,
            preview_height: 0,
            zoom: 1.0,
            model_info: None,
        }
    }
}

fn decode_texture(data: &[u8], restype: u16) -> Option<(u32, u32, Vec<u8>)> {
    if restype == resource_types::DDS {
        let dds = DdsTexture::read_from_texture_bytes(data).ok()?;
        let rgba = dds.decode_mip_rgba8(0).ok()?;
        Some((dds.width, dds.height, rgba))
    } else if restype == resource_types::TGA || restype == resource_types::PLT || restype == resource_types::BMP {
        let img = tga::read_tga(&mut Cursor::new(data)).ok()?;
        let rgba = img.decode_rgba8().ok()?;
        Some((img.width as u32, img.height as u32, rgba))
    } else {
        None
    }
}

impl TextureBrowserState {
    fn refresh(&mut self, module: &Module) {
        let res_list = module.resource_list();
        let texture_types = [resource_types::DDS, resource_types::TGA, resource_types::PLT, resource_types::BMP];
        let mut textures: Vec<TextureEntry> = res_list.iter()
            .filter(|(_, rt)| texture_types.contains(rt) || *rt == resource_types::MDL)
            .map(|(resref, restype)| {
                let ext = resource_types::type_to_ext(*restype).unwrap_or("???");
                TextureEntry {
                    resref: resref.clone(),
                    ext: ext.to_lowercase(),
                    restype: *restype,
                }
            })
            .collect();
        textures.sort_by(|a, b| a.resref.to_lowercase().cmp(&b.resref.to_lowercase()));
        self.textures = textures;
        self.selected = None;
        self.preview_texture = None;
        self.model_info = None;
    }

    fn load_preview(&mut self, module: &Module, ctx: &egui::Context) {
        let Some(idx) = self.selected else { return; };
        let Some(entry) = self.textures.get(idx) else { return; };
        let Some(data) = module.get_resource_data(&entry.resref, entry.restype) else { return; };
        let name = format!("{}.{}", entry.resref, entry.ext);
        if entry.restype == resource_types::MDL {
            self.preview_texture = None;
            self.model_info = Some(parse_mdl_info(&data, &entry.resref));
            return;
        }
        self.model_info = None;
        if let Some((w, h, rgba)) = decode_texture(&data, entry.restype) {
            if w > 0 && h > 0 && !rgba.is_empty() {
                let color_image = egui::ColorImage::from_rgba_unmultiplied(
                    [w as usize, h as usize],
                    &rgba,
                );
                let handle = ctx.load_texture(
                    &name,
                    color_image,
                    egui::TextureOptions::LINEAR,
                );
                self.preview_texture = Some(handle);
                self.preview_width = w;
                self.preview_height = h;
            }
        }
    }

    fn filtered_entries(&self) -> Vec<(usize, String)> {
        self.textures.iter().enumerate()
            .filter(|(_, e)| {
                let cat_match = match self.category {
                    ResCategory::All => true,
                    ResCategory::Textures => e.restype != resource_types::MDL,
                    ResCategory::Models => e.restype == resource_types::MDL,
                };
                let filter_match = self.filter.is_empty()
                    || format!("{}.{}", e.resref, e.ext).to_lowercase().contains(&self.filter.to_lowercase())
                    || e.resref.to_lowercase().contains(&self.filter.to_lowercase());
                cat_match && filter_match
            })
            .map(|(i, e)| (i, format!("{}.{}", e.resref, e.ext)))
            .collect()
    }
}

fn parse_mdl_info(data: &[u8], name: &str) -> String {
    match parse_scene_model_auto(data) {
        Ok(scene) => {
            let mut info = format!("Model: {}\nNodes: {}\n", name, scene.nodes.len());
            let mut mesh_count = 0;
            let mut total_verts = 0;
            let mut textures = std::collections::BTreeSet::new();
            for mesh in &scene.meshes {
                mesh_count += 1;
                for prim in &mesh.primitives {
                    total_verts += prim.positions.len();
                    for tex in &prim.texture_names {
                        if !tex.is_empty() { textures.insert(tex.clone()); }
                    }
                }
            }
            info.push_str(&format!("Meshes: {}\nVertices: {}\n", mesh_count, total_verts));
            if !textures.is_empty() {
                info.push_str("Textures:\n");
                for t in &textures {
                    info.push_str(&format!("  {}\n", t));
                }
            }
            info.push_str("\nNode Hierarchy:\n");
            for node in &scene.nodes {
                let indent = "  ".repeat(node.parent.map(|_| 1).unwrap_or(0));
                info.push_str(&format!("{}{:?}\n", indent, node.kind));
            }
            info
        }
        Err(e) => format!("Failed to parse MDL '{}': {}", name, e),
    }
}

pub fn show_texture_browser(
    ctx: &egui::Context,
    state: &mut TextureBrowserState,
    module: &Option<Module>,
) {
    let module_ref = match module {
        Some(m) => m,
        None => {
            let mut open = true;
            egui::Window::new("Texture Browser")
                .open(&mut open)
                .show(ctx, |ui| {
                    ui.label("No module loaded.");
                });
            if !open { state.open = false; }
            return;
        }
    };

    if state.textures.is_empty() {
        state.refresh(module_ref);
    }

    let mut open = state.open;
    let mut needs_refresh = false;
    let mut clicked_idx = None;
    let mut new_zoom = state.zoom;
    let mut filter_buf = state.filter.clone();

    let preview_w = state.preview_width;
    let preview_h = state.preview_height;
    let selected = state.selected;
    let has_preview = state.preview_texture.is_some();

    egui::Window::new("Texture Browser")
        .default_size([700.0, 500.0])
        .open(&mut open)
        .show(ctx, |ui| {
            ui.horizontal(|ui| {
                ui.label("Filter:");
                ui.text_edit_singleline(&mut filter_buf);
                ui.separator();
                ui.label("Type:");
                egui::ComboBox::from_id_salt("res_type_filter")
                    .selected_text(match state.category {
                        ResCategory::All => "All",
                        ResCategory::Textures => "Textures",
                        ResCategory::Models => "Models",
                    })
                    .show_ui(ui, |ui| {
                        ui.selectable_value(&mut state.category, ResCategory::All, "All");
                        ui.selectable_value(&mut state.category, ResCategory::Textures, "Textures");
                        ui.selectable_value(&mut state.category, ResCategory::Models, "Models");
                    });
                if ui.button("Refresh").clicked() {
                    needs_refresh = true;
                }
            });
            ui.separator();

            state.filter = filter_buf;
            let filtered = state.filtered_entries();

            egui::SidePanel::left("texture_list")
                .resizable(true)
                .default_width(250.0)
                .show_inside(ui, |ui| {
                    ui.label(format!("{} resources", filtered.len()));
                    ui.separator();
                    egui::ScrollArea::vertical().show(ui, |ui| {
                        for (orig_idx, label) in &filtered {
                            let sel = selected == Some(*orig_idx);
                            if ui.selectable_label(sel, label).clicked() {
                                clicked_idx = Some(*orig_idx);
                            }
                        }
                    });
                });

            egui::CentralPanel::default().show_inside(ui, |ui| {
                if let Some(ref info) = state.model_info {
                    egui::ScrollArea::both().show(ui, |ui| {
                        ui.label(
                            egui::RichText::new(info.as_str()).code()
                        );
                    });
                } else if has_preview {
                    if let Some(ref tex_handle) = state.preview_texture {
                        let max_w = ui.available_width().max(100.0);
                        let max_h = ui.available_height().max(100.0);
                        let img_w = preview_w as f32 * new_zoom;
                        let img_h = preview_h as f32 * new_zoom;
                        let scale = ((max_w / img_w).min(max_h / img_h)).min(1.0).max(0.1);
                        let disp_w = img_w * scale;
                        let disp_h = img_h * scale;
                        ui.add(egui::Image::new(SizedTexture::new(tex_handle, egui::Vec2::new(disp_w, disp_h))));
                    }
                    ui.separator();
                    ui.label(format!("Size: {}x{}", preview_w, preview_h));
                    ui.horizontal(|ui| {
                        ui.label("Zoom:");
                        ui.add(egui::Slider::new(&mut new_zoom, 0.1..=5.0).text(""));
                    });
                } else if selected.is_some() {
                    ui.label("Failed to load resource.");
                } else {
                    ui.label("Select a resource to preview.");
                }
            });
        });

    state.open = open;
    state.zoom = new_zoom;
    if needs_refresh {
        state.refresh(module_ref);
    }
    if let Some(idx) = clicked_idx {
        state.selected = Some(idx);
        state.load_preview(module_ref, ctx);
    }
}
