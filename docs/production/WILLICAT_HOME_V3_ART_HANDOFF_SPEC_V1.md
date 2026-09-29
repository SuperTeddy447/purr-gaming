# WilliCat Home V3 art handoff spec V1

Status: **GREYBOX CONTRACT / NOT ART APPROVAL**. Source of truth is the authored Godot scene, [`home_v3_world_authoring_lab.tscn`](../../scenes/dev/home_v3_world_authoring_lab.tscn). This document describes replacement boundaries for future art; it does not authorize production Home migration or final art generation. Dimensions below are approximate *world units in the current lab*, not instructions to infer positions from a concept image. Re-check them in Godot before production export.

## Non-negotiable replacement rules

- Keep each root at its authored floor-contact pivot (`local (0, 0)`); illustrations may extend upward/sideways. Do not normalize each cropped image independently so the root drifts.
- Preserve stable IDs, object roots, `PhysicalFootprint`, owned `InteractionSlot` children and their approach/action/exit anchors. A replacement texture does not own world position, collision or gameplay timing.
- Y-sort from floor-contact roots. Split visual back/front within an object when a character must cross it; the front lip/foreground component is separate. Do not repair occlusion with per-action character z-index changes.
- Use the locked individual character masters for identity. The family scale sheet is for relative scale/silhouette only. These greybox circles are **not** scale approvals and no runtime animation sheet is authorized here.
- Asset Forge should process each *object-local* source with alpha, registered root, consistent canvas and a QA preview. Keep source/provenance outside runtime assets. Do not cut a monolithic concept image into positioned gameplay pieces.
- Existing camera/FX markers remain scene children of their owning object. Art or effect may use them, but must never bake their screen/world coordinates into pixels.

## Object contracts

Sizes are visual envelopes in world units, approximately width × height. The footprint column is the authored navigation obstruction (width × depth); `—` means no obstruction. “Local floor root” means the root sits where the object meets the floor, with visual pixels mostly above it. All objects face the camera in the elevated 3/4 presentation unless noted; no final angle or perspective drawing is approved.

| Stable ID(s) | Visual envelope / root / facing | Separate pieces and occlusion | Owned interaction anchors | Footprint | Camera / FX anchors | Art/Forge expectation |
| --- | --- | --- | --- | --- | --- | --- |
| `counter_shell` | ~224×62; local floor root at front/base; long side horizontal | Back body and **separate front lip** (`VisualFrontOccluder`); a worker behind the counter must be covered by the lip without changing worker z | `OrderSlot`, `ServeSlot` (each approach/action/exit); existing `OrderPoint`, `ServePoint` retained for compatibility | 224×55 | None in shell | Two registered layers on one shared canvas; no Espresso, POS, Grinder or Pastry pixels baked in |
| `espresso_station` | ~72×65; local floor root; service-facing | Machine may be one visual; cup/steam/brew are **separate** runtime visuals | `CoffeeActionSlot` (approach/action/exit) | 73×45 | `CameraBrewFocus`, `CameraCupReveal`; `SteamFXAnchor`, `BrewFXAnchor`, `CupSpawnAnchor`, `CupRevealFXAnchor` | Export machine independently with stable root; do not bake cup, steam or effects into base sprite |
| `grinder_station` | ~48×69; local floor root; service-facing | Machine may be baked internally, not into counter | `GrindSlot` (approach/action/exit) | 48×35 | `GrindFXAnchor`; no camera marker yet | Alpha cutout with registered root; retain independent station identity |
| `pos_station` | ~58×46; local floor root; service-facing | Device may be baked internally, not into counter | `POSSlot` / `operate_pos` (approach/action/exit) | 58×30 | None yet | Independent alpha cutout; screen graphic can be replaceable later |
| `pastry_case` | ~88×52; local floor root; customer-facing | Case can be baked initially, not into counter or POS | `BrowseSlot` (approach/action/exit) | 88×32 | None yet | Independent alpha cutout; leave future item contents separable if animated |
| `table_a`, `table_b` | ~104×100 visible top/leg envelope; local floor root | Top/front edge should be separable if character-under/behind-table readability needs it | No table seat slot; **chairs own seats** | Each 108×80 | None | Same reusable object asset, different scene placements; register tabletop and leg to one floor root |
| `chair_a`, `chair_b`, `chair_c`, `chair_d` | ~48×44; local floor root; service/customer facing as authored | Back and front/seat lip separable if seated actor occlusion requires it | Each owns `SeatSlot` (approach/action/exit), capacity 1 | Each 48×28 | None | One reusable chair asset with consistent pivot; never bake a cat/customer into chair art |
| `cat_bed` | ~92×50; local floor root | Bed rim/front may be separate so resting cat reads inside the bed | `RestSlot`, `SleepSlot` (each approach/action/exit) | 88×41 | `SleepFXAnchor` | Export registered back/cushion and optional front rim; sleep FX remains separate |
| `window_perch` | ~86×47; local floor root; wall-facing visually | Perch may be one visual; background window and cat remain separate | `WatchSlot` (approach/action/exit) | 86×32 | `CameraWindowFocus`; no FX marker yet | Independent perch alpha asset; no baked cat or wall scene |
| `plant` | ~76×62; pot floor root | Pot/foliage may be baked; foreground foliage may become a separate occluder if cat passes behind it | `SniffSlot` (approach/action/exit) | 30×25 | None yet | Stable pot/root; alpha foliage padding so leaves do not clip |
| `scratch_post` | ~44×76; base floor root | Post/base can be baked; cat action separate | `ScratchSlot`, `StretchSlot` (each approach/action/exit) | 42×25 | None yet | Independent alpha cutout with generous top padding; no baked actor |
| `waiting_spot` | ~58×58 debug ring; marker floor root | **No production visual required**; debug ring only | `WaitSlot` (approach/action/exit) | — | None | Semantic-only object; art should not invent a visible marker unless later design approves one |
| `entrance_door` | ~98×68 greybox frame; threshold floor root; passage vertical | Door leaf/frame must be independently replaceable for future opening and foreground occlusion | `EnterSlot`, `LeaveSlot`, `StorySlot` (each approach/action/exit); `DoorStoryPoint` | — currently, to preserve passable threshold | `CameraStoryFocus`, `DoorFXAnchor` | Registered door parts on common root; **do not** bake customer or room background into door |
| `seasonal_display` | ~54×82; local floor root; event zone | One modular display visual, with replaceable event skin; FX separate | `InspectSlot` (approach/action/exit) | 53×28 when active | `CameraEventFocus`, `FXAnchor` | Event variant replaces this object/skin, not the whole room; source and runtime variant must share pivot/footprint contract |

## Character and world attachment contract

Placeholder `Worker`, `CustomerA/B`, and `CatA/B/C` are `CharacterBody2D` with floor-contact roots, collision and `NavigationAgent2D`. They are not part of environment art export. The actor scene owns `CameraEmotionFocus`, `HeadFX`, `HeartFX`, `PurrFX`, `FeetFX`; any future animation and character FX must stay registered to those roots. The orange protagonist final master and individual character masters are the appearance authority; verify proportions against the family scale sheet without allowing the sheet to override identity. Action, facing, root and foot-contact contracts must be reviewed before character animation production.

## Review gate before Environment V3 art

1. Human approves the actual Godot-authored layout and interaction clearances at 9:16 and tall-phone sizes.
2. Record the final root/facing, alpha canvas and back/front layers for each object in this table.
3. Confirm every art variant keeps its object-local footprint and slot/camera/FX children intact.
4. Run moved/rotated object and navigation tests again after visual replacement.
5. Complete real-device performance smoke profile before production Home cutover; the architecture lock alone is not that approval.
