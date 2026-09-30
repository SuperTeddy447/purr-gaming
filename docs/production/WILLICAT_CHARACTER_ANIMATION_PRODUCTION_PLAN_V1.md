# WILLICAT CHARACTER ANIMATION PRODUCTION PLAN V1

## Objective
Create the FIRST true vertical slice of the production character runtime pipeline for Godot 4.7, using the finalized orange protagonist. This proof will validate root stability, semantic interaction slots, navigation, occlusion, and lighting response without implementing the entire animation catalog.

## Scope
**Protagonist ONLY.** (Orange Base Master).
No costumes. No cosmetics. No other cats.

## 1. The Core Loop Proof
The animation proof will demonstrate a single, complete semantic loop:

1. **Idle (Floor)**
2. **Walk (Navigation to target)**
3. **Approach Chair (Slot alignment)**
4. **Sit Enter (Transition)**
5. **Sit Idle (Action loop)**
6. **Sit Exit (Transition back to floor)**
7. **Walk (Navigation away)**

## 2. Technical Validation Gates
The produced assets and runtime implementation must pass these specific checks:

### Root Stability & Baseline
- The character's floor-contact pixels must remain aligned to `(0,0)` during `Idle`, `Walk`, and `Sit`.
- Asset Forge must report 0 pixel vertical drift on the root across all frames.

### Facing & Navigation
- Provide 4-directional clips (Up, Down, Left, Right) for the `Walk` cycle.
- Prove that the character correctly switches facing based on navigation velocity.
- Validate that mirroring (flipping the `Right` clip for `Left`) works visually for this symmetric protagonist.

### InteractionSlot Alignment
- The character's root must snap precisely to `chair_a`'s `ActionAnchor`.
- The `Sit Enter` animation must visually align with the chair seat without requiring map-specific position offsets in the character code.

### Transition Timing
- Validate the handoff between `Walk` (loop) -> `Sit Enter` (one-shot) -> `Sit Idle` (loop) -> `Sit Exit` (one-shot) -> `Walk`.
- The gameplay slot state must drive the visual state cleanly.

### Depth & Chair Occlusion
- The seated cat must sort correctly behind the chair's `VisualFrontOccluder` (if applicable) and in front of the chair's backrest, proving that Y-sort and floor-roots are correctly configured.

### Runtime Shadow & Lighting
- The blob shadow must remain grounded on the floor during the `Sit Enter` and `Sit Exit` animations.
- The character must react correctly to `CanvasItem` lighting, blending with the Home V3 atmosphere day/night cycle without custom normal maps.

## 3. Asset Deliverables Required for Proof
- `protagonist_idle_down` (loop)
- `protagonist_idle_up` (loop)
- `protagonist_idle_right` (loop)
- `protagonist_walk_down` (loop)
- `protagonist_walk_up` (loop)
- `protagonist_walk_right` (loop)
- `protagonist_sit_enter_right` (one-shot, assuming chair facing right)
- `protagonist_sit_idle_right` (loop)
- `protagonist_sit_exit_right` (one-shot)

*Note: `Left` is generated via runtime `flip_h` alias for this proof.*

## 4. Execution Rules
- **DO NOT** use `MochiLayeredIdleVisual`.
- **DO NOT** modify the Home V3 layout lock.
- Build the proof inside a clean developer lab scene inheriting the hardening framework (`HardeningActor` + `HardeningInteractionSlot`), NOT directly in the production `home_scene.tscn`.
