# WilliCat Home Playtest-Ready Core Loop V1

Status: functional graybox playtest. This pass keeps the Home layout, Foundation layer order, markers, routes, Mochi, and existing Vertical Slice as the gameplay source of truth. No final art or screenshot pack was produced.

## Manual playtest flow

The Home opens in `PROTOTYPE MANUAL` with Debug View OFF and NORMAL timing. The shared Vertical Slice automatically brings one customer in, reacts the door, assigns a seat, and creates `order_coffee_basic_01`. It then waits for the player. The station displays `TAP ESPRESSO`; tap Espresso Station to make Mochi walk to CoffeeAction and prepare coffee. The customer/order indicates `SERVE TARGET` when the cup is ready. Tap the active customer to serve. The order bubble/cup clear, one reward is granted, the customer reacts/leaves, the entrance closes, Mochi returns to WorkerIdle, the seat releases, and the next loop can begin.

Tapping Espresso without an active order is rejected without changing worker/order/reward state. Additional Espresso taps while coffee is being made and repeated customer taps during serving are safe. Tapping an unrelated object while coffee is ready remains inspection-only; the order still needs a valid serve action.

## AUTO LOOP

**F7** switches `PROTOTYPE MANUAL` / `AUTO LOOP`. AUTO uses the same `VerticalSliceController`, `SliceCustomer`, `SliceWorker`, order, movement routes, seat claims, door, reward ledger, and reset states as MANUAL. It automatically advances through prepare/serve for unattended regression and observation. It is not a second gameplay implementation.

## Development controls

- **F1 / D** — toggle Debug View. Hit regions, route/marker helpers, modular labels and the inspector are debug-only; normal view stays clean.
- **F6** — compare against the unchanged locked Visual Master. **R** retains the old reference toggle.
- **F7** — switch MANUAL / AUTO LOOP.
- **F8** — toggle timing preset NORMAL / FAST. The current in-progress timer is not restarted; the next scheduled timing phase uses the selected preset.
- **F2–F5** — Mochi development positions: WorkerIdle, CoffeeAction, ServePoint, open floor.
- **1 / 2 / 3** — Mochi visual scale test: SMALL (~100 px), TARGET (~132 px), LARGE (~150 px), regardless of Debug View.
- **Z / X / C / V** — default, effective minimum, ~1.2×, and maximum camera zoom tests.
- **Mouse/touch tap** selects/interacts; drag pans and pinch zooms. A screen-space movement threshold cancels taps after camera movement.

Debug status includes loop number, current customer/worker states, route target, order, seat, interaction mode, and timing preset. Tapping a modular slot while Debug is ON also reports asset ID, semantic slot role, reference bounds, pivot, layer, Y-sort requirement, replacement status, TEMP/FINAL ART status, default local anchor, and interaction role.

## Central timing resource

All playtest times are in `data/home_prototype_timing.tres` (`PrototypeTimingConfig`). NORMAL values preserve a human-paced prototype; FAST uniformly scales every configured duration by 0.20 with a 0.001 s timer floor. Coffee preparation duration now lives here too, not on the order identity.

| Timing | NORMAL | FAST effective |
|---|---:|---:|
| Customer arrival pause / door opening lead | 0.18 s | 0.036 s |
| Seated pause before order | 0.80 s | 0.16 s |
| Coffee preparation | 2.00 s | 0.40 s |
| Serve action | 0.45 s | 0.09 s |
| Served reaction | 1.30 s | 0.26 s |
| Customer exit pause | 0.18 s | 0.036 s |
| Door hold-open | 0.35 s | 0.07 s |
| Door transition | 0.18 s | 0.036 s |
| Delay before next customer | 3.00 s | 0.60 s |

## Repeated manual play checklist

1. Launch the default Home; verify it starts in MANUAL with Debug OFF and NORMAL timing.
2. Leave input alone until the customer enters, the entrance reacts, a seat is claimed, and the Coffee Order appears.
3. Confirm `TAP ESPRESSO` is visible. Tap Espresso once; optionally tap it rapidly again while Mochi is walking/preparing.
4. Confirm Mochi follows the existing route to CoffeeAction behind the counter; watch the brew feedback and the cup follow Mochi toward the active seat.
5. When the customer shows `SERVE TARGET`, tap that customer. Tap again quickly during serving and verify only one serve/reward occurs.
6. Verify the reward appears once; order bubble and carry cup disappear; customer exits; door closes; seat releases; Mochi returns to WorkerIdle.
7. Repeat steps 2–6 until ten loops are complete. After every loop, confirm the next customer does not overlap the prior customer and no stale order/cup/selection/reward/door/seat/route remains.
8. Repeat at FAST with F8, then restore NORMAL with F8. FAST is for iteration, not the human-feel judgment.
9. Use debug mode only to inspect hit regions/routes/slot contracts; turn it off to judge whether the core actions remain readable without labels.
10. Drag across nearby props and pinch over Espresso/customer targets; neither gesture should activate the object. Check table/counter/entrance occlusion and compare with F6 when useful.

## Human review items — intentionally not redesigned

- The left passage beside the counter is approximately **33 world px**; judge whether the worker route feels believable and visually clear at runtime scale.
- **Seat D** currently lacks a clearly dedicated chair. The Seat D association/route remains in place pending a human visual playtest.
- Foreground floor plants remain fixed in the foreground-occluder layer (not actor Y-sort). Counter front remains a true foreground occluder. Review the current mock and raise a separate visual/layout decision if either reads incorrectly.

## Automated verification

The new `tests/test_home_playtest_ready_core_loop_v1.gd` covers all 17 IDs and 26 role contracts, authored placements/layers/variants, depth-sensitive pivots, separate counter/station ownership, runtime-driven blank signs, F8 preset reporting, and ten consecutive MANUAL plus ten AUTO loops with per-cycle cleanup and exactly-once rewards.

Run the new focused test with:

```sh
'/Applications/Godot.app/Contents/MacOS/Godot' --headless --path '/Users/teddywoot/willi-cat' --script 'res://tests/test_home_playtest_ready_core_loop_v1.gd'
```

The full regression matrix is listed in the task handoff. No final art, environment restyling, or screenshot capture pack belongs to this phase.
