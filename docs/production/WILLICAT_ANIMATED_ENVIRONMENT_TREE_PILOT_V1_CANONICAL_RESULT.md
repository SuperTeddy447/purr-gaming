# WILLICAT ANIMATED ENVIRONMENT TREE PILOT V1 — Canonical Candidate and Integration Proof Result

Date: 2026-09-30. Scope: the existing reviewed pilot, canonical DEV-rights candidate/proof, no production publication.

## 1. Human technical-animation review binding

**APPROVED by the direct human decision in this task.** Recorded after the historical hold, before art-lead review, under the unchanged frozen review order.

| Pin | Exact identity |
|---|---|
| Asset | `willicat_tree_pilot_dev_01` / `1-dev` |
| Attempt | `DEV_DIAGNOSTIC_tree_5e47090652224f75a183823ebc8581cc` |
| Original tree source SHA256 | `1428fdbe34eb90c819905f7ec4c2f985391c862c8c0510fe6018efca4ec6ba5a` |
| Reviewed atlas SHA256 | `23bf60755c402586010952a929a802ad30bd9b58c5e0cfb7f3850eabbfe679e6` |
| Template | `tree_dev_diagnostic_home_registration_v1` / `1` |
| Style | `WILLICAT_JAPANESE_RIVERSIDE_STORYBOOK_V1` / `1.0.0` |
| Measurement evidence SHA256 | `df08f5c8c949f59aa2dc21738718e482df3deae0517d1b89790bbc8e7e0eeaf3` |
| Decision binding SHA256 | `e578b1b9392024148357abc06301428b6f821d8d31ed582e1d1e0bdc277d6d00` |
| Technical review SHA256 | `5f0586ba6351e11fc02f4ebaa3ed90a4756f77b2ef1f16b095f7c1615cb0cc72` |

Required criteria `foliage_led_sway`, `no_whole_sprite_scale_pulse`, `readable_authored_arc`, `seam_perceptually_continuous` are approved from that explicit human decision, not inferred from numeric checks. The binding also pins the old diagnostic proof and immutable reviewed manifest.

These early role reviews record the direct trusted human conversation. Their local hashes are tamper-evident metadata, **not an authenticated production credential/signature**. Final `human` approval is absent.

## 2. Pilot-specific motion calibration binding

**APPROVED for this exact tree/attempt only.** Policy version: `tree-pilot-v1-exact-observation-calibration-1`. Calibration record SHA256: `85067db9949ee8d111f51557539a0b79b2e4f62ae4cd1c533bb3a0623d65ca0c`.

The existing recorded measurements were reproduced from the existing individual frame PNGs and compared byte-for-byte with the reviewed measurement record. The custom motion policy checks exact accepted observation/source/atlas/animation identity; it does not introduce a family-wide inequality or new numeric tolerance.

| Existing accepted observation | Value |
|---|---|
| Frames / loop duration | 23 / 3030 ms |
| Root displacement | 0 source px |
| Trunk/base displacement | 0 source px |
| Locked pixel region | `[0,480,512,640]` |
| Shadow drift | 0; separate static contact shadow |
| Visible bottom row / baseline | 599 / 600 source px |
| Canopy X centroid range | `['250.2288155329033', '255.33382885564993']` |
| Visual bounding-box X range | `[22, 485]` |
| Alpha-equivalent area range | `108497.79215686275` to `108498.37254901961` source px |
| Loop seam | max channel delta 0; changed pixels 0 |
| Intentional duplicate/rest closure | frames 0 and 22 |
| Whole-sprite scaling | absent |

Exact `durations_ms`: `[200, 120, 100, 100, 100, 120, 140, 190, 120, 110, 100, 90, 90, 90, 110, 160, 210, 160, 130, 110, 100, 160, 220]`.

The frozen global profile and original immutable animation policy reference remain `CANDIDATE_REQUIRES_CALIBRATION`. The per-asset policy-result version binds the new pilot decision. No global motion calibration or thresholds were created.

## 3. Human art-lead review binding

**APPROVED** for the same source/version/attempt, after motion acceptance. Record SHA256: `cb04442e4fc473a0a5bcb0c451537a1052f97908918e9e46c8db7990be687e1d`. Style linkage remains `WILLICAT_JAPANESE_RIVERSIDE_STORYBOOK_V1` version `1.0.0`, approved only for MVP visual input.

The same tree PNG/23 frames/timing and first-party contact-shadow bytes were used. No generation, repainting, normalization, source replacement or approved motion revision occurred in this continuation.

## 4–5. Canonical candidate compilation and identity

**PASS. Compiled once.** New canonical resources at `res://assets/first_party/tree_pilot_v1/` reference byte-identical approved normalized PNGs. The scene uses the proven centered canvas/offset/scale and separate shadow. Only canonical resource namespace/scene/clip display names differ from DEV resources.

Candidate bundle SHA256:

```text
e1ebe7b7f26c390129cfd9209866fadd6960e4bdf1f48ea55c521330ad5cd13b
```

Identity is SHA256 of the frozen canonical `tree-candidate-1` bundle receipt, whose sorted members pin all immutable resource bytes. Receipt: `attempt/canonical/candidate_bundle_receipt.json`. Bundle: `attempt/canonical/bundle/`. No `.godot`, generated `.import`, or `.uid` cache is a bundle member.

The frozen receipt pins the unchanged normalization fingerprint. A separate bundled `compiler_receipt.json` pins the canonical compiler code hash, frozen timing-wrapper hash, repository commit provenance, environment/version fingerprint, original source/normalized hashes and compiled output hashes. Current compiler identity is not substituted into the historical normalization receipt.

Repeated compilation of this attempt fails closed once the immutable bundle exists. No publisher or production signing operation was implemented or run.

## 6–7. Canonical integration proof and parity

**PASS.** A fresh isolated temporary Godot Home copy instantiated the actual compiled prefab at its exact intended logical `res://` paths. Fresh native runtime evidence was collected; old DEV proof was not relabeled.

Runtime-proof bundle SHA256:

```text
e1ebe7b7f26c390129cfd9209866fadd6960e4bdf1f48ea55c521330ad5cd13b
```

Candidate/proof parity: **PASS**. Every actual mapped member in the imported proof project matches the immutable receipt. Source/cache metadata and generated Godot import cache are not authoritative bundle evidence. `approved_bundle_hash` and `published_bundle_hash` are intentionally absent: no final authenticated release approval or publication exists.

The final repository inspection exposed that the frozen Phase 0 bundle checker intentionally accepts temporary roots only. A separate read-only archive verifier was added and tested against the installed archive; frozen contracts and candidate bytes were unchanged. Original 53 tests passed before this repair; the final 56-case run also covers archive extra members, duplicate mappings and symlinks. Both test receipts are retained.

The initial sandbox import could not write normal Godot user/editor data; its failure log is retained. The authorized isolated import retry passed. A first successful proof was retained in implementation-run history; the final run adds per-capture timestamps so the delivered video reflects native engine time. The candidate was not recompiled between proof runs.

## 8. Godot runtime result

**PASS — Godot 4.7.2 stable.** All 16 canonical proof checks passed:

- actual compiled prefab instantiated;
- nonempty native viewport capture;
- relevant world-authority projection preserved before/after;
- candidate/member parity;
- effective tree/shadow importer parameters match compiled policy;
- actor traverses both front/behind positions;
- all 23 animation frames play;
- moving actor present;
- runtime log contains no Godot errors/assertion failures;
- unresolved proxy raster pixels suppressed;
- rendered actor occlusion changes between front/behind;
- all 11 existing route legs reached;
- runtime texture/registration/speed/shadow/renderer checks passed;
- root/sprite/shadow transforms stable;
- exact nonuniform integer frame weights survive Godot loading;
- original trunk collision query and navigation obstruction relationship passed.

Root source baseline `(256,600)` maps to existing GameplayRoot. Tree world position stays `(-320,1270)`; existing collision, navigation, interaction semantics, seats, save IDs and world coordinates are unchanged.

The proof uses the existing gameplay zoom with a temporary focused camera. Canonical camera-layout files remain unchanged. This proves this pilot's registered runtime behavior, not production readiness of the whole visual world.

36 unresolved DEV proxy textures are transparent metadata-sized placeholders in the temporary copy only. Existing first-party Home context and orange actor remain visible. Unused legacy sample audio is excluded from this temporary tree proof to avoid previously observed unrelated importer errors; originals are unchanged. Gameplay regressions still passed. No third-party raw pack was copied into the repository or used for generation.

### Review evidence

- [Moving actor/tree MP4](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/canonical/evidence/runtime/CANONICAL_moving_actor_tree.mp4)
- [Moving actor/tree GIF](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/canonical/evidence/runtime/CANONICAL_moving_actor_tree.gif)
- [Front/behind contact sheet](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/canonical/evidence/runtime/actor_depth_contact_sheet.png)
- [Canonical integration receipt](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/canonical/evidence/canonical_integration_proof.json)
- [Exact calibration observations](../../artifacts/asset_factory/mvp_and_tree_pilot_v1/attempt/canonical/evidence/pilot_calibration.json)

59 native captured frames; MP4 uses variable durations from recorded engine timestamps (~7.39 s), GIF is a browsing conversion at 12 fps. Native proof/resource timing remains authoritative; video encoding cadence is not a motion threshold.

## 9. Regression results

| Suite | Actual result |
|---|---|
| Original DEV MVP | 27 passed |
| New canonical continuation + archive checks | 20 passed |
| New runtime/binding checks | 9 passed |
| MVP total | **56 passed** |
| Frozen Phase 0 | **80 passed**, 0 failures/errors |
| Existing Asset Forge | **62 passed** |
| Godot Continuous Home | PASSED |
| Godot proxy café | PASSED |
| Godot true vertical slice | all checks PASSED |

Logs and Phase 0 per-case receipt are in `attempt/canonical/evidence/regressions/`. Negative tests cover changed source/attempt/motion, rejected animator criteria despite numeric results, global calibration unchanged, skipped stage, stale/revoked rights revision, modified bundle/evidence, authority change, writable readiness override, forged role metadata, compile-once behavior and actual frozen runtime transitions. Historical traversal/symlink/write-once tests remain passing.

## 10. Protected-file parity

**PASS:** all 1,492 protected baseline files unchanged; all 115 existing reviewed artifact files unchanged. Frozen contracts, source PNG, normalized atlas/23 frames, shadow, DEV bundle/evidence and historical manifest/index/pointer remain unchanged. New canonical records are additive.

`attempt/current_canonical.json` identifies the current canonical continuation. `attempt/current.json` remains the historical DEV pointer; only canonical consumers use the canonical pointer. Stage snapshots progress adjacently to `runtime_validated`, without rewriting the historical hold or its immutable pending-review text. Current approvals are explicit appended records.

Only additive MVP implementation/evidence/report files and the MVP README changed in the repository. No tracked gameplay scene/asset/navigation/camera file changed; no commit or push occurred.

## 11. Rights state

Decision revision: `tree-pilot-canonical-dev-authorization-v1`.

| Action | Required scope set | State |
|---|---|---|
| inspect | structural_study | permitted for this pilot |
| candidate_compile | dev_runtime + modification | permitted for this canonical DEV candidate |
| integration_proof | dev_runtime | permitted |
| publish / rollback | production_runtime + publication_distribution | **unresolved / blocked** |

The remaining eight-policy scopes are preserved; raw redistribution, generative conditioning/reference and AI training are not granted here. This task used no generative adapter. The manifest's general rights gate stays `not_started`; action-scoped DEV evaluations must not be mistaken for global production clearance.

## 12. Derived production_ready

**FALSE / BLOCKED.** The frozen predicate is used with no protected production context/credential, and fails closed. No eligible production ledger or signature was fabricated. Read-only result/inspection values are derived diagnostic outputs, never writable manifest truth.

Structural, motion, visual and runtime gates are `passed`. Final `human` gate is `not_started`. Stage is `runtime_validated`, not `human_approved`. There is no production publication, approved release hash, published hash, signing credential or publisher capability.

## 13. Remaining blockers

1. Production runtime/publication rights and separate human production authorization are absent.
2. Final exact-bundle authenticated human approval is absent; early role approvals do not replace it.
3. Protected trust registry, production credential/publisher and protected current production context are not provisioned.
4. Catalog/final-release gate progression has not been executed in this bounded compile/proof task.

None of these blocks the completed candidate/proof result. Global motion-family calibration intentionally remains unestablished.

## 14. Exact next permitted step

Human review of this canonical evidence packet; then permitted metadata-only catalog/final-review preparation for the **same immutable bundle**. Any production progression additionally requires separate explicit authorization, current production rights and protected authenticated approval/publisher prerequisites. No automatic publication or new tree source is permitted.

WILLICAT ANIMATED ENVIRONMENT TREE PILOT V1
— CANONICAL CANDIDATE + INTEGRATION PROOF COMPLETE
— PRODUCTION PUBLICATION REMAINS BLOCKED
