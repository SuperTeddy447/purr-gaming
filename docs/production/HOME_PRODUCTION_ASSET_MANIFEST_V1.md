# WilliCat Home Production Asset Manifest

Status: **Playtest Ready Core Loop V1**. The Home art is still a graybox/mock; this manifest records how final visuals can replace it later without moving the gameplay layout. No final artwork was created in this pass.

The locked environment image is `docs/references/home/WILLICAT_HOME_ENVIRONMENT_STYLE_LOCK_V1.png` (941×1672). It remains unchanged, is not the normal runtime background, and is available only through **F6**. The older V2.1 image remains available through **R**.

## Stable visual IDs and contracts

There are exactly 17 stable IDs in `data/home_visual_asset_catalog.tres`. Repeated scene instances share an ID and are distinguished by semantic `slot_role` and visual variant. Each slot role carries its own target bounds, fit policy, pivot, default local position, expected layer, Y-sort requirement, occlusion/interaction role, replaceability and TEMP/final-art status. This allows one semantic asset to have separate placements (notably CounterBack/CounterFront) without duplicating IDs.

| Stable asset ID | Semantic category | Contract slots / target bounds | Pivot / layer / Y-sort | Replaceability / status |
|---|---|---|---|---|
| `architecture_home_01` | Architecture | Full canvas 941×1672; entrance frame 408×384 | Full-canvas top-left at StructuralBase; entrance wall-mount center at ForegroundOccluderLayer; no Y-sort | Replaceable full-canvas + frame; TEMP PLACEHOLDER; FINAL ART REQUIRED |
| `counter_basic_01` | Counter assembly | Back 540×200; front 560×225 | Back surface center at BackDecorLayer; front bottom-center at ForegroundOccluderLayer; no Y-sort | Independent replaceable parts, tintable candidates; TEMP; FINAL ART REQUIRED |
| `espresso_basic_01` | Coffee station | 110×130 | Countertop base-center; BackDecorLayer; no Y-sort | Replaceable visual; TEMP; FINAL ART REQUIRED |
| `grinder_basic_01` | Coffee-prep prop | 70×130 | Countertop base-center; BackDecorLayer; no Y-sort | Replaceable visual; TEMP; FINAL ART REQUIRED |
| `pos_basic_01` | Point of sale | 72×70 | Countertop base-center; BackDecorLayer; no Y-sort | Replaceable visual; TEMP; FINAL ART REQUIRED |
| `pastry_case_basic_01` | Display case | Shell 196×150 | Countertop base-center; BackDecorLayer; no Y-sort | Replaceable shell; TEMP; FINAL ART REQUIRED |
| `pastry_set_basic_01` | Display content | Croissant/muffin/tart each 42×28 | Center; independent BackDecorLayer child slots; no Y-sort | Replaceable variants separate from case; TEMP; FINAL ART REQUIRED |
| `table_round_01` | Furniture table | Two placements, each 145×90 | Floor bottom-center; DepthSortedLayer; Y-sort required | Replaceable; TEMP; FINAL ART REQUIRED |
| `chair_jade_01` | Furniture chair | Three placements, each 64×80 | Floor bottom-center; DepthSortedLayer; Y-sort required | Replaceable; TEMP; FINAL ART REQUIRED |
| `plant_floor_01` | Foreground decor | Two placements, each 100×160 | Floor bottom-center; fixed ForegroundOccluderLayer (not actor Y-sort) | Replaceable occluder; TEMP; FINAL ART REQUIRED |
| `plant_counter_01` | Countertop decor | 70×100 | Countertop base-center; ForegroundOccluderLayer; no Y-sort | Replaceable occluder; TEMP; FINAL ART REQUIRED |
| `vase_basic_01` | Tabletop decor | 44×50 | Center; inherits table's DepthSortedLayer sort ownership | Replaceable; TEMP; FINAL ART REQUIRED |
| `entrance_door_01` | Entrance door | Two leaves, each 150×160 | Floor bottom-center; DepthSortedLayer; Y-sort required | Replaceable leaves; TEMP; FINAL ART REQUIRED; runtime transform states |
| `sign_main_01` | Sign frame | 350×130 | Wall-mount center; BackDecorLayer; no Y-sort | Frame only; TEMP; FINAL ART REQUIRED; text remains runtime-driven |
| `sign_hanging_01` | Sign frame | 150×70 | Wall-mount center; BackDecorLayer; no Y-sort | Frame only; TEMP; FINAL ART REQUIRED; text remains runtime-driven |
| `sign_menu_01` | Sign frame | 160×104 | Wall-mount center; BackDecorLayer; no Y-sort | Frame only; TEMP; FINAL ART REQUIRED; text remains runtime-driven |
| `sign_freestanding_01` | Sign frame | 130×170 | Floor bottom-center; DepthSortedLayer; Y-sort required | Frame only; TEMP; FINAL ART REQUIRED; text remains runtime-driven |

The exact instance roles, slot names for human navigation, local anchors, occlusion semantics, fit modes and replacement rules are in [`HOME_ASSET_SLOT_CONTRACT_V1.md`](HOME_ASSET_SLOT_CONTRACT_V1.md). `scripts/home/home_asset_slot_contract.gd` is the runtime data schema; role identity, not a NodePath, is used for contract resolution.

## Scene ownership and rendering layers

```text
HomeScene
├── World
│   ├── StructuralBase: full-canvas architecture
│   ├── RoomSkinLayer: reserved extension slots
│   ├── BackDecorLayer: counter back, equipment, pastry display/content, wall frames
│   ├── DepthSortedLayer (Y-sort, z=50): tables, chairs, door leaves, floor actors
│   ├── ForegroundOccluderLayer (z=80): counter front, entrance frame, fixed foreground plants
│   └── FXLayer (z=100): prototype feedback/FX attachment slots
├── CounterSystem: logical references, worker region, anchors and marker links only
├── GameplayNodes / SliceWaypoints: stable semantic game positions/routes
└── DynamicSignage: separate blank runtime text surfaces
```

`CounterSystem` references independently owned CounterBack and CounterFront slots, a non-physics WorkerRegion, counter-top prop anchors, and existing interaction markers. The Espresso Station, Grinder, POS, Pastry Case/content, counter plant and other decor do not become children of the counter-front occluder. Mochi remains in DepthSortedLayer at CoffeeAction and is occluded naturally by ForegroundOccluderLayer; no per-state z-index override is used.

Tables, chairs, door leaves and the freestanding sign sort through the existing DepthSortedLayer. Floor plants intentionally remain fixed foreground occluders. Furniture replacement never changes the separate Seat A–D markers/routes; door art replacement never moves CustomerSpawn/CustomerExit or changes the door controller; signage art never absorbs dynamic text.

## Replacing the mock later

Keep the same stable ID and `slot_role`. Assign a shared texture, variant texture, or reusable visual scene in the current definition. Follow that slot's target bounds, fit policy, full-canvas pivot, expected layer, and Y-sort/occlusion contract. Textures are uniformly scaled (never stretched); floor-contact anchors remain pinned. Do not move major objects, markers, slots, or routes to fit a new sprite. Keep TEMP/FINAL status descriptive metadata only, never part of the stable ID.

The modular default, F6 locked-style comparison, current camera, runtime character/FX, scene ownership, all stable IDs, and blank runtime-driven sign surfaces remain as-is. This manifest defines replacement readiness; it does not authorize final art, environment restyling, or layout changes.

## True Vertical Slice 001 clarification

The first production slice uses the existing `espresso_basic_01`, `entrance_door_01`, `counter_basic_01`, table/chair, and architecture roles without adding or renaming catalog IDs or changing the 26 role contracts. Semantic animation attachments for Mochi and the one customer archetype are separate from this modular environment catalog. Their required action names, local presentation cues, and exact slice-only final-asset gaps are documented in [`TRUE_VERTICAL_SLICE_001.md`](TRUE_VERTICAL_SLICE_001.md) and [`TRUE_VERTICAL_SLICE_001_ASSET_GAPS.md`](TRUE_VERTICAL_SLICE_001_ASSET_GAPS.md). No final art is included by this clarification.
