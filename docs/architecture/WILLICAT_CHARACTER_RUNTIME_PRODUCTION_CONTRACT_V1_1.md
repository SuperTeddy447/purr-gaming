# WILLICAT CHARACTER RUNTIME PRODUCTION CONTRACT V1.1

Status: **READY FOR PRODUCTION LOCK REVIEW**

This document hardens the runtime architecture for collectible cats in Godot 4.7, aligning with the Home V3 spatial and lighting architecture.

## 1. Character Scene Hierarchy
The scene hierarchy strictly separates physical/gameplay presence from visual presentation.

```text
CharacterRoot (CharacterBody2D)  [OWNS: movement, collisions, slot occupancy]
├── CollisionShape2D             [OWNS: Navigation avoidance bounds]
├── NavigationAgent2D            [OWNS: Pathfinding]
├── ShadowSprite (Sprite2D)      [OWNS: Runtime blob shadow]
├── VisualRoot (Node2D)          [OWNS: Visual offset from logical root, facing/mirror scale]
│   ├── AnimatedSprite2D         [OWNS: Frame playback, base texture]
│   └── CosmeticAnchors (Node2D) [OWNS: Simple rigid cosmetics e.g., glasses]
├── SemanticAnchors (Node2D)     
│   ├── HeadFX (Marker2D)        [OWNS: Thoughts, emotes]
│   ├── HeartFX (Marker2D)       [OWNS: Affection]
│   ├── CarryAnchor (Marker2D)   [OWNS: Held props like coffee cups]
│   ├── CameraEmotion (Marker2D) [OWNS: Director focus for face]
│   └── CameraBody (Marker2D)    [OWNS: Director focus for bounding box]
└── AnimationPlayer              [OWNS: State transitions, FX method tracks, audio syncing]
```

## 2. Root / Pivot / Baseline Contract
**Correction Applied:** The lowest opaque pixel is NO LONGER required to be `(0,0)`. 
- **Logical Root:** The `CharacterBody2D` origin `(0,0)` is the stable logical floor-contact transform. This never bounces.
- **Visual Offset:** The `VisualRoot` node offsets the sprite based on metadata from Asset Forge (e.g., `baseline_y`).
- **Asset Forge Responsibility:** Forge outputs a fixed canvas size per animation with defined transparent padding. It outputs metadata defining the precise pixel coordinate of the character's "floor contact" in that canvas. The engine applies this as an offset to `VisualRoot`, guaranteeing that paws lifting or tails dropping below the feet do not cause the physical gameplay root to jump.

## 3. Facing Recommendation
**Recommendation: 4-Directional (Up, Down, Left, Right).**
- **Why:** The 3/4 elevated isometric camera makes 2-direction (Left/Right) look like a side-scroller when characters move on the Y-axis. 8-direction is prohibitively expensive. 4-direction provides the necessary volumetric feel for a living café.
- **Interactions:** Interaction slots (e.g., sitting at an angled chair) dictate a specific facing override upon reservation.

## 4. Mirroring Policy
**Correction Applied: MIRRORING IS OPT-IN ONLY, NEVER DEFAULT.**
- **Why:** Asymmetric ears, facial markings, and held items (e.g., coffee in the right paw) break when automatically mirrored via `flip_h`.
- **Implementation:** The `AnimationSet` data defines the source for every direction per clip:
  - `left_source`: `explicit` or `mirror_from_right`
  - `right_source`: `explicit` or `mirror_from_left`
- A clip is only mirrored by setting the `VisualRoot` scale to `(-1, 1)` if explicitly authorized by the asset's metadata.

## 5. Outfit Strategy Recommendation
**Recommendation: HYBRID (Baked Complex + Layered Rigid).**
- **Complex Outfits (Aprons, Sweaters):** Must be **BAKED** into the base character animation frames. Layered sprites for deforming 2D hand-drawn bodies cause severe visual registration risks ("outfit drift") during sit, loaf, and stretch states.
- **Rigid Cosmetics (Glasses, Hats):** Can be **LAYERED** via `CosmeticAnchors`. They do not deform and only require a stable attachment point.

## 6. AnimatedSprite2D vs AnimationPlayer Responsibilities
- **AnimatedSprite2D:** Exclusively handles frame progression of the active clip.
- **AnimationPlayer:** Coordinates the semantic animation states, triggers audio cues, toggles cosmetic visibility, and emits signals for FX syncing via method tracks.
- **Authority:** Gameplay script (`HardeningActor`) is the ultimate authority. It triggers the `AnimationPlayer`; the player does not drive gameplay state.

## 7. AnimationTree Decision
**Decision: REJECTED.**
- **Why:** `AnimationTree` excels at blending 3D skeletal weights or continuous 1D/2D blend spaces. For discrete 2D sprite frame swapping, it adds unnecessary node bloat. A lightweight state machine in the `HardeningActor` script triggering `AnimationPlayer.play()` is far cleaner and more performant for mobile.

## 8. Movement and Root Motion Policy
**Policy: NO 2D ROOT MOTION.**
- **Implementation:** Characters use in-place locomotion animations. `CharacterBody2D` physically moves via velocity driven by `NavigationAgent2D`. Root motion causes desyncs with navigation obstacle avoidance and complicates exact coordinate arrival.

## 9. Interaction Alignment Contract
- When an actor occupies a slot, the `CharacterBody2D` logical root snaps exactly to the slot's `ActionAnchor`.
- **Offsets:** Small visual alignment differences (e.g., a tiny cat needs to sit further forward on a deep chair) are handled via semantic `InteractionProfile` offsets defined in the `CatDefinition`, NEVER by hard-coding map coordinates.

## 10. Different Body Type Strategy
Do not normalize silhouettes. The `CatDefinition` resource handles variations:
- **`scale_profile`:** Base scalar for the entire node tree.
- **`anchor_offsets`:** Dictionary defining custom positions for `HeadFX`, `CarryAnchor`, etc., for this specific body.
- **Slot Compatibility:** `InteractionSlots` define `allowed_categories`. A Maine Coon might be blocked from a tiny kitten bed.

## 11. Chair Occlusion Strategy
- **Structure:** `Chair (StaticBody2D) -> Visual (Sprite2D) -> VisualFrontOccluder (Sprite2D with higher Z-index)`.
- **Policy:** Do not split chairs into complete front and back separate entities. Use a single chair base and a targeted front occluder sprite (e.g., the front armrest) that Y-sorts strictly above the character. Simple stools do not require occluders.

## 12. Character Lighting
**Policy: NO NORMAL MAPS. Default `CanvasItem` lighting.**
- Characters share a common light mask with the environment.
- The base art includes intrinsic soft shading. The runtime applies colored `CanvasModulate` (day/night) and soft `PointLight2D` tints. This preserves the matte storybook illustration style without creating plasticky specular highlights.

## 13. Runtime Shadow Contract
- **Owner:** `ShadowSprite` child of `CharacterBody2D`.
- **Implementation:** A simple, semi-transparent blob sprite. It uses a material that ignores 2D lighting (unshaded) so it doesn't double-darken at night.
- **Behavior:** It scales down and lowers opacity slightly when the character transitions to a jumping state, but remains grounded on the floor. It changes profile (e.g., widens) when the character transitions to `loaf` or `sit_idle`.

## 14. FX / Camera Anchor Set
Reduced to the absolute minimum semantic requirements:
- `HeadFX` (Emotes, thoughts)
- `HeartFX` (Affection, relationship events)
- `CarryAnchor` (Props)
- `CameraEmotion` (Director face focus)
- `CameraBody` (Director full bounding box focus)

## 15. Resource Data Models
**`CatDefinition.tres` (Immutable Design Data):**
- `identity_id` (e.g., `cat_orange_protagonist`)
- `animation_set` (Reference to `CatAnimationSet.tres`)
- `body_scale_profile`
- `mirroring_policy_overrides`
- `anchor_offsets`
- `interaction_profile` (Offsets for slot alignment)

**`CatAnimationSet.tres`:**
- Maps semantic actions (`sit`, `walk`, `idle`) to `SpriteFrames`.
- Defines frame rates and default loop behaviors.

## 16. First Production Proof (Lock Candidate)
**Proof Loop:** `Idle` → `Walk` → `Approach Chair` → `Sit Enter` → `Sit Idle` → `Sit Exit` → `Walk`
This single loop is sufficient to validate root stability, visual offsets, mirroring logic, slot alignment, and front-occlusion sorting.

## 17. Remaining Risks
1. **Asset Forge Offset Pipeline:** The exact metadata format from the art generation pipeline specifying the "logical floor pixel" must be rigidly enforced, or cats will bounce when walking.
2. **Action Transition Snapping:** Transitioning from `walk` (moving) to `sit_enter` (snapped to anchor) might look jarring if the navigation agent doesn't arrive precisely on the anchor pixel. Code easing may be required.
