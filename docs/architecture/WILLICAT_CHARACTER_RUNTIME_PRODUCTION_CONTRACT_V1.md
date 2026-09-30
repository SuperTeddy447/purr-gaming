# WILLICAT CHARACTER RUNTIME PRODUCTION CONTRACT V1

Status: **READY FOR HUMAN REVIEW**

This document defines the production runtime architecture for collectible cats in Godot 4.7, aligning with the locked Home V3 spatial and lighting architecture.

## 1. Current Actor & Animation Audit
The legacy Mochi animation system (`MochiVisualPresenter`, `MochiLayeredIdleVisual`) heavily relied on procedural tweens (tail, ears, breathing) to save memory, sacrificing the hand-drawn "feline first" quality required for the new protagonist. Legacy actors (`SliceCustomer`, `SliceWorker`) embedded Home-specific logic and states. 
The new `HardeningActor` correctly uses semantic `InteractionSlot` requests, decoupling character logic from map coordinates. This architecture requires an animation system that responds to generic semantic actions (`sit`, `sniff`, `work_coffee`) without dictating gameplay rewards.

## 2. Official Godot Research Findings
See `docs/research/WILLICAT_CHARACTER_RUNTIME_GODOT_RESEARCH_V1.md` for full details. 
**Key takeaways:**
- Use `AnimatedSprite2D` driven by `AnimationPlayer` for frame-by-frame control and simultaneous anchor/FX tweening.
- Avoid `AnimationTree` as it adds unnecessary complexity for discrete 2D sprite states.
- Avoid root motion; rely on in-place animation and scripted `CharacterBody2D` velocity.

## 3. Recommended Character Scene Hierarchy
```text
CharacterRoot (CharacterBody2D)
├── CollisionShape2D (Navigation avoidance / physics bounds)
├── NavigationAgent2D (Pathfinding)
├── ShadowSprite (Simple blob, CanvasItemMaterial unaffected by light)
├── VisualAnchor (Node2D, handles flip_h scaling if needed)
│   ├── AnimatedSprite2D (Main character frames, uses AnimationPlayer)
│   ├── Face/EmotionSprite (Optional, for modular expressions if needed)
│   ├── CosmeticAnchor (For future outfits)
├── FXAnchors (Marker2D)
│   ├── HeadFX
│   ├── HeartFX
│   ├── PurrFX
│   ├── FeetFX
│   ├── CarryAnchor
│   └── ServeAnchor
├── CameraAnchors (Marker2D)
│   ├── CameraEmotionFocus
│   └── CameraFullBodyFocus
└── AnimationPlayer (Drives frames, local anchors, audio cues)
```

## 4. Root / Pivot / Baseline Contract
- **Canonical Root:** The `(0, 0)` origin is the floor-contact / feet root (center of mass on the ground).
- **Stable Pivot:** The origin MUST NOT bounce or drift across animation frames. 
- **Baseline Rule:** Asset Forge must normalize frames so the lowest floor-touching pixel aligns with `(0, 0)`. The `AnimatedSprite2D` must use a consistent offset relative to the root, not repositioning per-frame.

## 5. Facing Recommendation
**Recommendation:** 4-Directional (Up, Down, Left, Right).
- **Rationale:** The Home V3 camera is an elevated 3/4 perspective. 4-direction covers all interaction angles without the exponential production cost of 8-direction. 
- **Implementation:** Engine maps continuous 360 movement into the closest of the 4 cardinal bins.

## 6. Mirroring Policy
- **Policy:** Asymmetric features (jade café apron, specific ear markings, holding coffee in a specific paw) make mirroring unsafe. 
- **Implementation:** The runtime must support explicit `Left` and `Right` clips. For perfectly symmetric cats (base protagonist without clothes), the `AnimationSet` data can alias `Left` to `Mirrored-Right` to save memory. The engine should NOT globally enforce `flip_h` purely based on velocity if a dedicated `Left` animation exists.

## 7. Animation-State Taxonomy
Do not overbuild. Group by semantic category:
- **CORE REQUIRED:** `idle`, `walk`, `turn`
- **LIFE EXPANSION:** `sit_enter`, `sit_idle`, `sit_exit`, `loaf`, `sleep`, `stretch`, `sniff`, `scratch`
- **EMOTION:** `alert`, `slow_blink`, `purr`
- **CAFÉ JOB:** `work_coffee`, `carry`, `serve`

## 8. Interaction Alignment Contract
- The `WorldObject` (e.g., Chair) owns the `ActionAnchor`. 
- When an actor occupies a slot, their `(0,0)` root snaps to the `ActionAnchor`.
- **Alignment:** The slot's `facing_policy` dictates the character's facing (e.g., facing left when sitting in `chair_a`).
- Animation happens in local space relative to this anchor. The animation does NOT move the gameplay coordinates.

## 9. Gameplay vs. Animation Authority
- **Gameplay is authoritative.** The semantic slot state (`reserved`, `occupied`) determines occupancy and task completion.
- **Animation is presentation.** Animation must NEVER grant rewards, fulfill orders, or release slots.
- **Sync:** Use `AnimationPlayer` method tracks to emit visual signals (e.g., `_on_cup_pickup_moment`) which the object's logic can listen to for visual syncing.

## 10. Runtime Movement Policy
- **In-place animation + CharacterBody2D.**
- Character plays `walk` in place; `CharacterBody2D` moves via `velocity` determined by `NavigationAgent2D`.
- Avoid 2D root motion. It causes desyncs with navigation avoidance on mobile and complicates coordinate mapping.

## 11. Depth / Occlusion Policy
- **Y-Sort:** Rely entirely on Godot's built-in Y-sort using the floor-contact origin.
- **Occluders:** Furniture (e.g., CounterShell) uses a separate `VisualFrontOccluder` in the scene tree to occlude cats walking behind it.
- **No Z-Index Hacks:** Never change the character's `z_index` in state logic. If a cat is inside a bed, the bed must provide a front rim to occlude the cat naturally.

## 12. Lighting / Shadow Policy
- **Lighting Response:** Characters use the default `CanvasItem` lighting mode. They should respond to `DirectionalLight2D` (sun/moon) and `PointLight2D` (lamps). No normal maps are required for characters to preserve the 2D illustration style.
- **Light Masks:** Characters must share a common light mask to interact predictably with room lamps.
- **Runtime Shadow:** A lightweight, semi-transparent blob `Sprite2D` shadow attached to the root. It must NOT cast directional Godot shadows. It scales slightly if the character jumps, but does not rely on expensive real-time light rendering.

## 13. FX Anchor Policy
Characters own their semantic FX anchors (independent of map coordinates):
- `HeadFX` (Thoughts, question marks)
- `HeartFX` (Affection, emotes)
- `PurrFX` (Near throat/chest)
- `FeetFX` (Dust, splashes)
- `CarryAnchor` (For holding items, flips with facing)
- `ServeAnchor`

## 14. Camera Anchor Policy
Characters own semantic `Marker2D` nodes for the `CameraDirector`:
- `CameraEmotionFocus`: Centered on the upper torso/face for dialogue/reaction shots.
- `CameraFullBodyFocus`: Centered on the character's bounding box.
- Avoid `CameraFaceFocus` unless a specific ultra-close up is needed (not currently justified).

## 15. Outfit Strategy Recommendation
**Recommendation:** Layered Sprites (Hybrid Approach).
- **Why:** Fully baked outfit variants (A) explode asset count exponentially. (C) 3D or skeleton deformations ruin the hand-drawn feel. 
- **How:** Outfits are separate `AnimatedSprite2D` nodes that inherit the same `AnimationPlayer`. The asset pipeline must guarantee frame-for-frame matching between the base cat and the outfit. 
- **Note:** Do NOT implement this yet. Base protagonist only.

## 16. Different Body Types Strategy
- **Resource Model:** Different body bounds means anchors (`HeadFX`, `CarryAnchor`) must be configurable per cat type.
- Do not normalize bodies. A Maine Coon should be larger than a Munchkin.
- **Implementation:** `CatDefinition.tres` defines an `anchor_offsets` dictionary and `scale_profile`. Interaction slots must be authored generously enough to fit the largest approved cat, or slots must specify `allowed_categories` (e.g., small_cat_only).

## 17. Resource / Save-Data Model
- **Reusable Definition (`CatDefinition.tres`):** 
  `identity_id`, `display_name`, `animation_set`, `scale_profile`, `fx_anchor_offsets`, `camera_anchor_offsets`.
- **Save Data (Player State):** 
  `cat_id`, `relationship_level`, `unlocked_state`, `equipped_cosmetics`, `current_assignment` (e.g., idle in cafe, working espresso).
- Do not save transient rendering state or exact navigation paths.

## 18. Asset Forge Character Validation Contract
Asset Forge MUST validate:
- **Floor-Contact Root:** Lowest opaque pixel aligns with `(0,0)`.
- **Padding:** Sufficient transparent alpha padding exists around the character.
- **Frame Size Consistency:** All frames in an animation clip share the same canvas bounds.
- **Frame Count:** Output `SpriteFrames` match expected clip length.
- **Stable Baseline:** No vertical bouncing of the floor contact point across frames.

## 19. Old Mochi Review (REUSE / ADAPT / REJECT)
| Component | Disposition | Reasoning |
| --- | --- | --- |
| `HardeningActor` | **REUSE** | Perfect generic slot interaction. No map coordinates. |
| `MochiLayeredIdleVisual` | **REJECT** | Procedural tweening destroys handcrafted premium art feel. Too complex for simple states. |
| `SliceCustomer` / `SliceWorker` | **REJECT** | Hardcoded Home-specific states (e.g., `WAITING_FOR_SERVE`). |
| `MochiVisualPresenter` | **ADAPT** | Keep the concept of a decoupled visual endpoint, but gut the procedural/layered complexity. Rebuild as a simple `AnimationPlayer` adapter. |
| Semantic Action mapping | **REUSE** | Mapping `sit` to an animation ID is necessary for generic interactions. |

## 20. Recommended FIRST Animation Proof
**Proof Loop:** `Idle` → `Walk` → `Approach Chair` → `Sit Enter` → `Sit Idle` → `Sit Exit` → `Walk`
**Why:** This proves:
- Root stability during a transition (`Walk` → `Sit Enter`).
- Facing alignment with the `InteractionSlot`.
- Chair occlusion (front vs. back layers).
- Runtime shadow behavior when state changes.
- Integration with the semantic interaction architecture.

## 21. Risks / Unresolved Questions
1. **Outfit Drift:** If outfits are layered sprites, maintaining pixel-perfect registration across many animations and feline body types is a massive art production risk.
2. **Chair Occlusion:** A seated cat may need to be split if the chair has arms that cover the cat, or the chair must be split into back/front sprites. The chair currently owns a `VisualFrontOccluder`, but testing is needed for precise overlapping.
3. **Mirroring Outfits:** If an outfit has text or an asymmetrical badge, mirroring `Left` to `Right` will break it. The pipeline must know which assets can be safely aliased.
