use eframe::egui;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Tool {
    Select,
    TerrainRaise,
    TerrainSmooth,
    WalkmeshWall,
}

impl Tool {
    pub fn name(self) -> &'static str {
        match self {
            Tool::Select => "Select",
            Tool::TerrainRaise => "Terrain",
            Tool::TerrainSmooth => "Smooth",
            Tool::WalkmeshWall => "Walkmesh",
        }
    }

    pub fn description(self) -> &'static str {
        match self {
            Tool::Select => "Click to select, drag to move",
            Tool::TerrainRaise => "Click to raise terrain, Shift+click to lower",
            Tool::TerrainSmooth => "Click to smooth terrain heights",
            Tool::WalkmeshWall => "Click walkmesh edges to toggle walls",
        }
    }

    pub fn hotkey(self) -> &'static str {
        match self {
            Tool::Select => "1",
            Tool::TerrainRaise => "2",
            Tool::TerrainSmooth => "3",
            Tool::WalkmeshWall => "4",
        }
    }
}

pub fn show_tools_panel(ui: &mut egui::Ui, active_tool: &mut Tool, terrain_raise_amount: &mut i32, terrain_smooth_radius: &mut i32) {
    egui::Grid::new("tools_grid")
        .num_columns(2)
        .striped(true)
        .show(ui, |ui| {
            for tool in [Tool::Select, Tool::TerrainRaise, Tool::TerrainSmooth, Tool::WalkmeshWall] {
                let is_active = *active_tool == tool;
                let btn = egui::Button::new(format!("{}  {}", tool.hotkey(), tool.name()))
                    .min_size([120.0, 28.0].into())
                    .fill(if is_active { ui.style().visuals.selection.bg_fill } else { ui.style().visuals.widgets.inactive.bg_fill });

                if ui.add(btn).clicked() {
                    *active_tool = tool;
                }

                ui.label(tool.description());
                ui.end_row();
            }
        });

    if *active_tool == Tool::TerrainRaise {
        ui.horizontal(|ui| {
            ui.label("Raise amount:");
            ui.add(egui::Slider::new(terrain_raise_amount, 1..=10));
        });
    }

    if *active_tool == Tool::TerrainSmooth {
        ui.horizontal(|ui| {
            ui.label("Radius:");
            ui.add(egui::Slider::new(terrain_smooth_radius, 1..=5));
        });
    }
}
