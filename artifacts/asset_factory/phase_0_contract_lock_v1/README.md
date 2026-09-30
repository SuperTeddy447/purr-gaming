# Phase 0 evidence

Final diagnostic receipts, not production asset approval. `test_only_*` files use a public ephemeral credential labeled **TEST FIXTURE — NOT PRODUCTION TRUST ROOT** and synthetic reviews/calibrations. The private fixture key was deleted by the test harness. Fixture artifact bytes are base64 test strings, not raw third-party or newly generated art.

| Evidence | Meaning |
|---|---|
| `contract_test_results.json`, `contract_tests.log` | Actual final contract suite; individual negative cases named. |
| `authority_snapshot.json`, `authority_extract.log`, `authority_provenance.json`, `world_projection.json`, `projection_tests.json` | Read-only extracted Home facts, historical file/script identity and canonical compatibility proof. |
| `timing_round_trip.json`, `timing_import.log`, `timing_playback.log` | Real Godot export/load/playback timing proof using unchanged existing art in temporary files. |
| `candidate_bundle_receipt.json`, `processing_receipt.json`, `bundle_parity.json`, `import_parity.json`, `simulated_release_import.log` | Exact source/tool/member/path identities and simulated promotion/import equality; no authenticated production approval. |
| `test_only_signed_manifest.json`, `test_only_context.json`, `test_only_trust.json`, `test_only_artifact_bytes.json` | Persisted reproducible public verification fixture; default verifier rejects fixture trust. |
| `negative_control.json` | Actual old tree observations; no invented final reviewer decision. |
| `forge_before.log`, `forge_after.log`, `regressions.json`, `*_regression.log`, `first_party_spatial_parity.log` | Actual baseline outcomes with no scene/test edits. |
| `initial_sandbox_import.log`, `initial_sandbox_home.log` | Earlier environment-denied attempts retained; not passing results. |
| `protected_before.json`, `protected_integrity.json` | Original game/Forge hash inventory and unchanged comparison. |
| `evidence_index.json`, `document_validation.json` | Final evidence/source contract hashes and links/schema/fixture consistency checks. |

The bundle PNGs/resources exist only under temporary diagnostic roots. Godot import cache is regenerated, excluded from content identity, and effective importer policy is compared separately. Production root/trust provisioning and human implementation authorization remain absent.
