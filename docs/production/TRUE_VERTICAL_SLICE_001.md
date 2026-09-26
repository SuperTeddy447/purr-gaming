# WilliCat — True Vertical Slice 001

Status: functional/presentation contract implemented; final visual and audio assets remain outstanding. This pass polishes one coffee-service flow, not the café feature set. It retains the Home camera/layout, Model C route, 17 stable visual IDs, 26 role contracts, one runtime customer, Manual/Auto modes, Y-sort/occlusion, signage, and Living Café prototype. The currently approved canonical Mochi image remains the static TEMP action visual at approximately 150 px in the default Home framing.

## Exact player flow

1. One customer appears at CustomerSpawn while the existing door opens, crosses CustomerEntry, then the door closes after its configured hold.
2. The customer follows the authored aisle to its assigned valid seat; the one allowed order, `order_coffee_basic_01`, appears as a world-space coffee bubble. In Manual mode the station cue invites a tap; Auto uses the same underlying state transitions without a tap.
3. Mochi's low-priority Living Café route is cancelled on actionable order/work. The existing `SliceWorker` walks to CoffeeAction, prepares coffee for the configured duration, then transitions to carrying a cup.
4. Mochi follows the existing Model C service route through the left counter exit to the seat-specific approach. Manual mode waits for a customer/serve-target tap; Auto begins serving on arrival.
5. At serve completion the order bubble and carried cup disappear, the customer reacts, and the idempotent reward ledger grants the current coin result exactly once.
6. The customer walks out through the entrance, the door closes, the seat and order IDs clear, and only then is Mochi released back to Living Café availability. Existing loop repeat settings may start the next customer later.

No second gameplay state machine was added. `TrueSlicePresentation` observes the existing worker/customer/door/interaction signals and emits semantic action, progress, FX, audio, and optional haptic cues. It never moves an actor, awards currency, changes order state, or chooses seats. `TrueSliceMomentFX` draws a short TEMP ring on order/preparation/pickup/serve moments. The existing order bubble, station prompt/progress, carried cup, customer cue, and reward popup remain the primary readable visuals. The world-space WorkerActionLabel is now Debug-only; the normal status/coin text no longer says “prototype” or exposes Manual/Auto controls.

## Mochi animation/action contract

All presentation names are semantic IDs, never filenames. `MochiVisualPresenter` routes `idle` and `ambient_idle` to `LayeredIdleVisual`; all work/movement actions continue through `ActionAnimatedSprite` and `MochiAnimationSet`. Missing layered art safely uses the exact canonical House Style Lock as TEMP BodyBase; missing action clips use the same stopped static fallback. The hierarchy preserves the foot-contact root and the existing `SliceMover`/`SliceWorker` gameplay boundary. Layered idle art and registration are specified in `MOCHI_LAYERED_IDLE_PRODUCTION_V1.md`; action frame sources remain under `res://assets/characters/mochi/animations/`.

| ID | Loop / timing expectation | Facing, floor pivot, event | Interruptibility | Future asset path |
| --- | --- | --- | --- | --- |
| `idle` | Loop; quiet indefinite hold | Keep last facing; fixed foot pivot; no gameplay event | Work may interrupt | `.../idle/` |
| `ambient_idle` | Loop/short variants; 3–9 s ambient pacing | Last facing or target zone; foot stays fixed; no work event | Immediately interruptible | `.../ambient_idle/` |
| `walk` | Loop, driven by actual mover speed/route | Face movement direction; no root-motion displacement; foot remains on route origin | Work may cancel an ambient walk | `.../walk/` |
| `prepare_coffee` | Loop or held sequence for current ~2.0 s NORMAL brew | Face station; foot at CoffeeAction; `coffee_prepare_started`, progress, completed | Not interrupted by ambient | `.../prepare_coffee/` |
| `carry_coffee` | Loop while following Model C route or waiting for serve tap | Face movement/customer; cup attachment follows actor/depth; `coffee_pickup` | Not interrupted by ambient | `.../carry_coffee/` |
| `serve` | One-shot over current ~0.45 s NORMAL serve | Face customer; no actor teleport; `coffee_served` at successful action completion | No duplicate completion/reward | `.../serve/` |
| `return_idle` | Walk-loop variant until WorkerIdle | Face movement; fixed foot pivot; worker state returns to IDLE | Ambient waits until customer exit | `.../return_idle/` |

These are playback contracts, not a requirement to retime gameplay to missing animation files. Later animation events may replace the current timer boundary only with explicit QA that preserves idempotent service and reset.

## Customer and door presentation contracts

The one TEMP customer archetype exposes `enter`, `walk`, `sit_wait`, `order`, `receive`, `satisfied`, and `leave`. Its `CustomerAnimationSlot` can host a future `AnimatedSprite2D` with those names. `enter`/`leave` face the route, `walk` loops without root motion, `sit_wait` and `order` preserve the seat foot pivot while coffee is pending, `receive` occurs at successful service, and `satisfied` is a short one-shot before `leave`. The current `CharacterPlaceholder`, bubble, ring, and thank-you cue remain TEMP. No dialogue or customer identity system is introduced.

The existing door controller still owns CLOSED → OPENING → OPEN → CLOSING → CLOSED using both modular Y-sorted door leaves. It now emits presentation milestones and explicit `entry`/`exit` threshold-crossing signals. Entry crossing starts the existing hold timer; exit crossing leaves the door open until the customer route finishes, then closing completes before the loop's `customer_exit` presentation event. Door animation and sound replacements can subscribe to `door_open`, `door_open_complete`, `door_close`, and `door_close_complete` without changing threshold logic. Current leaf transforms remain TEMP; no entrance geometry changed.

## Semantic cue map and integration

| Moment | Visual/FX now | Semantic signal for future integration |
| --- | --- | --- |
| Order | Bubble with brief scale pop; station prompt | `order_appear`; audio `order_appear` |
| Preparation | Station progress bar/ring, restrained steam arcs | `coffee_prepare_started`, `coffee_prepare_progress(float)`, `coffee_prepare_completed`; audio `espresso_start`, `espresso_loop`, `espresso_loop_stop` |
| Ready/pickup | Cup attached to Mochi; short ring/carry prompt | `coffee_pickup`; audio/haptic `coffee_ready` |
| Serve | Existing serve cue plus short ring; cup/bubble removed by original state boundary | `serve_started`, `coffee_served`; audio `serve`, haptic `serve_success` |
| Customer/reward | Thank-you cue and one coin popup | `customer_satisfied`, `reward`; matching audio; haptic `reward` |
| Door/interaction | Existing leaf movement and selection ring | Door open/close cues; optional haptic `valid_tap` |

Signals are local and optional. There is no audio playback file, device haptic dependency, global event bus, menu, production VFX framework, or final animation in this pass. The preparation progress signal is quantized to 5% steps for inexpensive future listeners; the existing worker timer remains the gameplay authority.

## Quality gates

| Gate | Status / evidence |
| --- | --- |
| 1 Functional | PASS automated: complete Manual and Auto loops, one reward, no invalid state transition. |
| 2 Readability | PROVISIONAL: Debug OFF has order/station/progress/carry/serve/reward cues and hides developer action label; device-sized human review still required. |
| 3 Spatial | PASS automated authored-route/depth regressions; final art clipping still needs visual review. |
| 4 Presentation | PASS event/action coverage and TEMP transition cues; final visual/audio quality cannot pass before assets and human review. |
| 5 Reset | PASS automated: no stale customer/order/cup/seat/movement; door CLOSED; Mochi available to Living Café after exit. |
| 6 Replaceability | PASS contracts/semantic slots: 17 IDs, 26 role contracts, animation slots and cue signals retained. Final assets are missing. |

See `TRUE_VERTICAL_SLICE_001_ASSET_GAPS.md` for only the assets needed to finish this slice. Do not infer approval for environment restyling, new recipes, extra customers, personality/progression, or production art generation from this document.
