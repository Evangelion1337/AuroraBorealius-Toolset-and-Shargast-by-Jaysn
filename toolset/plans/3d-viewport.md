# 3D Area Map Viewport Implementation Plan

## Goal
Replace the placeholder 2D text stats with a real 3D wgpu viewport that shows the area tile grid with colored tiles, instance markers, and mouse-driven orbit camera controls.

## Architecture

```
aurora-borealis (egui/eframe app)
  └── CentralPanel ──> allocate_painter() ──> egui_wgpu::Callback
                                                    │
                                                    ▼
                                            nwn-3d (3D renderer crate)
                                              ├── ViewportCallback (impl CallbackTrait)
                                              ├── TileRenderer (procedural mesh generation)
                                              ├── Camera (orbit controls)
                                              └── Pipeline (wgpu shaders)
```

## Files to Modify

### 1. `aurora-borealis/Cargo.toml`
- Change `eframe = "0.31"` to `eframe = { version = "0.31", default-features = false, features = ["wgpu", "default_fonts", "accesskit"] }`
- Add `nwn-3d = { path = "../nwn-3d" }`
- Add `egui-wgpu = "0.31"`

### 2. `nwn-3d/Cargo.toml` (currently empty skeleton)
- Add dependencies: `wgpu`, `egui`, `egui-wgpu`, `nwn-gamemodel`

### 3. `nwn-3d/src/lib.rs` (NEW: full 3D renderer)
- `mod camera; mod pipeline; mod viewport; mod tile_renderer;`
- `pub use viewport::*;`

### 4. `nwn-3d/src/camera.rs` (NEW)
- `OrbitCamera` struct:
  - `theta: f32` (horizontal angle), `phi: f32` (vertical angle), `radius: f32` (zoom distance)
  - `target: Vec3` (center point = area center)
  - `update(delta: MouseDelta) -> bool`
  - `view_matrix() -> Mat4`
  - `projection_matrix(aspect) -> Mat4`

### 5. `nwn-3d/src/pipeline.rs` (NEW)
- Wgpu render pipeline:
  - Simple vertex shader with MVP matrix
  - Fragment shader with per-instance color
  - Two rendering layers: (1) tile grid, (2) instance markers
- `pub struct TilePipeline { pipeline, uniforms, bind_group, vertex_buf, index_buf }`
- `fn update_mesh(device, queue, tiles: &[TileInfo], width, height, objects: &[InstMarker])`

### 6. `nwn-3d/src/tile_renderer.rs` (NEW)
- Procedural mesh generation from area tile data:
  - Flat quads at each tile position (10x10 NWN units)
  - Color = hash(Tile_ID) for visual distinction
  - Orientation arrow: small triangle showing rotation
  - Height offset based on Tile_Height
- Instance markers:
  - Creatures: red cones/dots
  - Doors: gold dots
  - Placeables: blue dots
  - Waypoints: green dots
  - Triggers: purple rectangles

### 7. `nwn-3d/src/viewport.rs` (NEW)
- `pub struct WgpuViewport { camera: OrbitCamera, pipeline: TilePipeline, ... }`
- Implements `egui_wgpu::CallbackTrait`:
  - `prepare()`: update camera uniforms, rebuild mesh if area changed
  - `paint()`: issue draw calls into the render pass
- `fn set_area(&mut self, area: &Area)` — called when user selects a new area

### 8. `aurora-borealis/src/main.rs`
- Add `WgpuViewport` to `AuroraBorealisApp` state
- Store wgpu `RenderState` from `CreationContext`/`Frame`
- Replace CentralPanel area detail → allocate viewport rect → `Callback::new_paint_callback(rect, viewport)`
- Pass area data to viewport when selection changes

## Implementation Order (MVP)

1. **Configure wgpu** — Cargo.toml changes, verify eframe starts with wgpu backend
2. **Create nwn-3d crate** — struct skeleton, trait implementations
3. **Basic 3D viewport** — colored triangle/quads test in the viewport widget
4. **Orbit camera** — mouse drag rotation, scroll zoom
5. **Tile grid** — procedural colored quads from ARE Tile_List
6. **Instance markers** — dots for creatures/doors/placeables/waypoints
7. **Integration** — wire area selection to viewport update
8. **Polish** — grid lines, orientation markers, height tinting

## Coordinate System
- NWN world: X right, Y up, Z forward (left-handed)
- WGPU: X right, Y up, Z out of screen (right-handed)
- Convert: NWN (x, y, z) → WGPU (x, z, y) [swap Y and Z]
- Tile position: `tile_x * 10.0` for X, `-tile_y * 10.0` for Z
- Tile height: Y = `tile.height * 0.5` (rough scaling)
- Instance positions: scale x/10.0, z/10.0 for tile-relative position

## Verification
1. `cargo build -p aurora-borealis` — compiles with wgpu
2. Launch `./target/debug/aurora-borealis` — GUI appears
3. Open a module → click an area → see 3D grid of colored tiles
4. Drag mouse to orbit, scroll to zoom
5. Colored dots appear for creatures, doors, placeables, waypoints
