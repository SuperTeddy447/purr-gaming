# WilliCat Home — Living Café Behavior Prototype V1

This is a disposable ambient-behavior playtest layered onto the existing Home and Vertical Slice. The Vertical Slice remains the only authority for orders, work, seats, rewards, doors, and customer movement. No final personality, character art, or animation system is introduced.

## Runtime cats and states

`LivingCafeAmbientController` manages Mochi plus two runtime-only `CharacterPlaceholder` cats under the existing `DepthSortedLayer`. Each has one low-priority activity: `IDLE`, `ROAM`, `LOOK_AROUND`, `WINDOW_WATCH`, `PLANT_INSPECT`, `SIT_REST`, `COUNTER_IDLE`, or a short `SOCIAL_PAUSE`. Mochi additionally uses `WORK_PRIORITY` while the real `SliceWorker` owns movement. The controller uses the existing `SliceMover`; it does not create a second work state machine. Placeholder body bobbing is the only ambient visual motion beyond walking/facing.

`PrototypeCatA` is CALM: a 35% movement choice and more rest. `PrototypeCatB` is CURIOUS: a 72% movement choice and more exploration. Mochi is WORKER_CALM and stays behind the counter. Actions last within the configurable ranges, so cats spend significant time still rather than roaming constantly.

## Semantic zones and routes

| Zone | Source | Access | Meaning |
| --- | --- | --- | --- |
| WORKER_IDLE | Existing `worker_idle_01` marker | Mochi only | Rest behind counter |
| COUNTER_IDLE | Runtime offset +80 px from WorkerIdle | Mochi only | Quiet counter-side routine |
| OPEN_FLOOR | Existing `ambient_main_a` marker | Dummy cats | Open floor pause |
| WINDOW_LOOK | Existing `ambient_main_b` marker | Dummy cats | Look toward window |
| PLANT_INSPECT | Existing `ambient_main_c` marker | Dummy cats | Inspect plant-side area |

The extra cats travel only between the three ambient floor markers. OPEN_FLOOR ↔ PLANT_INSPECT routes via WINDOW_LOOK, keeping them in the right-side corridor rather than crossing table bodies. They cannot reserve CoffeeAction, ServePoint, seats, worker-only zones, entrance threshold, or customer route waypoints. Mochi moves only along the already-safe rear counter line while ambient. All actors use foot pivots in `DepthSortedLayer`; no behavior changes z-index. The debug annotation controller itself is drawn above the world and does not affect depth sorting.

Reservations are keyed by semantic zone. A cat releases its prior zone and reserves its destination before walking. Unavailable zones are excluded from selection. An interrupted Mochi releases any reservation and clears its ambient route target. Once `SliceWorker` returns to IDLE with no active order, Mochi reserves WORKER_IDLE and may resume ambient after a pause. When an order is created, or any non-idle worker state begins, work preempts ambient immediately. This means no delayed ambient command can start during coffee preparation or service.

When two available extra cats are close and an activity ends, they can briefly face one another and pause. This is only a proximity cue; it has no relationship state, dialogue, reward, or gameplay impact.

## Interaction, debug, and timing

Tap PrototypeCatA or PrototypeCatB to show the existing selection ring plus its name and current activity. Tap Mochi for ambient activity when off-duty, or the existing work-state feedback when working. Debug OFF leaves only the cats and ordinary prototype interaction feedback. Debug ON adds each cat's ID, profile, activity, zone, work/ambient priority, and occupied zones. The existing F1/D debug toggle, F7 manual/auto toggle, F8 timing preset, F6 comparison, Mochi 1/2/3 and F2–F5 controls, and camera Z/X/C/V controls remain unchanged. No new shortcut is needed.

`data/home_ambient_timing.tres` centralizes idle duration, activity duration, roam delay, social pause, movement speed, and deterministic seed. Tests can duplicate the resource and set a known seed; no global random state is required.

## Playtest notes

Watch several loops in MANUAL and AUTO. In manual mode, let Mochi begin a quiet rear-counter routine, then tap Espresso after a customer orders: Mochi should stop ambient movement and make coffee normally. During service, both extra cats should continue independently without standing on a customer seat or service waypoint. Check the right-side corridor, counter front, table depth, and labels on a device-sized viewport. The ambient markers were reused without changing layout; final visual comfort and whether these subtle tendencies are perceptible still require a human playtest.

This is deliberately **not** the final personality system. It contains no collection, progression, needs, schedules, economy, save state, dialogue, final art, or production animation.
