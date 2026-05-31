# rust-neveredit — Agent Status

## Toolbar (3 scrollable bars)
- **File**: Open, Recent, Save, SaveAs, Props, Minimap export, Launch NWN, Quit, Modified indicator
- **View**: Window toggles (Res, BP, Items, Search, Tree, Con, Palette, Graph, Height, Nav, Mini, Sky) | render toggles (Tiles, Grid, Light, Fog, Walk, WEdges, Paint, Sprite, Water, Snap) | marks toggles (Creature, Doors, Placeable, Trigger, Waypoint, Encounter, Sound, Light) | "..." overflow
- **Tools**: Editor toggles (Env, Factions, Journal, Enc, Tex, Sound, Store, Whois, Geom, Find, Trans) | edit actions (New, Copy, Paste, Del) | Undo, Redo | bookmarks + NWSync (right-aligned)
- **Pattern**: `TopBottomPanel::top` + `ScrollArea::horizontal`, 1px item spacing, `label_toggle`/`label_button` (text + icon at 12px), `icon_button` (16px) for utility buttons.

## Rendering Fixes
- **Minimap overlay** & **ghost preview**: Fixed — were hidden behind 3D paint callback (egui renders shapes before paint callbacks in same layer). Now render in `Order::Foreground` layer.

## Data Loading
- **Faction/Journal editors**: Fallback lookups (`repute.fac`, `module.jrl`) since NWN modules use these names.
- **Appearance Picker**: Uses `resource_manager.get_2da("appearance")`.
- **`get_resource_data`**: Hak fallback + FAC/JRL alias swaps.
- **`resource_list`**: Includes hak resources.
- **Transition Editor**: ERF fallback for GIT data.
- **Encounter Editor**: `selected_idx` persisted.

## Tileset Loading Fixes
- **KEY header offsets**: Custom parser in `game_data.rs::parse_key` was reading BIF table offset from header[20..24] (should be [16..20]) and key table offset from [24..28] (should be [20..24]). The nwnrs-types KEY parser was always correct.
- **BIF header parsing**: `parse_bif_header` was using `FixedResourceCount` at header offset 12 instead of `VariableResourceCount` at offset 8.
- **KEY entry stride**: Fixed from 26 bytes to 22 bytes (16 resref + 2 restype + 4 resid).
- **ERF key entry format**: Haks like `cep2_ext_tiles.hak` use non-standard entries: bytes 16-17 hold sequential index (not resource type), type is stored as u32 at bytes 20-23. `extract_resource_from_erf` reads bytes 20-21 as u16, which works for this format.
- **ERF header offsets**: Keys offset at header[24..28] and resources offset at header[28..32] confirmed correct (localized strings at [20..24]).
- **`preload_tilesets`**: Now actually stores results in `tileset_cache` instead of collecting and discarding.
- **`find_and_load_tileset`**: No longer bails on `Tileset::from_bytes` parse errors — logs warning and continues searching other sources.
- **`find_tileset_in_game_data`**: No longer propagates parse errors — returns `Ok(None)` with warning.
- All 21 module tilesets exist in `nwn_base.key` with type 2013. nwnrs-types KEY/BIF parser uses correct offsets, so game data lookup should find them all.

## Known Issues
- `gff.get_int` exists but `parse_tile_list` used direct pattern-match on `FieldValue::Int`, which missed `FieldValue::Byte` for Tile_Height and Tile_Orientation, and `FieldValue::DWord` for Tile_ID. Fixed with `int_from_field` helper that handles all int-like types. (`nwn-gamemodel/src/area.rs:434`)
- Area Geometry Editor empty if area has no triggers/encounters
- Audio resources (WAV/BMU) missing from ERF (game data / haks only)
- `nwn_retail.key` has 93 entries that SHOULD fit at correct offset (89), verify

## Rendering Fixes (Session)
- Texture memory minimum: 2048 MB (was 1024 MB). Slider range: 2048..=4096.
- Drag commit: skips `set_area` rebuild when object hasn't moved (fixes one-frame black flash on click).
- Multi-select: `selection_list` now includes primary selection; all selected objects get wireframe highlights.
- Visibility filter: `update_visibility_filter` now calls `set_area` to apply immediately.
- Vertex-colored primitives: use `mat.diffuse * 0.5` instead of `[1,1,1,1]` fallback. Halves the color to compensate for the shader's (ambient + diffuse) lighting ≈ 1.166x multiplier that would over-brighten white to white (`nwn-tileset/src/lib.rs`).
- See-through fix: main pipeline blend changed from OVER to REPLACE (ignores alpha) (`nwn-3d/src/pipeline.rs`).



## Key Files
- `aurora-borealis/src/lib.rs` — main app
- `aurora-borealis/src/icons.rs` — `label_toggle`, `label_button`, `text_icon_layout`
- `nwn-gamemodel/src/module.rs` — `get_resource_data`, `resource_list`, `preload_tilesets`
- `nwn-tileset/src/lib.rs` — `find_and_load_tileset`, `find_tileset_in_game_data`, `extract_resource_from_erf`
- `nwn-gamemodel/src/game_data.rs` — `parse_key`, `parse_bif_header`
