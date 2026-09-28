# WilliCat V2 Batch 01 — human review

Status: **CANDIDATE / PARTIAL — not production-approved**. Open `scenes/dev/home_v2_environment_preview.tscn` and run current scene. Normal view is clean. F1/D shows existing technical debug; F6 compares the V2 production style lock; R still toggles the legacy V2.1 reference; G toggles six cat-life anchor guides. No gameplay/camera key was reassigned.

Review the real rendered captures in `artifacts/prototype_review/home_v2_batch_01/README.md` (941×1672, Godot Metal viewport): normal café, debug, style reference, order, CoffeeAction, anchors and one silent-story reaction. The source package and manifest provide candidate art, dimensions and hashes.

## Visual calls needed

| Area | Status | Observation / decision |
| --- | --- | --- |
| Architecture base | HUMAN REVIEW REQUIRED | Warm V2 room reads coherently, but fixed 941×1672 has no verified overscan; entrance has V1 leaf/frame mismatch. |
| Modular café | HUMAN REVIEW REQUIRED | Large empty floor is inherited from existing spatial layout. Do not reposition major objects without a separate gameplay/layout decision. |
| Counter occlusion | **WARNING** | Mochi's feet/lower body look as if standing on the countertop during CoffeeAction. Layer order test passes, but visible art alignment does not meet the intended visual standard. This blocks FINAL. |
| Stations/case | HUMAN REVIEW REQUIRED | Espresso/grinder/POS/case are distinct, but their specular/detail level may exceed the matte style lock; pastry case is empty. |
| Tables/chairs | HUMAN REVIEW REQUIRED | At canonical camera they appear small relative to the room. Their stable positions were not changed. |
| Cat-life props | HUMAN REVIEW REQUIRED | Bed and basket are readable, but the placeholder cats do not naturally occupy the bed/basket yet. Other P1 props are not placed. |
| Reaction bubble/story | PROTOTYPE PASS | Existing PrototypeCatB briefly notices and approaches the basket, displays question/surprise/heart, then returns to Living Café control. Visual storytelling is still rudimentary because character art is placeholder. |
| Espresso steam | PROTOTYPE PASS / VISUAL WARNING | Separate FXLayer node follows `worker_prepares`/`coffee_prepared`. It is very subtle in the full-café capture; tune only after art/layout approval. |
| Food/hanging plant | WARNING | Generated glow/halo around source art; held out of runtime scene. |
| Mobile memory | **WARNING** | 20 runtime PNGs occupy ~24 MiB on disk and ~90.8 MiB as a simple uncompressed RGBA estimate before Godot import/compression/mipmaps. No device profiling was available; review mobile import settings and active texture residency before approval. |

## Playtest steps

1. Run `scenes/dev/home_v2_environment_preview.tscn` at the default portrait size. Keep debug off; compare default view with F6 and inspect counter and character scale.
2. Press G to see cat-life destinations; observe the basket story and question/heart placeholder above PrototypeCatB. Press G again for clean view.
3. In manual mode, tap an arriving customer/order, tap Espresso, watch Mochi at CoffeeAction, then serve. Inspect lower-body counter occlusion and steam. Repeat in Auto mode using the existing F7 toggle.
4. Pan/zoom through existing camera controls and test portrait/tall-phone/tablet aspect profiles. Look for exposed background, unreadable stations, prop collisions and door-frame overlap.
5. Decide whether CounterFront needs an art-registration correction or regeneration. Do not treat the present screenshot or layering assertion as a visual sign-off.

Regenerate review PNGs with:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --fixed-fps 60 --path /Users/teddywoot/willi-cat --script res://scripts/dev/home_v2_capture.gd
```

No production art or gameplay redesign is implied by these review notes.

## Validation snapshot (2026-09-28)

- Asset Forge: 60/60 unit/acceptance tests pass in the repository `.venv`; all 22 selected-source hashes and 20 copied-runtime hashes match their Forge reports.
- Godot: 4.7.2 headless editor scan and V2 scene smoke pass; the `.gdignore` source/artifact folders are not imported. V2 manual and auto True Slice compatibility tests pass with one reward/order, idle worker and stopped steam.
- Existing Foundation, camera/aspect, Vertical Slice, Home productionization, modular visual mock, functional prototype, spatial validation, playtest-ready, Living Café, True Slice and Mochi production animation tests pass. `test_mochi_ingame_scale_v1.gd` remains failing at its hard-coded 1.2× zoom check: the current effective minimum is 1.2195×, so CameraRig correctly clamps below-minimum requests. Camera and that test were not changed by Batch 01.
- `git diff --check` passes. No commit or push was made.
