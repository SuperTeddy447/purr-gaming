# Tiny Swords asset system study V1

Scope: the locally downloaded `Tiny Swords (Free Pack)` in `/Users/teddywoot/Downloads/`, inspected for the DEV Home continuous-world proof. This is a study of packaging and runtime conventions, not a proposal to use its visual identity in the finished game.

## Source and terms

The extracted folder and the matching ZIP contain 410 PNG files and 18 `.aseprite` files. A targeted search of the pack found no README, license, attribution text, or redistribution terms. Rights therefore remain unverified from the supplied files. The proof copies only selected files into ignored `assets/dev_proxy/tiny_swords/`; no original Downloads files were changed, and none of these raw extracts should be committed until terms are established. Pixel Crawler remains the separate indoor DEV source under `assets/dev_proxy/pixel_crawler/`.

## Actual organization

| Source folder | Observed system |
|---|---|
| `Terrain/Tileset` | Five color variants of 576×384 terrain atlases; 64×64 water background; 3072×192 foam strip and `.aseprite`; 192×192 separate shadow. |
| `Terrain/Resources/Wood/Trees` | Four eight-frame PNG tree strips, four stump images, and `Trees.aseprite`. |
| `Terrain/Decorations` | Bush strips, rocks, water-rock animation strips and sources, clouds, rubber duck. |
| `Terrain/Resources` | Wood, gold, meat, tools and sheep sources/exports. |
| `Buildings` | Named building families in blue, red, black, yellow and purple variants. |
| `Units` | Faction-colored units and selected Aseprite sources; action/direction encoded in filenames. |
| `Particle FX` | Dust, splash, fire, explosions and an Aseprite source. |
| `UI Elements` | UI assets, not used in the world proof. |

The terrain atlas measures 576×384, exactly 9×6 cells at 64×64. Its first four columns contain a large grass patch with transparent perimeter cells and opaque interior cells; columns five through eight contain another surface/cliff family. This is an edge-aware atlas, not a single seamless ground screenshot. The proof uses source cell `(1,1)` for repeated grass, the analogous ochre cell for paths, source cell `(5,4)` at the bank, and the supplied 64×64 water tile. The outdoor `TileMapLayer` cells are 64 world units. The logical placement grid stays 32 world units: art tile size and placement cell size are intentionally different.

## Tree animation, measured from local source

`Tree1.png` is 1536×256: eight horizontal frames of 192×256. `Tree2.png` has the same layout. `Tree3.png` and `Tree4.png` are 1536×192: eight 192×192 frames. The `Trees.aseprite` header reports a 192×256 canvas, 36 timeline frames, RGBA depth, and 100 ms for every frame. The PNG strips used in this proof contain eight authored frames each; the source timeline's layer/export mapping was not assumed. Runtime plays the exported eight-frame loop at 10 fps, with no procedural sway.

Tree1 per-frame nontransparent bounds are approximately x=37–158, y=51–241 within the 192×256 canvas. The horizontal drift is only a few pixels. Tree2 spans approximately x=43–151, y=5–249. Frame canvas size stays constant while alpha changes; that makes a stable pivot possible. In the DEV prefab, the root is the ground contact point. The animated sprite is centered at y=-112 for Tree1 or -120 for Tree2, placing the last opaque trunk pixels close to root y=0. A 28×26 `TrunkFootprint` centered 18 units above the root provides collision and navigation obstruction. The canopy does not block walking. The separate authored `Shadow.png` sits at ground contact, visually below the tree. The prefab belongs to the existing Y-sorted world-object layer, so a walking character changes depth naturally on either side of its ground baseline.

`Bushe1.png` is an eight-frame 128×128 strip (1024×128); this proof uses one static frame for restrained vegetation. `Water Rocks_01.png` is a 16-frame 64×64 strip; the proof plays it at the source family's observed 100 ms rhythm. `Water Foam.aseprite` has 16 frames at 100 ms on a 192×192 canvas, matching its 3072×192 strip; it remains unplaced until an edge composition is designed around its actual transparent frame geometry. The scene does not animate every prop.

## Structure, pivot and shadow lessons

Blue `House1.png`, `House2.png`, and `House3.png` each use a 128×192 canvas but different alpha bounds: `(8,16)–(120,173)`, `(0,23)–(128,178)`, and `(3,37)–(125,172)`. Blue Castle is 320×256. Thus a common canvas family does not imply a common visual footprint. Building floor contacts and entrance anchors would need authored metadata; image bounds alone are insufficient. The proof deliberately avoids placing a Tiny Swords medieval building on the Pixel Crawler café.

The pack separates shadows (`Terrain/Tileset/Shadow.png`) from trees and uses stable transparent frame canvases. Filename families communicate color variant, character action and direction. The useful production pattern is to preserve explicit animation timing, frame canvas, floor baseline, shadow, collision footprint, terrain edge role and semantic ID as distinct data.

## Reuse and limits

Reusable for WilliCat: organized terrain atlases, stable-frame ambient loops, a separate shadow layer, small trunk-based collision, ground-contact Y sorting, semantic prefabs, and source animation metadata. Do not copy the medieval factions, military building silhouettes, colors, names, unit proportions, or Tiny Swords branding into final WilliCat art. The present outdoor color contrast and bank edge are temporary composition tests. Any production art should be purpose-made and licensed for its own distribution.

Implementation evidence: `scenes/dev/home_continuous_proxy/home_continuous_world_v1.tscn`, `scenes/dev/home_continuous_proxy/animated_tree_prop.tscn`, and the rendered proof under `artifacts/prototype_review/home_continuous_world_tiny_swords_proof_v1/`.
