# WILLICAT CHARACTER OUTFIT PROOF PLAN V1

## Objective
Validate the hybrid outfit strategy (Baked Complex vs. Layered Rigid) by creating a controlled micro-proof using the Orange Protagonist and a Jade Café Apron. This proof will determine whether the pipeline can support separate outfit layers during deforming animations without unacceptable visual "outfit drift".

## Scope
- **Character:** Orange Protagonist (Base Master).
- **Outfit:** Jade Café Apron (Complex/Deforming).
- **Animations:** `Idle`, `Walk`, `Sit Enter`.

## 1. Test Methodology
The proof will build and compare two simultaneous implementations side-by-side in a developer lab scene.

### Option A: Baked (Control)
- The character and the apron are authored and exported together as a single flat `SpriteFrames` sequence.
- **Hypothesis:** Perfect visual registration, zero drift, but requires unique asset generation for every combination.

### Option B: Layered (Variable)
- The character is exported alone.
- The apron is exported as a separate transparent layer.
- In Godot, an `AnimatedSprite2D` for the apron is layered over the base `AnimatedSprite2D`, both driven by the same `AnimationPlayer`.
- **Hypothesis:** Memory efficient, supports dynamic combination, but highly susceptible to pixel drift during stretching (`Sit Enter`) or bouncing (`Walk`).

## 2. Acceptance Criteria
To pass the Layered approach (Option B) for production, it must meet the following gates:

1. **Zero Drift:** The apron strings, neck strap, and cloth folds must not separate from the cat's body pixels during the highest-deformation frames of `Sit Enter` or the vertical bounce of `Walk`.
2. **Frame Sync:** The engine must play both `AnimatedSprite2D` nodes in perfect lockstep without 1-frame rendering desyncs.
3. **Asset Forge Feasibility:** The generation pipeline must prove it can reliably produce the isolated apron layer perfectly registered to the base body.

## 3. Execution Plan
1. Generate the base `Idle`, `Walk`, and `Sit Enter` clips for the naked protagonist.
2. Generate the Option A (Baked) clips.
3. Generate the Option B (Layered) isolated apron clips.
4. Construct the test scene with two actors running the exact same semantic state machine.
5. Capture video for human review.

If Option B fails Acceptance Criterion 1 or 3, the production pipeline will **default to Option A (Baked)** for all complex clothing to preserve the premium hand-drawn visual target.
