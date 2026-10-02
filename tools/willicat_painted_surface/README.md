# Painted surface + lighting spike — isolated DEV review

Open `Open_Painted_Surface.command`, or run `run.py`. This composes the existing Hero Replacement launcher and creates a fresh isolated Godot project under `/private/tmp` with save namespace `WilliCatCafePaintedSurfaceDEVV1`.

Controls: click/tap the floor to walk; **Depth walk** runs the authoritative 2D navigation route; **Make coffee** runs the existing service/reward flow. **2D / Hybrid** switches to the approved 2D diagnostic comparison. Geometry, object transforms, navigation and canonical orange SpriteFrames are inherited unchanged.

The new variant changes material bindings and the settings of the same two lights. It never edits the production project or automatically publishes. Existing/protected destinations, traversal and symlink escape are refused. This launcher is a DEV convenience, not an authenticated/protected production publisher.

## Sources and reproduction

- Raw generated atlas, complete prompt and provenance: `assets_src/materials/willicat_painted_surface_v1/`.
- Material map, palette/strength recipe and decoded texture means: `assets/dev_review/hybrid_cafe_painted_surface_v1/material_manifest.json`.
- Six exact atlas crops; `atlas_rect_px` is `[x,y,width,height]`; `crop_box_ltrb_px` records the equivalent extraction bounds.
- Source pixels are unchanged after generation except exact rectangular extraction/PNG export. Generated edges are not verified seamless; shader mirror-repeat is the explicit workaround.
- Palette/artistic shader values are DEV choices, not calibrated production thresholds.
- Runtime/material/test identity and evidence hashes: `artifacts/prototype_review/hybrid_cafe_painted_surface_v1/diagnostics/toolchain_artifact_receipt.json`.

Godot import caches are disposable and do not establish source identity. Human visual review and any future production rights/publisher approval remain separate.
