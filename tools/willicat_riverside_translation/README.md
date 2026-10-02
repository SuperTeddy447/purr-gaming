# Isolated Riverside 3D translation DEV proof

Double-click **Open_Riverside_Translation.command**. It copies the minimal required first-party resources into a fresh `/private/tmp/willicat_riverside_dev_…/project`, imports them and opens native Godot. Production Home and its save files are not loaded.

Requires the existing native Godot at `/Applications/Godot.app/Contents/MacOS/Godot`; verified with 4.7.2 and desktop Metal Mobile renderer. No new packages or plugins are installed.

Controls: click/tap the stone route to walk; **Walk route** runs café → river → bridge → continuation → return; **Route debug** toggles the DEV navigation outline; **NPC width** shows a second copy of existing orange art for scale only, not an authored new NPC.

```sh
python3 tools/willicat_riverside_translation/run.py --prepare-only --project /private/tmp/riverside_new_review/project
/Applications/Godot.app/Contents/MacOS/Godot --headless --editor --import --path /private/tmp/riverside_new_review/project --quit
/Applications/Godot.app/Contents/MacOS/Godot --path /private/tmp/riverside_new_review/project --rendering-method mobile --rendering-driver metal
```

Native diagnostic/evidence scripts copied by intake:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path /private/tmp/riverside_new_review/project --rendering-method mobile --rendering-driver metal --script res://tests/capture_riverside_translation_v1.gd -- /private/tmp/riverside_new_capture
/Applications/Godot.app/Contents/MacOS/Godot --path /private/tmp/riverside_new_review/project --rendering-method mobile --rendering-driver metal --script res://tests/test_riverside_input_depth_v1.gd -- /private/tmp/riverside_new_depth
python3 tests/test_riverside_launcher_v1.py
```

Evidence output destinations in these examples are temporary. These are development diagnostics, not Asset Factory canonical candidates, integration proofs, human approvals or production publication.

Editable `.blend` and exported geometry receipts: `assets_src/3d/riverside_translation_v1/`. Runtime GLBs: `assets/dev_review/riverside_translation_v1/glb/`. The build recipe composes the existing first-party Café Blender helpers. Use Blender only for an explicitly authorized new revision; playback does not rebuild geometry.

Existing painted texture PNGs and canonical protagonist sheets are consumed unchanged. Geometry dimensions are prototype authoring choices, not production Home measurements or family calibration. Existing gameplay data, navigation, semantic IDs and save namespace remain unchanged.
