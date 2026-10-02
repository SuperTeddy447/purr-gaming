# WilliCat Asset Factory MVP + Tree Pilot V1 — development diagnostic result

**2026-09-30. Scope: explicitly authorized DEVELOPMENT-ONLY DIAGNOSTIC PROOF PATH.** The frozen Phase 0 contracts remain authoritative and unchanged. This is a completed engineering/evidence slice, **not** a canonical candidate, canonical integration proof, approved release or production publication.

## Status

| Requested report item | Result |
|---|---|
| IMPLEMENTATION | **PASS — authorized DEV diagnostic slice** |
| STRUCTURAL DIAGNOSTIC | **PASS** |
| MOTION MEASUREMENTS | **RECORDED** |
| GODOT DIAGNOSTIC | **PASS** |
| STYLE SELF-QA | **PASS — agent observation only** |
| HUMAN TECHNICAL-ANIMATION REVIEW | **PENDING** |
| HUMAN ART-LEAD REVIEW | **PENDING** |
| CANONICAL CANDIDATE COMPILATION | **BLOCKED PENDING REQUIRED HUMAN REVIEWS** |
| CANONICAL INTEGRATION PROOF | **NOT YET EXECUTED** |
| PRODUCTION | **BLOCKED** |

The last completed canonical stage is `structurally_validated`; the current manifest is `human_hold`. `motion` and `visual` are `pending`; `runtime` and `human` are `not_started`. Measurements have not been converted into calibrated policy results. The profile's technical animator → art lead review order is preserved.

## Review first

All links point into the new [diagnostic artifact folder](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/).

| Evidence | Review purpose |
|---|---|
| [Moving character/tree MP4](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/evidence/DEV_DIAGNOSTIC/DEV_DIAGNOSTIC_moving_actor_tree.mp4) / [GIF](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/evidence/DEV_DIAGNOSTIC/DEV_DIAGNOSTIC_moving_actor_tree.gif) | Actual Godot viewport frames: actor walks from front to behind and returns; tree animates continuously. Not an empty-scene proof. |
| [Actor depth contact sheet](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/evidence/DEV_DIAGNOSTIC/actor_depth_contact_sheet.png) | Front, crossing, canopy occlusion and final behind pose. |
| [Source-speed loop](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/evidence/scene_speed_loop.gif) / [APNG](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/evidence/scene_speed_loop.apng) | Root/canopy motion on a fixed neutral canvas; ordered nonuniform holds. |
| [Frame contact sheet](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/evidence/animation_contact_sheet.png) | Frame identity and duration labels. |
| [Root/baseline overlay](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/evidence/root_baseline_overlay.png) | Pivot, baseline and pixel-identical lower trunk region. |
| [Motion measurements](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/evidence/development_motion_evidence.json) | Every frame: canopy centroid, alpha area, bounding box, ground contact, root identity and timing. |
| [Diagnostic runtime receipt](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/evidence/diagnostic_runtime_proof.json) | Exact logical resource/member parity, rendered pixel comparisons, loaded timing, actual movement and world projection parity. |
| [Human-hold manifest](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/human_hold_manifest.json) | Current frozen stage/profile data and pending gates. |

Video is 20 captured frames/second; GIF is a 12-frame/second derivative. Rendered comparison intervals freeze the pose and are excluded from the moving sequence. Frame timing observations are engine-time observations; intentional comparison pauses are not motion-policy evidence. Contact sheets/overlays are diagnostic composites, not fabricated Godot captures. The full route is recorded as observations even where the camera remains on the tree.

## Implemented boundary

New tooling: [tools/willicat_asset_factory_mvp](../../tools/willicat_asset_factory_mvp/README.md).

| Component | Implemented responsibility |
|---|---|
| Local attempt/store | Write-once source, journal and evidence; UUID attempt identity; atomic, serialized current/index pointers; failed command records; no production-root write capability. |
| Read-only specification/template/style lookup | Frozen Phase 0 validation; approved `WILLICAT_JAPANESE_RIVERSIDE_STORYBOOK_V1` version `1.0.0`; authority-derived registration; relevant projection hash. |
| Manual first-party intake | Immutable original PNG, exact prompt/generation receipt, source/prompt hashes, template ID/version binding and action-specific DEV authorization evidence. |
| Forge composition | Existing alpha-aware `resize_frame`, RGBA normalization and explicit grid extraction; exact extraction/atlas round trip. Existing Forge is not replaced or modified. |
| Tree recipe | Explicit foliage-led horizontal row bending, fixed lower trunk, asymmetric authored travel/holds, transparent canvases and separate static shadow. |
| Deterministic diagnostics | Schema, canvas/alpha/frame/duration checks; source/atlas hashes; root/baseline measurements; duplicate/seam reporting; live integrity checks. |
| Preview/evidence | Contact sheet, registration overlay, GIF/APNG, actual Godot MP4/GIF/keyframes and per-frame observations. |
| Isolated Godot preparation | Byte-copy existing tracked world/gameplay files; same logical `res://` bundle paths; separate diagnostic user directory; unresolved proxy pixels suppressed. |
| Catalog | Rebuildable DEV index; source/registration/stage/gate facts; no production-approved pointer. |

`compile` and `publish` explicitly block. Canonical compilation/proof and production publishing are deliberately unavailable in this DEV slice. **Implementation PASS does not mean every future Factory component is implemented.** Provider adapters, authenticated review intake, protected publisher, release/rollback service and all other categories remain deferred. No skill or MCP integration was created.

## Geometry and source traceability

The technical template was extracted **before source creation** from the existing Home tree registration. These are observed existing values, not newly selected geometry or motion limits:

| Registration fact | Existing authority / measured interpretation |
|---|---|
| Stable tree | `river_depth_tree` at existing world `(-320,1270)` |
| Source canvas | `512×640` |
| Ground pivot / baseline | `(256,600)` / `600` source pixels; centered canvas plus existing offset maps to GameplayRoot contact |
| Sprite placement | Existing scale `0.4`, offset `(0,-112)` |
| Shadow placement | Existing offset `(0,-5)`, scale `0.32`, alpha `0.38`; separate first-party Mini Pack 001 contact-shadow texture |
| Obstruction | Existing `TrunkFootprint`, size `28×26`, with existing collision/nav relationships; not resized to fit art |
| Relevant projection | `578bf3741f2850400053cec1fad10158927711e95410079376a5482f7593c150` before/after |

The raw generated tree is `1246×1262`. Its complete visible anatomy is inside the source borders at alpha >1; observed alpha-1 noise touches two borders. Only that near-zero fringe was removed in normalization, with the immutable raw PNG retained. The crop was fitted to the **existing** alpha extent budget and registered to the existing ground anchor; no world object was moved.

Source was generated once using builtin `image_gen`, **original text only**. No reference PNG or third-party art was supplied to generation. Approved calibration material/palette/projection rules supplied textual visual input. Model and cost were not exposed by the tool and are not invented. Source receipt identifies the tool/generation ID, exact prompt hash, template pin and no-reference inputs. Source hashes are unchanged after processing.

Receipts pin actual Factory/Forge code hashes, Git HEAD, recipe, dependency inventory/environment fingerprint, Python/Pillow/NumPy/jsonschema/Godot versions, raw-file/decoded-pixel hashes and outputs. Ordinary operator provenance is **not authenticated human approval**.

## Motion calibration evidence — measured, not calibrated

| Measurement / authored input | Recorded value |
|---|---|
| Frames | `23`; chosen pilot authoring samples, not a quality quota |
| Ordered `durations_ms` | `[200,120,100,100,100,120,140,190,120,110,100,90,90,90,110,160,210,160,130,110,100,160,220]` |
| Loop duration | `3030 ms` |
| Root displacement | `0 px` across the pixel-identical lower trunk region |
| Trunk/base displacement | `0 px`; baseline bottom visible row remains `599`, source baseline `600` |
| Lower trunk lock region | `[0,480,512,640]`; recipe-specific observation, **not** a universal tree template or drift tolerance |
| Canopy alpha-weighted X centroid range | `250.2288155329033` to `255.33382885564993` source pixels |
| Overall bounding-box X extent across frames | `22` to `485` source pixels; per-frame boxes retained |
| Alpha-equivalent silhouette area range | `108497.79215686275` to `108498.37254901961` pixels; interpolation/rounding variation, not a scale animation |
| Loop endpoint difference | Maximum channel delta `0`, changed pixels `0` |
| Duplicate frames | Intentional rest/seam endpoints `[0,22]`; no inferred missing timeline frames |
| Shadow drift | `0`; separate static shadow and unchanged runtime transform |
| Runtime transform drift | Tree, sprite and shadow transforms identical across captured samples |
| Whole-sprite scale pulse | Not applied; row translation only, no vertical/global scale transform |

Timing is encoded through the existing frozen Phase 0 Forge wrapper: speed `1000`, exact integer millisecond frame weights. Godot loaded all 23 weights exactly and actual frame playback advanced through every frame. No uniform-FPS fallback was used.

The motion recipe uses an asymmetric push, ease, hold, smaller return/overshoot and settle. Canopy carries most translation while the lower trunk remains unchanged. It does not provide independently authored leaf flutter or botanical simulation. Frame count, zero root drift, near-constant area and identical endpoints **cannot approve perceptual motion quality**.

All four canonical policies (`root_drift`, `baseline_drift`, `scale_drift`, `loop_seam`) remain `CANDIDATE_REQUIRES_CALIBRATION`. Technical animator must review `foliage_led_sway`, `no_whole_sprite_scale_pulse`, `readable_authored_arc`, and `seam_perceptually_continuous`, and an independently authorized calibration decision is still needed for numeric policy limits.

## Godot diagnostic findings

- Real rendered viewport, `960×640`, Godot `4.7.2.stable.official.ed1daf0bf`; 135 captured frames. PNG sequence is disposable temporary capture cache; review MP4/GIF/keyframes are retained.
- Original orange actor uses existing Mini Pack 001 first-party directional movement visuals. No character redesign or identity approval is asserted.
- Eleven successful existing-marker legs cover Café → Front Plaza → Riverside → Back Garden → Café, including front/behind/return tree crossings. Actor uses existing navigation, no teleport or invented marker coordinates.
- Actual before/behind rendered comparisons demonstrate Y-sort/occlusion. Pixel contributions include soft foliage alpha and are **not** a perceptual visibility score or approval threshold.
- Trunk obstruction/navigation and relevant authority projection remain unchanged. Production Home files/resources are not edited or hot-swapped.
- Only first-party world art is visible. Thirty-six existing unresolved DEV proxy textures are replaced by same-dimension transparent diagnostic textures **in the temporary copy only**; no proxy rights clearance is inferred and no third-party raw pack is added to the repository.
- New tree bundle imports independently with **zero errors**, exact path/member parity and actual resource playback. The generic copied project also imports legacy sample WAV files, which emit three nonblocking `file_access_memory.cpp:seek` messages. A WAV-only import probe reproduces all three; the tree-only import probe does not. Original sound files are left unchanged. Diagnostic runtime and final gameplay regressions contain no `ERROR`/`SCRIPT ERROR` messages. Whole-project importer cleanliness is not claimed.

## Agent visual self-QA

[Recorded self-QA](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/evidence/agent_visual_self_qa.json) is **development_visual_evidence**, not a human art-lead or animator decision.

| Check | Agent observation |
|---|---|
| Projection/material/palette | Layered elevated-3/4 illustrated broadleaf tree; restrained moss/sage foliage and warm wood; no strict isometric grid or mandatory jade treatment. |
| Source lighting | Matte reusable shading, no ground plane/cast-shadow baked into source and no dramatic environmental spotlight. |
| Root/shadow | Registered fixed root, separate contact shadow, no frame-to-frame base crawl in overlays or rendered samples. |
| Silhouette/detail | Grouped foliage masses and readable trunk at gameplay zoom; visible canopy overlap with the moving actor. |
| Motion | Authored horizontal canopy arc, asymmetric timing, unchanged lower trunk and no obvious whole-tree expansion/contraction in compared frames. |
| Context limitation | Existing Mini Pack 001 world remains a gameplay scaffold, **not** approved visual authority. Its terrain blocks, wall issues and other tree animations were not fixed by this pilot. |

Self-QA PASS is bounded to obvious engineering/style defects in this original pilot. Technical animator and art lead retain independent veto; mobile performance, species-specific animation refinement and production atlas packing remain unvalidated. Diagnostic atlas is `11776×640`; successful desktop import is not a mobile texture-budget approval.

## Verification and retained failures

| Verification | Actual result / limitation |
|---|---|
| MVP tests | **27/27 passed**, per-case receipt and final code hashes retained |
| Frozen Phase 0 tests | **80/80 passed**; existing projection/timing/import spike receipts were copied as regression fixtures, not represented as newly rerun Phase 0 spikes; signing fixtures are explicitly TEST ONLY and temporary keys were destroyed |
| Asset Forge tests | **62/62 passed**; Forge implementation unchanged |
| Existing Home continuous regression | Passed in final isolated copy: connected route, service/progression, furniture/nav behavior and save/load |
| Existing proxy café regression | Passed in final isolated copy |
| Existing true vertical slice regression | Passed in final isolated copy |
| Tree-only import | Exit `0`, no error messages |
| Live artifact/schema checks | Passed; exact source/atlas hashes, current human-hold pointer, frame/duration consistency |
| Protected files | All **1492** baseline tracked/frozen/style files retain their original SHA-256 hashes |

Early failures were diagnosed and fixed, with logs retained: denied initial sandbox user-directory creation, incomplete isolated proxy dependencies, floating-point timing comparison, missing regression-fixture/environment inputs, missing legacy startup references, and a NumPy boolean rejected by canonical JSON. No failed attempt was marked canonical PASS. Legacy sound importer messages are separately recorded, not hidden or attributed to the tree.

## Human handoff / stop

1. **Technical animator:** review source-speed loop, root/canopy measurements, actual moving-actor evidence and required subjective criteria; decide calibration separately without deriving thresholds automatically from this one pilot.
2. **Art lead:** review original tree against approved style calibration after frozen motion prerequisites; accept/reject/request revision independently.
3. Canonical candidate compilation remains blocked. DEV artifacts cannot be relabeled `candidate_bundle` or `integration_proof`; the later canonical compile-once → prove → approve → publish cycle requires its own satisfied prerequisites and exact bundle identity.
4. Production remains blocked by required review, calibrated policies, exact action-scoped rights and production authentication/publisher requirements. No real signing credential, authenticated asset approval, approved bundle, release or rollback was created.

**No frozen contract, existing scene, navigation, world coordinate, interaction slot, save ID, original PNG, existing Forge module or approved style calibration was modified. No Mini Pack 002, provider adapter, skill, commit or push.**

**TREE PILOT READY FOR HUMAN VISUAL/MOTION ACCEPTANCE — DEV DIAGNOSTIC EVIDENCE ONLY.**
