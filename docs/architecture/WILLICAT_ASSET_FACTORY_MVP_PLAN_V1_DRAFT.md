# WilliCat Asset Factory MVP plan V1 — draft

**Planning only.** The [architecture](WILLICAT_ASSET_FACTORY_ARCHITECTURE_V1.md) is approved in direction with hardening amendments completed. The tree pilot is **not** authorized for implementation. Phase 0 contracts/spikes and explicit human implementation approval must come first. No pilot, provider adapter, validator, source art, Godot resource or scene is created here.

## Phase 0 — contract lock before tree implementation

Phase 0 is a bounded prerequisite, not the tree pilot. Record a human-reviewed outcome for each item below; unresolved or failed outcomes block the dependent tree stage and any production publication.

| Contract/spike | Required outcome | Block if unresolved |
|---|---|---|
| Frozen MVP schema/profile subset | Pin `animated_environment` manifest fields, canonical stage/gate semantics and required review/evidence records without changing the approved category vocabulary. | Job/SPEC creation for pilot. |
| Derived `production_ready` predicate | Lock and test the architecture's complete current-attempt, compatibility, rights, gate, evidence, authenticated approval and bundle-parity predicate; never store it as writable truth. | Publisher/rollback. |
| Human approval trust mechanism | Select a verifier boundary unavailable to an agent sharing ordinary file-write privileges; support `reviewer_principal`, `reviewer_role`, `credential_id` or equivalent, exact signed payload/hash, and signature/equivalent authorization proof. A role string or hash-only log is insufficient. | `human=passed` and publisher. |
| World-authority projection hashing | Freeze canonical relevant fields and representation, with separate whole-file provenance hash/revision and `world_authority_projection_hash`; prove unrelated Home edits do not stale an asset while relevant changes do. | TEMPLATE compatibility and runtime proof. |
| Nonuniform `durations_ms` in Godot | Prototype a resource representation that preserves ordered frame timing; reject silent uniform-FPS conversion. | Candidate compile for animated tree. |
| Compile-once/proof/publish parity | Freeze immutable bundle layout and logical `res://` map; prove `approved_bundle_hash == runtime_proof_bundle_hash == published_bundle_hash` with publisher promotion only, never post-approval recompilation. | Runtime proof, human approval and publication. |
| Proof/production filesystem and import behavior | Spike an isolated temporary Godot project/worktree or equivalent using production-equivalent logical paths. Verify path traversal/symlink protection, write-once records, atomic pointers and serialized publisher writes. Treat Godot import cache as regenerable, not source-of-truth evidence. | Integration proof and production write capability. |

Phase 0 may produce contract notes and disposable technical spike evidence **only after separate implementation authorization**. It does not create tree art, the pilot asset or production resources. Strong authentication unresolved means publication stays blocked; no documentation assertion can substitute for an enforceable trust boundary.

## Pilot choice

| Candidate | Learning value | Cost/risk | Decision |
|---|---|---|---|
| `animated_environment` tree | Tests template/world pin, immutable source, root/baseline, authored timing, separate shadow, motion + visual veto, moving-actor occlusion and final approval | Calibration and nonuniform Godot timing need design work | **Recommended single pilot** |
| Directional chair | Strong pivot/direction and fixed GameplayRoot proof | Does not exercise motion quality or seam | Later pilot |
| Terrain micro-family | Tests adjacency, atlas and art/world cell split | Broad grammar and completeness validator surface | Later pilot |

Use only permitted first-party/manual source intake for the pilot. After Phase 0 and explicit human approval, extract and review existing Home tree registration/occlusion geometry and approve a style-family calibration; if either is missing, stop at TEMPLATE. Do not make art or start this pilot from this plan alone.

## Minimum slice and interfaces

| Component | MVP behavior |
|---|---|
| Job/manifest files | One `animated_environment` category profile; write-once attempt/source/evidence records; stage and six canonical gates; pinned hashes/versions; atomic mutable pointers. |
| Template/style/rights lookup | Read-only authority-derived tree template, approved calibration ref, historical world file/revision identity plus relevant projection hash, and rights evaluation bound to requested action, exact scopes and decision revision. |
| Manual source intake | Hash/copy first-party input into an immutable attempt; no external provider, generation or credit integration. |
| Forge adapter | Reuse frame extraction, root-preserving normalization, QA metrics, atlas and preview helpers; isolated per-attempt output. Pin Factory/Forge code, recipe, environment/dependency and tool versions, source-file/decoded-pixel and output hashes. Preserve `durations_ms`. |
| Validator dispatch | After authorization, implement tree-required schema, frame, root/baseline/scale/seam, provenance, evidence and world-projection checks; uncalibrated limits block automated pass. Separate deterministic motion measurements, calibrated policy results and technical-animator approval. |
| Evidence/review | Static registration overlay, frame contact sheet, scene-speed loop, root/canopy trace, shadow/actor depth captures; authenticated human approval bound to exact evidence and bundle hashes. |
| Candidate compiler/proof/publisher | Compile one immutable bundle; prove it with a moving actor at production-equivalent logical `res://` paths; promote the identical approved bundle only after recomputing `production_ready`. Never recompile at publish. |
| Catalog | Rebuildable index for this family and a protected approved-version pointer. |

Conceptual CLI surface: `request` (spec/job), `inspect` (stage, action-scoped rights, staleness), `process` (Forge candidate), `validate` (applicable checks), `preview` (evidence), `review` (human-verifier boundary), `compile` (single isolated candidate), `catalog` (index/status), `publish` (recompute predicate and promote same bundle). Names and grouping are not frozen; no commands are implemented now. Each mutating command should show its target job/version. Canonical real-path checks reject traversal and symlink escape; only a serialized protected publisher can write production locations. Prompt instructions alone provide no security boundary.

## Required acceptance tests and evidence

1. Schema/profile/stage transitions reject missing data and `production_ready` writes; failed results remain in attempt history.
2. Wrong source dimensions/alpha, missing frame, root drift or bad loop seam stop before `integration_proof`; uncalibrated limits never return a false pass.
3. Forge adapter leaves source hash unchanged, isolates outputs, and records full toolchain/environment fingerprint plus source-file, decoded-pixel and output hashes; exported timing matches `frame_map` and `durations_ms` or blocks compilation.
4. Rights `unresolved` blocks only the requested action/scope set. A DEV proof pass does not grant production permission. A later rights revision can make an already-published release ineligible and block subsequent production builds/releases containing it.
5. An unrelated Home edit with the same canonical relevant projection hash does not invalidate the tree; a changed relevant field invalidates it or requires explicit compatibility review. Runtime proof compares this projection while GameplayRoot transform, nav, IDs, anchors and camera remain authoritative; moving actor traverses before/behind the tree.
6. Numeric motion checks may pass while the technical animator rejects pulse-like/jelly quality; `motion` remains failed. Art lead can independently veto `visual`.
7. Forged `role: human` metadata, an agent-written approval record, invalid credentials or a mismatched signed payload cannot pass authenticated human approval. An approved review cites exact source, template, style, evidence and runtime bundle hashes.
8. Path traversal and symlink escape cannot reach production paths; attempts/source/evidence are write-once, pointer updates atomic, publisher operations serialized.
9. Publisher never recompiles an approved asset; the approved bundle hash equals runtime-proof and published bundle hashes, with unchanged logical `res://` mapping. Generated Godot import cache is not used as source-of-truth evidence.
10. File tampering, stale evidence, old Forge `FINAL` status and direct `production_ready=true` cannot create a production catalog pointer. Rollback refuses a previously approved version whose current rights, authority compatibility, human approval or other dependencies are ineligible.

Evidence bundle: source/normalized and toolchain hashes, template extraction and canonical authority projection, action-bound rights/style decisions, validator reports with calibration versions, registration and root overlays, full-speed loop, actor occlusion capture, projection parity/proof result, `runtime_proof_bundle_hash`, visual review, authenticated human record with `approved_bundle_hash`, and catalog/published bundle hash. An empty scene screenshot is insufficient.

## Rollback and deferrals

Publisher should keep immutable release history and bundle hashes. An active published release whose rights, authority compatibility, authenticated approval or other blocking dependency changes becomes explicitly `ineligible`/`revoked`; subsequent production builds/releases containing it are blocked. Rollback selects a previously approved version **only after** recomputing its current `production_ready` predicate and confirming its immutable bundle hash. If no version is eligible, publication/build remains blocked pending human resolution; do not label the ineligible current release safe. Rollback does not delete failed attempts, recompile assets or alter Home geometry.

Defer all other category profiles, tree art generation, provider adapters, automatic style scoring, full terrain/door/building grammar, GUI, scheduler, cloud storage, distributed jobs, rights interpretation, and the future skill. MVP completion is a separate human decision.

**MVP READINESS — PILOT DIRECTION APPROVED, BUT IMPLEMENTATION REMAINS BLOCKED UNTIL PHASE 0 CONTRACTS/SPIKES ARE RESOLVED AND EXPLICITLY HUMAN-APPROVED.** This plan does not authorize Phase 0 execution, tree implementation, art production or publication.
