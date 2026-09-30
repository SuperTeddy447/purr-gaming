# WilliCat proxy asset pack audit v1

Inspected 2026-09-29. This is a local development art review, not a determination of ownership or legal rights. No downloaded source was modified. The proxy artwork extracted for the proof is ignored by Git at `assets/dev_proxy/`.

| Pack | Source folder | License found? | Commercial use? | Modification? | Raw redistribution? | Attribution? | Safe to commit raw sprites? | Decision |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Pixel Crawler Free Pack, Anokolisa | `/Users/teddywoot/Downloads/Pixel Crawler - Free Pack` | `Terms.txt` | Yes, functional use in commercial products | Yes | Terms bar sale of the assets as a product; repository redistribution of extracted raw sprites is not expressly granted | Optional, appreciated | No for this proof | Primary local proxy family |
| Top-Down Retro Interior | `/Users/teddywoot/Downloads/Top-Down_Retro_Interior` | No terms, README, or license among supplied files | Unclear | Unclear | Unclear | Unclear | No | Inspected, not used |
| Cozy Coffee Shop Free Directional Furniture Add-On | `/Users/teddywoot/Downloads/cozy_coffee_shop_free_directional_furniture_add_on` | `LICENSE.txt` is labelled a practical draft; `README.txt` says no license terms were supplied | The draft says yes; status unclear | Draft says yes | Draft prohibits standalone redistribution | Unclear | No | Inspected, not used; visual scale and license certainty do not match this proof |
| SuperRetroWorld Farming, Gif | `/Users/teddywoot/Downloads/SuperRetroWorld_Farming` | `Custom_Commercial_License.txt` | Project use allowed by supplied commercial license | Yes | No standalone upload to a repository or asset service | Optional, credit “Gif” appreciated | No | Outdoor reference only |

## Actual assets inspected

- Pixel Crawler `Interior_Props_01.png` is 608 × 384. It contains top-down tables, chairs, counters, cooktops, doors, windows, plants, carpets, and small equipment. `Interior_Walls_01.png` is 656 × 400 and contains modular wall and floor patches. The floor and stone patch used in the proof each have a fully opaque 16 × 16 source cell. The character and props share the pack palette and perspective; this is why Pixel Crawler is the primary family.
- Pixel Crawler `Walk_Down-Sheet.png`, `Walk_Up-Sheet.png`, and `Walk_Side-Sheet.png` are each 384 × 64: six 64 × 64 frames in one row. The idle sheets are each 256 × 64: four 64 × 64 frames. The down/up/side sprites are authored directions. Side artwork faces right; the undecorated neutral body is mirrored for left. No rotation is used. Visible alpha is roughly x 24–40 and y 18–48 in each source cell. The prepared local strips keep all frames on the same 64 × 64 canvas and shift their lowest alpha to source y = 48, avoiding a changing floor contact point. No frame-rate metadata was found; the dev adapter uses 9 fps walk and 4 fps idle.
- The Cozy add-on has 32 individual chair/loveseat/bench sprites and four 1536 × 768 direction sheets with 384 × 384 cells. Directions are N, NE, E, SE, S, SW, W, NW. The individual `chair_wood_n.png` is 233 × 306, with a visually much larger and softer pixel scale than Pixel Crawler. Its README explicitly says those sheets are not a verified native tile grid. It was not resized into this scene.
- The Top-Down Retro Interior floor/wall sheet is 288 × 144 and its furniture sheet is 208 × 288. It has usable home furniture and flooring, but no supplied usage terms. No artwork was imported.
- SuperRetroWorld Farming's large terrain sheet is 1792 × 1280; its autotile sheet is 192 × 960. Visual inspection shows grass, paths, soil/farming patches, cliffs/shore-like edges, plants, water variants, fences, and structures. These may support Front Plaza, Back Garden, or Riverside later. No Garden or River visual was built here.

## Local proxy source mapping

The ignored `assets/dev_proxy/pixel_crawler/` extracts only selected cells and semantic prop crops from Pixel Crawler's interior sheets, plus the character's six idle/walk strips. The entrance crop has its central door panel made transparent so a moving actor can be seen through the passage. The original Downloads pack remains untouched. The animated walkthrough contains rendered game frames, not raw source sprites.
