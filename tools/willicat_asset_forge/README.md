# 🐱 WilliCat Asset Forge

**Local internal production tool** for creating, validating, processing,
previewing and exporting WilliCat game animation assets.

Version: 1.0.0

## Installation

```bash
cd tools/willicat_asset_forge
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Run GUI

```bash
./run.sh
# or manually:
source .venv/bin/activate
streamlit run app.py
```

Opens at http://localhost:8501

## Run CLI

```bash
source .venv/bin/activate

# Inspect a source image
python cli.py inspect docs/source_assets/mochi/walk_side_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_front_walk_walk.png

# Build runtime atlas
python cli.py build \
  --source docs/source_assets/mochi/walk_side_v1/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT_front_walk_walk.png \
  --character mochi \
  --action walk \
  --direction side_right \
  --rows 1 --cols 8 \
  --fps 8 \
  --runtime-size 320

# Export Godot SpriteFrames
python cli.py export-godot \
  --source <path> \
  --character mochi --action walk --direction side_right \
  --rows 1 --cols 8 --fps 8 --runtime-size 320

# List profiles
python cli.py list-profiles
```

## Folder Structure

```
tools/willicat_asset_forge/
├── README.md                    # This file
├── SKILL.md                     # Agent skill instructions
├── requirements.txt             # Python dependencies
├── pyproject.toml               # Project metadata
├── run.sh                       # GUI launcher
├── app.py                       # Streamlit GUI
├── cli.py                       # CLI for agents & humans
├── forge.py                     # Pipeline orchestrator
├── config.py                    # Constants
├── models.py                    # Data models
├── paths.py                     # Project root detection
├── registry.py                  # Profile loading
├── qa.py                        # QA analysis
├── godot_export.py              # Godot .tres generation
├── animation_preview.py         # GIF/APNG preview
├── image_processing.py          # Core image utilities
├── webp_processing.py           # Animated WebP handling
├── sprite_sheet.py              # Grid detection & extraction
├── profiles/
│   ├── characters/
│   │   └── mochi.json           # Mochi character profile
│   └── actions/
│       ├── walk.json
│       ├── prepare_coffee.json
│       ├── carry_coffee.json
│       └── serve.json
├── inbox/                       # Drop zone (git-ignored contents)
├── workspace/                   # Processing workspace (git-ignored)
├── output/                      # Generated assets (git-ignored)
└── tests/
    ├── test_core.py             # Unit tests
    └── test_mochi_walk_acceptance.py  # Acceptance test
```

## Example: Mochi Walk Side Workflow

1. Source: `docs/source_assets/mochi/walk_side_v1/` (5120×640 PNG, 8 frames)
2. Configure: 1 row, 8 columns, 640×640 source frames
3. Process: Extract → QA → Resize to 320×320 → Build atlas
4. Output: `output/mochi_walk_side_right_prototype_v1.png` (2560×320)
5. Godot: `output/mochi_walk_side_right_prototype_v1.tres`

## Source vs Runtime Principle

```
SOURCE (immutable)
→ workspace copy / extracted frames
→ processed frames (resize, padding)
→ derived runtime atlas
→ Godot runtime asset
```

**Never:** SOURCE → destructive overwrite

## How Agents Use SKILL.md

Any coding agent (Codex, Gemini, etc.) reads `SKILL.md` to understand:
- Available CLI commands
- Workflow steps
- Status values
- Source immutability rules
- Conversational UX patterns

## Adding a Character Profile

Create `profiles/characters/<id>.json`:

```json
{
  "id": "mochi",
  "display_name": "Mochi",
  "canonical_reference": "docs/references/mochi/...",
  "target_gameplay_height": 150,
  "default_runtime_frame_size": [320, 320],
  "default_fps": 8,
  "horizontal_mirror_policy": "disabled",
  "identity_notes": ["orange tabby", "cream muzzle", ...],
  "runtime_animation_root": "assets/characters/mochi/animations"
}
```

## Adding an Action Profile

Create `profiles/actions/<id>.json`:

```json
{
  "id": "walk",
  "display_name": "Walk",
  "default_fps": 8,
  "loop": true,
  "requires_direction": true,
  "recommended_frames": 8,
  "runtime_folder": "walk",
  "semantic_action": "walk"
}
```

## Exporting to Godot

Asset Forge generates a Godot 4.x compatible SpriteFrames `.tres` that uses
AtlasTexture sub-resources pointing into the runtime atlas PNG. The generated
format matches the existing production convention used by
`mochi_walk_side_right_prototype_v1.tres`.

To deploy: copy the atlas PNG and `.tres` from `output/` to the appropriate
`assets/characters/<char>/animations/<action>/` directory.

## Known V1 Limitations

- Horizontal atlas layout only (no grid output atlas)
- Square runtime cells only (e.g. 320×320)
- No automatic AI image generation (manual generation required)
- No automatic gameplay registration
- No multi-character batch processing
- Safe padding before resize only (not after)
- Alpha halo detection is lightweight/conservative
- WebP frame duration may not be available on all Pillow builds
- No undo/history in GUI
