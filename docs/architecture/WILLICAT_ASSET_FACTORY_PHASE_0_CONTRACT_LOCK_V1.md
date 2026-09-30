# WilliCat Asset Factory Phase 0 contract lock V1

**Scope: contract lock and limited diagnostic prototypes only.** The animated environment tree remains the recommended first pilot; the pilot has not been built. This document specializes the approved [architecture](WILLICAT_ASSET_FACTORY_ARCHITECTURE_V1.md) and [MVP plan](WILLICAT_ASSET_FACTORY_MVP_PLAN_V1_DRAFT.md), using the [hardened schema](WILLICAT_ASSET_MANIFEST_SCHEMA_V1_DRAFT.md), [registration/motion contract](WILLICAT_ASSET_REGISTRATION_AND_MOTION_CONTRACT_V1_DRAFT.md), [ecosystem](WILLICAT_ASSET_ECOSYSTEM_STANDARD_V1_DRAFT.md), [terrain/animation standard](WILLICAT_TERRAIN_ANIMATION_VFX_UI_STANDARD_V1_DRAFT.md), [provenance policy](../production/WILLICAT_PROVIDER_PROVENANCE_POLICY_V1_DRAFT.md), [research](../research/WILLICAT_ASSET_PROVIDER_PRODUCTION_BEST_PRACTICES_RESEARCH_V1.md), [hardening result](WILLICAT_ASSET_SPECIFICATION_HARDENING_V1_RESULT.md) and [recorded baseline](../production/WILLICAT_CURRENT_BASELINE_EVIDENCE_V1.md).

## 1. Phase 0 scope

Freeze one `animated_environment.tree.phase0.v1` subset and prove schema shape/stage obligations, canonical serialization, public approval verification, relevant world hashing, nonuniform timing, immutable bytes, temporary filesystem safety and a pure eligibility predicate. [Prototype source](../../tools/willicat_asset_factory_phase0/README.md) is separable from Forge. It is not an orchestrator, catalog, general validator suite or production publisher. Runtime resources and reused PNGs exist only in temporary diagnostic projects; the repository evidence contains metadata/logs, not a new art asset.

Evidence labels: **OBSERVED/MEASURED** repository or engine output; **LOCKED CONTRACT** selected technical rule; **TEST FIXTURE** synthetic successful approvals/policies for contract testing; **UNRESOLVED** production setup/calibration. No fixture PASS is a real tree's approval.

## 2. Decisions locked

Godot GameplayRoot remains authoritative; visuals fit it. SPEC/TEMPLATE precede SOURCE. Reuse/composition of Forge remains preferred; no Forge code changes were needed. Twelve stages and six gates retain approved names. Rights remain scoped to action/revision. Compatibility uses relevant projection, with separate full-file provenance. Compile once, prove and promote identical bytes. No agent-writable `production_ready`; no automatic beauty score. Human motion, visual and final veto remain independent. No provider integration or new style lock.

## 3. Animated environment pilot profile

JSON Schema 2020-12 plus the small `validate_manifest` content-contract proof specialize the broader draft. Required data accumulates; late-stage containers are omitted until data exists. Strings/semantic collections/objects cannot be empty substitutes. Explicitly authored empty `semantic_event_ids`, `blocking_dependencies` or `compatibility_affirmations` mean “none”; they are not missing registration or approvals.

| Stage | Newly required fields (exact names) |
|---|---|
| `spec` | `schema_version`, `profile_id`, `request_id`, `job_id`, `attempt_id`, `asset_id`, `asset_version`, `category`, `family_id`, `style_family_id`, `lifecycle_stage`, `disposition`, `requested_action`, `provenance_evidence`, `rights_evaluations`, `gates`, `invalidation` |
| `template` | `template`, `style_calibration`, `world_authority`, `registration` |
| `source` | `source` |
| `normalized` | `normalized`, `animation` |
| `structurally_validated` | `validator_results` |
| `motion_validated` | `motion_review`, `motion_policy_results` |
| `visual_qa` | `visual_review` |
| `preview` | `preview_evidence` |
| `prefab` | `candidate_bundle` |
| `runtime_validated` | `runtime_proof` |
| `cataloged` | `catalog_entry_ref` |
| `human_approved` | `human_approval` |

`gates` always contains `rights`, `structural`, `motion`, `visual`, `runtime`, `human`. Status vocabulary: `not_started`, `pending`, `passed`, `failed`, `not_applicable`; this animated tree profile **forbids not_applicable for its gates**. Completed passes require same-asset/version/attempt `record` and evidence. SOURCE needs approved `style_calibration`. NORMALIZED requires matched nonempty `frame_map`/`durations_ms`, unique frame IDs and valid regions. All supported clips are `ambient_sway`, `loop`, root/baseline locked, whole-sprite scale forbidden, foliage led, `timing_intent=authored_arc`; an annotation does not prove that intent succeeded.

`validator_results` stores required named structural/motion/runtime results with `validator_id`, `validator_version`, `gate`, `result`, `evidence`. `V-PROVENANCE`, `V-REVIEW-EVIDENCE`, `V-APPROVAL-AUTH` are recomputed live, not trusted as writable success records. Source, normalized exports, fingerprint and bundle are content identified. Publication is optional until a release exists and cannot manufacture approval. Other eight category profiles are not frozen or implemented by Phase 0.

## 4. Formal lifecycle transition table

```
spec → template → source → normalized → structurally_validated → motion_validated
→ visual_qa → preview → prefab → runtime_validated → cataloged → human_approved
```

| Adjacent transition | Required completed gates | Required data/evidence | Exact rights action/scopes |
|---|---|---|---|
| `spec` → `template` | Resolved data/evidence | `template`, `style_calibration`, `world_authority`, `registration` | `inspect`: `structural_study` |
| `template` → `source` | Resolved data/evidence | `source` | `manual_intake`: `structural_study` |
| `source` → `normalized` | Resolved data/evidence | `normalized`, `animation` | `normalize`: `modification` |
| `normalized` → `structurally_validated` | `structural` | `validator_results`, `gates.structural.record` | `inspect`: `structural_study` |
| `structurally_validated` → `motion_validated` | `structural`, `motion` | `motion_review`, `motion_policy_results` | `inspect`: `structural_study` |
| `motion_validated` → `visual_qa` | `structural`, `motion`, `visual` | `visual_review` | `inspect`: `structural_study` |
| `visual_qa` → `preview` | Resolved data/evidence | `preview_evidence` | `inspect`: `structural_study` |
| `preview` → `prefab` | `structural`, `motion`, `visual` | `candidate_bundle` | `candidate_compile`: `dev_runtime`, `modification` |
| `prefab` → `runtime_validated` | `structural`, `motion`, `visual`, `runtime` | `runtime_proof` | `integration_proof`: `dev_runtime` |
| `runtime_validated` → `cataloged` | Resolved data/evidence | `catalog_entry_ref` | `inspect`: `structural_study` |
| `cataloged` → `human_approved` | `structural`, `motion`, `visual`, `runtime`, `human` | `human_approval` | `publish`: `production_runtime`, `publication_distribution` |

The authoritative serialized rules are `lifecycle.json`. Every row records `from_stage`, `to_stage`, `required_gates`, `required_evidence`, `rights_action`, `required_scopes`, `required_version_pins_at_destination`, `blocking_conditions`, `retry_behavior`, `invalidation_behavior`. Required destination pins include profile, asset/attempt, template/style versions, projection and rights revision. Pins become available at TEMPLATE; `spec → template` verifies extracted destination pins rather than inventing predecessor geometry.

The pure `transition_allowed` proof checks adjacency, populated stage/profile data, preserved existing identity/content pins, same current attempt, no stale blockers, exact current rights scopes, required gate results and referenced evidence bytes; final transition also verifies authentication. Missing/failed conditions keep the prior completed stage. Same-byte re-review appends a new result, retaining failures; revised content uses a new attempt/version and loses dependent proof/review. Terminal cancelled/superseded attempts cannot be resumed as approved. No scheduler/history writer is implemented.

Independent future diagnostics can inform a gate before its ordered completion; they never authorize skipping stages. Motion/visual review evidence is produced before candidate compile; final human review occurs after proof/catalog. `rights=passed` is not permission for any other row/action.

## 5. Approval authentication and trust model

**LOCKED CONTRACT:** human-held external signing capability; Factory/publisher verification only. Select RSA-PSS with SHA-256, MGF1-SHA256, 32-byte salt, RSA modulus at least 3072 bits. This is a cryptographic encoding/security requirement, not an invented motion/geometry tolerance. Signature verification uses the installed public verifier in this spike; [RFC 8017](https://www.rfc-editor.org/rfc/rfc8017) defines RSASSA-PSS. No production key was created.

The human must provision a signing authority outside agent-accessible files/processes, for example a separately controlled machine or human-operated signing device with deliberate authorization. Provision a protected credential registry mapping `credential_id` to public key, opaque principal, allowed roles, active/revoked state and revision. The agent may submit an unsigned payload for review; it cannot select the trusted registry, add a credential, revoke/restore one or invoke the private signing operation. Final reviewer explicitly attests the motion/art-lead records cited by the payload; role labels alone do not authenticate those decisions.

A separately controlled publisher/build account must own the verifier, trust/configuration/context, release roots and final build eligibility check. The coding agent's account has staging capability only. If both share unrestricted write/execute privileges, signatures can detect payload tampering but cannot prevent replacing the verifier/trust root or bypassing the build. **Publication stays blocked until that deployment boundary and human trust root are provisioned and reviewed.** This task demonstrates neither a deployed publisher nor OS isolation.

| Record class | Meaning |
|---|---|
| Operator/CLI metadata | Initiator/timestamp/role annotation; no human approval authority. |
| Tamper-evident metadata | Hashes detect changes when checked against a trusted retained identity; no proof that a human authorized the original. |
| Authenticated approval | Exact canonical payload verifies under a currently active, authorized external credential in the protected registry. |

Missing/unknown/revoked/wrong-principal/wrong-role/invalid key, changed payload, bad signature or verifier error fails closed. Credentials and rights are reevaluated at every publish/rollback/build. `test_fixture=true` is rejected by default; only a test explicitly enabling fixture mode accepts it. Tests create and delete an ephemeral **TEST FIXTURE — NOT PRODUCTION TRUST ROOT** private key. Retained public fixture/envelope are not production credentials. The prototype's supplied trust/context dictionaries are dependency-injected **trusted inputs**, not a secure loader for agent files.

## 6. Canonical approval payload

`approval_payload.schema.json` freezes:

```
approval_schema_version; asset_id; asset_version; job_id; attempt_id;
template.{id,version}; style_calibration.{id,version};
world_authority_projection_hash; rights_decision_revision;
gate_results.{rights,structural,motion,visual,runtime}; evidence[];
runtime_proof_bundle_hash; approved_bundle_hash; asset_contract_hash;
reviewer_principal; reviewer_role; credential_id; decision; timestamp
```

Envelope: `payload`, `signed_payload_hash`, `signature` (base64), `algorithm`. `reviewer_role=final_human_reviewer`, `decision=approve`; identity need not be a personal name. `asset_contract_hash` signs the complete canonical manifest semantic view except `human_approval`, `publication`, `lifecycle_stage` (signature/release/progress are separate); this binds registration, timing, sources, reviews and rights evidence as well as the bundle. Stage completion is checked separately.

**restricted-json-1:** UTF-8 without BOM/newline; ASCII field keys, lexicographic sorted keys; compact separators; NFC strings, reject surrogates; JSON integers within exact ±(2^53−1), booleans/null only where schema allows. Floating-point signing inputs, duplicate parsed keys and nonfinite numbers are rejected. Arrays retain declared order; changing evidence order changes the signed payload, while reordered object keys do not. Projection geometry uses normalized decimal **strings**, avoiding float formatter ambiguity. SHA-256 hashes canonical bytes; signing uses SHA-256 over those exact payload bytes, not a free-form Markdown record. Timestamp is review metadata, not a trusted clock or substitute for current credential/revision checks.

## 7. World projection contract

`tree-authority-1` extracts the read-only first-party proof instance of continuous Home, after installers initialize and with autoplay off. Historical provenance records the continuous Home scene's full SHA-256 plus relevant installer, base/prefab, collision/navigation and visual-binding dependency hashes. Compatibility is SHA-256 of the canonical selected projection, not a scene file's bytes.

Selected fields: `projection_schema_version`, `world_id`, `stable_id`, `node_path`, `global_transform`; `attachment.{visual_root_path,local_transform}`; ancestor `depth_chain` (path/Y-sort/Z/relative-Z); `shadow` transform/depth; `collision` identity/transform/footprint/layers/mask/authored navigation outline; `navigation` region/agent clearance/layers/obstruction ref; explicit `semantic_event_ids` (none for this ambient tree). Transform order is `[basis_x.x,basis_x.y,basis_y.x,basis_y.y,origin.x,origin.y]`. Node paths are relative to the existing Home root/GameplayRoot, no process-dependent instance IDs.

Godot full-precision JSON extraction supplies finite numbers. Canonicalization preserves their decimal value, strips insignificant fractional zeros and normalizes −0 to `"0"`; it does not round using an invented tolerance. Depth entries are a set sorted by path; semantic IDs sorted and unique; transforms and obstruction polygon vertex order remain ordered. Missing required data/null/malformed fields block any compatibility claim. No other decoration, scene-byte hash, global navmesh polygon enumeration, animated frame index or actor's transient position enters this tree's compatibility hash.

Actual extraction observed the existing tree at `(−320,1270)`, trunk offset `(0,−18)`, footprint `(28,26)`, ancestor Y-sort, shadow offset `(0,−5)`/Z −1 and navigation clearance 11. These are observations from current files/runtime, not newly selected dimensions. Rendering binding observes centered 512×640 frames, visual scale 0.4 and offset `(0,−112)`; that template/presentation identity is separately bound in registration/source/bundle receipts. Those presentation values do **not** establish an approved alpha-ground-contact measurement, source pivot/baseline or new tree template. Source grounding remains future template review work. Synthetic schema fixture registration is explicitly test data, not a Home measurement.

## 8. Projection hashing proof

[Projection receipt](../../artifacts/asset_factory/phase_0_contract_lock_v1/projection_tests.json) proves same snapshot → same hash; changed unrelated copied decoration → same hash; copied relevant tree transform edit → changed hash; reversed object enumeration/depth set → same hash; missing `stable_id` → failure. Production Home was not edited. [Extracted snapshot](../../artifacts/asset_factory/phase_0_contract_lock_v1/authority_snapshot.json) and [canonical projection](../../artifacts/asset_factory/phase_0_contract_lock_v1/world_projection.json) retain measured values.

A new projection recipe version changes compatibility identity and requires review. A relevant navigation/transform/depth change blocks old eligibility until an authenticated compatibility decision or new template/proof/approval. Unrelated edits with unchanged relevant projection do not stale the tree solely because historical file hashes differ. Projection does not claim that unrelated edits preserve the whole game's behavior; existing runtime regressions remain separate.

## 9. Godot timing representation

**LOCKED `godot-ms-weight-1`:** pilot timings are positive integer milliseconds, at most 2^24, the exact integer encoding domain of binary32 frame weights. This bound concerns resource representation, not artistic timing quotas. Fractional milliseconds/out-of-domain values are rejected, never silently rounded. Ordered weights are `SpriteFrames.frame.duration = durations_ms[i]`; animation `speed=1000.0`; playback `speed_scale=1`, custom speed=1.

Absolute duration is weight/(animation FPS × absolute playing speed), giving milliseconds/1000 seconds. Godot provides per-frame relative durations and animation speed in [SpriteFrames](https://docs.godotengine.org/en/stable/classes/class_spriteframes.html); [AnimatedSprite2D](https://docs.godotengine.org/en/stable/classes/class_animatedsprite2d.html) owns playback speed. Engine/frame scheduling is not a hard real-time clock. Integer weight representation is lossless in the frozen domain; measured wall-clock holds can vary with scheduling/startup.

The small `timing.compile_timing` wrapper calls existing Forge `generate_sprite_frames_tres` for an explicit equal-cell horizontal map, then writes the declared frame weights. It refuses unsupported maps/timings. Forge's legacy 5 FPS/`duration=1.0` writer and API remain unchanged. Supporting arbitrary maps in the future is MVP work, not part of this proof.

## 10. Timing proof

Four existing frames are copied unchanged into a temporary bundle. Diagnostic timings `[100,300,150,450]` ms are **not production values or motion-quality evidence**. Godot 4.7.2.stable.official.ed1daf0bf loads the exported `.tres`, recovers all four exact intended durations, instantiates the diagnostic visual prefab and emits ordered frame-change signals over multiple loops. The second complete loop has the intended shorter/longer hold ordering; observed microseconds are retained without inventing a production acceptance tolerance. Startup hold variance is reported, not concealed.

[Round-trip/runtime receipt](../../artifacts/asset_factory/phase_0_contract_lock_v1/timing_round_trip.json), import/playback logs and processing receipt identify the engine and timing recipe. The original Mini Pack binding remains four frames at 5 FPS/0.8 s. No animation was improved or judged visually by this timing test.

## 11. Immutable candidate bundle contract

`tree-candidate-1`: directory of explicit members plus an external canonical receipt. Frozen diagnostic logical base: `res://assets/first_party/__phase0_diagnostic_tree__/`. This is a **future-equivalent path map used only in temporary projects**, not a production deployment path created now.

Members: unchanged `tree.png`, unchanged `shadow.png`, `tree_frames.tres`, presentation-only `tree.tscn`, `registration.json`, `rights_reference.json`, `import_policy.json`, `processing_receipt.json`. GameplayRoot/collision/nav do not belong to this visual-only prefab. The receipt is outside its own member list to avoid self-hashing. It contains `bundle_format_version`, sorted `resource_map` (logical path→member path), sorted `members` (path/SHA-256), `registration_hash`, `rights_reference_hash`, `timing_recipe_version`, `toolchain_fingerprint_hash`. Bundle identity is SHA-256 of `restricted-json-1` receipt bytes.

No timestamps, zip ordering, host absolute paths, generated UIDs or `.godot/imported` cache enter bundle identity. Ancillary diagnostic logs remain separate. Member paths/logical `res://` mappings are identity: moving identical bytes to another logical path changes the hash. A member change/new compile creates a new candidate cycle and invalidates prior proof/approval; no in-place replacement. `check_bundle` verifies bytes against the immutable receipt.

Fingerprint captures Phase 0 code/contract/diagnostic-script hashes, Forge code hash, recipe, Python/platform/package inventory and requirements hash, Pillow/jsonschema/OpenSSL/Godot versions, historical Git commit, source-file hash, canonical decoded RGBA header+pixels hash and output hashes. Processing receipt excludes itself from its output hash list; its own bytes are included by the bundle receipt. No concrete version is invented; receipts contain observed versions.

## 12. Proof/publish parity

```
candidate_bundle_hash == runtime_proof_bundle_hash
                      == approved_bundle_hash == published_bundle_hash
```

Compiler runs once **per final diagnostic candidate cycle**; proof and promotion copy/reference that candidate's bytes. No compiler is available to `promote_simulation`. A post-approval rebuild is a new cycle, even if it happens to reproduce the same content hash: immutable attempt identity and new reviews must be resolved, never silently replaced.

[Parity receipt](../../artifacts/asset_factory/phase_0_contract_lock_v1/bundle_parity.json) shows equality. Its `approved_bundle_hash`/`published_bundle_hash` are **simulation placeholders for byte identity only**, not an authenticated human approval or actual production publication. Tests mutate a member, change logical mapping, try overwriting/rebuilding and require failure/new identity.

Temporary proof and simulated-release projects use identical logical paths and fresh Godot import caches. `import_policy.json` pins measured texture importer `[params]` literals, renderer and playback policy. [Import parity](../../artifacts/asset_factory/phase_0_contract_lock_v1/import_parity.json) compares both effective imports to that exact policy; cache creation leaves source bundle hashes unchanged. Generated `.png.import` remap/UID/cache data are excluded, while **effective importer policy is included**. Future production with different engine/import policy must block or reprove; matching PNG hashes alone is insufficient. No actual production engine import was performed.

## 13. Filesystem/protected-write model

Prototype writes are restricted to canonical roots under `/private/tmp`; production roots are refused. It checks real paths, traversal and every symlink component (including dangling links), rechecks at write time, uses `O_EXCL`/`O_NOFOLLOW` for write-once source/member records, file sync, locked atomic pointer replacement and directory sync. Simulated publication writes a pointer only after every member matches. Interruption/partial copy preserves the old pointer or leaves no pointer; partial candidate is quarantined and never reused by overwriting it.

Tests cover traversal, symlink escape, wrong root, immutable source/candidate, concurrent serialized pointer changes, interruption and partial promotion. They prove these isolated operations, **not an adversarial race-proof production service**. Check-then-open alone cannot secure parent-directory races when an attacker can mutate the same root. Future publisher must own private staging/release roots under a different enforced privilege boundary and/or use descriptor-relative no-follow traversal throughout. The coding agent must have no write access to protected release/trust/context/code roots. Prompt instructions and chmod under the same unrestricted OS account are not that boundary.

## 14. Action-specific rights

| Action | Exact required scopes |
|---|---|
| `inspect` | `structural_study` |
| `manual_intake` | `structural_study` |
| `normalize` | `modification` |
| `modify` | `modification` |
| `integration_proof` | `dev_runtime` |
| `candidate_compile` | `dev_runtime`, `modification` |
| `publish` | `production_runtime`, `publication_distribution` |
| `rollback` | `production_runtime`, `publication_distribution` |
| `future_generate` | `generative_conditioning_reference` |

All eight scope names are preserved, including `raw_redistribution` and `ai_training`, which no current pilot operation requests. Outcomes remain `permitted`, `prohibited`, `unresolved`, `not_applicable`; only **permitted** satisfies a required scope. `future_generate` is disabled and conceptual only; no adapter exists.

`rights_evaluations[]` binds `action`, exact `required_scopes`, `decision_revision`, per-scope `assessments`/hashed evidence and `result`. Current revision must match protected context; duplicate/missing/extra scope sets fail. A DEV proof pass does not confer publish rights. Intake additionally requires first-party ownership/authorization evidence and input hashes; the first-party label is not a rights grant. Normalization/compilation transformations need modification permission. Publishing and rollback both require current production/runtime/distribution permissions. No third-party determination changes. The task permits this isolated diagnostic proof; neither its receipt nor a fixture settles production ownership/publication rights.

## 15. Motion measurement versus approval

| Layer | Owner/output | Can grant canonical `motion=passed` alone? |
|---|---|---|
| Deterministic measurements (`V-MOTION-MEASURE`) | Software: contact/baseline/area/centroid/seam/scale/timing traces, tool version and evidence | No |
| Calibrated policy (`V-MOTION-POLICY`) | Software: each required root/baseline/scale/seam criterion, calibrated policy version/result | No; absent calibration blocks |
| Human technical motion review | Qualified `technical_animator`: explicit results for `foliage_led_sway`, `no_whole_sprite_scale_pulse`, `readable_authored_arc`, `seam_perceptually_continuous` with loop/contact evidence | Required together with passing machine checks |

The animated tree's canonical motion gate passes only when all required validators/policies pass and all human criteria pass. `CANDIDATE_REQUIRES_CALIBRATION` cannot count as a policy version yielding success. Numerically plausible jelly motion can fail human motion review; art lead can independently fail `visual`. Final authenticated approval binds exact role-based review records/evidence. No eight-frame or FPS quota confers quality.

## 16. Formal derived production_ready

Authoritative executable proof: `contracts.production_ready(manifest, context, trust, artifact_bytes, allow_test_fixture=False)`. Context is resolved by the future protected publisher from current immutable ledgers/verified compatibility decisions, never directly accepted as agent-authored JSON. It is not a deployed publisher.

```
production_ready = valid schema + tree profile/content obligations
  AND selected current attempt, human_approved, not cancelled/superseded
  AND no manifest or current-context blocking stale dependencies; eligible release selection
  AND current template/projection/approved style OR explicit trusted compatibility affirmation
  AND exact requested publish/rollback scope set permitted at current rights revision
  AND structural/motion/visual/runtime/human passed
  AND all required current-version motion policies AND qualified animator criteria passed
  AND required named validator and human-review evidence exists and hashes match
  AND exact manifest semantic contract/versions/evidence authenticated by active human credential
  AND source/normalized/fingerprint/bundle receipt/member hashes verify
  AND candidate == runtime-proof == approved == proposed/actual published bundle hash
```

No profile-authorized motion N/A exists for this tree. Approval payload must match exact asset/version/job/attempt/template/style/world/rights tuple and `asset_contract_hash`; human gate record cannot substitute for signature verification. Protected compatibility affirmations bind kind, pinned/current identity and authenticated review-record hash, resolving relevant changes only with evidence; no automatic affirmative value on drift. These trusted assertions require a future protected authenticated ledger loader, not agent-written context values.

Publisher recomputes on every publish, rollback and production build, hashing actual member bytes and resolving current trust/rights/compatibility. A prospective publish hash denotes bytes verified at the destination before the atomic pointer; an existing release's hash must still match. `production_ready` is prohibited by schema as a source field; diagnostic reports may show the computed result but cannot grant it.

An active release becomes `ineligible`/`revoked` when current rights, authority, approval or dependencies fail. Subsequent builds containing it stop. Rollback can select an otherwise eligible historical completed attempt through a protected release-selection record; replacing a release does not itself terminally supersede its attempt. Explicitly cancelled/superseded attempts remain ineligible and require a new reviewed attempt. Prior approval is insufficient if current rights/authority/credential is invalid. No failed current release is described as safe.

## 17. Existing tree negative control

[Negative-control evidence](../../artifacts/asset_factory/phase_0_contract_lock_v1/negative_control.json) observes unchanged Mini Pack PNG dimensions/frame bounds, uniform playback and separate shadow. Existing route/spatial regressions can pass while perceptual motion/style/final authentication remain unapproved. Its canonical motion/visual/human review statuses are `not_started` in this diagnostic record: **no new or retroactively fabricated reviewer decision**. No calibrated policy, approved style/production rights or configured production trust root is inferred. The fixture predicate also rejects a normalized/unapproved tree. Four correct canvases and working depth do not make it eligible.

## 18. Machine-readable artifact index

| Artifact | Responsibility |
|---|---|
| [approval_envelope.schema.json](../../tools/willicat_asset_factory_phase0/contracts/approval_envelope.schema.json) | Payload/hash/signature algorithm envelope. |
| [approval_payload.schema.json](../../tools/willicat_asset_factory_phase0/contracts/approval_payload.schema.json) | Exactly signed fields, including complete semantic contract hash. |
| [bundle_receipt.schema.json](../../tools/willicat_asset_factory_phase0/contracts/bundle_receipt.schema.json) | Members, logical mapping, timing/registration/rights/toolchain identities. |
| [lifecycle.json](../../tools/willicat_asset_factory_phase0/contracts/lifecycle.json) | Twelve stages, eleven adjacent transitions, pins, blockers/retry/invalidation. |
| [predicate_context.schema.json](../../tools/willicat_asset_factory_phase0/contracts/predicate_context.schema.json) | Protected current context consumed by pure eligibility contract. |
| [review_record.schema.json](../../tools/willicat_asset_factory_phase0/contracts/review_record.schema.json) | Role, gate, version, evidence and criterion results; optional tool/policy. |
| [rights_actions.json](../../tools/willicat_asset_factory_phase0/contracts/rights_actions.json) | Existing eight scopes and exact action requirements. |
| [tree_manifest.schema.json](../../tools/willicat_asset_factory_phase0/contracts/tree_manifest.schema.json) | Request/job/attempt/asset data, stage containers and category profile. |
| [tree_profile.json](../../tools/willicat_asset_factory_phase0/contracts/tree_profile.json) | Pilot obligations, roles, validators, human criteria and evidence classes. |
| [world_projection.schema.json](../../tools/willicat_asset_factory_phase0/contracts/world_projection.schema.json) | Tree-relevant authoritative geometry/depth/navigation. |
| [world_projection_recipe.json](../../tools/willicat_asset_factory_phase0/contracts/world_projection_recipe.json) | Selection, canonicalization and hashing recipe. |

Shared review/projection/payload definitions use local schema references; no remote schema fetching is needed. The full nine-category draft remains architecture context; this specialized subset governs only the pilot contract proof. Approval examples, supplied context and retained public trust fixture in evidence are explicitly test-only. Source records are not a generic Factory job implementation.

## 19. Tests and evidence

[Machine test receipt](../../artifacts/asset_factory/phase_0_contract_lock_v1/contract_test_results.json) and [log](../../artifacts/asset_factory/phase_0_contract_lock_v1/contract_tests.log) record actual results. Tests cover valid fixture/schema stages, missing/empty fields, adjacent/no-skip transitions, authentication/tampering/revocation, rights action independence, projection cases, bytes/mapping/cache parity, safety/concurrency/interruption, nonuniform/legacy timing and pure eligibility.

All 17 requested false-predicate cases are named individually, plus forbidden writable override, uncalibrated motion, missing named V-FRAME evidence, unsigned contract edits and animator rejection despite passing numbers. Successful synthetic evidence is labeled **TEST FIXTURE — NOT PRODUCTION TRUST ROOT**. Actual Godot timing tests verify load-back and playback; they do not perform a moving-actor proof of a new tree pilot.

Forge: **62/62 before and after**, unchanged source. Godot: continuous Home, proxy café, true vertical slice pass with exit code 0 in an isolated copy; extra first-party/proxy spatial parity passes 39 entries. The initial sandbox-denied user-save runs were not counted as passing; final runs use a separate diagnostic user-data directory with authorized execution. [Protected integrity](../../artifacts/asset_factory/phase_0_contract_lock_v1/protected_integrity.json) compares 750 original game/Forge files unchanged. No game test or scene was edited to obtain PASS.

See [result](WILLICAT_ASSET_FACTORY_PHASE_0_RESULT.md) and evidence inventory/hashes for exact artifacts. Relevant scene/scripts/assets/test files are copies in temporary projects; the original project remains untouched.

## 20. Intentionally unresolved calibration values

Root/baseline/scale drift, canopy area/centroid/seam tolerances and authored-motion visual acceptance remain `CANDIDATE_REQUIRES_CALIBRATION`. No universal numeric threshold is introduced. New tree source grounding/pivot and approved family registration must be extracted/reviewed at future TEMPLATE, including actor/shadow context. No palette/style calibration is approved; neither jade nor Japanese countryside is locked. Existing observations and diagnostic integer timing samples are not new production geometry or animation quotas.

## 21. Remaining blockers

| Condition | What it blocks |
|---|---|
| Phase 0 review and explicit human implementation authorization absent | Starting tree MVP |
| Production human-held credential/protected registry and publisher/build privilege boundary not provisioned | Production approval/publication/build eligibility; accepted provisioning requirement, not an unresolved verifier contract |
| Approved style calibration and rights-permitted first-party source evidence absent | Pilot SOURCE |
| Calibrated motion policy and qualified perceptual review not supplied | Pilot motion/visual gate and production eligibility |
| Future protected context/compatibility ledger loader and hardened publisher not implemented | Actual production deployment; deliberately beyond Phase 0 |

No critical Phase 0 contract/timing/parity/regression failure remains in the final receipts. There is no claim that production security is deployed or the old tree is approved. Numeric calibration and production provisioning must not be replaced by a fixture flag.

## 22. Implementation authorization recommendation

**A. PHASE 0 CONTRACT LOCK COMPLETE — READY FOR ASSET FACTORY MVP IMPLEMENTATION REVIEW.** The frozen subset and limited proofs are reviewable; actual implementation is still unapproved. Human may review this contract set and authorize one tree slice with its stage-specific blockers enforced. Stop here: no tree MVP, art/provider integration, all-category pipeline, GUI, skill, production publish, commit or push.
