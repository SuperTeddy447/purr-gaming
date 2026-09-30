# Home V3 Batch A — image-generation handoff V1

**Use this only to request six independent, neutral-base art sources. Do not generate a complete café image and cut it up.** No production image has been generated in this prep. Godot [locked layout](../../scenes/dev/home_v3_level_design_pass_01.tscn) controls all geometry; the [Batch A spec](WILLICAT_HOME_V3_PRODUCTION_ART_BATCH_A_SPEC_V1.md) controls pixel registration and ownership. Art approval remains human. Save immutable source PNGs under `docs/source_assets/home_v3/production_batch_a_v1/`, named exactly as below; final runtime copies later belong in `assets/environment/home_v3/batch_a/`. Both directories are *future* asset destinations, not a request to install art now.

## Reference priority and handoff rules

1. **Geometry/registration:** the named real-Godot guide screenshot from [the Batch A review pack](../../artifacts/prototype_review/home_v3_production_art_batch_a_prep_v1/README.md), plus the world/source rect below. Guide coordinates and empty staging `Sprite2D` slots outrank any painting.
2. **Style only:** [WILLICAT_HOME_V3_VISUAL_TARGET_V2_1.png](../../docs/references/home/home/WILLICAT_HOME_V3_VISUAL_TARGET_V2_1.png) (actual repo path: `docs/references/home/home/WILLICAT_HOME_V3_VISUAL_TARGET_V2_1.png`). It is visual DNA, **never** a layout or final lighting map.
3. **Neutral lighting:** [V2 lighting art contract](../art/WILLICAT_HOME_V3_LIGHTING_ART_CONTRACT_V2.md); use the [neutral real-art proof](../../artifacts/prototype_review/home_v3_real_art_lighting_proof_revision_v1/01_neutral.png) only to understand matte material response, never to reuse its 1400×920/256×768 room placement.

Do not attach an older full-room concept, a crowd of unrelated references, final character art, or a generated café painting as a placement map. Attach the V2_1 target **with the explicit style-only instruction** and the one or two relevant guide images per asset. World units are not image pixels. All artwork uses elevated 3/4, soft/isometric-lite perspective, matte handcrafted illustration. The main value hierarchy stays quiet enough for 540×960 character and action readability. No baked sun streak, long directional shadow, lamp spill on other objects, wet/rain state, night grade, seasonal wash, movable-object shadow, readable baked text, person/cat or interactive object.

If a provider cannot export the exact narrow or nonstandard canvas, its raw generation is only a **draft**. An artist must register the intended artwork on the exact specified source canvas *without stretching or moving world landmarks* before submitting to Forge. Do not accept an auto-cropped/recentered PNG as the source. The fixed-canvas Forge mode intentionally preserves pixels and top-left registration; it is not a layout editor.

All final candidates are **CANDIDATE**, not FINAL. The following command shape uses the existing Forge package from repository `tools/` with its `.venv` Python; replace the three bracketed paths/IDs with each asset's values. Do not run against a missing source:

```bash
cd /Users/teddywoot/willi-cat/tools
willicat_asset_forge/.venv/bin/python -m willicat_asset_forge.cli build-static \
  --source ../docs/source_assets/home_v3/production_batch_a_v1/<final_png> \
  --asset-id <asset_id> --output-dir willicat_asset_forge/output/home_v3_batch_a/<asset_id> \
  --pivot FULL_CANVAS_TOP_LEFT --status CANDIDATE \
  --expected-size <width>x<height> <opaque_or_preserve_canvas_flag>
```

Floor flag is `--opaque`; the other five use `--preserve-canvas`. Forge records source/runtime hashes, exact dimensions, alpha visual bounds and edge-contact flags. It does **not** decide origin, scaling, tint, mask or whether painted lighting is acceptable; those require the Godot and human gates listed below. For all assets, initial Godot import is linear-filtered with mipmaps for zoom review, then platform compression must be A/B-tested for matte/alpha edge fidelity and real-device memory. Raw RGBA8 sizes below assume no GPU compression; full mip chains add about 33%.

## A1 — floor base

| Field | Required contract |
| --- | --- |
| Asset ID / final filename | `home_v3_floor_base_a1` / `home_v3_floor_base_a1.png` |
| Visual purpose / ownership | One quiet opaque, fixed floor; `STATIC ENVIRONMENT`. No nav/collision ownership. |
| Attach | `02_floor_envelope.png` first; V2_1 target second, **style only**. |
| Canvas / alpha / padding | 960×1980 RGB or fully opaque RGBA; 0 transparent margin; floor pattern may continue to exact canvas edge, without a dark frame. |
| World rect / pivot / scale | `(0,0,640,1320)`; top-left `(0,0)`; uniform `2/3` on `FloorBaseSlot/Texture`, centered OFF. |
| Perspective | Elevated 3/4 floor plane; restrained wood/stone/café insets only; no false raised object geometry. |
| Baked / forbidden | Material/form grain and subtle fixed architectural contact AO allowed. No chair/table/cat/door cast shadow, sun stripe, lamp pool, rain puddle, night color or season. |
| Occlusion / runtime lighting | Under every object; no front mask. Receives runtime CanvasModulate/window/lamp contributions. |
| Forge / memory | `build-static --opaque --expected-size 960x1980`; 7.251 MiB RGBA8 (~9.668 MiB with mips). Verify opacity, source hash, bounds, no visible tiling repetition. |
| Destination / acceptance | `assets/environment/home_v3/batch_a/home_v3_floor_base_a1.png` → `Architecture/BatchAArtSlots/FloorBaseSlot/Texture`. Must fit room outline and threshold without moving any root; default/tall/camera-min and event OFF are readable. |

Prompt to copy:

> Create ONLY the neutral floor surface for the locked WilliCat Home V3 Staggered Salon. Exact source canvas 960×1980 px, fully opaque, full-bleed; elevated 3/4/isometric-lite café floor matching the attached Godot floor guide's 640×1320 world footprint. Follow the attached V2_1 image for handcrafted matte storybook material, warm neutral flooring and restrained jade detail, **not** its furniture placement or lighting. Keep the center and both staggered seating lanes visually quiet so small cats and coffee feedback read. Subtle fixed material grain and architectural contact AO are permitted. Do not depict walls, counter, espresso equipment, tables, chairs, cats, plants, door leaves, text, furniture shadows, sun rays, lamp pools, puddles, rain, night or seasonal color grade. The bottom-center entrance route stays open. Deliver one unannotated PNG, no crop, no resized canvas, no border.

## A2a — north wall

| Field | Required contract |
| --- | --- |
| Asset ID / final filename | `home_v3_north_wall_a2` / `home_v3_north_wall_a2.png` |
| Visual purpose / ownership | Fixed cream/jade north architectural shell and blank café-name plaque; `FIXED BACK VISUAL`. |
| Attach | `03_wall_shell_envelope.png` first; `06_runtime_signage_surfaces.png` second; V2_1 target third, style only. |
| Canvas / alpha / padding | 960×360 RGBA; transparent outside structural silhouette. Structural edge contact is permitted where the wall joins side/service layers; do not auto-crop. Keep at least ~12 source px transparent around isolated ornamental protrusions. |
| World rect / pivot / scale | `(0,0,640,240)`; top-left; `2/3`, centered OFF. |
| Perspective | Elevated 3/4 fixed north wall, not a front-on dollhouse plane. Cream plaster, muted jade lower panel, warm wood, small aged brass trim. |
| Baked / forbidden | Intrinsic form shading/subtle AO only; no window sunlight, pendant/lamp light pool, movable shelves, plants, equipment, signs with text or character. |
| Occlusion / runtime lighting | Behind objects/actors. Neutral to runtime day/rain/night; no room-front mask. |
| Forge / memory | `build-static --preserve-canvas --expected-size 960x360`; 1.318 MiB RGBA8 (~1.758 with mips). Verify alpha, seams, source hash, intentional edge flags. |
| Destination / acceptance | `assets/environment/home_v3/batch_a/home_v3_north_wall_a2.png` → `NorthWallSlot/Texture`. Blank text-safe surface is world `(82,98,176,38)`; test runtime text against actors/camera. |

Prompt to copy:

> Draw ONLY the fixed north wall shell for the locked WilliCat Home V3 room, on an exact 960×360 transparent RGBA canvas. Register the full canvas top-left to world `(0,0)` at `2/3` scale; do not crop or recenter. Use the attached Godot wall and signage guides for position; use V2_1 solely for cream plaster, muted deep jade, warm wood, restrained aged brass and softened Art Deco handcrafted matte language. Leave a clean blank café-name plaque corresponding to world `(82,98,176,38)`—no readable text. Keep wall value quiet behind the service/character area. Architecture-only fixed joinery is allowed; no lamp fixture, plant, shelf prop, menu text, POS, pastry case, espresso machine, grinder, counter, cat or character. Paint intrinsic form and subtle fixed AO only. No baked sun, lamp pool, rainy/night/seasonal tint. Output the isolated registered wall PNG with transparent non-wall pixels and no background scene.

## A2b — left boundary

| Field | Required contract |
| --- | --- |
| Asset ID / final filename | `home_v3_left_boundary_a2` / `home_v3_left_boundary_a2.png` |
| Visual purpose / ownership | Unique fixed left wall/edge joining north wall, bed shelter and scratch transition without absorbing either prop; `FIXED BACK VISUAL`. |
| Attach | `03_wall_shell_envelope.png` first; `01_locked_home_ownership.png` second; V2_1 target third, style only. |
| Canvas / alpha / padding | 72×1665 RGBA. Architectural joins may touch top/bottom/left edge intentionally; no automatic trim. Empty rest of canvas transparent. |
| World rect / pivot / scale | `(0,156,48,1110)`; top-left; `2/3`, centered OFF. |
| Perspective | Same wall datum/material/perspective as A2a; understated bed/scratch **architectural backdrop only**. |
| Baked / forbidden | Intrinsic form/subtle fixed AO only; no CatBed, ScratchPost, plant, lamp, shelf object, door leaf, cat, cast furniture shadow or weather grade. |
| Occlusion / runtime lighting | Behind all gameplay; not a left-side foreground curtain. |
| Forge / memory | `build-static --preserve-canvas --expected-size 72x1665`; 0.457 MiB RGBA8 (~0.610 with mips). Verify seam to A2a and no route-narrowing silhouette. |
| Destination / acceptance | `assets/environment/home_v3/batch_a/home_v3_left_boundary_a2.png` → `LeftBoundarySlot/Texture`. Bed `(175,550)` and ScratchPost `(100,985)` remain separate, fully interactable. |

Prompt to copy:

> Create ONLY the long, narrow fixed LEFT boundary architecture of the locked WilliCat Home V3 room. Exact 72×1665 RGBA canvas, top-left registered to world `(0,156)` with uniform `2/3` scale; the entire visible architecture must stay within world x=0–48, y=156–1266. Follow the attached Godot wall and ownership guides for geometry; V2_1 is only a matte cream/jade/wood/brass mood reference. Match north-wall material datum and hand-painted elevated 3/4 perspective. A quiet fixed recess/shelter cue behind the bed and a small structural relationship near the scratch transition are fine; CatBed and ScratchPost themselves are NOT in this image. No plant, movable shelf, lamp, door leaf, character, sunlight, lamp spill or seasonal/weather layer. Preserve full transparent canvas and join seams; do not crop or move the strip to center. Deliver one isolated PNG.

## A2c — right boundary

| Field | Required contract |
| --- | --- |
| Asset ID / final filename | `home_v3_right_boundary_a2` / `home_v3_right_boundary_a2.png` |
| Visual purpose / ownership | Unique right shell joining service and window; `FIXED BACK VISUAL`, with a **required transparent window cut-out**. |
| Attach | `03_wall_shell_envelope.png` first; `04_signature_window.png` second; V2_1 target third, style only. |
| Canvas / alpha / padding | 72×1665 RGBA; world cut-out overlap `(592..605,360..532)` must be fully clear where the actual view-through passes. Do not fill it with a permanent sky. Intentional architectural edge contact at seams is permitted. |
| World rect / pivot / scale | `(592,156,48,1110)`; top-left; `2/3`, centered OFF. |
| Perspective | Right wall matches A2a/A2b with angled elevated 3/4 join; defer actual framed window pixels to A3. |
| Baked / forbidden | Fixed wall form/subtle AO only; no Plant, WindowPerch, exterior, rain, glass glare, lamp fixture or weather/season cast. |
| Occlusion / runtime lighting | Behind gameplay, alpha-clear at window view. No broad foreground occlusion over perch/plant. |
| Forge / memory | `build-static --preserve-canvas --expected-size 72x1665`; 0.457 MiB RGBA8 (~0.610 with mips). Check alpha mask world intersection and A3 seam in Godot. |
| Destination / acceptance | `assets/environment/home_v3/batch_a/home_v3_right_boundary_a2.png` → `RightBoundarySlot/Texture`. Perch/Plant remain independent and readable. |

Prompt to copy:

> Create ONLY the fixed RIGHT boundary wall of the locked WilliCat Home V3 room on an exact 72×1665 RGBA full canvas. Its top-left registers at world `(592,156)` with `2/3` uniform scale, occupying world x=592–640 and y=156–1266. Follow the two attached Godot guides exactly; V2_1 supplies only handcrafted cream/jade/wood/brass style. Match the north/left wall datum and elevated 3/4 perspective. Critically leave the world window view-through intersection x=592–605, y=360–532 FULLY TRANSPARENT, cleanly joined to the separate A3 frame; do not paint sky, glass, foliage or an exterior into this strip. Do not include WindowPerch, Plant, a cat, lamps, seasonal décor, door leaves, sun beams or night/rain grade. Keep the source canvas registered, not cropped/recentered. One isolated PNG.

## A4 — fixed service wall

| Field | Required contract |
| --- | --- |
| Asset ID / final filename | `home_v3_service_wall_fixed_a4` / `home_v3_service_wall_fixed_a4.png` |
| Visual purpose / ownership | Fixed background rhythm linking left order bay and right prep bay, never equipment; `FIXED BACK VISUAL`. |
| Attach | `05_service_fixed_vs_interactive.png` first; `06_runtime_signage_surfaces.png` second; V2_1 target third, style only; neutral proof only if material rendering needs clarification. |
| Canvas / alpha / padding | 804×420 RGBA; transparent outside fixed panel/cabinet/recess contours and in its overlap with the A3 opening (world x=565–584, y=360–468). About 12 source px edge safety for isolated trim; intentional structural seam contact okay. |
| World rect / pivot / scale | `(48,188,536,280)`; top-left; `2/3`, centered OFF. |
| Perspective | One coherent elevated 3/4 structural service wall; repeat material datum, not a baked continuous counter/equipment silhouette. |
| Baked / forbidden | Intrinsic panel/cabinet form and subtle fixed contact AO allowed. No CounterShell/POS/PastryCase/Espresso/Grinder pixels, cup, steam, worker, readable menu, sunlight/lamp pool. |
| Occlusion / runtime lighting | Back visual only. Counter front remains object-owned. Neutral under runtime atmosphere. |
| Forge / memory | `build-static --preserve-canvas --expected-size 804x420`; 1.288 MiB RGBA8 (~1.718 with mips). Verify five objects remain separate and the window alpha intersection is clear. |
| Destination / acceptance | `assets/environment/home_v3/batch_a/home_v3_service_wall_fixed_a4.png` → `ServiceWallSlot/Texture`. Menu text-safe world rect `(340,190,164,34)` stays blank. Brew/Cup quiet review zone `(310,285,235,180)` stays visually calm. |

Prompt to copy:

> Create ONLY the FIXED service-wall backdrop for the locked WilliCat Home V3 room: exact 804×420 RGBA canvas, top-left registered to world `(48,188)`, displayed uniformly at `2/3` scale (536×280 world). Use the attached Godot service/ownership and signage guides for geometry. V2_1 is a style-only reference for cream plaster, deep muted jade panels, warm wood joinery, tiny aged brass and softened handmade Art Deco. Join the left order/serve bay and right brew bay visually with permanent panel datum, shallow noninteractive fixed cabinetry/recess and blank signage surfaces, but NEVER paint the five interactive objects: CounterShell, POSStation, PastryCase, EspressoStation or GrinderStation. Keep the Worker+Espresso+Cup zone world `(310,285,235,180)` low-clutter for Brew Focus/Cup Reveal. Keep the window view-through intersection world x=565–584, y=360–468 completely transparent. Blank menu safe area world `(340,190,164,34)`, no readable text. No cup, steam, cast movable-object shadow, sun streak, lamp pool, weather or time tint. Full registered transparent source, no crop or recenter; one isolated PNG.

## A3 — signature window frame

| Field | Required contract |
| --- | --- |
| Asset ID / final filename | `home_v3_signature_window_frame_a3` / `home_v3_signature_window_frame_a3.png` |
| Visual purpose / ownership | Permanent fitted right-wall frame only; `FIXED BACK VISUAL`. Exterior, weather and light are separate runtime layers. |
| Attach | `04_signature_window.png` first; V2_1 target second **style only**; [neutral proof](../../artifacts/prototype_review/home_v3_real_art_lighting_proof_revision_v1/01_neutral.png) third only for material response. Proof texture dimensions are NOT placement authority. |
| Canvas / alpha / padding | 256×768 RGBA. View-through world `(565,360,40,172)` maps to source approx `(52,48)–(212,736)`; pane apertures inside it must be alpha 0, while thin frame mullions may remain. Frame sits within outer world `(552,348,64,192)`; at least 8 source px transparent safety around protruding trim where feasible. |
| World rect / pivot / scale | `(552,348,64,192)`; top-left; `1/4`, centered OFF. |
| Perspective | Right-wall-fitted elevated 3/4 frame with gentle recess, not a pasted frontal proof card. Do not modify WindowPerch at `(515,520)`. |
| Baked / forbidden | Frame material/form and tiny architectural AO only. No permanent outside scene, rain, glass glare, day/night glow, sunlight beam, plant/perch/cat. |
| Occlusion / runtime lighting | ExteriorBackdrop behind; frame above it but behind all gameplay; optional Glass/Weather/WindowLight nodes remain independent. Exterior must be clipped to opening. |
| Forge / memory | `build-static --preserve-canvas --expected-size 256x768`; 0.750 MiB RGBA8 (~1.000 with mips). Check opening alpha, edge pad, right/service seam and day/sunset/night/rain swaps. |
| Destination / acceptance | `assets/environment/home_v3/batch_a/home_v3_signature_window_frame_a3.png` → `SignatureWindowSlot/FrameTexture`. Same frame works with multiple future exterior profiles; perch/plant stay tappable and readable. |

Prompt to copy:

> Illustrate ONLY the fixed production signature WINDOW FRAME for the locked right wall of WilliCat Home V3. Exact 256×768 transparent RGBA canvas, top-left at world `(552,348)`, displayed uniformly at 0.25 scale to 64×192 world units. The real-Godot window guide controls perspective/placement; V2_1 supplies jade/cream/wood/brass storybook mood only; the neutral proof shows matte material response, not production scale. Design an elevated 3/4 right-wall inset frame with softened Art Deco rhythm and subtle intrinsic form/AO. Inside the view-through envelope corresponding to source `(52,48)–(212,736)`, all actual PANE openings MUST remain completely alpha-transparent; thin structural frame mullions may cross between panes. This allows any later day, sunset, night, rain or regional exterior behind the SAME frame. No painted exterior, sky, foliage, rain streaks, glass glare, glow, light beam, WindowPerch, plant or cat. Keep trim within the source and alpha-safe at edges. Deliver one registered PNG, no crop/recenter.

## Human rejection checks before calling any candidate FINAL

Open the six independent PNGs in the [staging scene](../../scenes/dev/home_v3_production_art_batch_a_staging_v1.tscn), never in production Home first. Compare `01`, `04`, `05`, `08`, `09` of the guide pack. Check the two window-overlap alpha holes with day/night/rain exterior stand-ins; inspect default/min/Brew/Cup camera and both portrait profiles; hide each interactive object to ensure its silhouette was not baked into A4; move a *dev clone* chair/bed/perch to ensure no residual shadow; leave Event OFF and door passage open. Reject wrong dimensions/pivot, warped perspective, service clutter, tiny unreadable signage, alpha seams, texture over-budget on the target phone, or any picture that needs a gameplay-coordinate patch. A technical Forge PASS alone never grants art approval.
