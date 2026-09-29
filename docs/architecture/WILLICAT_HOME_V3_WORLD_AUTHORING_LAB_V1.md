# Home V3 World Authoring Lab V1

Status: isolated **development greybox**. It does not replace the production Home, True Vertical Slice, assets or character animation. The architecture decision is in [`WILLICAT_PRODUCTION_ARCHITECTURE_LOCK_ADR_V1.md`](WILLICAT_PRODUCTION_ARCHITECTURE_LOCK_ADR_V1.md); the art boundary is in [`WILLICAT_HOME_V3_ART_HANDOFF_SPEC_V1.md`](../production/WILLICAT_HOME_V3_ART_HANDOFF_SPEC_V1.md).

## Scene and ownership

`res://scenes/dev/home_v3_world_authoring_lab.tscn` has `Architecture/Floor` (four portrait zones), `Navigation`, `DepthSortedLayer/{WorldObjects,EventLayer,Characters}`, `Camera`, `CameraInput`, `CameraDirector`, `HUD`, `DebugOverlay` and a dev-only `CaptureHarness`. The floor is 640×1320 world units. Authored roots and zone positions live in the scene; no concept-art pixel coordinates are consulted. World objects are reusable PackedScene instances, with stable IDs and child slots/footprints. Actors use the existing hardening generic actor/slot behavior. The V3 room script sequences a *proof*, not a second production state machine.

| Zone | Objects / purpose |
| --- | --- |
| Service / work | `CounterServiceZone` groups `counter_shell`, `espresso_station`, `grinder_station`, `pos_station`, `pastry_case`; counter owns order/serve semantics and Espresso owns work/camera/FX semantics |
| Customer / circulation | `table_a/b`, `chair_a–d`; each chair owns its seat; open central lane and `waiting_spot` |
| Cat life / idle | `cat_bed`, `window_perch`, `plant`, `scratch_post`, `FreeFloorIdle` |
| Entry / story / event | `entrance_door` with enter/leave/story slots and owned story focus; `SeasonalDisplayZone` and toggleable `seasonal_display` |

## Semantic slots and behavior proof

| Action | Owning object | Intended user |
| --- | --- | --- |
| `order`, `serve` | `counter_shell` | Customer-facing order / worker service |
| `work_coffee` | `espresso_station` | Worker only |
| `grind`, `operate_pos`, `browse` | `grinder_station`, `pos_station`, `pastry_case` | Future contextual tests |
| `sit` | Each `chair_*` | Customer, capacity one |
| `rest`, `sleep` | `cat_bed` | Cat |
| `watch`, `sniff`, `scratch`, `stretch` | `window_perch`, `plant`, `scratch_post` | Cat |
| `wait`, `enter`, `leave`, `story`, `inspect` | `waiting_spot`, `entrance_door`, `seasonal_display` | Customer/actor, scene story/event |

The automated gate verifies two customers enter/order/sit/leave, one worker acquires CoffeeAction and serves, and three cats request different daily-life slots. A fourth cat interaction tests WindowPerch. Slot capacity, reservation release, unique IDs and actor-category restriction are checked. A table forces a multi-segment navigation path; the actor's trace must not enter its footprint. Moving and rotating Chair A, CatBed, Plant and Espresso in the test checks local anchor preservation and navigation rebake. A small Chair A authoring adjustment (80→85 world x) was also made and saved through the live GodotAI editor; no generic actor code changed.

CameraDirector uses object-owned Brew/CupReveal/Event focus markers and cat-owned emotion focus; it locks pan/zoom input during shots, then restores the exact prior pan, zoom and input state. The HUD remains in CanvasLayer. Steam/Brew/CupReveal, bed Sleep, actor Heart/Purr and event FX are placeholders under their owning markers. Animation is never used to authorize gameplay transitions.

## Viewport and mobile gate

The running editor viewport was captured at 539×959 (canonical 9:16 profile with window decorations) and a separate real Godot `SubViewport` at 539×1168 (tall phone). Both render the authored room; screenshots are in [`artifacts/prototype_review/home_v3_world_authoring_lab_v1`](../../artifacts/prototype_review/home_v3_world_authoring_lab_v1/README.md). The default editor-game camera uses zoom 1.8 because this project's 1152-wide logical canvas is scaled to the ~540-pixel editor game window; its effective on-screen world scale is approximately 0.84. The raw tall SubViewport uses zoom 0.84 because it does not inherit that stretch. These are **lab-only** framing values, not changes to Home's camera. The test checks top/bottom action-band margins; screenshots should also be reviewed by a human for legibility and touch comfort. Current greybox object labels are tiny at canonical phone resolution and are not UX approval.

Real-device FPS/frame time, memory, navigation rebake time, active-agent cost and slot-lookup cost were **not measured**: no connected target device was available. Provisional thresholds and collection method are in the architecture ADR. Cat Emotion Focus preserves the room's camera limits, leaving the left-side CatBed subject toward the left of frame; this is a composition review item, not a contract failure. Full Home production cutover remains blocked until a physical-device smoke run records those data and a human accepts the spatial composition.

## Reproduce

Open and run `res://scenes/dev/home_v3_world_authoring_lab.tscn` in Godot 4.7.2. `F9` starts the semantic multi-actor demo, `F7` toggles slot/footprint debug, `F10` toggles the event display, and `F6` writes ten real viewport PNGs to `artifacts/prototype_review/home_v3_world_authoring_lab_v1/`. For the headless gate run:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /Users/teddywoot/willi-cat --script res://tests/test_home_v3_world_authoring_gate_v1.gd
```

The capture may be repeated after restarting the scene; it sequences actual slot requests and camera states. The tall-phone captures use a separate instance of the **same** scene, not reconstructed graphics. Do not run F6 while an existing sequence is active.
