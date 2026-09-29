# WilliCat Home V3 — Level Design Pass 01

Status: **ACCEPTED for spatial layout lock** by human review; **not** production Home cutover or final art approval. This is the historical Pass 01 evaluation; the [Layout Lock V1](WILLICAT_HOME_V3_LAYOUT_LOCK_V1.md) is now the formal spatial contract. Godot-authored object transforms, slots and footprints remain authoritative. Baseline: `scenes/dev/home_v3_world_authoring_lab.tscn`. Accepted scene: `scenes/dev/home_v3_level_design_pass_01.tscn`.

## Intent and baseline

The locked world architecture already passes its structural gates. This pass changes **where** reusable objects live, not how semantic interactions work. The prior 640×1320 greybox visibly stacked service, seating, cat life and event into four full-width color bands. CatBed/Plant/ScratchPost formed a separate pet zone, the entrance had one dominant spine, and Brew/Emotion shots exposed weak composition. The baseline real viewport is preserved in `artifacts/prototype_review/home_v3_level_design_pass_01/00_before_architecture_lab.png`.

## Three considered arrangements

| Direction | Strengths / camera opportunity | Weakness / choke risk | Cat-life and future decor |
| --- | --- | --- | --- |
| **A. Staggered salon with perimeter moments** (selected) | Service stays legible at the back while two seating islands stagger diagonally; Espresso moves lower to improve Brew/Cup framing; window nook becomes a visual anchor | Must keep chair/table gaps and entrance waiting pockets clear; left rest nook may still bias emotion framing | Bed sheltered off the first seating island, plant/window near table, scratch near entry wall; several open floor pockets remain movable |
| B. Right-wall service gallery | Short worker path between machines; broad left seating field, good large event wall | Customers crossing to OrderPoint would intersect the dominant entry lane; service/window compete for right edge | Cats can use left perimeter but activity is less visible with customers |
| C. Central counter island | Strong all-around worker silhouette and dramatic focal object | Four-way cross-traffic and a narrow portrait viewport make seat/serve paths fragile; event furniture has little slack | Cats can orbit island, but protected rest and movable decor become harder |

Direction A was chosen because it distributes daily-life opportunities without making the counter or door an obstacle island. It also preserves a readable service destination from the entrance while allowing two seating clusters to appear as one café, not a customer system next to a cat system.

## Authored composition

Pass 01 is an inherited **dev scene**, not a production Home replacement. Its floor is one continuous neutral field. The counter, POS and pastry occupy a shallow back-left work bay; Espresso and Grinder make an adjacent back-right preparation bay. Two table/chair groups stagger diagonally through the middle. A protected bed sits between service and the first table, while the perch and plant sit in the right window corner. ScratchPost is on the left entrance-side transition. The event niche is on the right before the door, outside the central entrance lane. Three semantic WaitingSpots distribute temporary customer holding positions near the entrance without visible production markers. No final illustration or Home V2 coordinate reconstruction is involved.

The service-to-seating and seating-to-entry rhythm remains vertical for portrait readability, but the partial work bays, offset tables and perimeter cat activities remove the four full-width horizontal test bands. Original objects, IDs, slots, footprints and reusable actor behavior remain owned by the same architecture.

## Actor flows and crowd result

- **Worker:** Counter/Serve and Espresso/Grinder/Pastry are adjacent, visually legible actions. Existing semantic `work_coffee` and `serve` requests succeed; Brew and Cup still come from the object-owned machine anchors.
- **Customers:** Door to waiting pockets to counter OrderPoint to four chair-owned seats to exit passes with no hard-coded actor destinations. The two seating islands leave a center lane and perimeter access rather than one long table wall.
- **Cats:** Three simultaneous activities pass at bed, plant and scratch. WindowPerch is against a visible window placeholder, now a credible watch corner. Bed is sheltered beside the first table rather than isolated in a separate cat zone. Cat and seated-customer coexistence is visible in the multi-actor/crowd frames.
- **Crowd:** The development sanity uses one worker, five customers and three cats. Entrance and OrderPoint capacity correctly reject a second simultaneous claim; four seats fill and the fifth waits for release. All five customers subsequently leave, reservations clear and no temporary actors remain. This is a small sequential-flow/capacity proof, **not** a queue simulation or performance benchmark. Crowd screenshot `04` shows the transient five-customer staging, not five seated customers at once.
- **Navigation:** Pass 01 rebakes with the real 15 obstructions (16 while the event is active). Normal demo, crowd, and post-move actor reacquisition passed with no reported navigation failure. We did not remove footprints or change generic actor route code.

## Camera, event and decoration review

World view, Brew, Cup, Cat Emotion and Event focus were captured from the running Godot scene. The close-up Brew/Cup zoom is authored as Pass 01 scene configuration (3.25/3.45, versus unchanged base defaults 2.45/2.65), while focus targets stay on Espresso-owned markers. This brings Worker, machine and cup into one readable middle section with less dead space; it does **not** approve final production camera values. Cat Emotion places the bed/cat away from the hard left edge and retains table/service context. Event Focus shows the seasonal display as a room-side niche, not an empty bottom strip. Automated checks confirm all focus shots restore the exact previous gameplay camera position and zoom.

Event-off/on toggling keeps the door and central route open and makes `seasonal_display` discoverable only while active. The same object keeps its `InspectSlot`, FX and camera anchor. A chair and CatBed were moved/rotated to other valid nearby placements; their owned anchors followed, navigation rebaked and customer/cat actors reacquired them. This supports future furniture movement, but it does not prove unrestricted Decor Mode placement.

The 9:16 and tall-phone full-viewport captures retain the entrance, seating, service, cats, window and event niche. Nothing important enters the top/bottom HUD strip in the reviewed views. The tall view exposes more vertical margin; it does not reduce the room to a narrow corridor. The scene's greybox labels are intentionally small and some labels overlap at the bed and door; those are dev-review limitations, not art or gameplay approvals.

## Known limitations and decision

Placeholder actors are not character-scale approvals. Greybox outlines show spatial grouping, but actual 3/4 object silhouettes, counter front/character occlusion, tablet/phone legibility and touch targeting still require the later art/device review. The crowd proof demonstrates capacity and eventual release, not natural multi-customer queuing. The left bed corner is improved but Cat Emotion framing may need human taste review; Brew/Cup are better centered but could still be composed differently once real registered art exists. No V2 production Home scene was migrated.

**Review outcome:** human review accepted the Staggered Salon direction and authorized formal Layout Lock V1. The known visual/device limitations remain future art-validation gates, not grounds to reopen the broad layout. Compare the before image with normal/debug/multi-actor/camera/event/tall images in `artifacts/prototype_review/home_v3_level_design_pass_01/README.md`. Production cutover remains separately gated.
