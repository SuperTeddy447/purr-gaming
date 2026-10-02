# Café visual recovery — DEV review only

Open `OpenCafeRecoveryReview.command` on macOS. It composes the existing café tooling into a **fresh isolated project under `/private/tmp`**, imports there, and opens Godot. The repository's Home scene, save namespace and world geometry remain unchanged.

- Click clear floor to walk the existing orange protagonist.
- **Depth walk** follows six real navigation targets around the counter and primary table.
- **Make coffee** runs the existing enter → order → brew → serve → sit → leave loop.
- **Seating view / Full café** changes only this review camera.

This remains `DEV_VISUAL_FRAMING_PROOF`, not a canonical integration proof or production publication. The human has explicitly approved this recovered café as the visual baseline for WilliCat Café Playable Slice V1; the tooling itself cannot confer that approval. See `docs/production/WILLICAT_CAFE_VISUAL_FIDELITY_RECOVERY_V1_HUMAN_REVIEW_DECISION.md`. The 0.62 ground presentation ratio and 1.25 actor visual multiplier are explicit DEV recipe choices. Upright sprites compensate for ground projection; gameplay coordinates, actor physics and interaction markers do not change.

## Reproduce deterministic exports

Use the Asset Forge virtual environment with `PYTHONDONTWRITEBYTECODE=1`. Run `build.py REPOSITORY FRESH_TEMP_OUTPUT_ROOT`. The existing generated family source is copied intact; this command **does not generate images**. It composes Forge strip extraction, floor-contact packaging and premultiplied resize with counter top/front partitioning and material-plane preparation. Floor-contact packaging intentionally has no bottom padding, preserving the exact ground baseline.

`run.py --prepare-only --project /private/tmp/FRESH_NAME` prepares a new proof project. Existing destinations and repository paths are refused. Then import the isolated project with Godot before running:

```text
--headless --path ISOLATED_PROJECT --script res://tests/test_cafe_visual_recovery_v1.gd -- OUTPUT_CHECKS_JSON
--path ISOLATED_PROJECT --script res://tests/capture_cafe_visual_recovery_v1.gd -- OUTPUT_CAPTURE_DIRECTORY
```

The first script checks registration, coordinate integrity, walking and service behavior. The native capture checks actual rendering, records actor positions/timestamps, and captures fixed-pose front/behind composites. Detailed gallery crops and video timing are documented in the evidence directory; screenshot capture overhead is not a mobile frame-rate benchmark.

See `docs/production/WILLICAT_CAFE_VISUAL_FIDELITY_RECOVERY_V1_RESULT.md` and `artifacts/prototype_review/cafe_visual_fidelity_recovery_v1/` for the human review evidence.
