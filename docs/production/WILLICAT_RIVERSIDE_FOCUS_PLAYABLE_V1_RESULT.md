# WILLICAT RIVERSIDE FOCUS PLAYABLE V1 — RESULT

Status: **DEVELOPMENT PLAYABLE PREVIEW COMPLETE**. No production publication or human visual acceptance of this new game/UI is claimed.

## Delivered slice

| Capability | Result |
| --- | --- |
| Task + duration | Optional task; 25/45-minute sessions; explicitly labeled 30-second demo |
| Session controls | Start, pause, resume, confirmed end; no penalty to earlier progress |
| Living companion | Existing orange protagonist walks along existing riverside markers during focus; rests on pause; completion reaction |
| Depth | Exact accepted tree/shadow, actor front/behind, existing trunk obstruction and navigation |
| Reward/notebook | One seed and one receipt per completed session; local durable aggregate + memories |
| Restart | Active deadline catches up; paused remaining time restores; settled receipt cannot mint twice |
| UI | Native Godot desktop and 480×960 portrait layout; primary/pause/end controls visible |
| Launch | Local helper makes an isolated Godot project and opens the playable preview |

Entry: [focus_retreat_v1.tscn](../../scenes/dev/focus_retreat/focus_retreat_v1.tscn). Instructions: [preview README](../../tools/willicat_focus_retreat/README.md).

## Verification

| Check | Observed result | Evidence |
| --- | --- | --- |
| Model, JSON command boundary, save/reload, rollback, recovery | **33/33 PASS** | `focus_test_results.json`, `focus_unit_tests.log` |
| Native runtime, actual 30-second timer, real buttons, actor movement, pause/resume, one reward, portrait and cancellation | **20/20 PASS** | `focus_runtime_proof.json`, `focus_runtime.log`, screenshots, `focus_playable.mp4` |
| Existing continuous Home route/service/save/navigation regression | **PASS** (one existing suite) | `home_regression.log` |
| Preview launcher path rejection | **4/4 PASS**; Python parses | `launcher_checks.json` |
| Protected existing files | **1677/1677 identical** to pre-task SHA-256 baseline | `protected_file_parity.json` |
| Reviewed tree bundle | Exact existing canonical bundle reused; no regeneration/compile | `focus_preview_receipt.json` |

Evidence root: [riverside_focus_playable_v1](../../artifacts/prototype_review/riverside_focus_playable_v1/).

Native tests recorded on Godot 4.7.2, OpenGL compatibility, Apple M2 Pro. Portrait is a desktop window layout test, **not** an Android/iOS device test. The movie/GIF encodes actual captured frames and recorded frame spacing; no staged empty-world substitute. Agent visual inspection covered desktop and active/completed portrait screens.

An earlier runtime capture failed the portrait primary-button visibility check. Layout and readable text were fixed before the final 20-check capture. The failed proof/check log is retained separately; it is not counted as a pass.

## Identity and authority

- Tree source SHA-256: `1428fdbe34eb90c819905f7ec4c2f985391c862c8c0510fe6018efca4ec6ba5a`.
- Existing accepted candidate/proof bundle SHA-256: `e1ebe7b7f26c390129cfd9209866fadd6960e4bdf1f48ea55c521330ad5cd13b`.
- Original tree source, reviewed motion/timing, canonical proof records, frozen Phase 0 contracts, style calibration, Home sources, project configuration, world transforms, navigation, anchors, colliders, save IDs and gameplay source files remain unchanged.
- New UI and visual reactions exist in additive development files and an isolated temporary world instance. The preview has its own camera framing, HUD and initial authored marker; it does not establish a new world authority.
- This new focus proof does not supersede the canonical tree proof or authenticate a production approval.

## Product boundaries and remaining work

This establishes a playable focus → world reaction → durable progress loop. It does not establish competitive superiority or retention; those require player testing.

Native Godot UI is used to validate the loop. React Native, WebView/mobile embedding, host background timing, notifications, accessibility/localization, app packaging, cloud sync and production economy are not implemented. The fresh installed launcher was exercised end-to-end and opened the native preview; its code hashes match the recorded proof. The import reports five inherited unused sample references with `Scripts`/`scripts` case mismatch, and no `SCRIPT ERROR`/`ERROR` entries. Those existing references were not modified; platform export needs a separate audit. See `launch_verification.log`.

The local notebook assumes a single writer and is not a security/anti-cheat ledger. Unrecoverable-save UI and bounded long-term history remain future work.

No authored Work/Sleep/barista animation was invented: the existing orange idle/walk views drive the companion. Existing terrain family seams/flat regions are inherited Mini Pack 001 limitations. This task creates no replacement art and grants no production visual approval to that environment.

Rights and authenticated production approval remain governed by the existing asset workflow. DEV use is available for the accepted pilot; production rights scopes/final credential requirements remain blocked. No production publisher was invoked. No source-art generation, commit, push, or React Native architecture replacement occurred.

## Next permitted step

Human playtest of this development preview: assess distraction, readability, session completion and the companion's emotional value. Then implement the chosen app host/bridge under explicit timer-authority and mobile lifecycle contracts. Production asset publication remains a separate gated action.
