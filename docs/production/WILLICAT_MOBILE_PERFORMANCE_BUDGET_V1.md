# WILLICAT MOBILE PERFORMANCE BUDGET V1

## 1. Frame-Time Target Policy
- **Primary Target:** 60 FPS (16.67 ms frame time).
- **Fallback Target:** 30 FPS (33.33 ms frame time).
- **Rationale:** Cozy living games benefit from 60 FPS for smooth character animation and panning, but 30 FPS is entirely acceptable for older devices or battery-saver modes. Gameplay does not rely on twitch reflexes.
- **Budgets (60 FPS):**
  - TARGET: < 12.0 ms
  - WARNING: > 14.0 ms
  - FAIL: > 16.67 ms consistent

## 2. Quality Tiers
| Feature | LOW (Fallback) | STANDARD | ENHANCED |
| --- | --- | --- | --- |
| **FPS Target** | 30 FPS | 60 FPS | 60 FPS |
| **Visible PointLights** | 2 (Key lamps) | 5 | 8-10 |
| **Shadow-casting Lights** | 0 | 0 | 1 (Sun/Moon only) |
| **Weather Particles** | 0 (Tint/sound only) | 50 (CPUParticles2D) | 200 |
| **Max On-Screen Cats** | 5 | 10 | 15 |
| **Character Shadows** | Blob Sprite | Blob Sprite | Blob Sprite |

## 3. Texture Memory Model & Budget
*Assumption: Mipmaps disabled. Uncompressed RGBA8 for characters/UI to preserve art quality.*
- **Math:** Width × Height × 4 bytes.
- **Home Base Architecture:** 2048×2048 ≈ 16 MB.
- **Furniture (Average):** 10 objects at 512×512 ≈ 1 MB each = 10 MB.
- **UI & FX:** ≈ 15 MB.
- **Character Animation (Per Cat):**
  - 4-dir Idle (16 frames), 4-dir Walk (32 frames), Sit (10 frames) = 58 frames.
  - Average padded frame size: 300×300.
  - Math: 300 × 300 × 4 bytes × 58 frames ≈ 20 MB per cat.
- **Total Estimated VRAM (5 Cats Loaded):** 16 + 10 + 15 + (20 × 5) = **141 MB**.
- **BUDGET:**
  - TARGET: < 200 MB
  - WARNING: > 250 MB
  - FAIL: > 350 MB (Will cause crashes on 2GB RAM low-end Androids).

## 4. Character Loading Strategy
**Room-Based Lazy Loading.**
- The game must **NOT** preload all 20+ collectible cat animation sets.
- Only load the `CatAnimationSet.tres` (and associated textures) for the specific cats currently assigned to or actively visiting the Home V3 room.
- Unload animation frames from memory when a cat leaves the café or goes off-screen to a distant zone.

## 5. Lighting & Shadow Budget
- **CanvasModulate:** 1 global node for day/night tinting. (Cost: ~0 ms).
- **DirectionalLight2D / PointLight2D:** Limit to active, on-screen area. Hide lights that are off-screen.
- **Shadow Policy:**
  - *Character Grounding:* Unshaded semi-transparent blob Sprite2D. (Cost: 1 draw call).
  - *Furniture Grounding:* Baked into furniture Sprite2D or separate Sprite2D. (Cost: 1 draw call).
  - *Real-time Cast Shadows:* 0 for LOW/STANDARD. Real-time 2D shadow mapping is strictly reserved for ENHANCED tier, and only for the primary DirectionalLight2D (Sun), never for indoor lamps.

## 6. Particles & Weather
- Use `CPUParticles2D` for broad compatibility.
- Ensure particle texture bounds are tight to prevent overdraw.
- If rain overdraw kills mobile fill-rate, fall back to an animated full-screen scrolling shader overlay (much cheaper than rendering 500 individual 64x64 rain sprites).

## 7. Draw Calls & Node Complexity
- **Draw Calls:** Target < 150 per frame.
- **Transparency / Overdraw Rules:**
  - Do not use giant 2048x2048 sprites that are 90% empty space just to maintain world position.
  - Assets must be tightly cropped to their opaque content.
  - Use Asset Forge to enforce bounding boxes.
- **Hidden Nodes:** Turn off `process` and `physics_process` for furniture or actors completely off-screen.

## 8. Asset Forge Performance Validation
Asset Forge MUST implement these automated warnings before exporting to Godot:
- **Empty Space Ratio:** Warn if bounding box is >30% fully transparent alpha.
- **Absolute Dimensions:** Warn if width or height > 1024px without explicit "Architecture" tags.
- **VRAM Estimate:** Print estimated RGBA8 footprint. Warn if a single animation clip exceeds 5 MB.
- **Mipmap Flag:** Strip mipmaps automatically for 2D sprites.

## 9. Stop Conditions for Art Production
Art production must halt and wait for optimization if:
1. The Staggered Salon room base exceeds 30 MB texture memory.
2. A single cat's core animation set exceeds 25 MB.
3. Rain/Weather drops a mid-range test device below 45 FPS due to overdraw.
4. Active lamps cause frame times to spike above 16.67ms on a standard device.
