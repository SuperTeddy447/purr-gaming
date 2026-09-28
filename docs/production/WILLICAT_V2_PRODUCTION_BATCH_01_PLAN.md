# WilliCat V2 Production Batch 01 — Working Plan

Status: candidate implementation complete for review, with known visual blockers recorded in `WILLICAT_V2_BATCH_01_HUMAN_REVIEW.md`. All new art remains `CANDIDATE / HUMAN REVIEW REQUIRED`; this plan does not approve final assets.

## Foundation audit

- Runtime Home is `scenes/home/home_scene.tscn`, with 17 stable visual IDs and 26 semantic slot roles from `data/home_visual_asset_catalog.tres`. Slots already support uniformly fitted textures, authored pivots, foreground occlusion and depth-sorted furniture.
- `CameraRig` owns pan, zoom and device-safe limits. The design canvas is 941×1672; gameplay markers, seats, CoffeeAction, WorkerIdle, ServePoint, customer routes and entrance positions are already authored.
- `VerticalSliceController` and `TrueSlicePresentation` own the coffee loop. `LivingCafeAmbientController` owns three local cats/agents, zone reservations and low-priority behaviors. `MochiVisualPresenter` and `CarryAnchor` own character display and carried cup.
- Four `DynamicSignage` surfaces own runtime wording. `FXLayer` has station feedback and empty attachment slots. F1/D, F6, F7, F8 and camera shortcuts already exist.
- The existing Asset Forge CLI handles sprite sequences, atlases and SpriteFrames. Static generated props require a small reusable alpha/pivot packaging step, leaving the sprite pipeline unchanged.
- V2 reference filenames exist in `docs/references/home/home/v2/` and `docs/references/home/characters/v2/`; the prompt's shorter paths do not exist. See `WILLICAT_V2_VISUAL_SOURCE_OF_TRUTH.md`.

## Batch assets

P0 attempts: clean architecture base; separate counter back and counter-front occluder; espresso, grinder, POS, empty pastry case; round table, jade chair; cat bed and rest cushion; floor plant. Each complete source goes to `docs/source_assets/environment/home_v2/<asset_id>/` with provenance. Only technically valid derivatives go to `assets/environment/home_v2/`.

P1 attempts after P0: stool, cat inspection basket, scratch post, window perch, pastries, cake, small/hanging plants, flower vase and blank signage family. Additional assets enter runtime only when their perspective, alpha and placement contract are verifiable.

Retain: existing Mochi art, other runtime cats' placeholders, customer/order/reward state, door controller, gameplay route markers, camera configuration, stable V1 catalog IDs, V1/legacy comparison references and authored default Home scene.

## Scene and behavior approach

- Create a V2 playable visual variant of the existing Home, using the same gameplay scene and replacing visuals by stable `asset_id` plus `slot_role`. Keep CounterBack, CounterFront and stations independent. A separate V2 preview entry makes candidate art reviewable without changing the default Home until the composition is approved.
- Register feline-life destinations as semantic marker IDs and connect them to the existing ambient zone/reservation system only where their floor positions are safe. Do not re-route the coffee worker or customer.
- Add a local world-space reaction component, one short ambient Explorer/basket moment and a separate Espresso steam FX attachment. These use existing movement and lifecycle signals, with no reward or timing changes.
- Capture review evidence from the actual Godot viewport. Normal and technical views share one composition; guides and asset IDs appear only in technical view.

## Risks and acceptance gates

1. **Generation compatibility:** Reject baked cats, text, clipped object bounds, wrong elevated perspective and opaque backgrounds on standalone props. Preserve every attempt as source; never label it FINAL.
2. **Architecture:** A generated clean plate must not bake modular counter, sign frames, entrance leaves or plants. It must register to the existing 941×1672 gameplay canvas. Device views must show no void; do not alter camera bounds to conceal missing art.
3. **Counter:** Back work layer < full-body character < front occluder. Verify with ~150 px Mochi at CoffeeAction and in front of the counter.
4. **Furnishing:** Floor-contact pivots and existing Y-sort naturally reverse character/table order. Full furniture bounds remain available even when the viewport clips them.
5. **Game:** True Vertical Slice MANUAL and AUTO complete with one reward and no altered customer/order/door logic. Ambient story never reserves a customer seat or interrupts coffee work.
6. **Technical:** Source/provenance is ignored by Godot; runtime textures are valid and size-audited; targeted tests, filesystem scan, scene smoke, camera/aspect checks and `git diff --check` run. Existing failures are reported rather than hidden.
7. **Human:** Review assembled V2 art on phone-sized viewports before promoting any candidate to FINAL or switching the default Home presentation.
