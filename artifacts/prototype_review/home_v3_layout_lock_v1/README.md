# Home V3 Layout Lock V1 — human review map

All pictures are real Godot 4.7.2 viewport captures of the **accepted Staggered Salon** dev scene, not final art or composited mockups. `01_live_normal.png` and `02_live_debug.png` were taken in this lock task through the live GodotAI game connection. The earlier [Pass 01 evidence pack](../home_v3_level_design_pass_01/README.md) remains the authoritative state-by-state camera/actor/aspect evidence; it was not regenerated or altered for the lock. This folder is `.gdignore` and is not loaded as a runtime resource.

| Review need | Real viewport evidence | Annotated inspection note |
| --- | --- | --- |
| Canonical greybox / 9:16 layout | `01_live_normal.png`; [Pass 01 normal](../home_v3_level_design_pass_01/01_normal_9x16.png) | Back service, staggered Table A/B, distributed cat locations, central door and right event niche; do not treat primitive colors as final palette |
| Debug ownership | `02_live_debug.png`; [Pass 01 debug](../home_v3_level_design_pass_01/02_debug_slots_footprints_routes.png) | Red outlines are physical footprints; colored points are owned slots/approaches. Verify no art asks to move them. |
| Service visual grouping | [normal](../home_v3_level_design_pass_01/01_normal_9x16.png), [Brew](../home_v3_level_design_pass_01/05_brew_focus.png), [Cup](../home_v3_level_design_pass_01/06_cup_reveal.png) | Upper-left Counter/POS/Pastry and adjacent upper-right Espresso/Grinder should gain common cabinetry/wall/lighting language while remaining separate scenes. |
| Signature window | [normal](../home_v3_level_design_pass_01/01_normal_9x16.png), [Cat Emotion](../home_v3_level_design_pass_01/07_cat_emotion_focus.png) | Right-wall frame, WindowPerch and Plant form one emotional corner; keep cat at WatchSlot visible and allow quiet daylight/rain variants. Cat Emotion image itself focuses the **bed**, not the window. |
| Cozy bed | [Cat Emotion](../home_v3_level_design_pass_01/07_cat_emotion_focus.png) | Left-middle bed between service and first table needs visual shelter from low architecture/textile without a new obstruction. |
| Scratch architecture | [normal](../home_v3_level_design_pass_01/01_normal_9x16.png), [multi-actor](../home_v3_level_design_pass_01/03_multi_actor_9x16.png) | Left lower transition should gain wall/shelf-end context; keep cat ScratchSlot approach clear. |
| Event footprint and entry clearance | [Event focus](../home_v3_level_design_pass_01/08_event_state_9x16.png), [crowd](../home_v3_level_design_pass_01/04_crowd_five_customers.png) | Event is right of the central door/WaitSlots; an event skin may not protrude into that circulation lane. |
| Tall-phone | [tall normal](../home_v3_level_design_pass_01/09_tall_phone_normal.png), [tall multi-actor](../home_v3_level_design_pass_01/10_tall_phone_multi_actor.png), [tall event](../home_v3_level_design_pass_01/11_tall_phone_event.png) | Check complete room and event both fit; placeholder character size and final touch targets still need device review. |

## Reproduce

Open `res://scenes/dev/home_v3_level_design_pass_01.tscn` and run **Current Scene**. In the game press **F7** for debug ownership; **F9** for the accepted 1-worker/2-customer/3-cat demo, **F5** for crowd, **F10** for event. In-game **F6** recreates the full Pass 01 state pack. Review this folder's two live GodotAI captures against that pack and the [layout lock](../../../docs/design/WILLICAT_HOME_V3_LAYOUT_LOCK_V1.md). Do not edit the locked gameplay scene to make an art preview look prettier.
