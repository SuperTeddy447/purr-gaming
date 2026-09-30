# WilliCat asset specification hardening V1 — result

Status: **documentation/schema hardening only**. No art, gameplay/world scene, navigation, Asset Factory, validator implementation, skill, Mini Pack 002, commit or push was produced. The provider [evidence report](../research/WILLICAT_ASSET_PROVIDER_PRODUCTION_BEST_PRACTICES_RESEARCH_V1.md) retains its conclusions and final ten rules. Detailed normative drafts: [ecosystem](WILLICAT_ASSET_ECOSYSTEM_STANDARD_V1_DRAFT.md), [registration/motion](WILLICAT_ASSET_REGISTRATION_AND_MOTION_CONTRACT_V1_DRAFT.md), [manifest](WILLICAT_ASSET_MANIFEST_SCHEMA_V1_DRAFT.md), [terrain/VFX/UI](WILLICAT_TERRAIN_ANIMATION_VFX_UI_STANDARD_V1_DRAFT.md), [provenance](../production/WILLICAT_PROVIDER_PROVENANCE_POLICY_V1_DRAFT.md).

## 1. Issues fixed

The previous manifest required SOURCE/PREFAB data at SPEC, used untyped connector/aperture objects, omitted terrain world span and motion-intent fields, and mixed gate/provenance vocabularies. The hardened drafts now distinguish base data from stage/category obligations, give typed structures and role-specific content validators, and define isolated evaluation separately from the production world. No previously approved principle was reopened.

## 2. Schema changes

The embedded JSON Schema 2020-12 has `lifecycle_stage`, nine canonical categories, base identity/provenance/gate records, typed `$defs` for coordinates, connectors, apertures, building layers, terrain tiles/families, motion clips and review records. `allOf` stage/category conditionals require later containers and gate statuses progressively. TEMPLATE records planned terrain/layers/directions/motion; NORMALIZED records actual tiles/layers/frames. Remaining cross-field/category rules are explicit content-validation profiles, not falsely claimed as JSON-only enforcement. Empty semantic placeholders are disallowed; missing stage data is omitted until required.

## 3. Canonical lifecycle stages

`spec → template → source → normalized → structurally_validated → motion_validated → visual_qa → preview → prefab → runtime_validated → cataloged → human_approved`. The stage records the highest completed step. Failed gates leave it at the prior step; correction/review may retry, retaining the failure record.

## 4. Category profiles

`terrain`, `wall_module`, `door_or_entrance`, `building_shell`, `furniture`, `animated_environment`, `character`, `vfx`, `ui`. The manifest table specifies required, optional and not-applicable data, validators and category-specific human evidence without duplicating the base. Motion may be `not_applicable` only for profile-declared static content.

## 5. Typed connector model

`connector_id`, `connector_role`, `coordinate_space`, exactly one of `exact_local_position`/`exact_local_segment`, `profile_id`, `compatible_profile_ids`, `edge_orientation`, `registration_ref`, `tolerance_policy_ref`. `V-CONNECTOR` checks reciprocal intended compatibility and registered geometry. Uncalibrated tolerance uses `CANDIDATE_REQUIRES_CALIBRATION`, never a fabricated numeric pass.

## 6. Typed aperture model

`walkable_aperture_world`, `visual_aperture_px`, `opening_width_world`, `opening_baseline_world`, `threshold_region_world`, `left_wall_connector`, `right_wall_connector`, `front_occluder_ref`, `depth_crossing_rule`, `approach_anchor_refs`, `door_interaction_ref`, `navigation_authority_ref`, `registration_ref`. `V-APERTURE` compares projected art against existing authoritative walkable geometry and actor crossing; navigation is not edited.

## 7. Terrain grammar model

TEMPLATE `terrain_plan` separates `art_tile_px`, `world_tile_span`, `logical_placement_cell_world`, `supported_roles` and `required_roles`. NORMALIZED `terrain` adds `completeness_claim`, typed atlas entries with `atlas_rect_px`, `terrain_role`, `neighbor_mask`, and optional edge/elevation/stair/cliff/shadow/overlay/phase refs. Roles include base, variation, path, edge, both corners, threshold, bank, water, elevation, stair, cliff, shadow and animated overlay. `V-TERRAIN-COMPLETE` prevents a partial family from passing as production-complete; `V-ADJACENCY` checks declared joins.

## 8. Motion model

Typed clips include `motion_class`, `motion_intent`, `frame_map`, `durations_ms`, `timing_intent`, `loop_mode`, `rest_frame`, `root_lock`, `baseline_lock`, `transform_policy`, `silhouette_motion_policy`, `loop_seam_policy`, `phase_policy`, `interruptible`, conditional `completion_event`. Tree sway can require locked contact/baseline, foliage-led authored arc, forbidden whole-sprite scale pulse and mandatory seam without imposing a frame-count/FPS quota. Human scene-speed review remains necessary.

## 9. Validator responsibility matrix

| Gate | Named responsibilities |
|---|---|
| `rights` | `V-PROVENANCE` evaluates evidence-backed use scopes. |
| `structural` | `V-SCHEMA`, `V-FRAME`, `V-CONNECTOR`, `V-APERTURE`, `V-LAYER-REGISTRATION`, `V-TERRAIN-COMPLETE`, `V-ADJACENCY`, `V-DIRECTION`, structural part of `V-SCALE`. |
| `motion` | `V-MOTION` checks contact, silhouette path, timing, seam and events. |
| `visual` | Art-lead review of camera composites, family cohesion and scale; diagnostics inform but do not grant approval. |
| `runtime` | `V-WORLD-INTEGRITY`, applicable `V-UI-STATE` binding, moving route/prefab proof. |
| `human` | Final reviewer decision; `V-REVIEW-EVIDENCE` audits same-version record/evidence existence. |

The ecosystem draft defines each validator's applicable categories, input, pass/fail criterion, evidence output and owner role. None is implemented here.

## 10. Formal gate/state transition table

Gate status: `not_started → pending → passed | failed`; a failed gate may return to `pending` with a new review record. A source/template revision invalidates dependent downstream passes. `not_applicable` is profile-authorized only. Stage transitions are one step at a time per the ecosystem table. `production_ready` is **derived**, never writable: human-approved stage, all applicable gates passed, production use scopes permitted, approved style calibration, current authority compatibility, runtime/catalog refs and evidence.

## 11. Sandbox versus production policy

`analysis_preview` supports read-only technical study; `isolated_asset_sandbox` permits quarantined diagnostics with DEV rights; `integration_proof` requires structural, applicable motion and visual passes plus DEV rights; `production_world` requires derived `production_ready`. A structurally failed asset cannot enter continuous production Home to test its appearance. An isolated diagnostic scene is not production promotion.

## 12. Unified provenance/use-scope model

Scope outcomes: `permitted`, `prohibited`, `unresolved`, `not_applicable` for `structural_study`, `dev_runtime`, `production_runtime`, `modification`, `raw_redistribution`, `generative_conditioning_reference`, `ai_training`, `publication_distribution`. `rights` is the gate for the scopes needed at a transition; no single clearance boolean covers every use. Existing unresolved/conflicting local-pack findings remain unresolved.

## 13. Template/version traceability

Source records `source_asset_version`, hashes, inputs and optional `supersedes`. Template records `template_id`, `template_version`, authority ref plus revision/hash, compatibility refs, optional supersession and `invalidation_relationship`. Authority revision changes identify dependent assets for review; no invalidation code is built.

## 14. Style-family calibration concept

`style_family_id` references a calibration artifact with `approved`/`unapproved` status and evidence. The artifact describes projection, gameplay camera, actor/object scale, contours, shadows, materials, value/detail/saturation hierarchy and cross-family contact sheets. No style is selected or generated. SOURCE requires approved calibration.

## 15. Intentionally unresolved values

Wall/module sizes, connector coordinates, doorway width/baseline, tree root/area/centroid/seam thresholds, scale drift and timing quotas remain **UNMEASURED** or `CANDIDATE_REQUIRES_CALIBRATION`. Extract geometry from current Home authority; calibrate motion/visual limits against human-approved first-party examples. Exact third-party package rights, actor-facing maps and local/archive discrepancies retain their prior unresolved status.

## Validation performed

The embedded JSON Schema parsed as JSON; 49 internal `$ref` targets resolved to local `$defs`; all seven updated/new documents had valid local relative links in the staged tree/repository; and a terminology search found no remaining obsolete writable gate/provenance names in the six drafts. The research report changed only by a canonical-terminology note; its final ten rules remained byte-for-byte unchanged. **No example manifest is included**, so no instance was claimed to pass stage/category validation. A full JSON Schema engine/content-validator run was not performed; no validator exists in this task. These checks are document consistency evidence, not production-asset PASS.

## 16. Readiness assessment

**A. SPECIFICATIONS HARDENED — READY FOR ASSET FACTORY ARCHITECTURE REVIEW.** The drafts now specify data shape, stage/category obligations, state transitions, use-scope rights, validator ownership, environment boundaries and human approval without fabricating dimensions. Architecture review must still decide implementation strategy and eventually obtain authoritative measurements/calibration before asset production. This is **not** approval to build the Asset Factory or generate art.
