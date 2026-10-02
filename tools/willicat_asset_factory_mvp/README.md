# WilliCat Asset Factory MVP — reviewed tree canonical continuation

The original DEV slice below remains historical and independently inspectable. Following the direct human decision, the **same reviewed attempt** advanced through `motion_validated → visual_qa → preview → prefab → runtime_validated`. No approved art/frame/timing data was regenerated or edited. Frozen Phase 0 remains unchanged.

## Canonical continuation boundary

- `canonical.py`: exact pilot-scoped human decision binding, reproduction of accepted measurements, adjacent frozen transitions, compile-once immutable bundle and canonical proof collection. The calibration is exact-observation acceptance for this pilot only; global policy stays `CANDIDATE_REQUIRES_CALIBRATION`.
- `canonical_proof.py` and `CANONICAL_tree_proof.gd`: fresh isolated Home copy, actual compiled visual prefab, same future logical `res://assets/first_party/tree_pilot_v1/` paths, original GameplayRoot/anchors/collision/nav, native viewport captures and moving actor. Unresolved proxy raster pixels are suppressed in the disposable project. Unused legacy sample audio is excluded only from this isolated copy.
- `archive.py`: read-only hash/resource-map verification for archived bundles through the bounded Store; frozen Phase 0 temporary-write restrictions remain unchanged.
- `canonical_cli.py`: read-only inspection of exact source/evidence, frozen journal transitions, bundle parity and fail-closed production status.
- `test_canonical.py` / `test_canonical_runtime.py`: 29 new acceptance cases; original 27 DEV cases remain intact.

`attempt/current_canonical.json` is the canonical continuation pointer. The older `attempt/current.json`, diagnostic catalog/index/status and `human_hold_manifest.json` remain **historical DEV records**, never authority for the current canonical stage. Canonical callers use the canonical pointer and journal only. Source/normalized/template/style/animation containers remain byte-semantically identical in every canonical snapshot. Their old text mentioning pending review is retained as immutable history; current decisions are in appended review records.

The legacy CLI `compile` still blocks; canonical compilation is the separately authorized, pilot-scoped Python boundary. Repeated canonical compilation fails because the write-once bundle already exists. No signing or publishing command has been added. Role review metadata records the explicit direct human conversation; it is **not authenticated final production approval**.

```sh
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=tools tools/willicat_asset_forge/.venv/bin/python \
  -m willicat_asset_factory_mvp.canonical_cli --repo "$PWD" \
  --root "$PWD/artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt"
```

Do not run the historical processing recipe below to replace the reviewed pilot. Its source, normalized atlas, individual frames and timing are already approved and immutable. Further production progression needs current action-scoped rights, final authenticated exact-bundle approval, a protected publisher/context and separate human production authorization. `production_ready` is recomputed by the frozen predicate; this pilot remains false. No production scene, asset or release pointer was written.

---

## Historical DEV diagnostic slice


Local tree-only tooling composed with the existing **Asset Forge** and read-only **frozen Phase 0** contracts. This implementation stops at `structurally_validated` / `human_hold`. It does not implement a provider adapter, canonical candidate compiler, canonical integration proof, human signing boundary, production publisher, release selection, or production catalog pointer.

## Boundaries

- `pipeline.py`: pinned template/style/authority, immutable manual source intake, Forge resize + explicit grid extraction, authored canopy bend, measured motion, previews and **diagnostic_bundle**.
- `store.py`: `/private/tmp` or the exact MVP artifact subtree only; traversal/symlink rejection, descriptor-relative exclusive writes, atomic serialized pointer updates. Same OS user can still alter files through unrelated tools; this is not a production credential boundary.
- `qa.py`: live source/normalized/frame/atlas hash checks and frozen schema; cannot confer human approval.
- `diagnostics.py`: prepare an isolated Home copy, suppress unresolved DEV proxy pixels, verify actual resource/path parity and authority projection, collect rendered evidence.
- `DEV_DIAGNOSTIC_tree.gd`: actual Godot frame playback and existing navigation-marker movement; before/behind render comparisons, root/shadow transforms and frame timing observations. No gameplay-coordinate edits.
- `test_mvp.py`: DEV boundary and lifecycle tests. Frozen Phase 0 tests retain their own authoritative responsibilities.

`compile` and `publish` commands always block. `production_ready` is never stored as a writable boolean. A catalog here is a rebuildable **diagnostic index**, not production approval.

## Reproduce the reviewed pilot

From the repository, use its existing Forge Python environment. Set `PYTHONDONTWRITEBYTECODE=1` and `PYTHONPATH=tools`. Every new processing attempt needs a fresh output directory; previous sources, journal snapshots and evidence are never replaced.

```sh
PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=tools tools/willicat_asset_forge/.venv/bin/python \
  -m willicat_asset_factory_mvp --repo "$PWD" --root /private/tmp/willicat_tree_new_attempt \
  run-diagnostic \
  --source artifacts/asset_factory/mvp_and_tree_pilot_v1/authoring/tree_source_v1.png \
  --template artifacts/asset_factory/mvp_and_tree_pilot_v1/template.json \
  --authority artifacts/asset_factory/mvp_and_tree_pilot_v1/authority_snapshot.json \
  --style docs/asset_factory/style_families/WILLICAT_JAPANESE_RIVERSIDE_STORYBOOK_V1.json \
  --authorization artifacts/asset_factory/mvp_and_tree_pilot_v1/authorization.txt \
  --authoring-receipt artifacts/asset_factory/mvp_and_tree_pilot_v1/authoring/source_receipt.json

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=tools tools/willicat_asset_forge/.venv/bin/python \
  -m willicat_asset_factory_mvp --repo "$PWD" --root /private/tmp/willicat_tree_new_attempt \
  prepare-diagnostic --project /private/tmp/willicat_tree_new_project

mkdir -p /private/tmp/willicat_tree_new_capture
/Applications/Godot.app/Contents/MacOS/Godot --headless \
  --path /private/tmp/willicat_tree_new_project --editor --import
/Applications/Godot.app/Contents/MacOS/Godot \
  --path /private/tmp/willicat_tree_new_project --fixed-fps 60 --resolution 960x640 \
  --script res://DEV_DIAGNOSTIC_tree.gd -- /private/tmp/willicat_tree_new_capture

PYTHONDONTWRITEBYTECODE=1 PYTHONPATH=tools tools/willicat_asset_forge/.venv/bin/python \
  -m willicat_asset_factory_mvp --repo "$PWD" --root /private/tmp/willicat_tree_new_attempt \
  collect-diagnostic --project /private/tmp/willicat_tree_new_project \
  --capture-dir /private/tmp/willicat_tree_new_capture
```

`inspect`, `validate`, and `catalog` use the same `--repo` and `--root`. Normalized source canvases and authored `durations_ms` are explicit; geometry is extracted from existing authority, not selected to fit source art. The source-generation tool remains outside the Factory and the receipt is ordinary operator provenance, not authenticated human approval.

Godot must render a real viewport for screenshot/video evidence; headless mode is used for import and existing tests only. Output PNG frames are temporary capture cache; MP4, GIF, keyframes and observations are retained. Image generation is not called by this CLI. No third-party images were supplied to source generation.

## Review sequence

1. Technical animator reviews measured motion and required subjective criteria. Calibration remains `CANDIDATE_REQUIRES_CALIBRATION`; recorded values do not become thresholds.
2. Art lead reviews the approved style-family fit independently after the frozen motion prerequisites.
3. Only after the frozen gates actually pass may a separate authorized canonical candidate/proof cycle begin. DEV bundle/evidence cannot be relabeled as that cycle.
4. Production rights, authenticated approval, protected publisher and current eligibility remain separate prerequisites. No release or rollback is available here.
