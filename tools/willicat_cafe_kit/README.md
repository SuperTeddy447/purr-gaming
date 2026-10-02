# Café modular kit playable review V1

Continuation of the existing café slice, in an isolated DEV project. Open `OpenCafeKitReview.command` or run the existing Forge Python environment with `tools/willicat_cafe_kit/run.py`. The helper composes the prior café/context preparation and uses a separate save namespace.

- **Depth walk**: actual navigation behind/beside/in front of furniture.
- **Make coffee**: original entrance → order → brew → serve → seat → exit; original single reward guard.
- **Closer view / Full slice**: same two camera configurations as the prior review.
- Idle floor clicks move the existing canonical orange protagonist.

Scene: `res://scenes/dev/cafe_interior_kit/cafe_interior_kit_v1.tscn`.

Three immutable source families produce18 reusable sprites. Existing service equipment, furniture, protagonist and entrance are reused. `build.py` composes Forge slicing, padding, alpha cleanup and premultiplied resizing; its recorded wall-plane correction and quiet mirrored floor export do not change world geometry. Rebuild only into a separate staging root, using preserved `generation_specs.json`; this tool never calls image generation.

Evidence: `artifacts/prototype_review/cafe_interior_kit_v1/`. Exact generation, hashes, rights scopes, source/runtime maps and registration are in `assets/dev_review/cafe_interior_kit_v1/*.json`.

This is human playable-review evidence, not canonical production approval. Production rights, final human visual approval, interior category/profile validation and protected publishing remain outside this DEV task. No mobile-device performance claim.
