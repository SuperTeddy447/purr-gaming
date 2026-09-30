# WilliCat Character Runtime Godot Research V1

## 1. Core Sprite & Animation Systems
- **AnimatedSprite2D + SpriteFrames**: Godot's built-in system for frame-by-frame 2D animation. Highly performant for mobile. Supports named animations.
- **AnimationPlayer**: A more robust timeline sequencer. While `AnimatedSprite2D` plays frames, `AnimationPlayer` can orchestrate sprite frame changes alongside positional tweens (e.g., moving an FX anchor), audio cues, and method calls (animation events).
- **AnimationTree**: Useful for 3D state machines and blend spaces. For 2D frame-by-frame, it often introduces unnecessary complexity (travel logic, blend position vectors) that can be handled more predictably by a direct state machine script driving an `AnimationPlayer`.
**Recommendation**: Use `Sprite2D` or `AnimatedSprite2D` driven by an `AnimationPlayer` to sequence frames, audio, and anchor transforms simultaneously. Avoid `AnimationTree` unless continuous blending (e.g., analog stick walk-to-run) is explicitly required.

## 2. Movement & Root Motion
- **CharacterBody2D + NavigationAgent2D**: The standard Godot pattern for kinematic movement with navigation map querying. 
- **Root Motion**: Godot 4 supports root motion, but it is primarily designed for 3D skeletal animation (`Skeleton3D`). Applying root motion to 2D frame-by-frame sprites requires manual track authoring and often fights with `NavigationAgent2D` pathing logic, leading to sliding or getting stuck on collision boundaries.
**Recommendation**: Rely on **in-place animation** combined with scripted `CharacterBody2D` velocity. This is production-safe, predictable on mobile, and decouples visual stride from navigation collision avoidance.

## 3. Rendering, Depth & Occlusion
- **Y-Sort (CanvasItem.y_sort_enabled)**: Godot 4 handles Y-sorting efficiently based on the Node's origin `(0,0)`. If the character's root is at the floor contact point, they will seamlessly sort behind tables and in front of chairs, provided the environment objects also use floor-contact roots.
- **Light Masks & CanvasItemMaterial**: Godot 2D lights interact with `CanvasItem` nodes based on their `light_mask`. Characters should use a consistent light mask. 
- **Normal Maps**: While possible via `CanvasTexture`, adding normal maps to every frame of frame-by-frame animation doubles texture memory and pipeline complexity. Given the "storybook illustration" style lock, normal maps should be omitted for characters to preserve the hand-drawn feel and mobile memory budget.

## 4. Shadow Implementation
- **DirectionalLight2D Cast Shadows**: Expensive on mobile and prone to artifacting with 2D sprites.
- **Sprite Shadow**: A simple, semi-transparent black/tinted ellipse `Sprite2D` placed at the character's root `(0,0)`. 
**Recommendation**: Use a lightweight shadow sprite. It stays flat on the floor, correctly scales with the character, and requires minimal GPU overhead compared to real-time 2D shadow casting.

## 5. Signals and Authority
- Godot's signal architecture allows decoupling. An `AnimationPlayer` can emit custom signals via a Call Method track (e.g., `_on_pickup_moment`).
- The `HardeningInteractionSlot` contract uses `action_started` and `action_completed`. Animation should visually represent these phases but never mutate the slot's reservation state directly.
