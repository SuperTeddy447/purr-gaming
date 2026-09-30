# WilliCat Home V3 Room Visual Integration Proof V1.4

Status: **REJECTED — REGENERATION REQUIRED**. This is the only generated V1.4 candidate. It is a development visual proof, not production art or a registered runtime room layer.

![Rejected V1.4 visual candidate](WILLICAT_HOME_V3_ROOM_VISUAL_INTEGRATION_PROOF_V1_4.png)

## Artifact and references

| File | Role | Properties |
|---|---|---|
| `WILLICAT_HOME_V3_ROOM_VISUAL_INTEGRATION_PROOF_V1_4.png` | One generated candidate, retained for review even though rejected | 940×1674 PNG, RGB/fully opaque, portrait ratio ≈9:16 |
| `../home_v3_strong_control_composition_guide_v1/01_clean_structural_9x16.png` | Primary geometry authority, directly captured from locked Godot scene | 539×959; original valid file preserved byte-for-byte |
| `../home_v3_strong_control_composition_guide_v1/02_zone_control_mask_9x16.png` | Zone authority, repaired Godot capture | 539×959; service/seating/bed/scratch/window/open-space zones now visible |
| `../home_v3_strong_control_composition_guide_v1/03_object_footprint_control_9x16.png` | Blocking footprint authority, repaired Godot capture | 539×959; real room object footprints visible; entrance intentionally has none |
| `../home_v3_room_visual_integration_proof_v1_3/proof_v1_3.jpg` | Style only | Known geometry drift must not be copied |
| `../../../docs/references/home/home/WILLICAT_HOME_V3_VISUAL_TARGET_V2_1.png` | Style only | Not a placement map |

The optional `04_generation_control_composite_9x16.png` does not exist. No production scene or asset was modified. The built-in image generation tool produced exactly one candidate; no refinement generation was run.

## Ultra-strict self-check

| Requirement | Result | Observed evidence |
|---|---|---|
| Scratch post on left/lower-left | PASS for side | One scratch post is left/lower-left rather than V1.3's right side. |
| Right window/perch/plant and open circulation | PARTIAL | No large tree or extra right furniture; window/perch arch and ledge are visually much wider than the narrow Godot guide. |
| Compact service, no central island | PARTIAL | No center island or right-window cabinetry link, but service furniture gains larger cabinet mass and shifts vertically relative to `01`. |
| Intentional open floor | PARTIAL | Main path remains open, but large round rugs under both seating islands and several decorative floor pads were inferred from guide shapes; they are not authored objects. |
| Entrance identical to guide | **FAIL** | Door is widened/enlarged and the image invents raised side platforms/steps and a broad threshold/mat. The Godot guide has a smaller simple lower entrance with no such construction. |
| No invented furniture/gameplay objects | PASS for tables/chairs; PARTIAL for props | Exactly two tables and four chairs, one bed, one scratch post and one window perch. Extra small floral/plant decor appears on fixed surfaces/tables. |
| Exactly three cats | PASS | One in bed, one at window perch, one in circulation. |
| Zero readable text | PASS | Signage is blank and no words/numbers are visible. |
| Camera exactly matches Godot guide | **FAIL** | Portrait 9:16 and elevated 3/4 are retained, but service/bed/tables shift upward and the lower entrance changes scale. This is compositional drift, not just detail variation. |
| Gameplay-first visual simplicity | PARTIAL | More restrained than V1.3 on the right, but invented rugs/entrance construction and displaced furniture prevent acceptance. |

Any FAIL means rejection under the V1.4 instruction. Do not call this “minor drift,” and do not use it as geometry or production source. The most visible issues are the entrance construction and the seating/service registration drift.

## Prompt submitted to built-in image generation

```text
Use case: sketch-to-render
Asset type: ONE development-only WilliCat Home V3 room visual integration proof, portrait 9:16 full-frame image.
Primary request: Turn the exact flat Godot Home V3 layout in Image 1 into a cohesive soft illustrated café proof. Preserve Image 1's camera view, crop, room envelope, relative object positions, open floor and entrance; render the existing shapes in-place. This is not a new café design.
Input images and priority:
Image 1 = ABSOLUTE GEOMETRY AUTHORITY: real Godot clean structural screenshot, 539x959. Its floor, walls, service objects, two seating islands, bed, window/perch, small plant, scratch post, entrance and empty circulation must remain where shown.
Image 2 = HARD ZONE MASK from same Godot camera: green service at upper-left/upper-middle, red exactly two staggered seating groups, blue cat-bed zone left, cyan scratch zone LOWER LEFT, yellow window/perch and small plant at upper RIGHT, dark grey protected open circulation. Do not render the mask colors.
Image 3 = EXACT WORLD-OBJECT FOOTPRINTS from same Godot camera. Keep service and furniture bounded by these colored footprints; preserve clear dark spaces and open entrance corridor. Do not render the footprint colors.
Image 4 = V1.3 STYLE ONLY. Borrow its painterly warmth, cream/jade/wood palette and storybook-diorama finish. Its geometry is wrong: DO NOT copy its scratch post on the right, oversized right tree, enlarged service cabinetry/front island, additional furniture, rugs or constructed entrance.
Image 5 = visual target STYLE ONLY, same palette/material identity; DO NOT copy its object positions, extra plants, rugs, signage, entrance steps or room geometry.
Composition: fixed portrait 9:16; elevated 3/4 soft isometric-lite; same zoom and framing as Image 1. Top-left service zone stays compact and does not extend to the right window. Exactly two round table islands in the same staggered positions, with four chairs total, two per table. One CatBed nook at left middle. One scratch post in the LOWER-LEFT zone near cat life, never right. Right zone has only the signature window, its perch, one SMALL supporting plant, and visibly open circulation. A small simple entrance centered in the lower foreground exactly where Image 1 shows it: no raised platforms, steps, porch, enlargement or extra structures. Keep large intentional empty floor around central/entrance paths. Do not add any gameplay objects.
Cats: EXACTLY THREE visible cats: one resting in the left CatBed, one on/near the right WindowPerch, one standing or walking in open circulation. No fourth cat.
Style: 60% painterly storybook illustration, 40% miniature diorama framing; matte soft edges, simplified readable shapes, handmade warmth, warm cream, muted deep jade, warm natural wood, restrained aged brass, soft textiles. No glossy 3D, luxury-hotel detail, ornate architecture, or tiny busy patterns.
Lighting: neutral soft daytime with intrinsic material shading, gentle ambient softness and subtle contact tone only. No dramatic rays, golden-hour grading, lamp pools, bloom, rain, night or event lighting.
Text: ABSOLUTELY NO readable text, letters, numbers, menu, café name, labels, watermark or caption. Signage surfaces remain blank.
Critical negative constraints: no extra table, chair, bench, cabinet, display case, rug, large plant/tree, staircase, service island, oversized counter extension, architecture bay, decorative floor island, raised entrance or clutter. Empty space is gameplay space. Preserve the structural guide's spatial hierarchy over any aesthetic tendency from the style references.
```

## Next review instruction

For any future regeneration, treat the colored seating circles as zone masks rather than rugs and align the entrance/table/service silhouettes to the primary structural guide before styling. The current task ended after this one rejected candidate.
