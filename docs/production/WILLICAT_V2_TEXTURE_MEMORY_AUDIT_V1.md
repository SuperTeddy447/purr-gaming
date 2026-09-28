# WilliCat V2 texture/memory audit — Batch 02

Scope: the 20 PNGs currently in `assets/environment/home_v2/`. This is an audit, not an import or artwork change. Measurements are from the actual runtime files. “Visible” is the percentage of pixels with alpha > 0; it is not the amount of opaque material. Decoded figures are width × height × 4 bytes, rounded to MiB, so they are planning estimates rather than profiler-measured GPU residency.

All 20 Godot `.png.import` files use the texture importer, `CompressedTexture2D`, `compress/mode=0` (lossless), `compress/high_quality=false`, `mipmaps/generate=false`, `process/size_limit=0`, and `process/fix_alpha_border=true`; none is marked as a VRAM-compressed texture. No per-texture repeat/filter override exists in these imports, and the V2 slot Sprite2D nodes inherit CanvasItem filtering/repeat from their parents/project defaults. Their effective on-device state should be profiled before changing it. Approximately 23 MiB is stored as PNGs on disk and 90.76 MiB is the cumulative RGBA8 decode estimate if all 20 are resident together. Some P1 textures are packaged but not placed in the playable preview, so this total is a conservative package-wide ceiling, not measured peak usage.

| Runtime texture (`*_home_v2_01.png`) | Pixels | Visible % | RGBA8 MiB | Assessment |
| --- | ---: | ---: | ---: | --- |
| architecture | 941×1672 | 100.0 | 6.00 | KEEP: full world canvas; avoid shrinking without overscan/profile review. |
| cake_set | 1066×1026 | 59.1 | 4.17 | DOWNSCALE CANDIDATE: small food prop, P1/unplaced. |
| cat_bed | 1190×948 | 78.9 | 4.30 | DOWNSCALE CANDIDATE: displayed much smaller than source. |
| cat_inspection_basket | 1351×846 | 70.6 | 4.36 | DOWNSCALE CANDIDATE: P1/unplaced in current preview. |
| cat_rest_cushion | 1444×726 | 79.1 | 4.00 | DOWNSCALE CANDIDATE: P1/unplaced. |
| cat_scratch_post | 762×1398 | 52.5 | 4.06 | DOWNSCALE CANDIDATE: P1/unplaced. |
| cat_window_perch | 1370×915 | 53.8 | 4.78 | DOWNSCALE CANDIDATE: P1/unplaced. |
| chair_jade | 864×1050 | 58.3 | 3.46 | REUSE CANDIDATE: existing chair instances already share this file; downscale only after close-zoom check. |
| counter_front_occluder | 1918×687 | 64.7 | 5.03 | KEEP for registration now; DOWNSCALE CANDIDATE later, independently from back. Never atlas across depth layers. |
| counter | 1927×624 | 35.4 | 4.59 | KEEP for registration now; DOWNSCALE CANDIDATE later. Wide transparent canvas is needed for its perspective/slot pivot. |
| espresso | 1122×1234 | 68.8 | 5.28 | DOWNSCALE CANDIDATE: ~110×130 world-pixel slot, but inspect max zoom/detail first. |
| flower_vase | 1200×1151 | 52.0 | 5.27 | DOWNSCALE CANDIDATE: ~44×50 world-pixel slot. |
| grinder | 602×1381 | 65.5 | 3.17 | DOWNSCALE CANDIDATE: ~70×130 world-pixel slot. |
| pastry_case | 1229×1064 | 74.2 | 4.99 | DOWNSCALE CANDIDATE: ~196×150 world-pixel slot. |
| plant_floor | 1003×1426 | 49.0 | 5.46 | REUSE CANDIDATE: repeated placements already share one texture; consider downscale after edge/pan QA. |
| plant_small | 1129×1173 | 53.3 | 5.05 | REUSE CANDIDATE: repeated small plants already share one texture. |
| pos | 1029×1096 | 70.2 | 4.30 | DOWNSCALE CANDIDATE: ~72×70 world-pixel slot. |
| signage_blank | 1189×1233 | 78.2 | 5.59 | DOWNSCALE CANDIDATE: used in multiple differently sized slots; preserve largest/max-zoom readability. |
| stool | 843×1000 | 53.0 | 3.22 | DOWNSCALE CANDIDATE: P1/unplaced. |
| table_round | 1172×823 | 65.3 | 3.68 | REUSE CANDIDATE: repeated tables already share one texture; independent depth remains mandatory. |
| **Total** | | | **90.76** | |

All placed props except the architecture are substantially larger in source pixels than their world-space slots (roughly 3× to >10× linear depending on object). That makes selective runtime-size derivatives the clearest future memory opportunity; no downsampling was performed in this batch. The 16 px top/left/right runtime padding visible on packaged props is small relative to total allocation and protects the art. Floor-contact props intentionally meet their bottom canvas edge; this is a pivot, not a missing source limb. A tiny translucent source fringe can touch an edge, but the source edge audit found no alpha > 0.5 on the outermost source row/column of the 19 prop sources.

No blanket atlas is recommended: CounterBack/Front must stay independently layered, tables/chairs/plants must remain replaceable and depth-sortable, and equipment remains individually interactive. Lossy/VRAM compression is a **COMPRESSION CANDIDATE** only after device visual and memory profiling because matte gradients/brass edges may degrade. No import settings, PNG bytes, or texture dimensions changed here.
