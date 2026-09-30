# WILLICAT CURRENT BASELINE EVIDENCE V1

This document captures the technical baseline of the WilliCat repository while the `WILLICAT_ASSET_FACTORY_ARCHITECTURE_V1` is under human review. It is a read-only capture. No problems have been fixed.

## 1. Asset Forge Test Results

**TESTED**
- **Test count:** 62 tests run
- **Pass/Fail:** 62 passed, 0 failed
- **Failures:** None
- **Execution time:** 4.92s

## 2. Godot Regression / Smoke Tests

**TESTED**
Godot regression tests executed without error for continuous Home, proxy café, and First-Party Mini Pack 001.

*   **test_home_continuous_world_v1.gd:**
    *   Actor route, navigation, and seating/interaction verified.
    *   Save/load area progression and position restored.
    *   Coffee/sniff events and depth/occlusion check passed.
*   **test_proxy_cafe_proof_v1.gd:**
    *   Actor coffee event (order, brew, serve, sit, leave) verified.
    *   Save/load state restored.
*   **test_true_vertical_slice_001.gd:**
    *   Semantic actions/events, door, coffee, carry, reward, haptic hooks, clean ambient reset passed.

## 3. Mini Pack 001 Tree Animation Inspection

**MEASURED**
*   **Source file(s):** `res://assets/first_party/storybook_mini_pack_001/normalized/tree_gentle_breeze.png` (Contact shadow: `contact_shadow.png`)
*   **Frame count:** 4 frames
*   **Frame dimensions:** 512 x 640 pixels per frame
*   **Configured playback FPS:** 5.0 FPS (uniform)
*   **Total loop duration:** 0.8 seconds (4 frames / 5.0 FPS)
*   **Root/trunk registration:** Visual offset is `(0, -112)` with scale `0.4`
*   **Separate shadow presence:** Yes, instantiated from `contact_shadow.png` at offset `(0, -5)`, scale `0.32`, opacity `0.38`.
*   **Godot SpriteFrames/animation resource used:** A `SpriteFrames` object is generated dynamically at runtime via GDScript inside `first_party_tree_binding.gd`.

## 4. Godot Runtime Timing Facts

**OBSERVED**
*   **Godot version:** v4.7.2.stable.official.ed1daf0bf
*   **Animation resource type:** `SpriteFrames` mapped to `AnimatedSprite2D`
*   **SpriteFrames speed/timing representation:** Uniform frames per second per animation, set via `set_animation_speed("animation_name", fps)`.
*   **Current code/resource controlling animation speed:** GDScript (`first_party_tree_binding.gd`) programmatically configures the animation FPS (`5.0`). Nonuniform per-frame timing (`durations_ms`) is not currently supported natively by this configuration.

## 5. Asset Trace: Source to Runtime

**OBSERVED**
Tracing the tree asset:
1.  **Source / Exported file:** `res://assets/first_party/storybook_mini_pack_001/normalized/tree_gentle_breeze.png`
2.  **Godot resource/prefab:** The visual binding `res://scenes/dev/first_party_style_proof/willicat_tree_home_01.tscn` preloads the raw PNG path directly.
3.  **Runtime scene:** Added as `river_depth_tree` inside `res://scenes/dev/home_continuous_proxy/home_continuous_world_v1.tscn`.

**UNRESOLVED / OBSERVATION**
*   **File/hash identity preservation:** The exact file identity is referenced by the `res://` path, meaning the source PNG bytes are relied upon by Godot's import system. There is currently no immutable candidate compiler step generating a locked bundle or tracking a content hash outside of Git provenance.

WILLICAT CURRENT BASELINE EVIDENCE V1
— CAPTURE COMPLETE
