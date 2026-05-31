# Multiple Area Tabs — Implementation Plan

## Goal
Replace the single-area "click-navigator-to-switch" flow with tabbed area editing. Users can open multiple areas simultaneously and switch between them via a tab bar above the viewport.

## Design

### State changes (`AuroraBorealisApp`)
- **Add** `open_areas: Vec<String>` — resrefs of open tabs, in display order
- **Add** `active_area_idx: usize` — index into `open_areas` for the active tab
- Keep `current_area: Option<Arc<Area>>` unchanged (it's used everywhere; tabs just manage which area is current)

`open_areas` stores only resrefs (not `Arc<Area>`) to avoid stale references. On every tab switch, we call `module.get_area(resref)` which uses the LRU cache — fast and always fresh.

### Tab bar rendering
- Insert a new `TopBottomPanel::top("area_tabs")` between the menu bar and the navigator/central panel
- Only shown when `open_areas` is non-empty
- Horizontal bar with tab buttons: `[Area1] [Area2] [Area3]`
- Each tab: clickable label + "×" close button
- Active tab is highlighted (different background)
- Close button removes from `open_areas`; if it was active, switches to nearest neighbor

### Tab operations
- **Switch to tab**: load via `module.get_area()`, set `current_area`, update viewport, clear selection
- **Close tab**: remove from `open_areas`, fix `active_area_idx`, if closed was active switch to neighbor
- **Open tab**: add resref to `open_areas` if not already present, set as active

### Modified navigator click handler
- Currently loads area directly. New behavior: `switch_to_area(name)`
- `switch_to_area()` either finds existing tab or opens new one, then switches to it

### Area creation (New Area dialog)
- After successful creation, call `switch_to_area(new_resref)` to auto-open a tab

### Area deletion
- If deleted area is in `open_areas`, remove it from tabs (same logic as close)

### Files to modify
- `/home/grimshackle/rust-neveredit/aurora-borealis/src/lib.rs` — all state, layout, and logic changes

## Verification
1. Build: `cargo build --release --package aurora-borealis`
2. Run: open a module, click multiple areas in navigator → tabs appear
3. Click tabs → area switches in viewport
4. Close tab with × → tab disappears, switches to neighbor
5. Create new area → tab opens automatically
6. Delete area from navigator → tab closes if open
