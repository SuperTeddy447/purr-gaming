# InteractionSlot contract V1

Status: architecture contract proven in `scenes/dev/world_architecture_hardening_lab.tscn`; not yet integrated into Home.

## Ownership and API

A `WorldObject` instance has stable room-local identity, a foot/floor transform, optional PhysicalFootprint, visual, and zero or more `InteractionSlot` children. A slot owns `ApproachAnchor`, `ActionAnchor`, `ExitAnchor`, semantic `action_type`, allowed actor categories, capacity, priority/tags, facing policy, character/object action names, duration, FX and camera-shot cues. The object owns local state and any object-level shared capacity. A room registry resolves *available* slots by semantic action plus optional stable object ID. A character calls `request_interaction(&"sit")` or `request_interaction_on(&"chair_a", &"sit")`; it never stores an authored destination pixel.

`HardeningInteractionSlot` implements the lab contract with weak actor references. This is a small composed component, not a giant inheritance base. Action names are open `StringName`s, so future `dig`, `plant`, `harvest`, `soak`, `fish`, `play`, `knead`, `eat`, `drink` can be supplied by new objects without adding map-specific branches to the resolver. New action *effects* still need dedicated object and animation adapters.

## Lifecycle

1. Discover compatible enabled slot; reject category/capacity conflicts.
2. Reserve atomically before movement. Object-level capacity is claimed at the same point.
3. Navigate via NavigationAgent2D to ApproachAnchor; a changed room nav revision refreshes the destination.
4. Occupy and bind actor feet/root to ActionAnchor; signal `action_started` to animation/object/FX adapters.
5. Run until completion condition; the lab uses configurable duration. Production may use animation events/object state completion instead.
6. Navigate to ExitAnchor, release exactly once, signal completion.

The slot rejects a second customer at capacity 1, including a different actor attempting `occupy`. A CatBed shares capacity 1 across RestSlot and SleepSlot. Cat B is rejected from the occupied bed and can choose Plant/Sniff. Espresso's CoffeeActionSlot allows worker only. Reservation is released on completion, explicit cancel, actor tree exit, slot disable, object removal and navigation failure. The actor detects a lost/freed slot and returns Idle. Scene teardown releases slots through node exit.

The lab's `HardeningWorld` currently walks the small scene tree for discovery. Production should maintain a room-scoped registry keyed by action and stable instance ID, updated on spawn/remove/toggle, with invalidation events; it should not use a global event bus or display-label NodePaths as identity. Character animation and object action must be synchronized by typed local signals/cues. Future `Sit`, `WorkCoffee`, `Soak`, and `Dig` each use the same reserve→approach→action→exit→release shell, while their visual/state effects live on the object/action adapter.
