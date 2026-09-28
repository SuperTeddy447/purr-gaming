# WilliCat V2 Batch 03 — Human Composition Review

**Candidate state:** ready for human composition review; nothing is marked FINAL. This pass changes only the V2 preview registration. Do not treat screenshot capture or passing technical tests as art approval.

## Open these first

1. `artifacts/prototype_review/home_v2_batch_03/10_final_runtime_clean.png` — unlabelled 9:16 candidate composition.
2. `artifacts/prototype_review/home_v2_batch_03/00_before_runtime.png` and `01_iteration_1.png`–`03_iteration_3.png` — layout progression.
3. `artifacts/prototype_review/home_v2_batch_03/11_final_runtime_guides.png` — semantic zone and anchor registration.
4. `12_counter_zone.png`, then `24_coffee_action.png` — counter grouping and the actual worker occlusion during preparation.
5. `13_left_table_zone.png`–`16_entrance_zone.png` — scale, grouping and floor-contact review.
6. `20_9x16.png`–`23_desktop.png` — composition at the existing viewport families.
7. Compare the clean capture against the primary master at `docs/references/home/home/v2/WILLICAT_HOME_ENVIRONMENT_V2_PRODUCTION_STYLE_LOCK_V1.png`. Use the existing **F6** toggle in the running V2 preview for a direct reference check; it is not a new shipping feature.

## Human decisions requested

- Does the clean scene read immediately as the same locked WilliCat café, with the right-side lounge feeling lived-in but not like a prop test row?
- Are the lower-center table and left table appropriately sized beside ~150 px Mochi and the customer placeholder?
- Do all four seat roots visually line up with the intended chair contact points? Does the extra left chair feel like a sensible seat rather than clutter?
- Is the window perch clearly tied to the window? Are the bed, basket, scratch post, stool and plant natural and discoverable?
- Do the main portrait frame and old cream entrance leaves need individual replacement modules to better match the master? They are known residual art-shape differences; the current pass did not hide or repaint them.
- At tall/wide/desktop crops, are important object silhouettes still legible and the central circulation sufficiently open?
- During `24_coffee_action.png`, is Mochi physically behind the work surface, with the front fascia correctly hiding the lower body? The character scale and floor root are protected from this composition pass.
- Are sign panels correctly attached to their architectural surfaces, even though their shape differs from the master?

## Suggested review flow

1. Open the V2 scene `scenes/dev/home_v2_environment_preview.tscn` in Godot and run the preview.
2. Start with normal Debug OFF. Compare the whole composition to the primary style-lock reference; do not judge from the guide image alone.
3. Press F6 to compare the current runtime with the locked style master; press F6 again to restore modular runtime.
4. Inspect the region captures at native size and then at phone-sized scale. Check asset completeness at the entrance and right edge; viewport cropping is intentional, clipped source art is not.
5. Run the existing manual/auto loop if desired. The capture pack's `24`–`26` images document one deterministic manual loop through the existing gameplay state machine.
6. Record approve / adjust / replace decisions for the main sign, entrance leaves, right-side prop density and chair placement before any art promotion.

## Candidate boundaries

- No default Home scene conversion, economy change, timing change, new customer logic, or Mochi artwork change was made.
- CounterBack, CounterFront, CoffeeAction and the Batch 02 layer stack remain unchanged.
- No per-device furniture positions were introduced and no camera limits were changed.
- Main sign and entrance leaf shapes remain visibly different from the target. The screenshots should be used to decide whether those individual modules need a follow-up replacement.
- All V2 art remains candidate status pending human approval.
