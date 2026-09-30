# WilliCat first-party animated storybook mini pack 001 — result

Status: **READY FOR HUMAN REVIEW** as a bounded first-party style proof. This is not a final production art pack. The existing proxy Home scene and gameplay architecture remain available and unchanged.

## What was built

The ten asset specs were saved to [`pack_manifest.json`](../source_assets/first_party_storybook_mini_pack_001/specs/pack_manifest.json) **before** generating new visual sources. The source folder preserves 23 files, including four rejected tree/chair sheets and an abandoned overlapping café shell sheet. The accepted art was normalized into 20 PNG exports; no raw generation file is referenced by the first-party test scene.

| Family | Accepted runtime content | Registration and semantic fit |
| --- | --- | --- |
| Grass/path | Grass interior and quiet ochre path tile | 256 px source cell → 64 world units; existing TileMapLayer cell positions |
| River | Static blue-green water, two alternating straight-bank tiles, four corner/shore source pieces | 256 px cell → 64 world units; original water collision boundary |
| Water motion | Four-frame calm ripple over static base | 150 ms/frame; no navigation effect |
| Tree | Four authored breeze poses plus first-party neutral shadow | 512×640 frame, pivot (256,600), scale 0.4; trunk collision 28×26 |
| Chair | Authored N, NE, E, SE, S, SW, W, NW views | 384×384 frame, pivot (192,364), scale 0.18; same 48×28 footprint and SeatSlot |
| Round table | Existing empty first-party table candidate normalized | 512×512, pivot (256,480), scale 0.2; same 108×80 footprint |
| Café shell | Separate back wall, wood floor, left/right front rails with clear entrance | Existing 640×1024 envelope, front gap centered at x=320, rear route retained |
| Orange protagonist | Canonical cat; Idle and Walk in Down, Up, Left, Right | 256×256, pivot (128,232), visual scale 0.34; existing CharacterBody2D/NavigationAgent2D feet radius 8 |
| Coffee FX | Four-frame authored cream steam/brass accent | 90 ms/frame; `Coffee ready → carrying` phase event triggers, then hides |
| Interaction button | Normal, pressed, disabled art | 320×128 state cells; styled only the DEV ROUTE button |

Runtime uses the non-destructive [`home_first_party_style_proof_001.tscn`](../../scenes/dev/first_party_style_proof/home_first_party_style_proof_001.tscn). It inherits the successful visual comparison, and its presentation installer swaps only relevant `VisualRoot` content, terrain textures and shell layers. The new scene does not change save identities, route markers, semantic object positions, slots, navigation footprints or actor movement code. Reusable tree, chair, table, shell, water, character-visual, FX and UI prefabs, plus three TileSet resources, are in `scenes/dev/first_party_style_proof/`.

## Validation and rejected iterations

[`storybook_forge_001.py`](../../tools/storybook_forge_001.py) checks source-cell alpha bounds, missing/duplicate frames, fixed canvases, floor baselines, perceived height drift, direction completeness, frame counts, output names and target prefabs. The final [`validation_report.json`](../source_assets/first_party_storybook_mini_pack_001/qa/validation_report.json) has **zero failures**. Adjacent-tile previews report mean opposite-edge RGB differences: grass 5.1, path 5.73, wood floor 2.95 and water 4.3 on a 0–255 channel scale. These are diagnostic seam measurements, supplemented by visual adjacency previews.

- Tree sheet V1 and V2: rejected because canopy/root touched sheet boundaries or gutters. V3 contains four complete authored frames.
- Chair sheet V1 and V2: rejected because arms/legs touched source edges. Accepted front and back sheets yield eight complete authored directions.
- Orange Down fourth source pose: rejected because it overlaps the row boundary. Idle plus two complete Walk poses remain. Other directions have three Walk poses each. The generated side-sheet prompt labels were visibly reversed; the normalized Left/Right outputs map by actual facing.
- Combined café shell V1: rejected because back and front modules overlap on the source canvas. Separate V2 back wall and front rail sources are used.
- Initial padded riverbank export: showed repeated gaps in live Godot pixels. The final two-tile bank atlas uses central authored source crops, alternated along the existing straight river boundary; the final [`03_riverside_water.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/03_riverside_water.png) has a continuous edge.

The compact four-frame tree loop is a deliberate 0.8 second breeze proof, not a scale/rotation pulse. The cat's floor root is semantic: its visual baseline is registered at frame y=232 while the existing collision circle remains at the actor origin.

## Live route and interaction proof

Godot 4.7.2 rendered the first-party scene at **540×960**. The styled ROUTE button's `pressed` signal started the existing route, then the cat traversed Café → Front Plaza → Riverside → Café property → Back Garden → sniff → Café → customer service. Coffee steam fired from the semantic phase event; save/load completed; the route ended with `route=true`, 11 screenshots and no reported error. The [route log](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/route_capture.log) records the sequence.

The [spatial parity log](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/spatial_parity.log) reports **39 identical entries** for existing object positions, footprints, seat anchors, tree positions, route markers and actor collision root between proxy and first-party scenes. Both reported 67 navigation polygons and 28 obstructions on initial bake. The [prefab smoke log](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/prefab_smoke.log) confirms all reusable scene and TileSet targets load and enter the scene tree.

## Real Godot evidence

| Required view | File |
| --- | --- |
| Terrain with moving cat | [`01_first_party_terrain.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/01_first_party_terrain.png) |
| Animated tree, cat in front | [`02_animated_tree.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/02_animated_tree.png) |
| Partial occlusion behind tree | [`02b_character_behind_tree.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/02b_character_behind_tree.png) |
| Riverside water and continuous bank | [`03_riverside_water.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/03_riverside_water.png) |
| Directional seating | [`04_directional_seating.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/04_directional_seating.png) |
| Café front-layer crossing | [`05_cafe_shell_depth.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/05_cafe_shell_depth.png) |
| Moving orange protagonist | [`06_protagonist_walk.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/06_protagonist_walk.png) |
| Event-triggered coffee steam | [`07_coffee_fx.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/07_coffee_fx.png) |
| Pressed ROUTE UI state | [`08_ui_state_test.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/08_ui_state_test.png) |
| Whole Home | [`09_home_world_overview.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/09_home_world_overview.png) |

Motion proof: [`first_party_style_proof_001.gif`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/first_party_style_proof_001.gif) is an accelerated selection of live Godot route frames plus six contiguous runtime FX frames; [`first_party_coffee_fx_runtime.gif`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/first_party_coffee_fx_runtime.gif) is a cropped, enlarged view of those same live FX pixels. Neither GIF is an image-generator video or a painted scene. The [A/B overview](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/proxy_vs_first_party_ab_overview.png) compares the unchanged proxy world with the new skin. Evaluation is in the [style proof](../art/WILLICAT_ANIMATED_STORYBOOK_WORLD_STYLE_PROOF_V1.md).

## Remaining limitations

This is visibly a mixed-art test: service machines, small plants/rocks, the interior door object and most HUD controls remain proxies. The grass/path boundary is square and needs an authored feathered transition for production. The café shell is deliberately minimal; it is not a complete production Café. Animated loops and Down Walk are compact and would benefit from more authored frames. These limitations do not prevent judging whether the visual direction works in the existing moving world.

Exact additions and the one draft-standard append are listed in [`file_inventory.json`](../source_assets/first_party_storybook_mini_pack_001/file_inventory.json). No commit or push was made.
