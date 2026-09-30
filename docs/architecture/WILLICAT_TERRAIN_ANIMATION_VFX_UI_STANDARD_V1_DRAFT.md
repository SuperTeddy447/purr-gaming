# WilliCat terrain, animation, VFX and UI standard V1 — draft

Proposed family requirements, not art or a palette lock. Evidence: [provider report](../research/WILLICAT_ASSET_PROVIDER_PRODUCTION_BEST_PRACTICES_RESEARCH_V1.md), [Tiny Swords creator tilemap guide](https://pixelfrog-assets.itch.io/tiny-swords/devlog/1138989/tilemap-guide), [Mini Pack 001 route/screenshots](../production/WILLICAT_FIRST_PARTY_ANIMATED_STORYBOOK_MINI_PACK_001_RESULT.md). Canonical `terrain`, `animated_environment`, `character`, `vfx`, `ui` profiles, lifecycle/gates and typed fields live in the [manifest schema](WILLICAT_ASSET_MANIFEST_SCHEMA_V1_DRAFT.md) and [registration/motion contract](WILLICAT_ASSET_REGISTRATION_AND_MOTION_CONTRACT_V1_DRAFT.md).

## Terrain family

| Required authored role | Acceptance evidence |
|---|---|
| Base and restrained variation cells | Repetition/density preview at actual Home camera; no oversized flat rectangle or noisy checkerboard. |
| Path center, ends, sides, bends, intersections and threshold transition | All inside/outside corners and café approach joins in neighbor mosaic; existing walkable route untouched. |
| Grass/soil/stone/gravel or other approved surface edges | Neighbor mask and allowed combinations explicit; no implicit edge created by cropping a center tile. |
| Water body, bank edge/corners, foam/ripple overlay | Bank has continuous edge at current river coordinates; phase offsets avoid synchronized foam; water visuals do not redefine collision. |
| Elevation top, cliff to water, cliff to lower ground, stairs and separate depth shadow **if this terrain family uses elevation** | Each connector variant and layer order previewed with walking actor. Do not require elevation art where Home geometry has none. |

At TEMPLATE, `template.terrain_plan` contains `art_tile_px`, `world_tile_span`, `logical_placement_cell_world`, `supported_roles` and `required_roles`. At NORMALIZED, typed `terrain` adds `completeness_claim` (`partial` or `complete`), `tiles[]` and optional `coverage_evidence_ref`. Each tile has `tile_id`, `atlas_rect_px`, `terrain_role`, `neighbor_mask`, and optional edge/elevation/connector/shadow/animated-overlay and `phase_policy` refs. Defined roles are `base`, `variation`, `path`, `edge`, `inside_corner`, `outside_corner`, `threshold`, `bank`, `water`, `elevation`, `stair`, `cliff`, `shadow`, `animated_overlay`. A family need not support every role; `V-TERRAIN-COMPLETE` requires a complete claim and coverage of declared required roles for production-family passage, while `V-ADJACENCY` checks declared neighbors. A partial family remains in isolated evaluation.

**Art cell px**, **world tile span** and **logical placement cell world** are independent. Tiny Swords uses 64 px art tiles and a layered flat/raised/foam/shadow grammar; current Home proof has a 32-unit placement grid, and Mini Pack exported 256 px terrain mapped to 64 world units. Variant density, seams and bank joins require both automated neighborhood checks and human visual review. Navigation/collision are existing world data. Unmeasured first-party dimensions remain `UNMEASURED` until extracted from the authoritative Home revision.

## Environmental and character animation

| Family | Required grammar |
|---|---|
| Tree/bush ambient sway | Fixed canvas and ground-contact root, separate shadow, foliage-led bend/lateral motion, authored rest/ease/extreme/return/settle, seam review with actor behind/in front; prohibit whole-sprite scale pulse. |
| Flutter and water | Declare spawn/phase policy, visual plane, loop seam and static fallback if needed; animated overlay must not alter nav. |
| Mechanical prop | Separate housing from moving part; named `off`, `idle`, `working`, `completed` states and transition/interrupt rules. |
| Character | Explicit `action × direction × state × variant` clip map, foot baseline, per-frame duration, loop/exit, optional approved mirroring; no inferred extra direction. |

Frame-count/canvas checks only establish structural validity. `V-FRAME` compares `frame_map` against `durations_ms`; `V-MOTION` inspects root/baseline, silhouette intent and loop seam. Tiny Swords' locally measured tree base remains registered while the upper shape shifts; Mini Pack's four registered frames were still judged pulse-like. Human scene-speed loop review is mandatory; numerical motion tolerances are `CANDIDATE_REQUIRES_CALIBRATION`.

## Cozy VFX classes

| Class | Candidate WilliCat uses | Contract |
|---|---|---|
| Ambient | steam, leaves, petals, river ripple | Low-intensity loop, phase/depth/anchor declared; sparse use. |
| Interaction | splash, dust, coffee puff, pickup | Semantic event trigger, onset/peak/dissipation, one-shot completion and reset. |
| State | ready, selectable, rare, relationship | Bound to a state transition; cannot signal a state the gameplay object lacks. |
| Character | heart, sleep, happy, curiosity | Actor anchor, timing, interruption and depth declared. |
| UI | button press, reward pop, fill, unlock, ribbon/badge | Semantic state and accessibility/readability review at portrait size. |

Tiny Swords documents compositing multiple dust/fire/explosion pieces and supplies splash; transfer the **layered one-shot mechanism**, not battle scale or spectacle. Mini Pack coffee FX is correctly bound to the existing `Coffee ready → carrying` event; visual style/quality is a separate gate.

## UI kit families

- **Button:** `normal`, `pressed`, plus `selected`/`disabled` when those semantic states exist. Define hit area, art bounds, pressed offset and focus/selection legibility independently.
- **Bar:** frame/base, independent fill, clipping/mask or stretch rule, semantic min/max/value. Never bake live value into background art. Tiny Swords local `BigBar_Base.png` / `BigBar_Fill.png` demonstrate separation.
- **Panel:** scalable background with declared 9-slice or safe stretch region; separately registered slots, icons, ribbons and badges. The [Tiny Swords Unity handoff](https://pixelfrog-assets.itch.io/tiny-swords/devlog/1316041/unity-version-available) documents configured UI 9-slice, while local PNGs require their own slice metadata before Godot use.
- **State feedback:** visuals must correspond to actual interaction state and remain readable with a moving world behind the HUD. The Mini Pack reskinned only ROUTE; it does not validate a complete UI kit.

No UI, VFX, terrain or animation family is approved for production by this document. The independent `rights`, `structural`, `motion`, `visual`, `runtime`, `human` gates in the [ecosystem standard](WILLICAT_ASSET_ECOSYSTEM_STANDARD_V1_DRAFT.md) apply; `production_ready` remains derived after final human approval.
