# Home Modular Visual Mock V0

This is a temporary graybox-plus visualization of the existing Home scene. It does not add gameplay, a customization/shop system, final art, or new camera/marker behavior. `home_scene.tscn` remains the sole scene composition and all visible placeholder parts are removable `HomeAssetSlot`s.

## Scene ownership

```text
HomeScene
├── World
│   ├── StructuralBase / HomeBakedBaseSlot (architecture_home_01)
│   ├── RoomSkinLayer (reserved empty slots)
│   ├── BackDecorLayer
│   │   ├── CounterBackSlot
│   │   ├── EspressoStationSlot / GrinderSlot / POSSlot
│   │   ├── PastryDisplaySlot ── PastrySlot01–03
│   │   ├── Main / Hanging / Menu sign-frame slots
│   ├── DepthSortedLayer (existing Y-sort, z=50)
│   │   ├── Table1Slot ── TableVaseSlot; Table2Slot
│   │   ├── Chair slots; EntranceDoorLeft/RightLeafSlot
│   │   ├── SignFreestandingSlot
│   │   ├── WorkerCatPlaceholder; MochiScaleTestDEV; runtime customer
│   │   └── Existing hidden depth-test helpers
│   ├── ForegroundOccluderLayer (existing z=80)
│   │   ├── CounterFrontSlot
│   │   ├── EntranceForegroundSlot
│   │   ├── CounterPlantSlot (drawn above counter rim)
│   │   └── ForegroundPlantsSlot ── left/right plant slots
│   └── FXLayer (existing slots, unchanged)
├── CounterSystem (logical cross-layer references and anchors only)
├── GameplayNodes / SliceWaypoints (unchanged)
└── DynamicSignage (existing four blank runtime controls)
```

`CounterSystem` points at the independent counter-back and counter-front visuals; owns a non-physics `WorkerRegion` and counter-top anchor markers; and references the existing interaction marker root. It offers `set_skin_color(Color)` as a visual-only tint hook. The back stays in `BackDecorLayer`; the front stays in `ForegroundOccluderLayer`. Espresso, grinder, POS, pastry case/contents and counter plant each have separate owners. The `CounterFrontSlot` covers characters because z=80 is above the unchanged Y-sorted character layer at z=50; no actor z-index override is used.

## Stable IDs and placeholder status

`data/home_visual_asset_catalog.tres` contains the single definition for each ID:

`architecture_home_01`, `counter_basic_01`, `espresso_basic_01`, `grinder_basic_01`, `pos_basic_01`, `pastry_case_basic_01`, `pastry_set_basic_01`, `table_round_01`, `chair_jade_01`, `plant_floor_01`, `plant_counter_01`, `vase_basic_01`, `entrance_door_01`, `sign_main_01`, `sign_hanging_01`, `sign_menu_01`, `sign_freestanding_01`.

All use **TEMP PLACEHOLDER** geometry. The visual catalogue is only a small semantic-ID-to-scene/texture mapping, not a global system or inventory. Repeated placed objects (chairs, plants, pastries, door leaves) share their semantic asset definition while selecting a per-slot visual variant.

The environment lock image is **not** used as a runtime background. The approved image is at `docs/references/home/WILLICAT_HOME_ENVIRONMENT_STYLE_LOCK_V1.png` (941×1672) and is referenced without edits by `DEV_VISUAL_MASTER`. **F6** switches between that image and the modular mock, hiding modular environment slots while leaving runtime characters, UI, camera and gameplay alive. **R** shows/hides the older V2.1 image as a separate optional comparison. Default view starts modular, with both reference images hidden.

The base placeholder draws fixed walls, floor, tile surface, stair/passage and doorway backing only. Counter, machines, display, signs, furniture, food and plants are distinct runtime owners. Sign art contains only empty frames; café name/menu/slogan remain controlled by the unchanged `DynamicSign` controls.

## Replacing temporary visuals

Every Home object slot uses `HomeAssetSlot` with a stable `asset_id`, semantic `slot_role`, optional `variant_override`, and catalog contract. For final images, set that definition's shared `texture` or add per-variant images to `texture_variants` where one ID has multiple parts (e.g. counter back/front, door leaves or pastry variants). A matching variant texture takes precedence over the shared texture and temporary `visual_scene`. Respect the role's target bounds, fit policy, alpha/pivot, layer, and existing local position in `HOME_ASSET_SLOT_CONTRACT_V1.md`; texture fitting preserves aspect ratio. Cropped replaceable objects/furniture require transparent alpha; `architecture_home_01` is the only opaque full-canvas asset. A final `PackedScene` can instead replace `visual_scene` while retaining the slot role, owner, anchor and gameplay marker references.

| ID | Current visual variant and owner | Tintable candidate | Alpha / depth | Future animation |
|---|---|---|---|---|
| `architecture_home_01` | Full canvas in `HomeBakedBaseSlot`; frame variant at entrance foreground | No | Opaque base; fixed layer | No |
| `counter_basic_01` | Back work surface and separate front panels | Yes, both pieces | Front should be transparent/cropped; fixed back and z=80 front | No |
| `espresso_basic_01`, `grinder_basic_01`, `pos_basic_01` | Separate counter-top station owners | No | Transparent crop; fixed BackDecor layer | Not in V0 |
| `pastry_case_basic_01` | Case shell | No | Transparent crop; fixed BackDecor layer | Not in V0 |
| `pastry_set_basic_01` | Croissant/muffin/tart content variants | No | Transparent crops; independent children inside the case | Not in V0 |
| `table_round_01`, `chair_jade_01` | Two tables and three chairs in DepthSortedLayer | No | Transparent; floor-contact Y-sort | No |
| `plant_floor_01` | Two selected foreground plants | No | Transparent; fixed occluder layer in this mock | No |
| `plant_counter_01`, `vase_basic_01` | Counter-top plant above the front rim; vase attached to Table 1 | No | Transparent; counter plant fixed occluder layer / vase inherits table owner | No |
| `entrance_door_01` | Independent left/right leaves | No | Transparent; bottom-center Y-sort | Closed/opening/open/closing are reserved as data only |
| `sign_main_01`, `sign_hanging_01`, `sign_menu_01`, `sign_freestanding_01` | Blank sign frames; freestanding frame Y-sorted | No | Transparent crops; runtime text surfaces remain separate | No |

Door leaf variants are separate visual owners, but no door state machine, animation or route changes have been added. Existing customer spawn/exit routes and seats are untouched.

## Controls and verification

- F6: locked-master comparison; F6 again returns to modular mock.
- R: optional legacy V2.1 reference; R again returns to modular mock.
- F1/D: existing debug view; also enables small slot labels. Labels are hidden in normal view.
- Mochi scale test: starts at LARGE (~150 px). Existing 1/2/3, F2–F5, and Z/X/C/V test controls remain.

Automated coverage is in `tests/test_home_modular_visual_mock_v0.gd`, alongside the existing Foundation, Vertical Slice, camera/aspect, Mochi-scale and productionization checks. Manual visual review should compare default framing, F6, the R legacy mode, counter overlap at CoffeeAction, and camera minimum/default/1.2×/maximum while Mochi is at WorkerIdle, CoffeeAction, ServePoint and Open Floor.
