# WilliCat Multi-Room Vertical Proof Plan V1

Status: **smallest technical proof plan**, not an implementation. No production Home scene, art, gameplay controller or save file is changed by this plan. Contract under test: [World/Location/Room V1.1](../architecture/WILLICAT_WORLD_LOCATION_ROOM_ARCHITECTURE_V1_1.md) and [World State/Persistence V1](../architecture/WILLICAT_WORLD_STATE_AND_PERSISTENCE_CONTRACT_V1.md).

## Proof question

Can the same actor, InteractionSlot, object-footprint, camera and atmosphere contracts survive a room transition, furniture edit, save round-trip and cat lifecycle without a Home-specific coordinate or duplicate live object?

One isolated dev proof is sufficient. It should exercise a single `WorldDefinition` with one location containing **Room A** and **Room B**. A portal connects them. The room shapes, nav polygons, object positions and camera bounds must differ materially. Use primitive colors/shapes only. Do not inherit Home V3 or use final environment art.

## Proposed proof content

```text
ProofGameRoot
├── WorldFlowController
├── WorldSession / SaveCoordinator (one temporary proof save slot)
├── TransitionCover (screen-space)
└── RoomHost (one active RoomRoot)
    ├── Room A: entrance, chair with SeatSlot, cat bed with RestSlot,
    │           plant with SniffSlot, required circulation corridor
    └── Room B: different floor/nav shape, chair or plant reused,
                entry/return portal and different CameraDirector profile
```

Room A and B reuse the **same** chair, bed/plant PackedScenes and generic cat movement/slot code already proven in `scenes/dev/world_architecture_hardening_lab.tscn`. New proof controllers may wrap that code for room travel and save snapshots; they may not copy the slot or movement state machine. A simple cat placeholder actor is enough. Use two logical cats only if needed to prove both travel and offscreen residence: Cat A travels A→B; Cat B remains logically in A and advances one coarse schedule step while A is unloaded. There is no need for café rewards, inventory UI, complex customer simulation or production art.

Prospective dev-only paths, to be chosen during implementation: `scenes/dev/world_location_room_proof/room_a.tscn`, `room_b.tscn`, `proof_game.tscn`, and focused `tests/test_world_location_room_vertical_proof_v1.gd`. These paths are not created by this planning task.

## Deterministic scenario

1. Boot Room A from its authored scene. Record its baseline Chair ID/transform and the original SeatSlot/ApproachAnchor transform. Assert exactly one active RoomRoot and one visible actor for Cat A.
2. Enter decoration mode only after active interactions finish. Move/rotate the authored chair to a valid placement using an allowed orientation; assert its SeatSlot/ApproachAnchor, collision, footprint and camera/FX children (where present) follow the single root. A blocked door-path/overlap candidate must be rejected without changing live state.
3. Commit the chair move, rebuild Room A navigation once, wait for map synchronization and prove the seat and exit remain reachable for the largest eligible actor profile. Leave decoration mode and perform a semantic `sit` request without hardcoded coordinates.
4. Start A→B travel through a portal. Resolve destination by `room_id`/`spawn_id`, cancel transient shot/reservations, save Room A delta to WorldSession and release Room A actors/nav/scene. Assert Cat A's one logical record moves to B; Cat B remains assigned A. No actor remains in unloaded A.
5. Activate Room B with different geometry/camera; instantiate Cat A's visual actor from its logical record at the semantic spawn. Assert no duplicate Cat A actor, no source-room camera shot/pan and no stale slot reservation. Use the same behavior code to find B's compatible semantic destination.
6. Advance the proof game clock by a controlled interval while A is unloaded. Assert Cat B's coarse schedule/activity changes **once** in logical state, with no simulated offscreen path/actor. Save to a temporary `user://` proof slot.
7. Destroy the active proof game/session in the test, create a fresh session, decode/migrate/validate the save and enter B. Cat A is still assigned to B; A remains unloaded. This is a real disk round-trip, not copying an in-memory Dictionary.
8. Travel B→A and instantiate Room A from its unchanged authored `.tscn`. Apply the saved chair override exactly once; Cat B materializes from the advanced logical record, Cat A remains logically B with no live actor in A. Confirm the chair was not duplicated and its owned SeatSlot/nav footprint moved to the restored transform.
9. Travel A→B again; reify Cat A with the same `cat_id` and activity/assignment policy. Check that the active-room count never exceeds one after each completed transition and that no stale camera/atmosphere fixture from A remains bound.
10. Inject a failed destination ID/resource load. The source room and controls remain usable, or a pre-transition source snapshot reconstructs them if teardown already occurred. Inventory, cat assignment and any optional reward receipt remain unchanged.

The scenario can run headlessly with explicit assertions. Add a small manual/real-viewport pass for camera and occlusion; headless success alone cannot certify their appearance.

## Pass/fail gates

| Gate | PASS condition | FAIL signal |
|---|---|---|
| Identity | Room IDs resolve through catalog; `(room_id, instance_id)` is unique; same local ID is allowed in another room | Bare ID resolves to wrong room/object |
| Authored baseline | A reload uses original room scene plus exactly one chair override | `.tscn` edited, duplicate chair, moved chair snaps to baseline |
| Object ownership | Chair root move carries Seat/Approach/Exit, footprint and registered visuals | Detached marker/collision or manually patched global coordinate |
| Placement safety | Overlap, doorway and required approach blockage rejected; failed preview/commit leaves room unchanged | Invalid placement accepted or failed placement persists |
| Navigation | One accepted move causes at most one committed nav rebuild; paths to required destinations work after sync | Stale path/agent routing into chair, forced rebake every drag frame |
| Actor code reuse | Same cat/slot behavior runs in both different layouts | Room A/B coordinate conditional in generic actor |
| Room lifetime | Exactly one ACTIVE RoomRoot at a completed transition; no actor/nav/camera leak in unloaded room | Two active rooms, stale physics/camera binding |
| Cat world state | One `CatWorldState` per `cat_id`; travel and offscreen step survive disk save/reload | Lost assignment, duplicate visual actor or full offscreen navigation |
| Customer boundary | If included, ordinary visit drops/reconstructs only by explicit transaction policy | Guest list grows or reward can be paid twice |
| Persistence | Changed chair returns after fresh-process round-trip with same room/object key; unchanged baseline not serialized | In-memory-only success, full-scene dump, NodePath save |
| Migration/error | Prior schema fixture migrates, unknown definition is preserved recoverably, corrupt primary uses backup or reports failure without half-applying | Silent item loss/duplication or partial state mutation |
| Portal/camera | Both directions use semantic spawn; destination camera starts from its own profile; source shot/input lock cleared | Raw map coordinate in actor, old camera carried to B |
| Atmosphere/event | Destination fixtures evaluate from saved profile IDs; event visual/slot/footprint/nav activation remains coherent | Stale fixture or invisible active footprint/slot |
| Home baseline | No diff in locked Home V3 scene, production Home, True Slice controller, or approved art | Any unintended production file edit |

## Mobile and visual measurements

Before production lock, capture a physical low/mid-tier target-device run at 9:16 and tall portrait. Record cold room load and return load time, frame-time p50/p95, peak memory before/after transition, nav rebuild p50/p95/max for committed furniture moves, Input/CameraDirector reset, and texture memory with representative—not final—room art. Use the provisional mobile cutover thresholds from `WILLICAT_PRODUCTION_ARCHITECTURE_LOCK_ADR_V1.md` as comparison points, not as already achieved results. A tiny placeholder test proves lifecycle correctness but cannot prove final-art memory or visual cohesion.

Also capture real Godot viewport images of A default, A chair moved, invalid placement feedback, A→B portal moment, B default, B→A restored chair, and a debug view of object footprints/semantic slots. Confirm depth/occlusion with a character behind and in front of the chair/table in at least one room without per-state z-index changes.

## Minimal implementation order for a future task

1. Definitions/ID resolver and two differently shaped room scenes.
2. Single `RoomHost` and transactional travel/camera cleanup.
3. RoomDelta projection/application with chair placement validation and nav sync.
4. Cat logical record plus active-room actor materialization and coarse clock step.
5. Versioned proof save codec, round-trip, migration and failure fixtures.
6. Headless assertions, live viewport captures, then physical mobile profile.

Stop if the proof requires changing generic InteractionSlot/actor behavior, moving locked Home V3 transforms, rewriting production coffee/reward logic, or introducing a second full world scene merely to keep logical cats alive. Resolve the architecture before expanding scope.
