---
name: willicat-asset-forge
description: >
  WilliCat Asset Forge — local tool for processing, validating, previewing
  and exporting WilliCat game animation assets. Supports PNG sprite sheets,
  animated WebP, and individual PNG frames.
---

# WilliCat Asset Forge — Agent Skill

## Purpose

Process raw sprite sheets and animated WebPs into runtime-ready Godot assets
for the WilliCat game project. This tool is deterministic — the agent is the
UX layer; Asset Forge is the processing engine.

## Golden Rules for Coding Agents

1. **Asset Forge is inside WilliCat but ignored by Godot**:
   The entire tooling folder `tools/willicat_asset_forge/` is protected by `.gdignore`. Godot will never scan or import Python scripts, virtual environments (`.venv/`), workspaces, test fixtures, or transient tool files.
2. **Source art is immutable**:
   Source files in `docs/source_assets/` or `inbox/` are NEVER modified or overwritten. All splitting, analysis, and resizing operate on in-memory buffers or transient workspace copies.
3. **Runtime export goes to `assets/`, never `tools/`**:
   Asset Forge outputs into `tools/willicat_asset_forge/output/` by default. When exporting runtime assets for the game, deploy them to `assets/characters/<character>/animations/<action>/`. Never point the Godot project at files inside `tools/`.
4. **Human visual approval is required before FINAL**:
   New assets enter the pipeline as `PROTOTYPE` or `CANDIDATE`. Never mark an asset `FINAL` without explicit visual review and human approval in the Godot preview scene.
5. **Prefer Forge over one-off sprite scripts**:
   Agents must use the Asset Forge CLI (`python cli.py build ...`) for ordinary sprite-sheet processing tasks rather than writing new one-off Python scripts. Forge enforces the locked processing recipe (`MOCHI_SPRITE_RUNTIME_PROCESSING_PROMPT_V1`), performs automated QA, generates manifests, and builds compliant SpriteFrames resources.
6. **Existing special-case scripts remain historical/reference tools**:
   Historical scripts (such as `build_mochi_walk_side_prototype_v1.py` or `build_mochi_directional_walk_runtime_v1.py`) are reference artifacts. Do not create new one-off build scripts unless an edge case truly cannot be handled by Asset Forge.

## When to Use

Activate this skill when the user asks to:
- Create, process, inspect, or export a WilliCat animation asset
- Build a runtime atlas from a sprite sheet
- Generate a Godot SpriteFrames `.tres` resource
- Perform QA analysis on animation frames
- Preview an animation

## Agent Workflow

1. **Identify character** — Read `profiles/characters/<id>.json`
2. **Identify action** — Read `profiles/actions/<id>.json`
3. **Identify direction** — Ask only when action requires direction
4. **Ask only for missing information** — Don't re-ask known values
5. **Locate source file** — Check `docs/source_assets/`, `inbox/`, or user-specified path
6. **Inspect before processing** — Run `python cli.py inspect <path>`
7. **Never overwrite source** — Source files are immutable
8. **Run Asset Forge CLI** — Use `python cli.py build ...`
9. **Report QA warnings** — Show QA summary to user
10. **Build derived runtime asset** — Atlas + individual frames in `output/`
11. **Generate Godot SpriteFrames** — When requested, run `python cli.py export-godot ...`
12. **Deploy to runtime** — Copy verified atlas and `.tres` to `assets/...`
13. **Never mark FINAL** — Without explicit human visual approval
14. **Do not use external paid APIs** — Local-only execution
15. **Do not modify gameplay** — Asset Forge produces presentation assets only

## CLI Reference

### Inspect a source image

```bash
cd tools/willicat_asset_forge
python cli.py inspect <path_to_image>
```

### Build runtime atlas

```bash
python cli.py build \
  --source <path> \
  --character mochi \
  --action walk \
  --direction down \
  --rows 1 \
  --cols 8 \
  --fps 8 \
  --runtime-size 320 \
  --status PROTOTYPE
```

### Export Godot SpriteFrames

```bash
python cli.py export-godot \
  --source <path> \
  --character mochi \
  --action walk \
  --direction down \
  --rows 1 \
  --cols 8 \
  --fps 8 \
  --runtime-size 320
```

### List available profiles

```bash
python cli.py list-profiles
```

### Package an isolated static environment prop (V2 candidate)

```bash
python cli.py build-static \
  --source <immutable_source_png> \
  --asset-id <lowercase_snake_case_id> \
  --output-dir output/home_v2/<asset_id> \
  --pivot FLOOR_CONTACT_BOTTOM_CENTER \
  --status CANDIDATE
```

Use `--pivot FULL_CANVAS_TOP_LEFT --opaque` only for a complete architecture plate. Other supported pivots include `COUNTERTOP_BASE_CENTER`, `COUNTER_FRONT_BOTTOM_CENTER`, `COUNTER_BACK_SURFACE_CENTER`, `WALL_MOUNT_CENTER` and `CENTER`. The command creates `<asset_id>.png` and `<asset_id>.runtime.json`, checks source-edge alpha and immutability, and preserves source art. `PASS` is technical packaging only, not a visual/FINAL approval. Run it on one source per asset; select a regenerated source explicitly rather than overwriting a prior one.

## Source Immutability

- SOURCE files are NEVER modified
- Pipeline: SOURCE → workspace copy → processed frames → derived atlas → Godot asset
- All processing happens on copies in `output/`

## Status Workflow

- `PROTOTYPE` — Initial test, default
- `TEMP` — Accepted for temporary True Slice use
- `CANDIDATE` — Ready for human review
- `FINAL` — Human-approved production asset

## Supported Inputs

- `.png` — Sprite sheets (horizontal, vertical, grid) or single frames
- `.webp` — Animated WebP (auto-detects frame count/duration) or static

## Output

- Runtime atlas PNG (horizontal strip)
- Individual frame PNGs
- Asset manifest JSON
- Godot SpriteFrames `.tres`

## Directory Layout

```
tools/willicat_asset_forge/
├── .gdignore       # Tells Godot to ignore this entire directory
├── .gitignore      # Excludes venv, transient workspaces, caches
├── cli.py          # Agent-facing CLI
├── app.py          # Human-facing Streamlit GUI
├── forge.py        # Pipeline orchestrator
├── profiles/       # Character and action configs
├── inbox/          # Drop zone for source files (transient)
├── workspace/      # Processing workspace (transient)
├── output/         # Generated assets (transient)
└── tests/          # Unit and acceptance tests
```

## Conversational Agent UX

If the user says "ช่วยทำ Mochi walk down ตัวใหม่":

1. Check if a source file exists (generated walk-down sprite sheet)
2. If not: "มีไฟล์ที่ generate แล้วหรือยังครับ?"
3. If yes: Locate it, run Asset Forge, prepare preview, report results
4. The agent handles conversation; Asset Forge handles processing
