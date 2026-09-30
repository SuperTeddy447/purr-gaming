# WilliCat Animated Storybook World — style proof V1

Status: **first-party working direction ready for human visual review; not final production art**. Style family: `willicat_home_storybook_v1`.

## Visual language proved

The accepted source family uses warm cream, deep muted jade, natural amber wood, soft leafy green, blue-green river water, restrained aged brass and neutral contact shadows. It is matte illustrated art with simplified silhouettes and light gouache texture. The camera remains the existing elevated three-quarter Home view. No complete room painting is used as a traversable world layer.

The orange protagonist follows the canonical identity in `docs/references/characters/WILLICAT_ORANGE_PROTAGONIST_FINAL_MASTER_V1-TRANSPARENT.png`: orange tabby markings, cream muzzle/chest, one bent ear, one upright ear and a curled fluffy tail. The generated left/right source sheet labels were reversed by the image model; normalization maps visible facing rather than prompt labels. No raster flip is used.

The first-party art occupies the same semantic space as the proxy proof. The new café back wall is behind gameplay objects; the two detached front rails are in the Y-sorted object layer, leaving the original front doorway open. The riverbank uses two alternating vertical crops from one authored bank source. Water is a static base plus a four-frame ripple. Trees use four authored breeze poses with fixed trunk contact, a separate neutral shadow and the original 28×26 collision footprint.

## Live visual comparison

See [`proxy_vs_first_party_ab_overview.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/proxy_vs_first_party_ab_overview.png), the [moving route GIF](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/first_party_style_proof_001.gif), and the [front/behind tree pair](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/02_animated_tree.png) / [`02b_character_behind_tree.png`](../../artifacts/prototype_review/first_party_storybook_mini_pack_001/02b_character_behind_tree.png). The GIF is an accelerated selection of real Godot viewport frames; the short coffee segment uses six consecutive live FX frames.

| Criterion | Proxy world | First-party mini pack | Reading |
| --- | --- | --- | --- |
| Readability | Distinct hard-edged pixel silhouettes | Rounded illustrated tree, chair, table and orange cat remain distinct at 540×960 | Improved visual fit, with mixed proxy service props still visible |
| World scale | Established coordinates and footprints | 39 position/footprint/anchor entries identical in automated parity test | No art-driven repositioning |
| Style coherence | Consistent retro pixel world | Coherent new terrain, river, shell, furniture and protagonist; remaining service props/bushes are proxies | Stronger WilliCat direction; mixed detail still obvious |
| Animation | Proxy tree/water/actor loops | Authored tree, ripple, four-direction cat Idle/Walk and event-triggered coffee steam | All visible in running route; compact loops are a proof limitation |
| Depth | Working Y-sort | Cat appears in front of tree, then partly hidden by trunk/canopy; café rails remain correctly layered as the cat uses the open entrance | Preserved with first-party visuals |
| Mobile clarity | Recognizable at portrait view | Cat enlarged to 0.34 visual scale; chair/table and tree readable | Service props and small HUD text need later polish |
| Emotional fit | Temporary game-proxy look | Warm illustrated materials, canonical orange cat and soft river/tree motion | Meaningfully closer to WilliCat |
| Production consistency | Technical proxy family | Explicit specs, source records, 20 normalized PNGs, reusable prefab targets and validation report | Ready for a controlled next batch |

## Art and production constraints

- All generated material was produced as individual asset sources with the built-in image generation tool, then normalized by `tools/storybook_forge_001.py`. The round table uses the existing first-party candidate in `assets/environment/home_v3/production_batch_a_v1/`. The final test scene references normalized exports only.
- Four-frame tree/water/coffee loops are intentional compact authored proof loops. Character Idle has one source pose per direction; Walk has two Down poses and three in the other views. The rejected Down fourth pose overlapped its source cell boundary.
- The hand-painted grass, path and wood tiles pass the adjacency preview, but their square surface boundaries remain visible in some locations. Riverbank variants are straight only in the current Home composition; corner source pieces are normalized for later use.
- The service bar, machines, loose bushes/rocks, doorway object and non-test HUD controls remain proxy art. This limits the perceived coherence of the current screenshot and is the next bounded production task if this direction is approved.
- Source art rights and export clearance for the already-existing round-table candidate should be confirmed during production handoff. This proof does not make a rights determination.

## Human review decision

Use this proof to decide whether `willicat_home_storybook_v1` should become the production direction. Review the moving character, café front-layer crossing, tree occlusion, bank continuity and coffee event at portrait size before approving a larger art batch. Keep the existing proxy scene available as the rollback comparison.
