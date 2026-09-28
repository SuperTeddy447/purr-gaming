# GodotAI live workflow report V1

Date: 2026-09-28. Editor: Godot 4.7.2 official, project WilliCat. The GodotAI dock reported a connected local server. The calling Codex tool registry did **not** expose a `godot-ai` namespace, despite a configured client entry. We used the addon-supported local `godot-ai attach --port 8001 --ws-port 8002` bridge through a temporary MCP client outside the repository. This is still live GodotAI MCP, not text-only scene editing. No server credentials are in this repository.

## Phase-0 capability proof

| Requested capability | Exact live proof | Result |
| --- | --- | --- |
| Inspect editor state | `editor_state` returned project WilliCat, Godot `4.7.2-stable (official)`, play/readiness state | PASS |
| Read open scene | `scene_open` opened `res://scenes/dev/mochi_animation_preview.tscn`, then Home read-only | PASS |
| Inspect hierarchy | `scene_get_hierarchy` returned Mochi Actor/CarryAnchor and Home's DepthSortedLayer/GameplayNodes | PASS |
| Inspect Node2D transforms/properties | `node_get_properties` returned Actor position/rotation/scale and Home CoffeeAction `(402,445)` | PASS |
| Select **or inspect** a node | Inspected Actor and ConnectionProbe property sets; visual selection itself not claimed | PASS (inspect) |
| Create temporary node | `scene_manage(create)` made `godotai_connection_test.tscn`; `node_create` made Marker2D `ConnectionProbe` | PASS |
| Modify transform | `node_set_property` moved probe from `(0,0)` to `(64,96)` | PASS |
| Save isolated scene | `scene_save` wrote `res://scenes/dev/godotai_connection_test.tscn` | PASS |
| Run isolated scene | `project_run(mode=current)` returned helper live, no current-run errors | PASS |
| Capture screenshot | `editor_screenshot(source=game)` returned a real PNG frame, 359×640 scaled from 539×959, `stale_frame=false` | PASS |
| Read runtime output | `logs_read(source=game)` returned game-helper registration | PASS |

## Lab A/B live authoring and play proof

- Lab A: `scene_open`, hierarchy and transform reads, then GodotAI `node_set_property` moved CounterStation `(260,220)→(270,220)` and ChairA `(295,595)→(285,595)`; `scene_save`; `project_run(mode=current)`; real game screenshot; `logs_read` showed worker, cat, and customer completion.
- Lab B: inspected hierarchy/transforms, moved TableRound `(420,650)→(410,650)`, CatBed `(85,350)→(95,350)`, Plant `(80,650)→(90,650)` through GodotAI; saved, ran, captured, and read all three completion logs.
- Both lab-only cameras were set to `(1.7,1.7)` zoom through GodotAI for readable evidence. Production Home camera was not touched.
- In Lab A, `game_manage(input_key=F9)` selected four dev-only depth probe placements. `editor_screenshot(source=game)` captured each at 539×959 with `stale_frame=false`. See the [artifact index](../../artifacts/prototype_review/world_architecture_bootcamp_v2/README.md).
- `project_manage(op=stop)` stopped each editor play session after inspection. No production scene was saved through GodotAI.

## What happened outside GodotAI

Official source research used web and read-only source fetches. Existing repository inspection, initial lab scripts/scenes, docs, and test authoring used filesystem tools. A Godot 4.7.2 headless scan and automated tests verified parser/runtime behavior. The final lab object moves, camera tuning, scene saves, runs, screenshots, and logs were performed through the live GodotAI editor bridge.

## Workflow value and limitations

**Value:** live hierarchy/property inspection found the real baseline ownership split; scene mutation and immediate run/screenshot revealed actual draw order, viewport scale, and portability in a way `.tscn` text cannot prove. The attach route worked even though this Codex session did not dynamically load the server namespace.

**Limits:** connection through attach needs a running Godot editor/server and a local bridge process; this is less convenient than a directly registered MCP tool. GodotAI's screenshot tool returned real game framebuffer images but does not itself validate gameplay assertions. The lab's rectangular navmesh deliberately does not subtract furniture footprints; the screenshots prove Y-sort/occlusion but not collision-aware crowd routing or mobile performance. `@tool` placeholder rendering is for editor/lab feedback only.
