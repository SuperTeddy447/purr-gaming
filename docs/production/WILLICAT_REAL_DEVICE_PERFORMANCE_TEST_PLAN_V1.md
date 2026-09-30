# WILLICAT REAL-DEVICE PERFORMANCE TEST PLAN V1

## 1. Active Actor Benchmark Plan
This plan defines the tests required to measure navigation, physics, and animation loads.
- **Populations:**
  - *NORMAL:* 1 Worker, 2 Customers, 3 Cats. (Total 6 actors).
  - *BUSY:* 1 Worker, 5 Customers, 5 Cats. (Total 11 actors).
  - *STRESS:* 5 Workers, 10 Customers, 15 Cats. (Total 30 actors).
- **Measurement:** Measure `physics_process` time specifically. Navigation avoidance and path querying must not cause the physics tick to exceed 8ms.

## 2. Navigation Cost Budget & Test Strategy
- **Path Queries:** Actors must stagger path requests. Max 2 actors may request a new path from `NavigationServer2D` on the same frame.
- **Avoidance:** Only enable RVO avoidance for moving actors. Stationary (sitting/loafing) actors become static obstacles.
- **Nav Rebake:** Rebaking the navigation map (when furniture moves) takes significant MS. This is ONLY allowed when the player explicitly enters/exits "Decoration Mode." Never rebake during normal living café simulation.

## 3. InteractionSlot Scaling Risks
- **Current lookup:** Iterating over `get_tree().get_nodes_in_group("interaction_slots")`.
- **Scaling Limit:** If N < 50 slots, iteration is < 0.2ms (acceptable). If the café grows to > 150 slots, linear search is a risk.
- **Trigger:** Profile script time during semantic lookups (e.g., `find_best_chair`). If it exceeds 1ms on mobile, implement a spatial registry or grid-based caching system for slots.

## 4. Benchmark Scenarios
Construct explicit Godot test scenes for these scenarios and measure them on physical devices:
1. **BASELINE:** Home environment, daylight, no actors, no weather. (Tests static draw calls and base VRAM).
2. **NORMAL:** Busy actor load (11 actors), daylight. (Tests animation and navigation).
3. **EVENING BUSY:** Busy actor load, CanvasModulate night, 5 PointLight2D lamps on. (Tests 2D lighting passes).
4. **WEATHER:** Busy actor load, 200 CPUParticles2D rain. (Tests transparency overdraw and fill-rate).
5. **EVENT:** Busy actor load, Event layer visible, Event particles.
6. **CHARACTER STRESS:** 20 cats walking simultaneously in an empty room. (Isolates CharacterBody2D + AnimationPlayer cost).

## 5. Mobile Device Matrix
Tests must be executed on real hardware. Emulators and desktop profiles are invalid for GPU fill-rate and thermal throttling.
- **Tier 1: Low-End Android (Fallback Target)**
  - *Specs:* Snapdragon 4xx/6xx series, 3GB RAM, OpenGL ES 3.0 / Vulkan 1.0.
  - *Goal:* Verify 30 FPS fallback, ensure no Out-Of-Memory (OOM) crashes during Room Load.
- **Tier 2: Mid-Range Android (Standard Target)**
  - *Specs:* Snapdragon 7xx or Exynos equivalent, 4-6GB RAM.
  - *Goal:* Verify stable 60 FPS under NORMAL load.
- **Tier 3: High-End iOS (Enhanced Target)**
  - *Specs:* iPhone 13 or newer (A15+ Bionic).
  - *Goal:* Ensure 60 FPS under WEATHER/EVENING BUSY load with no thermal throttling/dimming after 15 minutes.
- **Tier 4: Older iOS (Legacy Target)**
  - *Specs:* iPhone 8 / iPhone X (3GB RAM).
  - *Goal:* Ensure memory footprint stays below iOS Jetsam limits (approx < 1.2 GB process total, < 300MB VRAM).

*(Unresolved Decision: The exact minimum supported OS versions for iOS and Android have not yet been locked by the production team. Define these before final QA).*

## 6. Real-Device Procedure Checklist
For every device in the matrix, perform this physical test:
1. **Cold Launch:** Measure time from tap to Home V3 loaded.
2. **Idle:** Let game sit for 2 minutes. Measure baseline memory and device heat.
3. **Normal Load:** Spawn 6 actors. Record FPS over 60 seconds.
4. **Busy Load:** Spawn 11 actors. Record FPS over 60 seconds.
5. **Atmosphere Shift:** Trigger Sunset -> Night. Turn on 5 lamps. Record frame-time spikes during light activation.
6. **Weather Shift:** Trigger Heavy Rain. Record GPU fill-rate impact (FPS drop).
7. **Decoration Mode:** Move 3 large furniture pieces. Record main-thread stall (hiccup) duration during nav rebake.
8. **Camera Focus:** Trigger `CameraDirector` sequence. Verify panning is smooth (no stutter).
9. **Sustain:** Leave on Evening Busy for 15 minutes. Check for thermal throttling (screen dimming, forced FPS drop).

## 7. Proposed Dev Performance HUD Fields
Implement a tiny, isolated `CanvasLayer` HUD (F3 toggle) for developers/QA, displaying:
- **FPS:** (e.g., 60)
- **Frame ms:** (e.g., 16.2 ms)
- **Physics ms:** (e.g., 2.1 ms)
- **Active Actors:** (e.g., 11)
- **Nav Queries/sec:** (e.g., 2)
- **Lights (Vis/Shadow):** (e.g., 5 / 0)
- **Particles:** (e.g., 150)
- **VRAM Est:** (e.g., 185 MB)
- **Draw Calls:** (e.g., 120)
