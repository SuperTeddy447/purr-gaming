# WILLICAT CHARACTER ANIMATION PRODUCTION PLAN V1.1

## Objective
Create the FIRST true vertical slice of the production character runtime pipeline for Godot 4.7, using the finalized orange protagonist. This proof will validate logical root stability via visual offsets, semantic interaction slots, navigation, occlusion, and lighting response.

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
### Root Stability & Visual Offset Validation
- **Requirement:** The character's physical `CharacterBody2D` root MUST NOT move during in-place animations.
- **Validation:** Asset Forge must supply metadata defining the exact floor-contact pixel for each frame canvas. The engine applies this as an offset to `VisualRoot`. 
- **Test:** Verify zero visual foot sliding or vertical bouncing during `Walk` and `Sit Enter`, even if the bounding box or lowest opaque pixel changes.

### Mirroring Policy Enforcement
- **Requirement:** Mirroring is opt-in, not default.
- **Validation:** Provide explicit `Right` and `Left` clips for the asymmetric orange protagonist. Do NOT rely on engine `flip_h` for this test, proving that explicit directional asset loading works.

### Facing & Navigation
- **Requirement:** 4-Directional locomotion.
- **Validation:** Provide `Walk` and `Idle` in Up, Down, Left, and Right. Prove the engine smoothly selects the correct facing based on `NavigationAgent2D` velocity vector binning.

### InteractionSlot Alignment
- **Requirement:** Root snaps to `ActionAnchor`; visual alignment is handled via `InteractionProfile` offsets.
- **Validation:** The `Sit Enter` animation must align perfectly with the chair without hardcoding map coordinates into the actor script.

### Depth & Chair Occlusion
- **Requirement:** One-piece chair base with a targeted `VisualFrontOccluder`.
- **Validation:** The seated cat must sort behind the chair's front armrest occluder but in front of the chair's backrest, proving Y-sort and Z-index layering.

### Runtime Shadow
- **Requirement:** Unshaded blob shadow.
- **Validation:** The shadow must change from a small circle (`Walk`) to a wider oval (`Sit Idle`) via the `AnimationPlayer` state, while ignoring directional scene lighting.

## 3. Asset Deliverables Required for Proof
*Note: Due to the asymmetric protagonist, Left and Right clips must be explicitly provided. Mirroring is disabled.*

**Locomotion:**
- `protagonist_idle_down`, `protagonist_idle_up`, `protagonist_idle_right`, `protagonist_idle_left`
- `protagonist_walk_down`, `protagonist_walk_up`, `protagonist_walk_right`, `protagonist_walk_left`

**Interaction (Assuming chair faces Right):**
- `protagonist_sit_enter_right` (one-shot)
- `protagonist_sit_idle_right` (loop)
- `protagonist_sit_exit_right` (one-shot)

## 4. Execution Rules
- **DO NOT** use legacy Mochi scripts or `AnimationTree`.
- **DO NOT** modify the Home V3 layout lock or production scene.
- Build the proof inside a clean developer lab scene inheriting the hardened framework.
