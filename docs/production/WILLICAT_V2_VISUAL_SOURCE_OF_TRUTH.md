# WilliCat Visual Universe V2 — Source of Truth

Status: production direction locked; generated game art remains **CANDIDATE / HUMAN REVIEW REQUIRED** until it is approved in the running Home scene.

## Authoritative references

The requested filenames exist one directory deeper than the prompt's suggested paths. These are the actual repository paths; do not silently fall back to V1 artwork.

| Role | Actual repository path | Authority |
| --- | --- | --- |
| Environment production style | `docs/references/home/home/v2/WILLICAT_HOME_ENVIRONMENT_V2_PRODUCTION_STYLE_LOCK_V1.png` | Primary material, palette, rendering and perspective lock |
| Gameplay composition | `docs/references/home/home/v2/WILLICAT_HOME_ENVIRONMENT_V2_GAMEPLAY_TRANSLATION_V1.png` | Placement and open circulation reference; semantic gameplay anchors in the Godot scene remain authoritative |
| Character in world | `docs/references/home/home/v2/WILLICAT_CHARACTER_FAMILY_HERO_SCENE_V1.png` | Warmth and lived-in mood only; its cinematic camera is not a gameplay camera |
| Character family | `docs/references/home/characters/v2/WILLICAT_CHARACTER_FAMILY_LINEUP_V2.png` | Feline-first family anatomy and relative identity |
| Orange protagonist | `docs/references/home/characters/v2/WILLICAT_ORANGE_PROTAGONIST_DIFFERENTIATION_V1.png` | Current orange protagonist design direction; no automatic replacement of existing Mochi runtime art |
| Optional feline detail | `docs/references/home/characters/v2/WILLICAT_CENTRAL_MASCOT_FELINE_REFINEMENT_V1.png` | Additional ear, gaze, paw and tail behavior reference |

All six images above are read-only references. The V2 environment and character references were found in untracked directories at the start of Batch 01; retain their names and locations unless the project owner explicitly reorganizes them.

## World and camera contract

- Preserve the current portrait 9:16, elevated three-quarter, soft-isometric-lite Home camera and `CameraRig`. No free rotation or new gameplay framing.
- Keep the lower-foreground entrance, upper-left/central counter and work zone, pastry case, open central circulation, customer seating and upper-right staircase.
- Godot's current design canvas is 941×1672 world pixels. `data/room_main_cafe_camera.tres` owns the camera position `(470.5, 836)`, design minimum zoom `0.82`, default zoom `1.0`, maximum zoom `1.35`, and current pan bounds. Device-safe effective zoom is computed at runtime.
- Architectural overscan must be verified in rendered 9:16, tall-phone and 3:4 views before changing camera bounds. Generated overscan is not permission to move gameplay markers or widen camera movement silently.

## Visual language and palette

Character-first living café: premium illustrated 2D/2.5D, roughly equal miniature-diorama and handcrafted storybook influence. Surfaces are matte and warm; silhouettes stay readable at mobile scale. Use warm medium wood, cream, muted deep jade, restrained brass, soft natural greens and warm amber light. Avoid photorealism, glossy 3D/PBR, low-poly styling, dark-hotel ambience and micro-detail that disappears at gameplay size.

## Character rule

**Feline first. Mascot second. Costume third.** Neutral characters retain four paws, feline shoulders/haunches, whisker pads, readable ears and tail, and believable sitting, loafing, stretching, sniffing and paw interaction. Brief upright activity is allowed only when an action needs it. At approximately 145–150 px on screen, eye openness, pupil emphasis, ear direction, muzzle and tail posture should still communicate emotion. The existing Mochi artwork and animation presenter are not replaced by this environment batch.

## Modular runtime rule

- The existing 17 stable asset IDs and 26 `slot_role` contracts in `data/home_visual_asset_catalog.tres` remain runtime identity. New `*_home_v2_01` identifiers describe V2 **art packages**, not replacements for those stable IDs.
- Architecture, CounterBack, CounterFront, espresso, grinder, POS, pastry-case shell, pastry contents, tables, chairs, entrance leaves, cat-life props and decor stay independently replaceable. Floor furniture and characters use their existing depth owners and floor-contact pivots.
- Counter work surface renders behind characters; CounterFront renders in `ForegroundOccluderLayer`. Do not use per-state z-index tricks. Carry cup, customer/order state and gameplay routes remain runtime-owned.
- Sign art contains blank surfaces only. Four `DynamicSignage` nodes own readable text at runtime.

## Source and provenance rule

Preserve generated original PNGs unmodified under `docs/source_assets/environment/home_v2/<asset_id>/`, with prompt, generation date, dimensions, input references, status and QA notes. Use `.gdignore` so Godot does not import provenance images. Deploy only validated runtime derivatives to `assets/`; keep previews and rejected trials outside runtime folders. Never mark generated art `FINAL` without human visual approval in Godot.
