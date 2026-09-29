# ADR V1 — Godot-authored world is gameplay truth

Decision date: 2026-09-28. Status: **PRODUCTION ARCHITECTURE LOCKED; HOME PRODUCTION CUTOVER NOT YET AUTHORIZED**. Scope: structural world-authoring rules, not art/layout approval. `ff6b8c6` was inspected (author SuperTeddy447, parent `965b4df...`, 605 changed files). It added the GodotAI integration, dev architecture labs and Home V2 visual tooling; it did not change `scenes/home/home_scene.tscn` or the True Slice state machine, and current architecture tests pass. Existing uncommitted hardening refinements are preserved. No history was rewritten.

## Decision

Godot Room/Zone scenes, their reusable PackedScene objects, and semantic gameplay data own the spatial truth. AI concept images are visual-direction references, never coordinate/layout authorities. A monolithic concept render cannot specify reliable walkable footprints, actor approach points, occlusion boundaries or future movable furniture. Environment art must later be authored to fit the approved playable greybox, then processed by Asset Forge; it must not be reverse-engineered into gameplay geometry.

Every meaningful world object owns its interaction slots, floor footprint, collision where needed, camera focus markers and semantic FX anchors. A generic actor asks the room/object for `sit`, `work_coffee`, `sniff`, `rest`, `inspect`, etc.; it never embeds Home-specific `Vector2` destinations. This is mandatory because the same behavior must survive object movement, alternate rooms and event variants. Animation presents semantic gameplay state but cannot award rewards, complete orders or own slot occupancy. CameraDirector and FX follow object/character-owned markers; relocating the parent moves these targets with it. These same rules are the minimum foundation for future decoration placement and persistence.

## Formal invariant check

| Invariant | Evidence |
| --- | --- |
| 1–2 Object-owned slots and full reserve/approach/action/exit/cleanup | Hardening object scenes, `HardeningInteractionSlot`, unreachable/cancel/deletion tests |
| 3 No Home-specific destinations in actor behavior | `hardening_actor.gd` accepts semantic action/object ID; authored coordinates remain in `.tscn` |
| 4–5 Espresso and CounterShell ownership separated | Espresso `CoffeeActionSlot`, CounterShell `OrderPoint`/`ServePoint`; move assertion |
| 6–7 Footprint/nav and move/rotate ownership | Table path bends around footprint; rotated Chair and moved Bed/Plant/Espresso retain slots and anchors |
| 8 Animation only presents state | Actor/action signals and slot state own completion; no image/animation callback grants gameplay rewards |
| 9 CameraDirector separate | `camera_director.gd` has no actor path logic; exact restore, priority, cancel, scene-exit tests |
| 10 Event variants share actor/slot architecture | Base toggle and inherited event-room test use same `HardeningActor` script |
| 11 Authored positions vs save | `.tscn` instance transforms; stable-ID placement snapshot only, no runtime save migration |
| 12 No concept-coordinate reconstruction | Dev scenes use authored primitive geometry; no concept image is loaded for layout |

Structural proof is in `tests/test_world_architecture_hardening_v1.gd` and the 18 real-viewport images under `artifacts/prototype_review/world_architecture_hardening_v1/`. This is sufficient to lock the **contract**, not to cut over Home or approve art. The new orange protagonist Visual Master and family scale sheet are identity/relative-scale references only; no character art or animation is generated here.

## Explicit mobile cutover gate (unmeasured)

Profile a canonical 9:16 and tall-phone build on the minimum supported *physical* device during Home V3 greybox. Record device/OS/build, 60-second warm-run median and p95 frame time/FPS, 1% low, peak RSS/texture memory, nav rebake p50/p95/max after discrete Chair/Bed/Plant/Espresso moves, active NavigationAgent count, semantic slot lookup p95, event-off/on memory delta, and dropped frames during Brew/Cup shots. Provisional acceptance targets to validate with product engineering: 60 FPS desired; p95 frame time ≤33.3 ms floor; no repeated placement spike >33.3 ms; slot lookup p95 <0.5 ms with the authored room; six active agents baseline and a 10-agent stress case. Memory target must be set against the chosen minimum device after actual imported art exists. These are **targets, not measurements**. Desktop lab results cannot close this gate.

Until that profile, True Slice parity, GodotAI visual review and human approval pass, do not modify or replace production Home. See [Home Migration Plan V2](WILLICAT_HOME_MIGRATION_PLAN_V2.md).
