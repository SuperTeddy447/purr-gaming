# Hybrid café feasibility — DEV only

Open `OpenHybridDiorama.command` for the Mobile renderer. Use `run.py --renderer gl_compatibility` for the web-capable fallback. Both create a fresh project under `/private/tmp`; the repository and approved 2D scene are not run through an editor import.

**Depth walk** drives the existing 2D visitor/nav through seven depth checkpoints. Tap/click the floor to pick via Camera3D and send the resulting Vector2 to the existing actor. **2D / Hybrid** toggles the original 2D presentation for inspection; no free camera rotation exists.

This is one small diorama: floor, rear frame/window/shelf, counter, table, two chairs, planter, lamp, existing orange cat. No new bitmap art, 3D cat, independent 3D gameplay/collision/nav, factory integration, save migration or production publication.

The launch receipt verifies all 164 café review-bound files. Runtime-generated meshes and material choices are DEV presentation experiments, not frozen asset templates or a production-approved kit.

Capture: run Godot in the isolated project with `--script res://tests/capture_hybrid_diorama_v1.gd -- /absolute/new/evidence/directory`. Measurements are desktop observations, not phone certification. See the research and result documents for limitations and the recommendation.
