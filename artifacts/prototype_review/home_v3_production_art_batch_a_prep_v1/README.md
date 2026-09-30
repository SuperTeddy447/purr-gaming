# Home V3 Batch A prep — real Godot guide pack

All nine PNGs were captured from the running **Godot 4.7.2 game viewport**, using the [development-only staging scene](../../../scenes/dev/home_v3_production_art_batch_a_staging_v1.tscn) inherited from the locked [Home V3 spatial scene](../../../scenes/dev/home_v3_level_design_pass_01.tscn). They show the **current greybox plus Batch A ownership guides**, not generated production art. The empty art slots were not rendered as fake final images. No gameplay root/camera moved for these captures. All PNGs are valid, nonzero, RGB and visually nonblank; eight are 539×959, the tall capture is 539×1168.

| File | What to inspect | Result |
| --- | --- | --- |
| [01_locked_home_ownership.png](01_locked_home_ownership.png) | Locked Home composition, all six art envelopes, numbered roots of the 17 independent art-bearing gameplay objects | Captured 539×959 |
| [02_floor_envelope.png](02_floor_envelope.png) | 640×1320 floor, walkable rectangle, quiet character/seat paths | Captured 539×959 |
| [03_wall_shell_envelope.png](03_wall_shell_envelope.png) | North and unique side strips; right-strip transparent window intersection | Captured 539×959 |
| [04_signature_window.png](04_signature_window.png) | Right-wall window frame/view-through envelope vs independent WindowPerch/Plant | Captured 539×959 |
| [05_service_fixed_vs_interactive.png](05_service_fixed_vs_interactive.png) | Fixed service wall vs separate Counter/POS/Pastry/Espresso/Grinder; Brew/Cup quiet zone | Captured 539×959 |
| [06_runtime_signage_surfaces.png](06_runtime_signage_surfaces.png) | Proposed blank café-name and menu text-safe surfaces | Captured 539×959 |
| [07_depth_grouping.png](07_depth_grouping.png) | Static back architecture vs object-owned CounterFront; no room-wide front mask | Captured 539×959 |
| [08_staging_9x16.png](08_staging_9x16.png) | Complete 9:16 staging guide at canonical gameplay framing | Captured 539×959 |
| [09_staging_tall_phone.png](09_staging_tall_phone.png) | Same ownership and route on the existing tall-phone review profile | Captured 539×1168 |

Numbered roots in images 01/08/09: 1 CounterShell, 2 EspressoStation, 3 GrinderStation, 4 POSStation, 5 PastryCase, 6 TableA, 7 TableB, 8 ChairA, 9 ChairB, 10 ChairC, 11 ChairD, 12 CatBed, 13 WindowPerch, 14 Plant, 15 ScratchPost, 16 EntranceDoor, 17 SeasonalDisplay. The three WaitSpots are invisible semantic owners, not art assets.

The normal game camera remains position `(320,650)`, zoom `1.8`, limits `(0,0)–(640,1320)`; eight main viewport captures use that framing. The 539×1168 shot uses a raw isolated `SubViewport` and zoom `0.84` to match the established tall-phone capture convention for the project's 540×960 `canvas_items/expand` stretch; it does **not** change the locked scene camera. Godot DebugOverlay is OFF; the dev-only `BatchAGuide` annotations are ON. EventLayer is OFF; no manual/auto gameplay loop is staged.

Regenerate in the Godot editor: open `res://scenes/dev/home_v3_production_art_batch_a_staging_v1.tscn`, run current scene, then press **F3**. The scene captures all nine files here and exits. The equivalent standalone launch argument is `--capture-batch-a` after Godot's `--` separator. `F3` was used for this pack because the inherited scene already uses F8 to move a test object; F8 must never be used for Batch A evidence.

The green window guide marks the **maximum view-through envelope**, not a finished pane mask or an approved final frame. The actual frame may have thin mullions; each pane must be alpha-clear and exterior/weather clipped to those apertures. The right boundary and service wall must be clear behind the broader opening. These alpha, perspective and final material joins cannot pass until real art is submitted. The [production spec](../../../docs/production/WILLICAT_HOME_V3_PRODUCTION_ART_BATCH_A_SPEC_V1.md) and [copy-ready image handoff](../../../docs/production/WILLICAT_HOME_V3_PRODUCTION_ART_BATCH_A_IMAGE_GEN_HANDOFF_V1.md) supply the exact candidate contracts.
