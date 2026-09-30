# Mini Pack 001 — first-party generation record

Provider/mode: built-in `image_gen.imagegen` tool, individual raster asset source generation. Isolated props/sheets, terrain textures, FX and UI were generated; no world screenshot or complete traversable room was generated. The source files in `source/` preserve unmodified tool outputs. Normalization is reproducible through `tools/storybook_forge_001.py`.

| Asset source | Prompt intent and source constraints | Reference/iteration |
| --- | --- | --- |
| `grass_source_v1.png` | Quiet repeatable hand-painted grass, soft leafy greens, no unique focal object | Standalone terrain source |
| `path_source_v1.png` | Repeatable pale cream/ochre compacted earth with sparse pebbles and grass flecks, no scene/border/shadow | Standalone terrain source |
| `water_base_source_v1.png` | Calm repeatable blue-green gouache river surface, no fish/gameplay objects | Standalone terrain source |
| `river_bank_source_v1.png` | Isolated four-piece sheet: straight grassy cream-earth/rock bank, useful left/right corners, shore transition, waterline; separated on transparency | Individual river family source |
| `water_ripple_source_v1.png` | Four sequential small centered calm ripples and pale foam traces on transparency, fixed registration, no large wave/glow | 2×2 animation sheet |
| `tree_sheet_v3.png` | Four complete views of one leafy tree in a gentle authored breeze; fixed trunk/root, no rubber scaling or rotation, wide transparent gutters | V1/V2 sheets rejected for clipping; V3 accepted |
| `chair_back_sheet_v3.png`, `chair_front_sheet_v3.png` | Eight individually authored elevated 3/4 chair directions in muted jade upholstery, cream seat, warm wood, brass details, equal perceived size and floor contact | Existing `WILLICAT_ASSET_A07_CAFE_CHAIR_V1.png` used as design reference; V1/V2 sheets rejected for clipping |
| Round table | No new generation. Normalize existing empty first-party `WILLICAT_ASSET_A06_ROUND_CAFE_TABLE_V1.png` | No baked contents |
| `cafe_back_wall_source_v2.png` | One isolated cream/jade café back-wall module with two arched windows and restrained brass lamps; no room/floor/furniture/characters | Separate asset after combined V1 overlapped modules |
| `cafe_front_rail_source_v2.png` | One isolated low jade/wood front rail with two disconnected halves and a fully transparent central walkable aperture | Separate foreground occluder |
| `cafe_floor_source_v1.png` | Repeatable matte warm-wood plank floor material only; no room, scene, props or lighting wash | Shell floor subcomponent |
| `orange_down_source_v1.png`, `orange_up_source_v1.png`, `orange_left_source_v1.png`, `orange_right_source_v1.png` | Canonical orange WilliCat identity reference; per-direction 2×2 sheet of one Idle and three Walk poses, four paws, bent/upright ears, curled tail, fixed floor root, transparent gaps, no action props | Referenced canonical protagonist master. Right/Left prompt labels proved visually reversed and were remapped by visible facing; overlapping Down pose rejected |
| `coffee_fx_source_v1.png` | Four compact cozy cream steam curls with one restrained aged-brass sparkle, stable center, no cup/explosion/glow | 2×2 one-shot effect sheet |
| `button_source_v1.png` | Three identically sized handcrafted pill buttons: cream/jade normal, jade pressed, subdued disabled; no text/icons | UI states strip |
| `contact_shadow_source_v1.png` | Single isolated soft desaturated warm gray-green elliptical ground contact shadow on transparency, no directional sunlight | Reused under first-party tree, furniture and cat |

Rejected source sheets are preserved as `tree_sheet_rejected_v1.png`, `tree_sheet_rejected_v2.png`, `chair_sheet_rejected_v1.png`, `chair_sheet_rejected_v2.png`; `cafe_shell_source_v1.png` is the abandoned overlapping modular sheet. Raw source files do not enter the runtime scene.
