# WilliCat Home V3 art handoff — Pass 01 layout revision

Status: **HISTORICAL PASS 01 REVISION / SUPERSEDED BY ART HANDOFF LOCK V1**; still not final-art approval. This records the accepted layout rationale. Use [`WILLICAT_HOME_V3_ART_HANDOFF_SPEC_LOCK_V1.md`](WILLICAT_HOME_V3_ART_HANDOFF_SPEC_LOCK_V1.md) for new asset work. All object-local visual envelopes, floor roots, footprints, owned slots, occlusion split requirements, FX anchors and stable IDs remain governed by the locked Godot scene. The Godot-authored `scenes/dev/home_v3_level_design_pass_01.tscn` is the placement source of truth; do not reconstruct positions from these notes or from a concept image. Production Home remains untouched.

## Composition changes for future registered art

| Area | Pass 01 placement intent | Replacement-art implication |
| --- | --- | --- |
| Back-left service | CounterShell with POS/Pastry nearby | Preserve independent object assets. Counter front lip still needs a separate occluder; do not bake POS/Pastry into counter art. |
| Back-right preparation | Espresso and Grinder next to, but not inside, CounterShell | Keep machine-local Brew/Cup/Steam and root registration. The Pass 01 dev camera uses Brew 3.25 and Cup 3.45 zoom; these are **review settings**, not final camera approval. |
| Seating | Two staggered round-table islands and four chair-owned seat positions | Make 3/4 silhouettes readable without merging chairs into table textures. Preserve Y-sort/floor pivots and actual navigation footprints. |
| Rest nook | CatBed sheltered between service and first table | Registered bed front rim should allow a resting cat to read inside; no cat baked into bed. Avoid art protrusion that visually closes the left approach. |
| Window moment | WindowPerch and Plant on the right-side window edge | Window/frame/light are architecture placeholders only. Perch remains an independent interactable object; do not bake a cat or wall into it. Maintain view of cat at `WatchSlot`. |
| Entry/transition | ScratchPost at left transition; three invisible WaitingSpots near the entrance | Waiting spots are semantic-only. Do not invent visible queue rings for production. Door remains a separate replaceable threshold/leaf. |
| Event niche | SeasonalDisplay to the right of central entry circulation | Keep its local slot, FX and CameraFocus. Event variants swap content on that object, not a whole-room painting. |

The new floor regions are **temporary spatial cues**, not palette/style direction. Actual illustrated architecture should maintain a continuous café room with believable perimeter corners and clear circulation; it must not recreate the old full-width colored test bands. This document does not authorize final art generation. Re-check every authored transform and camera frame in Godot after layout approval and before asset export. Character placeholder circles and their on-screen heights are not final scale references.
