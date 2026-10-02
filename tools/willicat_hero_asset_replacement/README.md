# Hero asset replacement — isolated DEV review

Open `Open_Hero_Asset_Replacement.command`, or run `run.py`. The launcher composes the existing V2 preparation pipeline into a **fresh project under `/private/tmp`** with a separate save namespace. It refuses existing/protected destinations, traversal and symlink escape. Production publication is not part of this tool.

Controls: click the floor to walk; **Depth Walk** runs the existing route; **Make coffee** runs the original customer/service/reward loop. The canonical orange sprite artwork and original 2D gameplay/navigation remain authoritative.

The `.blend` sources are in `assets_src/3d/cafe_hero_replacement_v1`. `build_hero_assets.py` reuses the existing first-party kit's Blender geometry/axis/UV helpers and existing textures. It rebuilds ten selected editable assets into a caller-provided output directory; it does not author layout or install its output automatically. Use an isolated output directory; rebuilding creates a new review revision.

Conceptual example (substitute an absolute isolated output path):

```sh
/Applications/Blender.app/Contents/MacOS/Blender --background \
  --python tools/willicat_hero_asset_replacement/build_hero_assets.py -- \
  --repo /Users/teddywoot/willi-cat --out /private/tmp/NEW_HERO_BUILD
```

Native evidence and receipts live under `artifacts/prototype_review/hybrid_cafe_hero_replacement_v1`. All assets are DEV candidates for human visual review; this launcher is not the protected Asset Factory production publisher. Godot import caches are disposable, not asset identity evidence.
