# WilliCat Playable Placeholder Reset V1 — result

Status: **playable isolated dev prototype**. Production Home, locked Home V3, final art, and project main-scene setting are unchanged. This pass stops environment image generation and uses only existing project-owned primitive/graybox visuals.

## Launch and controls

Open `res://scenes/dev/playable_placeholder/playable_world.tscn` in Godot 4.7.2 and run the current scene, or use:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/teddywoot/willi-cat --scene res://scenes/dev/playable_placeholder/playable_world.tscn
```

The first customer visit begins automatically. The first completed order grants one coin and unlocks Back Garden. Subsequent visits start with **LOOP** or `R`. **GARDEN** / `G`, or tapping the visible Back Door after unlock, travels to the garden; **CAFÉ** / `B`, or tapping Garden Door, returns. **CAT** / `C` assigns Mochi to the active room. A garden arrival triggers a simple sniff action. Only the active room has scene nodes; cat assignment survives room unload.

**VIEW** / `1` selects whole-room overview, **ZOOM** / `2` selects closer gameplay view, and **FOCUS** / `3` briefly focuses the cat through CameraDirector. Mouse wheel or two-finger pinch zooms; dragging pans within bounds. **MOVE** / `F8` toggles furniture mode: drag a table/chair, release to validate and confirm, or press `Esc` to cancel. Invalid footprints and moves that disconnect required café routes roll back. Rotation is not offered in V1. **SAVE** / `S` saves at a safe checkpoint; **LOAD** / `L` restores the saved room, furniture delta, cat room, first-order garden unlock and coin. Saved data is at `user://willicat_placeholder_reset_v1.save`, separate from production saves.

## Rooms, objects, and systems

`playable_world.tscn` hosts one room at a time. `main_cafe.tscn` is a plain rectangle with reusable Counter, POS, PastryCase, EspressoStation, GrinderStation, two tables/four chairs, CatBed, ScratchPost, Plant, Entrance and Back Door. `back_garden.tscn` has a bench, plant patch, SunSpot, CatSniff/CatRest points and return door. Authored scene transforms own positions; reused object scenes own InteractionSlots, anchors and PhysicalFootprints. The generic actor uses NavigationAgent2D and the same slot reservation/action/release lifecycle; no character behavior contains Home coordinates. Room-local navigation is rebuilt on confirmed furniture moves, not during drag.

The café adapter sequences one customer: enter → order → coffee preparation → carry cup → serve → sit → leave → worker idle → reward. The order bubble, steam, cup and reward label are temporary placeholders. The reward handler uses a stable order receipt to prevent duplicate grant. No economy balancing, production character art, or new animation pipeline was added. The garden and café use the same generic room/actor/slot architecture. CameraDirector remains focus-shot owner; a dev camera-input adapter adds clamped overview/default/pinch/pan.

Persistence stores a primitive, versioned world snapshot with `(room_id, instance_id)` furniture deltas, active room/spawn, logical cat room/activity, unlocked room IDs, coins and reward receipts. It does not serialize room scenes, node paths, nav state or animation frames. The save is written to a temporary file and read back before replacement; a prior file is copied to `.bak` when present. This is a prototype codec, **not** a proven mobile-atomic save or migration implementation.

## Asset provenance and license

Only existing WilliCat repository graybox object/actor scenes and Godot-drawn primitive shapes were used. No third-party pack, external asset, AI-generated art, or copied game layout was introduced. The new screenshots are runtime captures, not runtime textures. There is no external attribution requirement for this pass.

## Evidence and tests

| Capture | What it shows | Result |
|---|---|---|
| [01_main_cafe.png](../../artifacts/prototype_review/playable_placeholder_reset_v1/01_main_cafe.png) | Main Café during order | Real Godot Metal viewport, 540×960 PNG |
| [02_cafe_after_loop.png](../../artifacts/prototype_review/playable_placeholder_reset_v1/02_cafe_after_loop.png) | One reward, customer cleared | Real Godot Metal viewport, 540×960 PNG |
| [03_back_garden.png](../../artifacts/prototype_review/playable_placeholder_reset_v1/03_back_garden.png) | Garden and cat activity | Real Godot Metal viewport, 540×960 PNG |

The images were inspected for non-blank output. Regenerate them with:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path /Users/teddywoot/willi-cat --resolution 540x960 --script res://scripts/dev/playable_placeholder/capture.gd
```

`tests/test_playable_placeholder_reset_v1.gd`: **PASS** — café object inventory, camera presets/pan clamp, complete and repeated customer-to-reward loops, once-only reward per order, cleanup, chair/seat-anchor movement, invalid-placement rollback, tap-vs-drag portal handling, garden transition/cat state, café and garden save/load, saved garden sniff-action reacquisition, delta-only furniture, and progression restore.

Existing regressions: `test_world_architecture_hardening_v1.gd`, `test_world_architecture_labs_v2.gd`, `test_camera_aspect_v1_2.gd`, `test_home_v3_level_design_pass_01.gd`, and `test_true_vertical_slice_001.gd` all **PASS**. Godot 4.7.2 headless editor scan and runtime smoke also completed without script errors. `git diff --check` passes; new source files were additionally checked for trailing whitespace.

## Known limitations and human playtest

- Café actions are automatically sequenced; there is no manual tap-to-brew UX yet. This is a playable observation/room/decor/save proof, not the final mobile interaction design.
- Character drawings and activity feedback are deliberately crude. The garden is sparse. Labels are small at some camera scales; confirm touch readability on a real phone.
- The worker and cat use placeholder actor visuals. Character Runtime V1.1's full directional animation contract is not implemented here.
- Garden activity is represented by logical assignment plus an active-room sniff action; no offscreen navigation is simulated.
- Decoration is limited to authored tables/chairs. It has footprint and required-route gates, but no touch rotation, inventory, shop or full decoration editor.
- Save schema migration, corrupted-primary recovery and mobile filesystem behavior still require production proof. Saves are blocked during an active café visit.
- The room geometry is a new dev placeholder layout, not Home V3, and should not be interpreted as approved final level design.

Human checklist: launch the dev scene; let one order finish; confirm one coin and clean reset; repeat LOOP; pan/pinch; enter MOVE and drag/cancel/confirm a chair; enter Garden via its door; watch the cat sniff; return to Café and verify the cat remains assigned to Garden; SAVE, close, relaunch and LOAD; confirm the room, chair and cat assignment persist.

## Exact repository change scope

All files introduced by this task are new/untracked; no existing tracked production file was edited. Therefore `git diff --stat` for this task is empty until these new files are staged. Do **not** mistake the repository's pre-existing unrelated tracked changes in `scripts/dev/atmosphere/real_art_proof_capture.gd` and `tools/willicat_asset_forge/*` for this task's diff. The exact new-file set is:

```text
scenes/dev/playable_placeholder/back_garden.tscn
scenes/dev/playable_placeholder/main_cafe.tscn
scenes/dev/playable_placeholder/playable_world.tscn
scenes/dev/playable_placeholder/sun_spot.tscn
scripts/dev/playable_placeholder/capture.gd
scripts/dev/playable_placeholder/capture.gd.uid
scripts/dev/playable_placeholder/placeholder_cafe.gd
scripts/dev/playable_placeholder/placeholder_cafe.gd.uid
scripts/dev/playable_placeholder/placeholder_camera_input.gd
scripts/dev/playable_placeholder/placeholder_camera_input.gd.uid
scripts/dev/playable_placeholder/placeholder_floor.gd
scripts/dev/playable_placeholder/placeholder_floor.gd.uid
scripts/dev/playable_placeholder/placeholder_room.gd
scripts/dev/playable_placeholder/placeholder_room.gd.uid
scripts/dev/playable_placeholder/placeholder_world.gd
scripts/dev/playable_placeholder/placeholder_world.gd.uid
tests/test_playable_placeholder_reset_v1.gd
tests/test_playable_placeholder_reset_v1.gd.uid
artifacts/prototype_review/playable_placeholder_reset_v1/.gdignore
artifacts/prototype_review/playable_placeholder_reset_v1/01_main_cafe.png
artifacts/prototype_review/playable_placeholder_reset_v1/02_cafe_after_loop.png
artifacts/prototype_review/playable_placeholder_reset_v1/03_back_garden.png
docs/production/WILLICAT_PLAYABLE_PLACEHOLDER_RESET_V1_RESULT.md
```

No commit or push was made.
