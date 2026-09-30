# WILLICAT WORLD VISUAL STRUCTURE V1

## 1. Visual Production Unit Recommendation
**Recommendation: HYBRID ROOM-FIRST KIT.**

Recent experiments treating the room as completely isolated walls (floor, north wall, left wall, right wall, window) generated independently resulted in disjointed, "pasted together" assets that break lighting and material cohesion.

**The Hybrid Room-First Workflow:**
1. **Design the Room Shell Together:** The floor, fixed walls, permanent architectural trim, and signature window must be designed, sketched, and painted as a **single cohesive master illustration**. This ensures unified perspective, lighting intent, and material harmony.
2. **Extract the Kit:** Once the Room Shell is visually locked, it is cut into its constituent Godot layers (Floor, Back Wall, Front Occluders).
3. **Modular Furniture:** Interactive objects (Counter, Espresso, Chairs, Beds) are designed separately but color-calibrated against the Room Shell master.

## 2. Visual Style Calibration
**Direction: More Illustrated, Less Architectural Realism.**

Recent tests drifted toward luxury architectural renders and ornate Art Deco hotels. WilliCat must course-correct back toward its North Star:
- **Softer, Handmade Identity:** Lines and edges should feel slightly imperfect and painterly.
- **Simpler Material Treatment:** Avoid hyper-realistic wood grains or glossy reflections. Use larger, readable shapes.
- **Warmth:** The café must feel like a cozy, personal, lovingly maintained space, not a sterile, high-end corporate establishment.
- **Diorama vs. Storybook:** Keep the diorama *framing*, but the texture and finish must be *storybook illustration*.

## 3. Environment Pipeline Breakdown
To inform the technical architecture, visual composition must be divided as follows:

| Element | Production Strategy | Reusability |
| :--- | :--- | :--- |
| **Room Shell (Floor/Walls)** | Painted as a unified whole, cut for engine layers. | **Location-Specific.** Varies by building/biome. |
| **Fixed Architecture (Windows)** | Baked into the Shell's visual design. | **Location-Specific.** |
| **Core Service Stations (Counter)** | Modular objects, designed to match the Shell. | **Reusable** across rooms, skinnable. |
| **Movable Furniture (Chairs, Beds)**| Highly modular, independent assets. | **Highly Reusable** across the entire game. |
| **Atmosphere / Lighting** | Runtime-driven (CanvasModulate, PointLight2D). | **Universal System.** Driven by metadata. |
| **Seasonal Overlays** | Overlays/Skins applied to modular objects. | **Reusable** globally. |

## 4. Addressing Visual Coherence
- **Color Grading:** The runtime lighting system must do the heavy lifting for time-of-day. Base assets must remain neutral to avoid "baked-in" shadows conflicting with runtime lights.
- **Footprints:** All modular furniture must strictly adhere to the `WILLICAT_HOME_V3_ART_HANDOFF_SPEC_LOCK_V1` rules for padding, floor-contact roots, and Y-sort compatibility to avoid looking like stickers pasted on a background.
