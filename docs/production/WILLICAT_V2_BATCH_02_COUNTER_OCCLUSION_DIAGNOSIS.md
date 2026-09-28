# V2 Batch 02 — Counter occlusion diagnosis

Status: measured against the Batch 01 runtime PNGs and playable `home_v2_environment_preview.tscn` before correction, then verified with rendered Batch 02 captures. The original Home scene, its CoffeeAction marker, and the counter textures remain unchanged.

## Layer and registration measurements (world pixels)

| Element | Existing value | Derived visible/texture extent |
| --- | --- | --- |
| CounterBack slot | `(465,520)`, BackDecorLayer `z=20`, centered pivot, target `540×200` | 1927×624 texture at scale `0.280228`; canvas x=195..735, y=432.57..607.43 |
| Worker | DepthSortedLayer, Y-sort, `z=50`; full-body Mochi around 150 px high | Root/feet and ContactShadow at WorkerIdle `(620,445)` or CoffeeAction `(402,445)` |
| CounterFront slot | `(465,625)`, ForegroundOccluderLayer `z=80`, bottom-center pivot, target `560×225` | 1918×687 texture at scale `0.291971`; canvas x=185..745, y=424.42..625 |
| CounterFront opaque edge | Sampled runtime alpha >200 along vertical line | At CoffeeAction x=402, first opaque pixel around y=462; at WorkerIdle x=620, around y=481 |
| Exit rear waypoint | `(165,445)` | Same elevated corridor height as the two worker anchors |

The back/front widths differ by 20 world pixels (10 per edge) and canvas top by ~8.15 pixels. Their curves, front corners and top lips are visually close enough to represent one physical counter. Neither source has a large transparent runtime margin after Forge packaging. Alpha at x=402 is zero from y=420 through y=460 and opaque from ~470 downward; the absence of occlusion at y=445 is expected from the *content silhouette*, not a z-order bug. CounterFront is already above the full-body worker, and the contact shadow is correctly attached to the worker root.

## Root cause and minimal correction

The root/feet markers at y=445 sit **above the counter's opaque front and effectively on its top plane**. This is physically wrong for a floor-standing worker behind the counter. The generated CounterBack and CounterFront modules are sufficiently registered; cropping or shifting the front texture upward would open a gap at its floor contact and misalign the two lips. An arbitrary character z-index or cropped worker would hide the defect without restoring floor contact.

The V2-only inherited scene now places WorkerIdle at `(620,525)`, CoffeeAction at `(402,525)`, and the rear exit waypoint at `(165,525)`. The x coordinates, CounterBack/Front slot transforms, all textures, canvas scale, original Home markers and production CameraRig are unchanged. At CoffeeAction, approximately 63 world px of the worker's lower body lie below the front silhouette edge; at WorkerIdle about 44 px. The existing front sprite covers the contact shadow. The focused test samples the front texture alpha at both worker roots and verifies the original z-layer order. Real-viewport captures `01`–`07` show the full transition: the worker is full-body on leaving the left counter edge and becomes naturally occluded again on return. Manual and Auto V2 True Slice loops pass with the corrected corridor.

No CounterFront source pixels should be repainted or regenerated unless the rendered transition falsifies this geometric diagnosis.
