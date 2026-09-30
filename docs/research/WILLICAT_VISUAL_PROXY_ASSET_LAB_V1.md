# WilliCat visual proxy world and asset lab V1

Date: 2026-09-30. Scope: only the seven local sources named in the brief. This is a DEV comparison, not an art or license approval for a shipped game.

## Local rights check

| Source | Local evidence | Lab decision |
| --- | --- | --- |
| Cozy Coffee directional add-on | `LICENSE.txt` permits use in games and modification but forbids raw redistribution; `README.txt` says no license terms were supplied and describes some v1.1 generated art. These statements conflict. | DEV only, ignored raw sheets, no redistribution. Clarify provenance before shipping. |
| Top-Down Retro Interior | Six PNGs; no local license or terms found. | DEV only, ignored atlas. |
| FreeAssets | PNGs; no local license or terms found. | DEV-only isolated study, ignored raw files. |
| Tiny Swords (Free Pack) | No license or terms located in the supplied downloaded folder. | Preserve existing ignored DEV extracts only. |
| SuperRetroWorld Farming | `Custom_Commercial_License.txt` allows project use, restricts standalone asset sharing and AI training; some local license lines appear truncated. | Inspection only; do not import or redistribute. Confirm complete terms if later used. |
| Isometric Frog Character | Two sheets; no local license or terms found. | Inspection only. |
| Pixel Crawler Free Pack | `Terms.txt` permits commercial products and edits, forbids resale of the art as a standalone product; credit optional. | Existing regression-safe DEV fallback. |

## Directional furniture measurement

The Cozy source has four families (`chair_wood`, `armchair_terracotta`, `loveseat_cream`, `booth_bench`), each with eight actual authored views: N, NE, E, SE, S, SW, W, NW. Each family has a 1536×768 sheet: four columns, two rows of **384×384** cells. The sheet order is N/NE/E/SE, then S/SW/W/NW. Pixel inspection found every cell's opaque bottom at local Y=380, so `(192,380)` is a usable sheet-space floor pivot. The separate trimmed sprites all have a 2-pixel transparent border but change canvas width and height by direction; they cannot be substituted at one top-left coordinate without re-registration.

| Family | Trimmed canvas range, source px | Cell opaque extent, source px | Result |
| --- | --- | --- | --- |
| Wood chair | 191–241 wide; 306–354 tall | left 73–98, right 285–310; top 30–78; bottom 380 | Four existing café chairs use one sheet-space pivot and one DEV world scale. |
| Terracotta armchair | 251–325 wide; 283–335 tall | left 31–68, right 315–352; top 49–101; bottom 380 | Wider family; do not inherit chair collision just because its pivot matches. |
| Cream loveseat | 203–366 wide; 215–292 tall | left 11–92, right 291–373; top 92–169; bottom 380 | Direction changes width substantially. |
| Booth bench | 183–365 wide; 193–293 tall | left 11–102, right 282–372; top 91–191; bottom 380 | Requires its own seat count and footprint metadata. |

At the measured comparison scale of **0.18 world unit/source pixel**, the wood chair opaque silhouette is about 34–43 units wide and 55–64 units high. This is a local visual choice, not a first-party asset pixel mandate. All four chair directions preserve the existing 1×1 placement-cell gameplay footprint and `SeatSlot`; a visual switch in the test changes no world transform or collision bounds. The seat faces each table: the southwest chair uses NE art, the southeast chair uses NW art. The existing semantic `CafeTableSet2` descriptor is replaced in the lab by a reusable visual-binding scene, while the table and chairs remain direct semantic world children for save deltas. A Retro Interior 24×21-source-pixel round table crop at 3× world scale was the smallest warm-wood candidate that grouped visibly with the chairs. The current bar, equipment, floor, thresholds and entrance retain their proven Pixel Crawler fallback because the inspected alternatives do not supply a complete compatible working café shell and bar.

## Building layer study

`Building_Restaurant.png` and `_Front.png` share a 768×1024 canvas; the opaque bounds are `(41,104)–(744,864)` for base and `(357,655)–(627,864)` for Front. **Front is the patio seating/hedge subset**, not a complete front façade or an interior wall. Of its nontransparent pixels, 97.3% exactly match pixels in the same positions in the base. Cinema repeats the pattern on 1024×1024 canvases: the Front contains sign/queue foreground pieces; 97.78% of its opaque pixels exactly match the base. The small differences are edge/render details, so the common canvas is the registration contract.

The isolated `building_layer_experiment.tscn` draws base, then an animated walking proxy, then registered Front at a higher draw order. The proof frame shows the character's head emerging while the patio foreground hides the lower body. This validates **front-layer occlusion**, not a traversable restaurant interior: the base is a complete opaque exterior and provides no walkable room, doorway collision, or navigation data. FreeAssets' thick outlined isometric projection also differs strongly from the current Home's elevated tilemap, so this building is deliberately absent from the continuous map.

`Building_Appartment_Level1/2/3.png` all use 512×1024 canvases, X bounds 23–490 and bottom Y=866. Their top bounds rise from 398 to 204 to 10 as floors are added. The lower doorway region is about 99% pixel-identical between levels in a measured X=315–445/Y=630–840 window. Thus the files are registered full replacements that retain approximate footprint and door placement, not three independently stackable floor sprites. Their roof height changes and must not drive gameplay footprint or camera automatically.

## Living world and UI

The Home proof continues to use Tiny Swords 64×64 terrain cells, the authored eight-frame animated tree, and the authored 16-frame water-rock loop. Static grass, paving, bank and structure remain quiet. The route frame at Riverside shows the walking actor partly behind the animated tree; the plaza and garden frames show the actor at the same world scale while crossing real thresholds.

Tiny Swords UI is grouped by functions: regular/pressed button pairs (e.g. two 320×320 Big Blue states), separate bar base/fill (320×64 base and 64×64 fill), a 448×448 wood-table panel with separate 192×192 slots, icons, banners, ribbons and four 64×64 cursors. This suggests semantic button-state pairs, independent progress fill, panel slot anchoring and per-interaction cursor feedback. Those are useful rules for DEV menus, decoration, café actions and event panels. Their castle/wood identity does not match WilliCat's production UI, so no global UI replacement or extra panel was introduced.

## SuperRetroWorld production grammar

The supplied folder has 292 PNGs: 207 Props, 82 Characters and 3 Tilesets, plus Godot tile resources and a custom license. Named folders separate `Characters/Farm`, `Characters/Animals`, `Props/Fire`, `Props/Door` and tile atlases. The suffix `01`–`04` on `farm_hoe_01_32x32.png` is a **character/palette variant**, not a direction: each 96×128 file itself contains three action frames across four directional rows of 32×32 cells. `farm_hoe_atlas_32x32.png` is 384×256, packing four three-column variants side-by-side over four used directional rows, with the lower half empty. Walk strips also come in 16×20 and 32×32 variants. `fire_01_16x32.png` is 96×32 (six frame cells); `campfire_16x32.png` is 48×128 (three columns × four visual state rows), so the whole sheet must not be blindly looped as one animation. Naming consistently exposes action, variant and frame cell. Strong production lesson: ship a manifest distinguishing direction rows, timeline columns, variants and states; a filename alone is insufficient. Its dense 16/32-pixel style is unsuitable as the first-party visual look.

## Isometric Frog character grammar

The front sheet is 1750×1050 = 5×3 cells of 350×350; 13 cells contain art and two are blank. The back sheet is 1750×700 = 5×2 cells; nine contain art and one is blank. Front opaque bounds within a cell cluster around X=106–260, with bottom 317–335 depending on pose; back bounds cluster around X=107–259 and bottom 321–323. These variations show why a fixed frame canvas plus explicit baseline is needed. The sheets visibly contain front/back idle, expression and walking-like poses, but there is no supplied clip map, timing, side view or mirroring permission. Do not infer a full four- or eight-direction runtime set. The large outlined cartoon projection and 350-pixel cell are not a useful substitute for the current proxy actor. The current WilliCat Character Runtime V1.1 rule—stable logical floor root, VisualRoot offset, explicit direction/clip mapping, opt-in mirroring—remains appropriate.

## Projection compatibility matrix

| Pack | Projection / camera | Native cell or canvas | Direction evidence | Pixel density / outline | Best role | Current Home fit |
| --- | --- | --- | --- | --- | --- | --- |
| Cozy Coffee | Elevated three-quarter furniture | 384×384 registered cells; chair art 191–241×306–354 | 8 authored views for 4 families | Dense rendered pixels, warm outlines | Directional seating reference | **Limited yes** after one visual scale/pivot; no full shell. |
| Top-Down Retro Interior | Near top-down interiors | 16-ish tiles; tested table crop 24×21 | No complete directional furniture family found | Coarse warm pixels, low outline | Secondary table/prop study | **Limited yes** for a small table; incomplete shell. |
| FreeAssets | Isometric exterior buildings | Restaurant 768×1024; apartment 512×1024 | Fixed building view | Large clean raster, thick dark outline | Registered exterior/front-layer rule | **No** as live Home building; isolated occlusion proof only. |
| Tiny Swords | Elevated top-down outdoor world | 64×64 terrain; tree 192×256 frames | Static prop views; authored loops | Medium-density pixel art, strong contours | Existing outdoor environment | **Yes**, already proven with actor/depth. |
| SuperRetroWorld Farming | Top-down/elevated RPG | 16×20, 32×32 character; 16/32 prop cells | Four direction rows within action strips | Dense small pixel grid | Naming/atlas production grammar | **No** visual fit; inspect only. |
| Isometric Frog | Front/back cartoon character | 350×350 cells | Front and back only | Smooth large raster, thick outline | Baseline and clip-map caution | **No** actor replacement. |
| Pixel Crawler | Top-down pixel café | 16×16 shell tiles; 64×64 actor frames | Down/up/side runtime clips | Coarse pixel, dark outlines | Regression-safe bar/shell/actor | **Yes** fallback. |

The smallest usable visual combination for this proof is Cozy wood chairs + one Retro warm table crop in the café, Tiny Swords outdoors, and proven Pixel Crawler for the remaining shell/service/actor. It is a proxy comparison, not a coherent final WilliCat style lock. The most obvious remaining visual issue is the palette and pixel-density gap between the new seating, the old service bar and the outdoor art; first-party non-pixel art should solve that as one style family.
