# Riverside art translation refinement V2 — DEV only

Open `Open_Riverside_Refinement_V2.command` to import and launch a **fresh temporary project**. Its main scene is `scenes/dev/riverside_refinement_v2/DEV_WILLICAT_RIVERSIDE_3D_ART_REFINEMENT_V2.tscn`. It inherits the exact V1 Vector2 actor/navigation/route implementation and only overrides presentation. V1 and production Home files are preserved.

Controls: click/tap the stone route; **Walk route** tours café → riverside → bridge → far bank → return; **Route debug** shows the authoritative DEV polygon; **NPC width** displays a second existing-art width proxy. This is not autonomous NPC gameplay.

Rebuild sources using Blender's background Python entry point and `blender_build.py -- --repo <repository> --out <fresh source output>`. Reuse the six existing painted texture sources; import GLB material slots through the V2 runtime. Build receipts record measured bounds and geometry provenance. Development dimensions and sway settings do not establish production geometry or motion tolerances.

Native tests: `capture_riverside_refinement_v2.gd`, `test_riverside_input_refinement_v2.gd`, `capture_riverside_matched_refinement_v2.gd`, `test_riverside_controls_refinement_v2.gd`. Pass an absolute temporary output directory as the Godot user argument. `test_riverside_launcher_refinement_v2.py` checks temporary path safety and byte-preserving intake.

Recommendation and human review remain in the V2 production result document. No production publishing, canonical Factory approval or world migration is performed by this launcher.
