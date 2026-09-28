# World architecture bootcamp V2 — real Godot viewport evidence

Captured through the connected GodotAI editor/runtime on 2026-09-28. All PNGs are 539 × 959, full game viewport, from isolated development scenes. These are evidence, not runtime assets or a proposed Home redesign.

`.gdignore` keeps this evidence directory out of Godot's runtime import scan.

| File | View / check |
| --- | --- |
| `lab_a_runtime.png` | Lab A running: counter, seating, cat-life props, three actors; all behavior itineraries complete in logs. |
| `lab_b_runtime.png` | Reused scenes/scripts in a physically different layout; all itineraries complete. |
| `depth_counter_behind.png` | Worker foot point behind CounterFront; counter masks lower body. |
| `depth_probe_2.png` | Worker in front of counter; Y-sort reverses without actor z-index change. |
| `depth_probe_3.png` | Worker behind table; table covers appropriate lower body. |
| `depth_probe_4.png` | Worker in front of table; Y-sort reverses. |

For depth inspection, run either lab and press F9 to cycle behind-counter, front-counter, behind-table, and front-table poses. This development-only probe suspends movement and does not change character `z_index`. The lab navigation polygon is intentionally simple and does not yet model furniture clearance; these images establish sorting, not collision/nav clearance.
