# WILLICAT GODOT MOBILE PERFORMANCE RESEARCH V1

## 1. Engine & Renderer Selection
- **Godot 4.7 Forward Mobile vs Compatibility:**
  - **Forward Mobile (Vulkan/Metal):** Recommended for modern devices. It handles 2D lighting and multiple `PointLight2D` nodes much more efficiently than GLES3. However, it requires Vulkan 1.0 / Metal support.
  - **Compatibility (OpenGL3):** Required for very old low-end Android devices. 2D lighting performance degrades rapidly as light count increases.
  - **Recommendation:** Target Forward Mobile as primary. Fallback to Compatibility only if the low-end device matrix absolutely demands it.

## 2. 2D Batching and Draw Calls
- Godot 4.x automatically batches 2D draw calls.
- **Batch Breakers:** Changing materials (e.g., custom shaders), changing `z_index` repeatedly across interleaved textures, overlapping `CanvasItem` bounds with different textures, or mixing `Sprite2D` with different `BlendMode` settings.
- **Recommendation:** Use texture atlases where appropriate, though WilliCat's component-based approach relies on independent Sprites. Keep materials consistent (default `CanvasItemMaterial`) and rely on Y-Sort rather than explicit `z_index` interleaving.

## 3. Texture Memory, Compression, and Mipmaps
- **Uncompressed RGBA8 Math:** `Width × Height × 4 bytes`. A 2048×2048 texture consumes ~16.7 MB in VRAM.
- **VRAM Compression (ETC2/ASTC):** Reduces VRAM footprint by 4x to 6x. 
  - *Risk:* 2D hand-drawn art with soft alpha gradients often suffers from severe banding and blocking artifacts under standard VRAM compression.
- **Mipmaps:** Increase memory by ~33%. 
  - *Risk:* Since WilliCat uses a fixed 2.7x zoom orthographic-style camera and doesn't zoom out extensively, mipmaps are largely unnecessary and waste memory.
- **Recommendation:** Disable mipmaps for all environment and character sprites. Attempt VRAM compression for background/opaque elements. Characters and transparent UI elements may require uncompressed RGBA8 (or lossless WebP in storage) to preserve the storybook quality, demanding a strict memory budget.

## 4. Lighting and Shadows
- **CanvasModulate:** Extremely cheap. Acts as a global vertex color multiplier.
- **PointLight2D / DirectionalLight2D:** Moderately expensive depending on resolution and overlapping bounding boxes.
- **Shadows (`LightOccluder2D`):** Very expensive on mobile tile-based GPUs (requires generating 1D shadow maps and multipass rendering).
- **Recommendation:** Heavily restrict or entirely eliminate real-time 2D shadow-casting from lights on mobile.

## 5. Navigation & Physics
- **NavigationAgent2D:** Path queries run on the NavigationServer. Heavy bursts of queries cause frame spikes.
- **Avoidance (RVO):** Processing many agents with avoidance radius enabled scales poorly on mobile CPUs.
- **Map Baking:** Dynamic navigation map rebaking (e.g., moving furniture) causes severe main-thread stalls.
- **Recommendation:** Stagger path queries across frames. Only bake nav maps in "Decoration Mode," not during normal gameplay.

## 6. Particles
- **GPUParticles2D:** Uses compute shaders. Not universally supported on all older mobile hardware.
- **CPUParticles2D:** Runs on the CPU. Safe, but limited in volume before bottlenecking the main thread.
- **Recommendation:** Use CPUParticles2D for rain/leaves, keeping particle counts under 200.

## 7. Transparency & Overdraw
- Mobile GPUs (tile-based deferred rendering) are severely bottlenecked by **Fill Rate** and **Overdraw** (drawing multiple transparent pixels on top of each other).
- A giant 2048x2048 sprite that is 90% transparent alpha will destroy mobile performance just as fast as a 90% opaque sprite, because the GPU still evaluates the transparent pixels.
- **Recommendation:** Assets MUST be tightly cropped.

## 8. Profiling Tools
- **Godot Built-ins:** 
  - `Debugger -> Profiler` (CPU frame time breakdown).
  - `Debugger -> Monitors` (FPS, draw calls, active objects, node counts, VRAM usage).
  - `Debugger -> Visual Profiler` (GPU time breakdown, Godot 4.x).
- **Native Tools:** Xcode Instruments (iOS) and Android Studio / Android GPU Inspector (AGI) are mandatory for accurate on-device GPU profiling. Desktop editor metrics are proxies only.
