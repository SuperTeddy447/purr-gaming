# WilliCat Phase 0 contract proofs

Limited, separable prototype; **not the Asset Factory MVP or a production publisher**. Frozen contracts live in `contracts/`. No production signing key or art is included.

| Module | Scope |
|---|---|
| `contracts.py` | Schema/content obligations, canonical serialization, projection hash, public signature verification, pure transitions/eligibility. |
| `filesystem.py` | `/private/tmp` only: traversal/symlink checks, write-once files, locked atomic pointers, hash/copy parity simulation. |
| `timing.py` | Diagnostic explicit horizontal frame weights over unchanged Forge exporter. |
| `probe.py` | Reuse existing art into temporary diagnostic bundle, load/play in Godot and simulate same-byte promotion. |
| `extract_authority.gd` | Read-only Home tree extraction in temporary project copy. |
| `timing_probe.gd` | Nonuniform timing load-back/playback in temporary project. |
| `tests/` | Synthetic signed fixtures and negative cases; no production key or asset approval. |

Use existing Forge venv (Python/jsonschema/Pillow), installed Godot and `/usr/bin/openssl`; no new dependencies were installed. Review the Phase 0 document before rerunning. Prototype writes require isolated temporary roots; schema validation does not perform production deployment. Signature tests generate a disposable RSA test key and delete it; test-only public fixtures remain diagnostic evidence.

From repository root, contract tests (they update diagnostic fixture receipts only):

```sh
PHASE0_REPO="$PWD" \
PHASE0_EVIDENCE_DIR="$PWD/artifacts/asset_factory/phase_0_contract_lock_v1" \
PYTHONPATH="$PWD/tools" \
tools/willicat_asset_forge/.venv/bin/python tools/willicat_asset_factory_phase0/tests/run.py
```

Timing proof requires a **new** temporary work root and extracted `authority_snapshot.json`; output is diagnostic, not approved source. `probe.py` does not copy or modify Home or publish into the repository. Isolated Godot project copies must contain existing data/resources needed by regressions, use a distinct diagnostic user-data directory and retain original scene/script/asset bytes. Permission to write that diagnostic user-data directory may be required by the execution sandbox.

```sh
PYTHONPATH="$PWD/tools" tools/willicat_asset_forge/.venv/bin/python \
  -m willicat_asset_factory_phase0.probe "$PWD" \
  /private/tmp/willicat_phase0_fresh_run \
  "$PWD/artifacts/asset_factory/phase_0_contract_lock_v1"
```

Production credential provisioning, protected ledger resolution, race-resistant publisher/deployment isolation, real motion validators/calibration, catalogs, providers and pilot generation are deliberately absent. `allow_test_fixture=True` is never a production capability; default verification refuses those credentials. Test labels and role strings authenticate no human.
