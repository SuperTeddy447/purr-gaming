# Mochi Prepare Coffee Runtime Atlas V1

Place the whole `MochiPrepareCoffeeRuntime` folder at the root of your Godot 4 project:

`res://MochiPrepareCoffeeRuntime/`

## Atlas
- Frames: 8
- Layout: 8 × 1
- Cell: 388 × 474 px
- Stable feet/root in every cell: (194, 441)
- Safe transparent padding: 32 px
- Max visible character height: 412 px
- Scale for ~150 px gameplay character height: 0.364078
- Preview FPS: 8

## Import QA
Recommended for the atlas:
- Mipmaps: OFF
- Fix Alpha Border: ON
- Repeat: Disabled
- Filter: Linear
- Preserve transparency / RGBA

Open `MOCHI_PREPARE_COFFEE_150PX_PREVIEW.tscn` to preview.
The AnimatedSprite2D node is anchored around the stable feet/root point rather than tail width.
