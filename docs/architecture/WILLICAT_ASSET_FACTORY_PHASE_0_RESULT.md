# WilliCat Asset Factory Phase 0 — result

**A. PHASE 0 CONTRACT LOCK COMPLETE — READY FOR ASSET FACTORY MVP IMPLEMENTATION REVIEW.** This is a contract/prototype result, not MVP or production authorization. The [contract lock](WILLICAT_ASSET_FACTORY_PHASE_0_CONTRACT_LOCK_V1.md) defines the normative details. Explicit human Phase 0 review and implementation approval must precede the tree pilot.

## Files/code added

- Two architecture documents: this result and `WILLICAT_ASSET_FACTORY_PHASE_0_CONTRACT_LOCK_V1.md`.
- [Prototype directory](../../tools/willicat_asset_factory_phase0/README.md): pure contracts, temporary filesystem proof, diagnostic Forge timing wrapper, bounded probe, two Godot diagnostic scripts, tests; `.gdignore` keeps tooling out of the game import tree.
- Eleven versioned JSON files under `tools/willicat_asset_factory_phase0/contracts/`: tree schema/profile, transition rules, approval payload/envelope, review record, projection schema/recipe, bundle receipt, rights action mapping and predicate context.
- [Evidence directory](../../artifacts/asset_factory/phase_0_contract_lock_v1/README.md): receipts, actual logs, test-only public signature fixtures, negative control and protected-file inventory. No private signing key or copied raw art is retained there.

## Contracts frozen and prototypes executed

| Area | Actual result | Production boundary |
|---|---|---|
| Pilot schema/transition | Only `animated_environment.tree.phase0.v1`; all 12 stages, 11 adjacent transitions, required stage data, named validators and meaningful evidence | Nine-category Factory/orchestrator not built |
| Authentication | RSA-PSS/SHA256 public verification, canonical payload + semantic contract hash, tamper/credential/role/revocation rejection | External human signing authority and protected trust/publisher account not configured; publication blocked |
| World projection | Actual Home tree extraction; five determinism/relevant/unrelated/order/missing-field cases passed | Historical whole-file/script snapshot recorded separately; future approved template still required |
| Timing | Godot 4.7.2 native weighted frames at speed 1000 preserve diagnostic `[100,300,150,450]` ms exactly through export/load and playback ordering | Diagnostic only; existing 4-frame/5-FPS tree unchanged; no motion-quality approval |
| Immutable bundle/import parity | One compile in final candidate cycle; candidate/proof/simulated-approval/simulated-release hashes identical; fresh import parameters also equal | All resource/source copies remain temporary; no actual approval/publication |
| Filesystem | Temporary-root restriction, traversal/symlink/write-once/atomic/locking/interruption/partial-copy tests passed | Not a deployed adversarial race-proof publisher; different enforced privilege boundary still required |
| Rights | Existing eight scopes; exact action/scope/revision checks, unresolved/prohibited fail closed; DEV ≠ production | No new legal clearance or provider adapter |
| Motion/predicate | Required current machine policy results + qualified animator criteria + separate visual/authentication veto; pure derived predicate rejects all 17 requested failure cases and writable override | Test approvals/calibrations synthetic; original tree remains ineligible |

Projection hash: `578bf3741f2850400053cec1fad10158927711e95410079376a5482f7593c150`. Final diagnostic bundle hash: `ba575e84c9e5291e520d0fa5cabc4bf5eaa2c6c8235dfab4595d2c2f50c76aab`. All four parity fields equal that bundle hash; `approved_bundle_hash` is explicitly simulated identity, not a real human approval.

## Tests and evidence

- **80/80 Phase 0 tests passed, 0 failures, 0 errors**: [machine receipt](../../artifacts/asset_factory/phase_0_contract_lock_v1/contract_test_results.json), [log](../../artifacts/asset_factory/phase_0_contract_lock_v1/contract_tests.log). Includes schema/empty fields, transitions, public verification/tamper/revocation, action rights, projection, timing, byte/path/import parity, immutable/atomic/concurrent writes, all 17 predicate failures, missing named validator evidence, uncalibrated/stale policy and animator veto.
- **Asset Forge 62/62 before and after**; no source/API change. The diagnostic wrapper composes its unchanged uniform exporter. [Regression receipt](../../artifacts/asset_factory/phase_0_contract_lock_v1/regressions.json).
- Existing **continuous Home, proxy café, true vertical slice pass with exit code 0** in isolated source copy; existing first-party/proxy spatial parity also passes 39 entries. Earlier sandbox user-directory failures are retained and not counted as passes.
- **750 protected original game/Forge files unchanged**, including assets/scenes/scripts/tests/project and Forge code: [integrity receipt](../../artifacts/asset_factory/phase_0_contract_lock_v1/protected_integrity.json).
- [Negative control](../../artifacts/asset_factory/phase_0_contract_lock_v1/negative_control.json) retains the unmodified Mini Pack tree with dimension/runtime diagnostics but no fabricated canonical motion/visual/final review. Fixture mode is disabled by default and never authorizes production.

## Unresolved items and authorization

Motion/root/baseline/scale/seam limits remain `CANDIDATE_REQUIRES_CALIBRATION`. Approved style calibration, future tree template/source registration, rights-permitted first-party source evidence and human reviews are not supplied by Phase 0. Before production, human must configure the external credential/registry and an agent-inaccessible publisher/build boundary. Future protected ledger/context resolution and real validators remain MVP work; this spike does not claim them implemented.

These are explicit stage/deployment requirements, not missing Phase 0 serialization/verifier/timing/parity contracts. **No critical Phase 0 failure remains in final evidence.** Human may review for one tree MVP implementation slice; no implementation starts automatically. No art generation, Mini Pack 002, provider integration, GUI/scheduler/skill, original gameplay modification, production path publish, commit or push was performed.
