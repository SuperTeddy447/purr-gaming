# True Vertical Slice 001 — final asset gaps

Every item below belongs to the single coffee-service flow or the portion of Home visible during it. `TEMP` means the existing modular mock or draw-code cue is intentionally retained. The owner is an existing role/slot or a semantic presentation attachment, not a new persisted asset ID. B = blocks final visual/audio-quality sign-off; NB = replaceable polish that does not block the gameplay-quality gate. No final asset is claimed as delivered.

| Group / asset ID | Status / current TEMP source | Final requirement | Slot / owner; visual target bounds and pivot | Animation requirement | Gate |
| --- | --- | --- | --- | --- | --- |
| CHARACTER `mochi_action_set_01` | Action SpriteFrames runtime **READY**; `SIDE RIGHT` walk **TEMP ACCEPTED**; `PREPARE COFFEE V1` **CANDIDATE / HUMAN REVIEW REQUIRED**; final action art **REQUIRED**. TEMP canonical body remains fallback for missing clips (`carry_coffee`, `serve`, `return_idle`); no FINAL SpriteFrames installed | House-style coherent `walk`, `prepare_coffee`, `carry_coffee`, `serve`, and `return_idle` clips plus the missing directional variants; stable per-clip registration | `MochiAnimationSlot/ActionAnimatedSprite` with `assets/characters/mochi/runtime/mochi_animation_set.tres`; ~145–150 px visible at default framing, feet fixed at actor root, separate `ContactShadow` | Action semantic fallback and gameplay ownership in `MOCHI_PRODUCTION_ANIMATION_PIPELINE_V1.md` | B |
| CHARACTER `mochi_layered_idle_set_01` | Layered Idle Runtime Pipeline: **READY**. Production Layer Artwork: **REQUIRED**. Current visible art is canonical TEMP fallback; no layer art is installed | Six registered transparent layers: `mochi_body_base_v1.png`, `mochi_tail_v1.png`, `mochi_ear_twitch_v1.png`, and `mochi_eyes_{open,half,closed}_v1.png` | `MochiAnimationSlot/LayeredIdleVisual`; ~145–150 px full composited height, canonical feet unchanged, separate `ContactShadow` | `MOCHI_LAYERED_IDLE_PRODUCTION_V1.md`; procedural idle is immediately action-interruptible and never owns gameplay state | B |
| CHARACTER `mochi_carry_attachment_01` | Runtime `CarryAnchor` **READY**; final cup/hand art **REQUIRED**. TEMP `PrototypeCarryVisual` draw code follows the anchor | Cup/hand attachment coordinated with body facing and service pose; left-side mirror requires art review | Existing root `CarryAnchor` local (28,-80) on right, mirrored x on approved left; actor foot pivot unchanged | Carry/serve alignment, disappear at successful serve | B |
| ENVIRONMENT `architecture_home_01` | TEMP modular `HomeBakedBaseSlot` and entrance frame | Final café room skin/entrance frame coherent with Mochi | `architecture_full_canvas` 941×1672 top-left; `architecture_entrance_frame` 408×384 wall-mount center | None | B |
| ENVIRONMENT `counter_basic_01` | TEMP separate modular back/front slots | Final counter back and front preserving occlusion | `counter_back` 540×200 back-surface center; `counter_front` 560×225 front bottom-center | None | B |
| ENVIRONMENT `table_round_01` / `chair_jade_01` | TEMP table/chair slots | Final service-seat furniture readable with customer depth | Existing `table_guest_area_a/bc` 145×90 and `chair_seat_a/bc_left/c_right` 64×80; floor bottom-center, Y-sort | None | B |
| ENVIRONMENT `plant_floor_01`, `plant_counter_01`, `vase_basic_01` | TEMP modular scene props | Coherent visible decor at same anchors; no route/occlusion change | Existing floor-plant 100×160 bottom-center, counter-plant 70×100 base-center, vase 44×50 center | None | NB |
| ENVIRONMENT `sign_main_01`, `sign_hanging_01`, `sign_menu_01`, `sign_freestanding_01` | TEMP frames; blank dynamic sign text | House-style frames; text remains runtime-driven | Existing frame bounds 350×130, 150×70, 160×104 wall centers; freestanding 130×170 floor bottom-center | None | NB |
| STATION `espresso_basic_01` | TEMP `EspressoStationSlot` modular prop | Final espresso machine with safe visual brew/steam attachment | `espresso_machine` 110×130 countertop base-center, BackDecorLayer | Brew action/steam contact; no route change | B |
| STATION `grinder_basic_01`, `pos_basic_01`, `pastry_case_basic_01`, `pastry_set_basic_01` | TEMP visible counter props | Coherent background equipment/display only; no extra interactions for this slice | Existing contracts: grinder 70×130, POS 72×70, case 196×150 countertop base-center; pastry pieces 42×28 center | None for this slice | NB |
| FOOD/PROP `coffee_cup_basic_01` | TEMP `PrototypeCarryVisual` drawn cup | Final coffee cup sprite at station/carry/serve, consistent scale | Carry attachment ~28×25 TEMP local draw bounds, pivot aligned to Mochi; final dimensions to be approved on-device | Pickup/carry/serve variants | B |
| CUSTOMER `customer_archetype_01` | TEMP `CharacterPlaceholder` in `customer_placeholder.tscn` | One coherent customer archetype with readable seat and reaction poses | `CustomerAnimationSlot` under existing floor-contact actor; target height ~130 px world TEMP; final pixel bounds need device review | enter/walk/sit_wait/order/receive/satisfied/leave | B |
| DOOR `entrance_door_01` | TEMP two modular leaves and transform tween | Final leaf art retaining current threshold and separation | `entrance_door_left/right` each 150×160 floor bottom-center, DepthSortedLayer | OPENING/OPEN/CLOSING/CLOSED, current timing | B |
| FX `order_pop_01` | TEMP `PrototypeOrderBubble` scale pop | Small final order appearance transition | Customer `OrderBubble`; 164×56 TEMP bubble centered above seated cat | One-shot ~0.22 s | NB |
| FX `espresso_steam_ready_01` | TEMP `PrototypePreparationFeedback`, `PrototypeCoffeeReadabilityCue`, `TrueSliceMomentFX` | Restrained steam/progress/ready cue | Espresso `CoffeeFXAttachment` and existing FXLayer slots; machine-relative, no floor pivot | Brew loop + ready one-shot | B |
| FX `serve_happy_reward_01` | TEMP `TrueSliceMomentFX`, `PrototypeCustomerReadabilityCue`, `SliceRewardFX` | Distinct serve/happy/reward accents | Existing FXLayer / customer cue, world-space, no actor depth changes | One-shots at serve/customer satisfied/reward | NB |
| UI `coffee_order_slice_01` | TEMP `PrototypeOrderBubble` text/cup silhouette | Final legible one-coffee order/ready indicator | Customer order bubble; 164×56 TEMP bounds, customer-relative | Waiting/ready state change | B |
| UI `service_feedback_slice_01` | TEMP station prompt, progress, serve cue, status, coins | Compact phone-readable prompt/progress/reward presentation | Existing `PrototypeCoffeeReadabilityCue`, `PrototypeStatusLabel`, `PrototypeCoinsLabel`; safe-area/world-space anchors retained | State-led transitions only | B |
| AUDIO `door_open_close_01` | MISSING; semantic `door_open`/`door_close` cues only | Quiet door open/close pair | Optional local audio listener; no visual bounds/pivot | Trigger on transition start | B |
| AUDIO `order_appear_01` | MISSING; cue only | Soft order arrival | Optional local audio listener; n/a | One-shot on order bubble | B |
| AUDIO `espresso_action_01` | MISSING; start/loop/stop cues only | Espresso start, restrained loop, ready finish | Optional local audio listener; n/a | Loop only while preparing | B |
| AUDIO `serve_reward_satisfied_01` | MISSING; cues only | Serve, happy response, reward accents | Optional local audio listener; n/a | One-shots at authoritative events | B |

Haptics are optional semantic hooks (`valid_tap`, `coffee_ready`, `serve_success`, `reward`) and are **not** final-asset blockers. No placeholder audio, invented permanent sprite, or unrelated future content was added.

## Mochi walk directional status

The current side-right sequence is a temporary True Slice visual, not a complete or FINAL walk set. The resolver reads the existing `SliceMover` direction; the shared animation set disables side mirroring so asymmetric Mochi artwork is never silently flipped.

| Direction | Status | Runtime behavior |
| --- | --- | --- |
| SIDE RIGHT | **TEMP ACCEPTED** | `walk + RIGHT` → `TEMP:walk_side`, unflipped |
| SIDE LEFT | **REQUIRED / TEMP FALLBACK** | Canonical static fallback; no mirrored prototype |
| DOWN | **REQUIRED / FALLBACK** | Canonical static fallback; side-right clip is not used |
| UP | **REQUIRED / FALLBACK** | Canonical static fallback; side-right clip is not used |

Walk is **not globally FINAL**. Next missing animation asset: a true **SIDE LEFT walk** sequence; DOWN and UP remain required as well.
