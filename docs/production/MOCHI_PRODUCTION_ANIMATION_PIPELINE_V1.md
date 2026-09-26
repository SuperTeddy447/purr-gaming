# Mochi production animation pipeline V1

Status: **hybrid presentation runtime READY; SIDE RIGHT walk TEMP TRUE-SLICE ACCEPTED; PREPARE COFFEE V1 CANDIDATE / HUMAN REVIEW REQUIRED; remaining final action art REQUIRED**. `MOCHI_WALK_SIDE_RIGHT_V1` is assigned to the shared semantic animation set as a TEMP candidate only for rightward horizontal movement. `MOCHI_PREPARE_COFFEE_V1` is assigned to the shared semantic animation set as a TEMP candidate for generic station-facing coffee preparation (8 frames, 8 FPS, looping). Neither is marked FINAL. Idle/ambient idle use the layered procedural contract in `MOCHI_LAYERED_IDLE_PRODUCTION_V1.md`; action states retain this SpriteFrames pipeline. No gameplay states or animation-driven completion are added. The canonical House Style Lock image remains unchanged and is the safe idle fallback.

## Runtime hierarchy and authority

```text
MochiScaleTestDEV (existing floor-contact root; SliceMover + SliceWorker unchanged)
├── ContactShadow                    separate, subtle runtime floor shadow
├── MochiAnimationSlot               MochiVisualPresenter / semantic action endpoint
│   ├── LayeredIdleVisual             idle + ambient_idle; canonical BodyBase TEMP fallback
│   │   ├── BodyMotion/BodyBase       production body or exact canonical fallback
│   │   ├── BodyMotion/FaceLayers     OPEN / HALF / CLOSED patch slots
│   │   ├── TailPivot/Tail            independent event-like sway slot
│   │   └── EarPivot/EarTwitch        one asymmetric twitch slot
│   └── ActionAnimatedSprite          work/route SpriteFrames playback when clips exist
├── CarryAnchor                      local cup attachment, mirrored on approved side views
├── FXAnchors/HeadFX, ActionFX       future local FX attachment points
└── CarryCupPlaceholder              existing TEMP cup; follows CarryAnchor and SliceWorker state
```

`TrueSlicePresentation` is still the sole bridge from existing worker/ambient states to semantic actions. It now sends those actions to `MochiVisualPresenter.play_action(action_id)`; it never chooses an image filename. `MochiVisualPresenter` selects an available clip from `MochiAnimationSet` and reads the existing `SliceMover` target to choose direction. `VerticalSliceController`, `SliceWorker` timers, rewards, routes, ambient reservations, and customer logic remain gameplay authority. A clip ending does **not** finish brewing or serving. The four coffee semantic events (`coffee_prepare_started`, `coffee_prepare_completed`, `coffee_pickup`, `coffee_served`) remain presentation/audio/FX boundaries, not frame-number triggers.

## Semantic action contract

All frames keep the actor root at the feet. Standing visible height is approximately **145–150 px at default Home framing**; the current Home LARGE setting targets 150 px. `MochiAnimationSet` stores loop/interruption/event metadata and fallback links; future SpriteFrames animation names use semantic IDs. Clip directories below are under `res://assets/characters/mochi/animations/`. Directional suffixes `_down`, `_up`, `_side`, optionally `_left`/`_right`, may be added to any action where art exists.

| Action ID | Loop / target duration | Direction and pivot | Work interruptibility / event dependency | Fallback / production directory |
| --- | --- | --- | --- | --- |
| `idle` | Procedural, indefinite | Fixed canonical Home-facing; feet fixed | Immediately work-interruptible; no event | LayeredIdleVisual → canonical TEMP; see layered-idle contract |
| `ambient_idle` | Procedural, indefinite; slightly more activity | Fixed canonical Home-facing; feet fixed | Immediately work-interruptible; no event | Same LayeredIdleVisual with ambient timing profile |
| `walk` | Loop while the existing mover advances | Direction from route, no root motion; feet fixed | Ambient walk cancellable by work; no animation completion event | RIGHT → TEMP `walk_side`; missing directions → `idle` static; `walk/` |
| `prepare_coffee` | Loop for ~2.0 s NORMAL brew timer | Station-facing generic; foot at CoffeeAction | Ambient cannot interrupt; timer ends preparation on `coffee_prepare_completed` | TEMP `prepare_coffee` (8 frames, 8 FPS); `prepare_coffee/` |
| `carry_coffee` | Loop along Model C route / while awaiting serve tap | Route/customer-facing; separate cup at CarryAnchor | Ambient cannot interrupt; begins at `coffee_pickup` | `walk` → `idle` → static; `carry_coffee/` |
| `serve` | One-shot, ~0.45 s NORMAL service | Customer-facing; foot stays at service point | No duplicate completion; `coffee_served`/cup removal comes from gameplay timer | `idle` → static; `serve/` |
| `return_idle` | Walk-like loop until WorkerIdle | Route-facing; foot remains on authored waypoints | Ambient waits for customer exit; `worker_returned_idle` is gameplay event | `walk` → `idle` → static; optional dedicated clip may live in `walk/` |

The `serve` animation may contain a future semantic presentation marker for cup transfer, but gameplay must still make the authoritative serve decision and grant reward once. The existing cup remains separate from the normal walk sprite. Espresso steam/progress remains station-owned and independent of Mochi frame count.

`MochiVisualPresenter.play_action()` routes the two idle actions to LayeredIdleVisual and all other semantic actions through the existing action clip resolver. Living Café and True Slice callers continue using the same semantic interface.

## Direction and fallback resolution

Movement target delta determines DOWN (toward camera), UP (away), RIGHT, or LEFT. The existing presenter reads `SliceMover.current_target`; no second direction system was added. Stationary action clips retain the last direction or use an explicit facing request from the existing actor. A preview can supply direction directly. Layered idle always retains canonical Home-facing orientation and is never horizontally mirrored, preserving asymmetric ear/tail identity. The shared runtime `MochiAnimationSet` references the prototype through `temp_frames` and sets `allow_side_mirror = false`: `walk + RIGHT` selects `TEMP:walk_side` unflipped; LEFT, DOWN, and UP continue to the canonical static fallback. No right-side artwork is used for vertical movement and no temporary horizontal mirroring is active. For an action clip, candidates are tried in this order within each source:

1. Exact directional clip (`action_left`, `_right`, `_up`, or `_down`) if present.
2. For horizontal directions, `action_side`; LEFT mirrors only when `allow_side_mirror` is true. RIGHT uses the side clip unflipped. Dedicated LEFT art takes precedence. The default mirror is a pipeline convenience, **not** approval to invert Mochi's asymmetric ear/tail identity; set `allow_side_mirror = false` when art direction requires dedicated left frames.
3. Generic semantic clip (`action`).

Source order is FINAL then TEMP for action clips. If none exists, the action fallback chain is tried with the same source order (`carry_coffee→walk→idle`, `return_idle→walk→idle`, `prepare_coffee→idle`, `serve→idle`, `walk→idle`). Missing idle layers use the exact canonical body fallback through LayeredIdleVisual; see the layered-idle contract. If an action clip is missing, the canonical BodyBase is shown with idle motion stopped. Empty SpriteFrames animations are treated as missing. The preview displays requested action, direction, actual source/clip, and TEMP/FINAL status. Gameplay never depends on which fallback won.

## Frame, pivot, scale, and shadow policy

- Deliver transparent PNG frame sequences or an atlas/sheet converted with standard Godot import tools into a `SpriteFrames` resource; no custom importer is required.
- Raw canvases **may differ between clips**, but every frame *within a clip* must share consistent foot registration and canvas width. Keep transparent padding for ears, tail S-curve, paws, scarf, apron, and gestures. No frame-to-frame jitter or clipped extremity.
- `MochiVisualPresenter` calculates the clip's visible alpha height and foot Y once, or uses optional `visible_height_by_clip` and `foot_y_by_clip` overrides in `mochi_animation_set.tres`. It scales that clip against the current canonical static height and offsets the frame so feet meet the actor root. Changing 1/2/3 scale in the existing development test refreshes the animated scale too.
- Do not bake large room/floor shadows into animation frames. `ContactShadow` stays under the same foot root independently. Do not bake the cup into ordinary walk frames; use `CarryAnchor` (current local right-side x=28, y=-80) and coordinate dedicated carry/serve poses with it.
- No actor z-index, room marker, camera, or Model C waypoint is changed by animation playback.

## Source layout and naming

`assets/characters/mochi/runtime/mochi_animation_set.tres` owns the action SpriteFrames resources. `data/mochi_layered_idle_config.tres` owns idle timing, future layer textures, pivots, and cropped-source offsets. The existing `animations/idle/`, `ambient_idle/`, `walk/`, `prepare_coffee/`, `carry_coffee/`, `serve/`, and `fx/` paths remain available, but idle/ambient PNG layer sources are specified in `MOCHI_LAYERED_IDLE_PRODUCTION_V1.md`. Keep the canonical reference out of production runtime folders. Action animation names remain semantic, e.g. `walk_side`, `prepare_coffee`, `serve`.

To install one action without code changes: import its PNG frames (or atlas) into Godot, add the frames to a `SpriteFrames` resource using the semantic clip name, set loop/FPS according to the table, assign the resource to `final_frames` in `mochi_animation_set.tres`, and add pivot/visible-height overrides only if automatic alpha bounds are unsuitable. Open `scenes/dev/mochi_animation_preview.tscn`, inspect all directions, then run the pipeline and True Slice tests. Other missing actions continue to use their own fallback. Do not place the frame sequence directly into gameplay scripts.

## MOCHI_WALK_SIDE_RIGHT_V1

Status: **TEMP TRUE-SLICE ACCEPTED**. Human visual gate: **PASS**. Direction is **SIDE RIGHT only**; the shared gameplay `MochiAnimationSet` selects it for rightward movement as temporary art. This does not mark the directional walk set complete or the clip FINAL. LEFT, DOWN, and UP art remain missing; this runtime set keeps their existing canonical static fallback. Horizontal mirroring is disabled for this shared set so Mochi's asymmetric details are not inverted.

The authoritative PNG and animated WebP reference are copied unchanged to `docs/source_assets/mochi/walk_side_v1/`. That directory contains `.gdignore`, so the originals stay out of Godot runtime imports. PNG is the runtime prototype source; WebP is reference-only. The decoded PNG cells and WebP frames were compared in order: all eight RGBA frames match exactly; each WebP frame is 125 ms, with infinite looping (8 FPS).

The runtime-derived sheet is `assets/characters/mochi/animations/walk/mochi_walk_side_right_prototype_v1.png` (2560×320 RGBA, eight 320×320 cells). It is built by `scripts/dev/build_mochi_walk_side_prototype_v1.py`, which crops each 640×640 PNG cell independently, downsamples premultiplied RGBA using Lanczos, and reassembles in source order. No frame is repositioned, cropped to alpha, sharpened, recolored, or painted over. `mochi_walk_side_right_prototype_v1.tres` exposes the 8-frame looping `walk_side` clip at 8 FPS.

Source alpha bounds are cell-local, right/bottom exclusive. All frames have alpha transparency, clear left/right cell gutters, and the same bottom contact at y=640. Frames 1, 4, 5, and 8 touch the top edge; therefore the source has no top safety padding on those poses. This is recorded as a prototype risk, not repaired by moving or cropping the artwork.

| Frame | Alpha bounds (x0,y0,x1,y1) | Bounds center X | Approx. head-area center X | Visible height |
| ---: | --- | ---: | ---: | ---: |
| 0 | (102, 0, 541, 640) | 321.5 | 378.5 | 640 |
| 1 | (114, 12, 548, 640) | 331.0 | 387.0 | 628 |
| 2 | (112, 2, 511, 640) | 311.5 | 374.5 | 638 |
| 3 | (97, 0, 538, 640) | 317.5 | 387.0 | 640 |
| 4 | (68, 0, 537, 640) | 302.5 | 386.0 | 640 |
| 5 | (67, 10, 529, 640) | 298.0 | 380.0 | 630 |
| 6 | (38, 4, 525, 640) | 281.5 | 379.5 | 636 |
| 7 | (49, 0, 512, 640) | 280.5 | 374.0 | 640 |

At a 150 px target height, the runtime node scale is 150/320 = **0.46875**. Visible-height variation is at most 12 source px (~2.8 gameplay px). The whole alpha-bounds center spans 50.5 source px (~11.8 gameplay px), largely because the striped tail changes the bounds; the alpha-weighted center moves only 9.9 source px (~2.3 gameplay px), and the rough head-area center spans 13 source px (~3.0 gameplay px). Frame 7→0 head-center delta is ~1.1 gameplay px. These measurements suggest the apparent bbox drift is mostly changing silhouette/tail rather than root translation, but visible jitter still needs human judgment in the real preview. Feet do not require per-frame root correction. The tail remains inside horizontal cell bounds; its curl changes as intended gait, while top-edge ear contact remains a clipping-margin risk.

The silhouette retains the orange tabby markings, side-view almond eye, cream muzzle, asymmetric ears, jade apron with Art Deco detail, cream shirt, rust neckerchief, and striped tail. Close source inspection shows mild frame-to-frame line/detail variation, especially around small face and apron ornament marks; no major identity or costume loss was observed. Human review in the runtime preview accepted the motion, identity at gameplay scale, and loop for TEMP True Slice use.

The preview in `scenes/dev/mochi_animation_preview.tscn` retains **8** to toggle the RIGHT-facing TEMP walk test and return to idle. The normal semantic preview path is **3** (request `walk`) then **D** (RIGHT); its status should read `walk RIGHT → TEMP:walk_side`. **A**, **W**, or **S** keep LEFT/UP/DOWN on fallback. The preview disables side mirroring for its duplicated test set. The runtime integration changes only clip resolution; Home routes, root, CarryAnchor, ContactShadow, idle layering, and gameplay state are unchanged.

Known production polish issue (not a temporary True Slice blocker): frames 1, 4, 5, and 8 touch the top cell edge, leaving minimal/zero transparent headroom above the ear tips. Human runtime review found no blocker for temporary True Slice use. Do not alter, crop, or regenerate these frames in this integration. The final replacement should include safe transparent headroom. Remaining whole-silhouette bounds variation is largely tail-driven; no per-frame root correction is introduced.

Manual review: open and run the existing preview scene, use **3** then **D** to verify the normal semantic right-walk resolution, or press **8** to toggle the isolated prototype preview. Watch at least three loops at the default 150 px ruler; use the live frame readout and **Space** to pause on frames 1, 4, 5, and 8 (displayed one-based) to inspect the top ear tips. Also check whether the head/body visibly slide, the apron ornament morphs, the S-tail clips, and frame 8 → frame 1 loops cleanly. Press **8** again or **1** to restore canonical idle.

## MOCHI_PREPARE_COFFEE_V1

Status: **CANDIDATE / HUMAN REVIEW REQUIRED**. Direction is **generic / station-facing**; the shared gameplay `MochiAnimationSet` selects it for `prepare_coffee` as temporary art across all facings. It is not marked FINAL. The animation contains character-only gesture without espresso machine, cup, counter, or station props baked into the frames.

The source delivery package (`MochiPrepareCoffeeRuntime_GodotReady.zip`) was extracted and inspected:
- Provenance documentation is preserved in `docs/source_assets/mochi/prepare_coffee_v1/` (`.gdignore`, `MOCHI_PREPARE_COFFEE_RUNTIME_METADATA_V1.json`, `README_GODOT.md`, `MOCHI_PREPARE_COFFEE_EDGE_DIAGNOSTIC.png`, `MOCHI_PREPARE_COFFEE_150PX_PREVIEW.png`).
- Authoritative runtime atlas: `res://assets/characters/mochi/animations/prepare_coffee/mochi_prepare_coffee_v1.png` (3104×474 RGBA, eight 388×474 px cells in an 8×1 horizontal layout).
- Authoritative SpriteFrames resource: `res://assets/characters/mochi/animations/prepare_coffee/mochi_prepare_coffee_v1.tres` (8 frames, 8.0 FPS, `loop = true`). Clean project-relative paths with no Downloads or foreign references.
- Safe transparent padding: all cells have safe transparent padding >= 32 px (top gutter: 32–37 px, bottom gutter: 28–29 px, left gutter: 32–64 px, right gutter: 51–80 px). No ear tips or tail curves touch cell edges.
- Geometry & registration: stable feet/root in cell at (194, 441). Maximum visible character height is 412 px. At target gameplay height of 150 px, uniform scale is 150 / 412 ≈ **0.364078**. Registered via `visible_height_by_clip[&"prepare_coffee"] = 412.0` and `foot_y_by_clip[&"prepare_coffee"] = 441.0` in `mochi_animation_set.tres`. Sprite offset is (-194, -441), placing the authored feet exactly on the actor gameplay root at (0, 0).
- Station relationship: visual separation is preserved. Composition consists of Mochi's prepare_coffee AnimatedSprite2D + existing EspressoStation + existing coffee progress/steam FX + existing ContactShadow + DepthSortedLayer behind CounterFront occluder.
- Direction policy: station-working pose; treated as generic prepare_coffee without directional variants and without auto-flipping (`flip_h = false`).
- True Vertical Slice: seamlessly plays during `SliceWorker.State.PREPARING_COFFEE` in both Manual and Auto modes. Looping playback matches the gameplay preparation timer (~2.0 s in Normal mode) without modifying gameplay logic, order timers, or reward handling.

Human review gate checklist:
1. Mochi identity: orange tabby markings, almond eye, cream muzzle, asymmetric ears, jade apron, neckerchief.
2. Animation smoothness: small barista working / prepare-coffee arm and body gesture at 8 FPS.
3. Feet/root stability: feet remain grounded on ContactShadow at the CoffeeAction marker without root drift.
4. Apron and face stability: no ornament morphing or facial distortion.
5. Tail behavior: natural swaying posture behind character.
6. Loop transition: clean cycle between frame 8 and frame 1.
7. Station composition: natural gesture reading beside EspressoStation behind CounterFront.
8. Gameplay scale: ~150 px scale hides minor raster artifacts.
9. Alpha fringe: edge diagnostics confirm clean alpha with no white or dark halo against café background.

## Independent preview

Open `scenes/dev/mochi_animation_preview.tscn`. Keys: **1–7** choose idle, ambient_idle, walk, prepare, carry, serve, and return_idle; press **4** to inspect `prepare_coffee` at ~150 px gameplay scale; **3** then **D** verifies the normal semantic `walk + RIGHT` resolution; **8** toggles the isolated right-facing TEMP walk-side preview; **W/A/S/D** select UP/LEFT/DOWN/RIGHT for ordinary action clips; **Space** pauses/resumes; **R** restarts; **G** toggles guides. The preview shows the floor pivot, 150-design-px height ruler, CarryAnchor, TEMP pivot guides, eye state, and actual source/clip status with live frame readout. It uses the same presenter as Home but does not change café gameplay. It is a development view, not a production character editor.

## Artist delivery checklist and blockers

For idle PNG requirements use the dedicated layered-idle artist contract. Action frames must preserve the locked identity, alpha transparency, stable feet, adequate padding, ~150 px standing presence, and loop/one-shot timing. Verify contact shadow remains separate, cup follows both facings, and brew/serve events remain readable at default and zoomed Home camera framing. Test action directions and missing-clip fallback in the preview; then play one Manual and one Auto café loop. Final art is **not yet delivered**, so animation smoothness, exact silhouette, frame registration, and device-scale readability remain blockers for final sign-off—not for the runtime pipeline.
