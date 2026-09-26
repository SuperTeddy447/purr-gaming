# WilliCat Home Asset Slot Contract V1

Status: playtest foundation; all listed visuals remain temporary placeholders. The contract documents the current authored anchors and how future art replaces the placeholder without moving gameplay.

## Identity and replacement rules

- The 17 `asset_id` values in `data/home_visual_asset_catalog.tres` are stable semantic identities. Do not add `_TEMP`, `_FINAL`, theme names, or display labels to them.
- An ID may have multiple semantic `slot_role` contracts. For example, `counter_basic_01` deliberately owns `counter_back` and `counter_front` visual slots. Resolve artwork by stable ID plus semantic role/variant; do not make a persisted identity from a scene path or visible label.
- Replace artwork on the existing catalog definition/variant. Do not move a slot, gameplay marker, seat, CoffeeAction, WorkerIdle, ServePoint, door threshold, or route waypoint to fit the art.
- A `PackedScene` visual or texture can replace the mock behind the same slot role. Keep stations, pastry contents, counter pieces, runtime sign surfaces, and gameplay anchors separately owned.
- `target_bounds` are reference world-space bounds, not a required source-PNG pixel dimension. The original source canvas/pivot must be retained; do not trim transparent canvas in a way that shifts floor contact.

## Fit policies

| Policy | Meaning |
|---|---|
| `FIT_WITHIN_REFERENCE_BOUNDS` | Uniformly scale the complete source canvas to fit inside the contract bounds. Preserve aspect ratio; unused space is acceptable. |
| `NATIVE_REFERENCE_SCALE` | Keep source pixels at 1:1 world scale. Use for the 941×1672 full-canvas architecture/reference canvas. |
| `PIVOT_LOCKED` | Uniformly fit as above while keeping the declared pivot registered exactly at the slot origin. Never let trim/crop change the anchor. |

Texture dimensions may be larger or smaller than target bounds. Stretch-to-fill is not allowed. Alpha-cropped transparent art is welcome when the complete authored canvas/pivot metadata remains stable. Counter front/back use independent visual variants and contracts; replacing one must not absorb Espresso, Grinder, POS, Pastry Case, or pastry content.

## Pivot conventions

- `FLOOR_CONTACT_BOTTOM_CENTER`: floor furniture, door leaves, freestanding sign, and fixed foreground floor plants register their bottom-center to the existing slot origin. Tables, chairs, doors, and the freestanding sign use the existing `DepthSortedLayer` Y-sort. Floor plants intentionally remain in the fixed foreground-occluder layer and do not dynamically sort with actors.
- `COUNTERTOP_BASE_CENTER`: equipment and counter-top decor register at the base that currently touches the counter surface; this does not move the Espresso/CoffeeAction anchor.
- `COUNTER_FRONT_BOTTOM_CENTER`: the counter-front visual is bottom-anchored to the existing counter-front origin and stays a true foreground occluder.
- `COUNTER_BACK_SURFACE_CENTER`: counter back surface remains independently centered on its existing BackDecor slot.
- `WALL_MOUNT_CENTER`: fixed sign frames and the entrance frame keep their current mount point. Sign copy remains a separate runtime surface.
- `CENTER`: display content/tabletop decor remain centered on their current local slots.
- `FULL_CANVAS_TOP_LEFT`: full-room architecture keeps its origin at the top-left of the unchanged 941×1672 canvas.

## Current per-slot contracts

Positions are local to each slot's existing direct parent. Bounds are world-space reference bounds. All rows are `TEMP PLACEHOLDER`; all rows are replaceable and marked `FINAL ART REQUIRED`, except where a row describes runtime-owned structure/content. `Y-sort` means the current depth architecture must own ordering; it is not permission to set per-character z-index.

| Stable ID | Semantic slot role (current scene slot) | Default local position | Target bounds | Pivot / fit | Layer / Y-sort | Occlusion / interaction |
|---|---|---:|---:|---|---|---|
| `architecture_home_01` | `architecture_full_canvas` (`HomeBakedBaseSlot`) | (0, 0) | 941×1672 | Full-canvas top-left / native 1:1 | StructuralBase / no | Room background; no interaction |
| `architecture_home_01` | `architecture_entrance_frame` (`EntranceForegroundSlot`) | (426, 1620) | 408×384 | Wall-mount center / fit | ForegroundOccluderLayer / no | Entrance frame foreground |
| `counter_basic_01` | `counter_back` (`CounterBackSlot`) | (465, 520) | 540×200 | Counter-back surface center / fit | BackDecorLayer / no | Counter back surface |
| `counter_basic_01` | `counter_front` (`CounterFrontSlot`) | (465, 625) | 560×225 | Counter-front bottom center / pivot-locked | ForegroundOccluderLayer / no | Counter-front occluder; inspect target |
| `espresso_basic_01` | `espresso_machine` (`EspressoStationSlot`) | (402, 445) | 110×130 | Countertop base center / fit | BackDecorLayer / no | `COFFEE_STATION`; TAP cue when an order waits |
| `grinder_basic_01` | `grinder` (`GrinderSlot`) | (510, 445) | 70×130 | Countertop base center / fit | BackDecorLayer / no | Independent coffee-prep prop |
| `pos_basic_01` | `pos_terminal` (`POSSlot`) | (314, 435) | 72×70 | Countertop base center / fit | BackDecorLayer / no | Independent POS inspection target |
| `pastry_case_basic_01` | `pastry_case_shell` (`PastryDisplaySlot`) | (658, 500) | 196×150 | Countertop base center / fit | BackDecorLayer / no | Case shell/inspection target |
| `pastry_set_basic_01` | `pastry_croissant_display` (`PastrySlot01`) | (-52, -75) | 42×28 | Center / fit | BackDecorLayer / no | Separate case content |
| `pastry_set_basic_01` | `pastry_muffin_display` (`PastrySlot02`) | (0, -75) | 42×28 | Center / fit | BackDecorLayer / no | Separate case content |
| `pastry_set_basic_01` | `pastry_tart_display` (`PastrySlot03`) | (52, -75) | 42×28 | Center / fit | BackDecorLayer / no | Separate case content |
| `table_round_01` | `table_guest_area_a` (`Table1Slot`) | (270, 930) | 145×90 | Floor bottom-center / pivot-locked | DepthSortedLayer / yes | Y-sorted furniture; Seat A marker remains separate |
| `table_round_01` | `table_guest_area_bc` (`Table2Slot`) | (540, 1260) | 145×90 | Floor bottom-center / pivot-locked | DepthSortedLayer / yes | Y-sorted furniture; Seat B/C markers remain separate |
| `vase_basic_01` | `table_a_vase` (`TableVaseSlot`) | (38, -82) | 44×50 | Center / fit | DepthSortedLayer via table / inherited | Tabletop decor; follows table's depth owner |
| `chair_jade_01` | `chair_seat_a` (`ChairTable1LeftSlot`) | (210, 915) | 64×80 | Floor bottom-center / pivot-locked | DepthSortedLayer / yes | Y-sorted furniture; seat semantics are separate |
| `chair_jade_01` | `chair_seat_bc_left` (`ChairTable2LeftSlot`) | (460, 1230) | 64×80 | Floor bottom-center / pivot-locked | DepthSortedLayer / yes | Y-sorted furniture; seat semantics are separate |
| `chair_jade_01` | `chair_seat_c_right` (`ChairTable2RightSlot`) | (620, 1260) | 64×80 | Floor bottom-center / pivot-locked | DepthSortedLayer / yes | Y-sorted furniture; seat semantics are separate |
| `plant_floor_01` | `floor_plant_left` (`FloorPlantLeftSlot`) | (40, 0) | 100×160 | Floor bottom-center / pivot-locked | ForegroundOccluderLayer / fixed foreground | Floor-plant occluder |
| `plant_floor_01` | `floor_plant_right` (`FloorPlantRightSlot`) | (775, -110) | 100×160 | Floor bottom-center / pivot-locked | ForegroundOccluderLayer / fixed foreground | Floor-plant occluder |
| `plant_counter_01` | `counter_plant` (`CounterPlantSlot`) | (540, 440) | 70×100 | Countertop base center / fit | ForegroundOccluderLayer / no | Countertop visual occlusion |
| `entrance_door_01` | `entrance_door_left` (`EntranceDoorLeftLeafSlot`) | (426, 1506) | 150×160 | Floor bottom-center / pivot-locked | DepthSortedLayer / yes | Door state, entrance depth; current semantic tap target |
| `entrance_door_01` | `entrance_door_right` (`EntranceDoorRightLeafSlot`) | (426, 1506) | 150×160 | Floor bottom-center / pivot-locked | DepthSortedLayer / yes | Door state, entrance depth |
| `sign_main_01` | `main_sign_frame` (`MainSignFrameSlot`) | (372, 180) | 350×130 | Wall-mount center / fit | BackDecorLayer / no | Frame only; copy is runtime-driven |
| `sign_hanging_01` | `hanging_sign_frame` (`HangingSignFrameSlot`) | (97, 540) | 150×70 | Wall-mount center / fit | BackDecorLayer / no | Frame only; copy is runtime-driven |
| `sign_menu_01` | `menu_sign_frame` (`MenuSignFrameSlot`) | (705, 342) | 160×104 | Wall-mount center / fit | BackDecorLayer / no | Frame only; copy is runtime-driven |
| `sign_freestanding_01` | `freestanding_sign` (`SignFreestandingSlot`) | (855, 1470) | 130×170 | Floor bottom-center / pivot-locked | DepthSortedLayer / yes | Y-sorted frame; text surface remains separate |

## Explicit ownership constraints

- CounterBack and CounterFront stay separate visual slots joined only by the existing logical `CounterSystem`. CounterTopPropAnchors do not parent or absorb station art. Espresso/CoffeeAction, Grinder, POS, PastryCase, pastry content, and counter decor stay independent.
- Pastry case shell and pastry set remain separately replaceable. Replacing pastry content does not imply inventory or menu logic.
- Table/chair art does not own or relocate Seat A–D marker semantics. Current `Seat D` chair ambiguity remains a human playtest item.
- Doorway frame and door leaves remain distinct. The current CLOSED/OPENING/OPEN/CLOSING transform controller owns the temporary motion; final art may later replace visuals without changing those states or entry/exit markers.
- Four `DynamicSignage` surfaces own text at runtime. Never bake cafe name, menu copy, or slogans into final sign-frame artwork.
- Carry cup, order bubble, action feedback, and customer/Mochi actors are runtime prototype visuals, not members of these 17 art IDs.

The headless `test_home_playtest_ready_core_loop_v1.gd` test checks ID uniqueness, all 26 instance roles, contract completeness, variants, authored local anchors, layer ownership, bounds, pivots, Y-sort requirements, separate counter/station ownership, and blank runtime-driven signs.
