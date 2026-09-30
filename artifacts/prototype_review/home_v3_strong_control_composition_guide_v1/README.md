# WILLICAT HOME V3 STRONG CONTROL COMPOSITION GUIDE V1

This artifact contains a deterministic, text-free, high-constraint visual reference that strongly communicates the real Home V3 geometry directly from the Godot engine. 

These images must be used to constrain AI image generation and prevent generative drift away from the locked layout.

## 1. PRIMARY CONTROL IMAGE
- **`01_clean_structural_9x16.png`** 
This is the **PRIMARY** image for structural and visual control. It shows the real Home V3 room with simple placeholder geometry. Image models should use this as the primary reference to reinterpret into finished art.

## 2. SECONDARY CONTROL IMAGES
- **`02_zone_control_mask_9x16.png`**
This acts as a HARD ZONE CONTROL MASK. It makes spatial ownership unambiguous.
- **`03_object_footprint_control_9x16.png`**
This shows the room's currently blocking `PhysicalFootprint` outlines. It does not invent a footprint for objects that intentionally have none.

## 3. ZONE-MASK MEANING (`02_zone_control_mask_9x16.png`)
The solid flat regions represent specific gameplay zones:
- **Dark Grey**: Open Circulation / Protected Event Space
- **Green**: Service Zone (Counter, Espresso, Grinder, POS, Pastry)
- **Red**: Seating Zones (Tables and Chairs)
- **Blue**: Cat Rest Zone (CatBed)
- **Cyan**: Scratch Zone (ScratchPost)
- **Yellow**: Window / Perch Zone (WindowPerch and Plant)
- **Entrance**: The current EntranceDoor has no blocking `PhysicalFootprint`, so no magenta region appears in `02` or `03`. Use `01` for its real visual position and preserve the open lower circulation lane.

## 4. GODOT GEOMETRY IS AUTHORITATIVE
The absolute geometry comes directly from Godot's `home_v3_level_design_pass_01.tscn`. The object positions, footprints, and camera projection in these control guides are 100% correct.

## 5. GENERATIVE RESTRICTIONS
When using these control guides, image-generation models MUST NOT:
- Move or shift zones
- Fill open circulation spaces with decorative filler
- Add or invent architecture
- Invent new counters, islands, or L-shaped service connections
- Invent stairs or display cases
- Reinterpret the room footprint
- Add text or typography

## 6. STYLE AUTHORITY
`WILLICAT_HOME_V3_VISUAL_TARGET_V2_1.png` is **STYLE ONLY**. It must never be used as a layout or spatial authority.

## Meta
- **Dimensions**: 539 x 959
- **Camera Source**: Fixed Home V3 gameplay camera (portrait 9:16, elevated 3/4 isometric-lite)
- **Validation**: Generated directly from Godot nodes; camera transform, object transforms, and layout fully verified against production `home_v3_level_design_pass_01.tscn`.
- **Text Contamination**: None.
- **Capture repair**: The original `02` and `03` exports were blank because the dev capture script did not recognize `HardeningFootprint` and transformed its already-global outline twice. They were regenerated from the same locked scene; the valid `01` image was preserved byte-for-byte. Optional `04_generation_control_composite_9x16.png` is not present in this pack.
