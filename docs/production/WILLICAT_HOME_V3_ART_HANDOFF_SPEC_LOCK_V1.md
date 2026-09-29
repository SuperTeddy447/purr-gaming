# WilliCat Home V3 — locked environment-object art handoff V1

**Status: art-production contract READY; artwork itself NOT approved or generated.** Supersedes the *layout-dependent* parts of `WILLICAT_HOME_V3_ART_HANDOFF_SPEC_V1.md` and `...PASS_01.md`; the accepted [Staggered Salon Godot scene](../../scenes/dev/home_v3_level_design_pass_01.tscn) and [layout lock](../design/WILLICAT_HOME_V3_LAYOUT_LOCK_V1.md) remain spatial authority. There are **17 art-bearing stable object instances** below plus three semantic-only `waiting_spot*` instances; the whole room therefore contains 20 stable world-object instances. The older brief's “17” must not be interpreted as deleting a wait slot or the event object.

## Export/registration rules shared by all assets

Each source package contains an independently usable transparent sprite/layer set, a named stable ID or reusable type, a full-canvas alpha export, its `(0,0)` **floor-contact root**, registered back/front pieces when specified, a no-character/no-unrelated-prop source, and an in-Godot review image at the canonical 9:16 and tall-phone views. Visual envelopes below are **approximate world-unit target silhouettes**, not guaranteed PNG dimensions, and cannot override an object's real `PhysicalFootprint`. Keep transparent safety padding around protrusions (minimum target roughly 8–12% of the visible silhouette on each side/top and a small nonzero floor margin; more for foliage, door motion or high trim). No alpha may touch the atlas cell boundary after Forge processing. The root/visible art can be locally adjusted for honest floor contact; never move the Godot object root or semantic anchor to compensate for a crop.

All objects use the same elevated 3/4, soft-perspective, matte illustrated camera family. “Front split” means a registered local visual in the object's own sorting hierarchy, not a full-screen layer or actor z-index change. A movable candidate means **future** decoration eligibility only after validated placement/nav and visual-overhang QA; it does not authorize changing the locked starter transform. Fixed/service/event objects still use reusable PackedScenes and can be placed differently in another authored room. Seasonal skins preserve the same root, silhouette clearance and gameplay contract. All exports pass through Asset Forge for alpha, canvas/root normalization, seam/clipping checks, provenance, preview and runtime import validation; Forge does not choose world placement.

## Object-by-object geometry and visual role

`W×H` is the intended visible envelope; `FP` is the actual navigation floor footprint from the current object scene. “Down” means the front/lower-screen side in the approved elevated 3/4 view. All roots have 0° rotation in the locked starter room. `C` = future movable-decoration candidate, `F` = authored/fixed baseline or separate approval for relocation, `E` = event-variant object. Every row is reusable in future rooms as an independent scene/type; the doorway's fitting may need a room-specific frame skin.

| Stable ID | Gameplay / visual role, facing | Envelope; FP | Layer/occlusion and transparent padding | Mobility; season/reuse |
| --- | --- | --- | --- | --- |
| `counter_shell` | Customer order/serve counter; long horizontal face toward lower screen; visual service anchor | ~224×62; FP 224×55 | **Required** registered back body + `VisualFrontOccluder` lip. Preserve worker-behind-counter read; pad ends/lip. No machines/POS/pastry baked in. | F; neutral base plus surface skin; reusable |
| `espresso_station` | Worker CoffeeAction hero machine in right prep bay; controls toward worker/down | ~72×65; FP 73×45 | Machine body independent. Cup, steam and Brew/Cup FX **not baked**; pad above steam path and sides. No counter pixels. | F starter; technically relocatable with owned markers; restrained material variants; reusable |
| `grinder_station` | Grind machine beside Espresso; controls down | ~48×69; FP 48×35 | One machine body is fine; independent from Espresso/counter; extra top padding for hopper. | F starter; neutral/season-neutral skins; reusable |
| `pos_station` | Customer/worker transaction device on left service wall; readable display down | ~58×46; FP 58×30 | Device separate from cabinetry, screen detail replaceable; side and top padding. No final text baked. | F starter; interface skins possible; reusable |
| `pastry_case` | Customer-facing display on left service wall; window faces down | ~88×52; FP 88×32 | Case separate from counter/POS; contents may be replaceable local layer; pad glass highlights/hinge. | F starter; seasonal pastry contents permitted; reusable |
| `table_a` | First customer seating island near bed; tabletop in elevated 3/4 | ~104×100; FP 108×80 | Registered tabletop/legs; optional shallow front lip only if seat occlusion needs it. No chairs/actors baked. Pad legs and tabletop corners. | C; tabletop decor skin allowed; same table type as B |
| `table_b` | Second staggered customer island near window/event side; same table type | ~104×100; FP 108×80 | Same export/root/layer rules as A; varied surrounding room decor, **not** a mismatched gameplay table. | C; seasonal place settings only within approved silhouette; reusable |
| `chair_a` | First-island seat, owner of SeatSlot; 3/4 customer-facing | ~48×44; FP 48×28 | Independent back/seat/front rim if seated actor needs occlusion; pad backrest. No cat/customer baked. | C; upholstery skins; same chair type as B–D |
| `chair_b` | First-island seat; same facing family | ~48×44; FP 48×28 | Same chair registration; no table pixels or broad shadow. | C; upholstery skins; reusable |
| `chair_c` | Second-island seat; same facing family | ~48×44; FP 48×28 | Same chair registration; maintain readable seated floor contact. | C; upholstery skins; reusable |
| `chair_d` | Second-island seat; same facing family | ~48×44; FP 48×28 | Same chair registration; do not visually block right circulation. | C; upholstery skins; reusable |
| `cat_bed` | Sheltered rest/sleep object at left-middle nook; opening down | ~92×50; FP 88×41 | Back/cushion and optional shallow **front rim** so resting cat reads inside. Bed framing shelf/wall is room-base art, not bed collision. Pad rim/textile. | C; removable textile skins; reusable |
| `window_perch` | Signature cat watch location against right window; seat oriented to window but cat visible in 3/4 | ~86×47; FP 86×32 | Perch independent from fixed window/wall and cat. Keep WatchSlot silhouette unobscured; pad outer ledge. | F in starter layout; season-neutral perch skin; reusable elsewhere with matching wall context |
| `plant` | Sniff interaction and soft window/seating frame; pot rooted on floor | ~76×62; FP **pot only** 30×25 | Foliage may overhang but cannot visually close the lane or hide cat; optional local front leaf layer. Extra foliage alpha padding. | C; controlled foliage/season variants; reusable |
| `scratch_post` | Cat scratch/stretch at left transition; must visually meet shelf/wall edge | ~44×76; FP 42×25 | Independent post/base; architectural companion is room-base or separate nonblocking trim. Top/side padding for post/cat motion. | C; material skins; reusable |
| `entrance_door` | Enter/leave/story threshold at lower center; passage oriented vertically into room | ~98×68 placeholder (final frame may rise above root); **no blocking FP** | Separate frame/leaf/foreground segment as needed for believable door motion and entrance occlusion. Leave central threshold open; generous swing/top padding. No customer/room baked. | F; seasonal wreath/sign may be separate; reusable fitting with room-specific frame |
| `seasonal_display` | Flexible event/story display right of entrance, active only with EventLayer | ~54×82; FP 53×28 **when active** | Display base + replaceable local event skin; FX separate. No silhouette expansion toward entry route without clearance re-review; pad highest variant. | E; seasonal skins expected; reusable event type |

## Owned interaction, camera and FX contract

For each row the following existing child nodes remain with that object's root. All slots retain their own Approach/Action/Exit anchors and reservation capacity; the visual must make the action plausible. A dash means no such marker currently exists, **not** permission to invent a map coordinate.

| ID(s) | Owned interaction semantics | Camera / FX relationship |
| --- | --- | --- |
| `counter_shell` | `OrderSlot`, `ServeSlot`; compatibility `OrderPoint`, `ServePoint`, `CustomerApproach`, `WorkerIdle` | No local focus/FX marker; preserve separate front lip |
| `espresso_station` | `CoffeeActionSlot` / `work_coffee` | `CameraBrewFocus`, `CameraCupReveal`; `SteamFXAnchor`, `BrewFXAnchor`, `CupSpawnAnchor`, `CupRevealFXAnchor` |
| `grinder_station` | `GrindSlot` | `GrindFXAnchor` |
| `pos_station` | `POSSlot` / `operate_pos` | — |
| `pastry_case` | `BrowseSlot` | — |
| `table_a`, `table_b` | No seat slot; chairs own `sit` | — |
| `chair_a`–`chair_d` | Each `SeatSlot` / `sit`, capacity 1 | — |
| `cat_bed` | `RestSlot`, `SleepSlot`, shared capacity 1 | `SleepFXAnchor` |
| `window_perch` | `WatchSlot` | `CameraWindowFocus` |
| `plant` | `SniffSlot` | — |
| `scratch_post` | `ScratchSlot`, `StretchSlot` | — |
| `entrance_door` | `EnterSlot`, `LeaveSlot`, `StorySlot`, `DoorStoryPoint` | `CameraStoryFocus`, `DoorFXAnchor` |
| `seasonal_display` | `InspectSlot` gated with EventLayer | `CameraEventFocus`, `FXAnchor` |

`waiting_spot`, `waiting_spot_b`, `waiting_spot_c` are invisible semantic WaitSlot owners. **No production sprite package is needed.** `FreeFloorIdle`, `SeasonalDisplayZone`, actors and room architecture are not additional art-bearing object IDs. Runtime signage is independent text on clean surfaces; neither the café name nor menu copy belongs in a base sprite.

## Visual scale and perspective control

The locked protagonist and family scale references—not the greybox actor circles—are the character height authority. At a shared world-unit registration, chairs should read as roughly one-third to one-half of an adult cat's standing visible height; table top/legs as roughly two-thirds; bed large enough for one resting cat; Espresso and PastryCase as compact equipment, not architectural monuments; CounterShell as a service span; door as a clear person/cat crossing threshold. Use the approximate envelopes above as **QA targets**, then compare in a live 540×960 game viewport and tall portrait. Reject any asset that makes a cat appear toy-sized beside a cup/machine, makes a seat impossible to occupy, or narrows a verified route. Do not infer an absolute final cat pixel height from the dev placeholder.

Provisional on-screen silhouette ratios for the *first art proof*, where `C = 1.0` is the supplied locked protagonist's visible standing height at the canonical camera: supporting cats follow the supplied family-scale sheet (never independently rescaled), chair ~0.30–0.45 C, table ~0.60–0.80 C, counter front/body ~0.35–0.55 C (back wall is separate architecture), Espresso ~0.40–0.60 C, PastryCase ~0.30–0.50 C, Plant ~0.35–0.65 C, bed ~0.30–0.45 C, ScratchPost ~0.45–0.65 C. Door **opening** must visibly accommodate a crossing character; its frame may extend above the old 98×68 greybox placeholder while the passable threshold/anchor and camera sightline stay unchanged. These are review bands, not sprite-export or gameplay coordinates. In particular, the door's final visual height cannot be inferred from the short primitive frame.

The named `WILLICAT_ORANGE_PROTAGONIST_FINAL_MASTER_V1` and `WILLICAT_CHARACTER_FAMILY_FINAL_SCALE_CHECK_V1` files were **not located in this repository** during the lock audit. Their *authority* is recorded here, but a generation brief must receive the actual approved masters (or verified links) before anyone claims final character-to-environment scale approval. This missing in-repo reference does not change the accepted spatial layout.

## Generation packages and dependency order

Every generation/artist brief supplies: this handoff + Environment V3 art direction, a screenshot of the **Godot object in context**, its stable ID and reusable scene path, approximate envelope and real FP, local floor root, elevated 3/4 facing, owned action anchor relationship, required layer split/FX emptiness, alpha padding, and a no-baked-neighbor/no-character rule. Expected return: named transparent standalone full-canvas source(s), any registered Back/Front pieces, root registration note, provenance and a neutral unlit preview. **Do not provide an old concept painting as a coordinate map.**

- **Room base:** fixed floor, low walls, window structure, service-wall visual connectors. Output layered room architecture with transparent/opaque regions as appropriate; keep object slots/nav separate.
- **Service family:** CounterShell split first, then Espresso and PastryCase, then POS/Grinder. The artist receives the whole service composition as context but returns five distinct registered exports. Do Brew/Cup/worker-behind-counter QA before any decorative detail pass.
- **Furniture family:** one table type and one chair type, instanced at the locked A/B and A–D roots; no per-instance crop/re-scale. Show occupied/empty states and moving-chair visual QA.
- **Cat-life family:** Bed with optional rim, Perch independent of window, Plant pot/foliage, ScratchPost independent of wall. Show each with a cat at its owned ActionAnchor and with FX padding.
- **Threshold/event family:** split door frame/leaf and passive room opening; seasonal display base plus per-event skins. Show Event OFF/ON, a door crossing and a customer waiting simultaneously.

Recommended batch order is the risk-first sequence in [art direction](../art/WILLICAT_HOME_ENVIRONMENT_V3_ART_DIRECTION_V1.md): room spatial foundation → high-risk service/seating silhouettes → cat-life → threshold/sign/event. A batch passes only after Asset Forge alpha/root/seam QA, Godot replacement in this locked dev scene, normal/debug and camera-state screenshots at both aspect profiles, navigation/slot/event regression, and human style/scale review. No provider (OpenAI, SpriteCook, manual or otherwise) and no Forge output can change the Godot root or footprint. If an asset requires gameplay-coordinate changes, perspective/cat-scale drift, impossible action contact, clipped alpha, blocked circulation, wrong occlusion or merged unrelated objects, **reject it and revise the asset**. Escalate a genuine spatial contradiction for explicit layout re-review rather than silently changing the lock.
