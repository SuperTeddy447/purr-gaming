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
12. **Never mark FINAL** — Without explicit human visual approval
13. **Do not use external paid APIs** — V1 is local-only
14. **Do not modify gameplay** — Asset Forge produces assets only

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
  --direction side_right \
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
  --direction side_right \
  --rows 1 \
  --cols 8 \
  --fps 8 \
  --runtime-size 320
```

### List available profiles

```bash
python cli.py list-profiles
```

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
├── cli.py          # Agent-facing CLI
├── app.py          # Human-facing Streamlit GUI
├── forge.py        # Pipeline orchestrator
├── profiles/       # Character and action configs
├── inbox/          # Drop zone for source files
├── workspace/      # Processing workspace (transient)
├── output/         # Generated assets
└── tests/          # Unit and acceptance tests
```

## Conversational Agent UX

If the user says "ช่วยทำ Mochi walk down ตัวใหม่":

1. Check if a source file exists (generated walk-down sprite sheet)
2. If not: "มีไฟล์ที่ generate แล้วหรือยังครับ?"
3. If yes: Locate it, run Asset Forge, prepare preview, report results
4. The agent handles conversation; Asset Forge handles processing
