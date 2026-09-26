# Home Functional Prototype V1

This is a temporary graybox playtest of the existing Home and Vertical Slice 001. It adds no final art, inventory, recipes, or parallel gameplay state machine. The Home starts in **PROTOTYPE MANUAL** mode; **F7** switches between manual interaction and the automatic regression loop.

## Development shortcuts

- **F7** — toggle PROTOTYPE MANUAL / AUTO LOOP.
- **F8** — toggle centralized NORMAL / FAST prototype timing presets.
- **F1 / D** — existing debug view; when active, world hit areas and modular-slot inspection details are visible.
- **F6** — toggle the locked Visual Master comparison.
- **R** — existing V2.1 reference comparison.
- **F2–F5** — Mochi test positions (WorkerIdle, CoffeeAction, ServePoint, Open Floor; debug view only).
- **1 / 2 / 3** — Mochi scale tests (Small, Target, Large; available with debug on or off).
- **Z / X / C / V** — camera tests (default, effective minimum, ~1.2×, maximum; debug view only).
- **Mouse wheel** — camera zoom. **Drag** — pan. **Two-finger pinch** — zoom.

## Prototype timing

The shared timing resource is `data/home_prototype_timing.tres`: arrival pause 0.18 s, seated-to-order pause 0.8 s, coffee preparation 2 s, serve 0.45 s, served reaction 1.3 s, customer exit pause 0.18 s, door hold 0.35 s, door transition 0.18 s, and next-customer delay 3 s. F8 selects FAST at 0.20× duration for repeated checks. Coffee timing no longer lives on the order identity.

## Manual playtest checklist

1. **A.** Launch the default Home scene.
2. **B.** Keep Debug View OFF; the customer/order cues and bottom-line interactions should remain understandable without debug labels.
3. **C.** Watch a customer enter; confirm the entrance opens and closes after the threshold crossing.
4. **D.** Tap/select the seated customer and confirm the temporary Coffee Order bubble is associated with them.
5. **E.** Tap Espresso Station; before an order exists, verify the “No active coffee order” feedback and no state change.
6. **F.** Watch Mochi walk to CoffeeAction behind the counter.
7. **G.** Watch the short brew progress cue on Espresso Station.
8. **H.** Confirm the cup placeholder appears and follows Mochi to ServePoint.
9. **I.** Tap the customer or ServePoint to serve.
10. **J.** Confirm one reward callout and one coin increase only.
11. **K.** Watch the customer react briefly, then leave through the entrance.
12. **L.** Confirm the door returns to CLOSED.
13. **M.** Confirm Mochi returns to WorkerIdle and the cup/order bubble disappear.
14. **N.** Repeat the manual loop for three customers; confirm seats A–D are released and reused without overlapping customers.
15. **O.** Drag across/near Espresso Station and nearby props; a camera pan must not trigger an object action.
16. **P.** Pinch zoom over interactable objects; zoom must not select them.
17. **Q.** Check Mochi/customer depth at the counter and around tables; use the existing debug geometry to inspect table/counter occlusion.
18. **R.** Toggle F6 to compare the current modular café with the locked Visual Master, then return to the mock.
19. **S.** Repeat on each available aspect profile; note any touch-target overlap or blocked readability before changing the layout.

For an unattended timing check, press **F7** for AUTO LOOP. It uses the same customer, worker, order, movement, serving, reward, seating, door, and reset states as manual mode.

## Human visual review notes

No café markers or major props were repositioned. Touch regions use a 52 px minimum in viewport space and tighter object regions win when hit areas overlap. Please visually check those regions and the temporary cup/order cues on a device; if targets feel crowded, adjust their semantic hit sizes before considering any room-layout change.
