# WilliCat Riverside Focus — playable development preview

A timer companion vertical slice, using the existing continuous Home and the exact accepted animated tree bundle. Native Godot UI; no React Native/WebView bridge or mobile package is implemented here.

## Play

From `/Users/teddywoot/willi-cat`:

```sh
tools/willicat_asset_forge/.venv/bin/python tools/willicat_focus_retreat/run.py
```

Requires the existing Forge Python environment and Godot at `/Applications/Godot.app/Contents/MacOS/Godot`. Preparation copies an isolated project into `/private/tmp`, verifies the current canonical tree receipt, imports the disposable copy, and opens the preview. It does not change `project.godot` or publish assets.

Choose **25 min**, **45 min**, or **Demo 30s**; optionally enter a task; select **Start focus**. Willi walks between the existing riverside navigation markers. **Pause session** freezes remaining time and stops Willi; **Continue focusing** resumes. Completion adds one local seed and one notebook receipt. **End this session** asks for confirmation and does not award a seed for an unfinished session. Demo seeds belong only to this preview.

The notebook is stored in the separate Godot user namespace `WilliCatFocusRetreatPreviewV1`, as `willicat_focus_retreat_dev_v1.save`. Closing and reopening preserves active/paused sessions and settled receipts. Running sessions continue against their deadline while closed. This is a single-process, local notebook, not an authenticated economy or cloud sync service. Do not run multiple preview instances against the same notebook.

Corrupt primary saves fall back to a checksummed previous snapshot. If neither copy validates, the preview retains the files and blocks updates; an interactive recovery flow is not implemented. Storage failures roll back the in-memory change and do not emit reward/world events.

## Boundaries

| File | Responsibility |
| --- | --- |
| `scripts/dev/focus_retreat/focus_session.gd` | State, deadlines, pause/resume, command deduplication, completion receipts |
| `scripts/dev/focus_retreat/focus_service.gd` | Serialized command intake, checksum/readback, temporary file + backup + rename, committed events |
| `scripts/dev/focus_retreat/focus_companion.gd` | Consume committed events; orange actor navigation; exact reviewed tree/shadow attachment |
| `scripts/dev/focus_retreat/focus_retreat.gd` | Native UI, responsive layout, separate world viewport |
| `scenes/dev/focus_retreat/focus_retreat_v1.tscn` | Additive preview entry scene |
| `tools/willicat_focus_retreat/run.py` | Read-only repo intake; isolated project preparation and launch |

Transport-neutral JSON command example:

```json
{"protocol_version":1,"request_id":"unique-operation-id","action":"start","duration_s":1500,"task":"One meaningful thing"}
```

`pause`, `resume`, and `cancel` additionally require the exact current `session_id`. JSON fractional durations, stale session commands, unsupported reward commands, and overlapping sessions are rejected. `snapshot` reads the current state. Events include `focus_started`, `focus_paused`, `focus_resumed`, `focus_cancelled`, and `session_complete`. A future app host must choose its timer/persistence authority explicitly; this preview does not establish React Native background-execution behavior or a bridge implementation.

The existing Home coordinates, colliders, semantic slots, save IDs, and navigation sources remain unchanged. The new scene uses an existing authored initial marker, suppresses the old HUD/input and unrelated actors in its own instance, and frames its own viewport. The accepted tree's source pixels and nonuniform 23-frame motion remain unchanged. Other unapproved ambient trees are held at their existing rest frames in this view.

Unresolved third-party proxy textures are suppressed with transparent same-size placeholders by the existing proof preparation routine. Existing first-party terrain/river/character visuals remain development context; the known Mini Pack 001 terrain edges and mixed family quality are not declared visually production-ready. No third-party raw packs are added.

## Verify

Create an isolated project without launching it:

```sh
tools/willicat_asset_forge/.venv/bin/python tools/willicat_focus_retreat/run.py --prepare-only --project /private/tmp/willicat_focus_check/project
```

Use a **new**, nonexistent destination under `/private/tmp`. Traversal, existing destinations, and symlink escape outside that root are rejected.

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /private/tmp/willicat_focus_check/project --editor --import --quit
/Applications/Godot.app/Contents/MacOS/Godot --headless --path /private/tmp/willicat_focus_check/project --script res://tests/test_focus_retreat_v1.gd -- /private/tmp/focus_tests.json
/Applications/Godot.app/Contents/MacOS/Godot --path /private/tmp/willicat_focus_check/project --script res://tests/capture_focus_retreat_v1.gd -- /private/tmp/focus_capture
```

Use a fresh capture directory so the capture's isolated test notebook cannot reuse old receipts. The native capture exercises real buttons and the real 30-second timer, records actor/tree traces, then tests portrait controls and cancellation. It never writes the player's preview notebook. It is development gameplay evidence, not canonical asset integration approval or production authorization.

## Remove / roll back

Close the preview and discard its disposable project. The original repo main scene remains unchanged. Remove only these additive preview files if desired; keep review evidence. Delete the separate user notebook only if deliberately resetting preview progress. Do not alter the accepted tree bundle or its approvals.
