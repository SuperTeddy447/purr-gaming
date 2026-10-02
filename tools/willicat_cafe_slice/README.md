# Café interior playable review V1

A native portrait Godot **DEV_REVIEW_CANDIDATE**: unchanged Continuous Home gameplay, eleven original modular source images, one new table group, separate counter planes, and quiet coffee polish.

## Open

Double-click `OpenCafeReview.command`, or run:

```sh
/Users/teddywoot/willi-cat/tools/willicat_asset_forge/.venv/bin/python /Users/teddywoot/willi-cat/tools/willicat_cafe_slice/run.py
```

The launcher creates a fresh isolated project under `/private/tmp`, imports its resources, and opens Godot. It does not edit the canonical project, publish production resources, regenerate art, or alter the reviewed Tree Pilot. Its save namespace is separate from normal Home.

- **Make coffee**: the existing entrance → order → brew → serve → chair → exit loop; one reward.
- **Depth walk**: actual navigation through entrance, counter front/back, and table back/side/front.
- **Closer view**: inspect the service/table region. **Full slice** restores entrance framing.
- **Tap the floor**: move the canonical orange character during idle; controls stay disabled during guided actions.

Scene: `res://scenes/dev/cafe_interior_slice/cafe_interior_slice_v1.tscn`.

The scene is also loadable in the main project, but the launcher is the reviewed portrait configuration. It suppresses unresolved old proxy pixels in the temporary copy; it does not delete the original proxy fallback.

## Checks and evidence

The result report and captured moving-character proof are in:

- `docs/production/WILLICAT_CAFE_INTERIOR_PLAYABLE_VISUAL_SLICE_V1_RESULT.md`
- `artifacts/prototype_review/cafe_interior_slice_v1/`

`test_cafe_interior_slice_v1.gd` is the new logic/registration check. `capture_cafe_interior_slice_v1.gd` runs native real-time button-driven navigation and service, captures fixed-pose occlusion comparisons, and records timestamps. It is development evidence, not canonical integration approval.

No interior production profile, production rights clearance, final human visual approval, or protected publishing credential is asserted. Mobile/device validation remains pending.
