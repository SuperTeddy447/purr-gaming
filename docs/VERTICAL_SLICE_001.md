# Vertical Slice 001 — manual check

Open the WilliCat project in Godot 4.7 and run the project (F5). The HomeScene starts the café loop automatically. Watch the customer enter, reach Seat A, order coffee, receive service, earn a 5-coin callout, and leave. The next customer arrives after a short cooldown. No input is required.

To run only one cycle, select `HomeScene/VerticalSliceController` in the scene editor, turn off `Auto Repeat Slice` in the Inspector, and run again. `Start On Ready` can be turned off to prevent automatic startup. These are development options, not a player-facing menu.

Press F1 or D for the debug view. It shows cycle number, customer/worker states, active order, prototype coins, and movement target. Press F1 or D again to return to the clean view. R toggles the clean V2.1 reference art; Space resets the camera. Pan and zoom with mouse drag/wheel or touch drag/pinch throughout the loop.

To restart from zero coins and the first customer, stop the running game and run the project again. The coin counter is session-only and is not saved.

The V2.1 backdrop is still development reference art; its baked-in characters are not gameplay actors. The moving cat/customer placeholders, order bubble, worker action label, and reward callout are runtime elements and temporary art.
