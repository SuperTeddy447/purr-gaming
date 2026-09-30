# WilliCat asset ecosystem standard V1 — hardened draft

Status: **PROPOSED architecture input, not production approval.** The continuous Home's Godot coordinates, navigation, gameplay roots, save IDs, camera and semantic anchors are authoritative. Generated art fits the world; the world is never moved to fit art. Provider research remains in the [evidence report](../research/WILLICAT_ASSET_PROVIDER_PRODUCTION_BEST_PRACTICES_RESEARCH_V1.md). The typed data and stage requirements are in the [manifest schema](WILLICAT_ASSET_MANIFEST_SCHEMA_V1_DRAFT.md).

## Canonical vocabulary

**Categories:** `terrain`, `wall_module`, `door_or_entrance`, `building_shell`, `furniture`, `animated_environment`, `character`, `vfx`, `ui`.

**Lifecycle stages:** `spec → template → source → normalized → structurally_validated → motion_validated → visual_qa → preview → prefab → runtime_validated → cataloged → human_approved`.

**Gate IDs:** `rights`, `structural`, `motion`, `visual`, `runtime`, `human`. Each gate status is `not_started`, `pending`, `passed`, `failed` or `not_applicable`. Rights use-scope outcomes are separately `permitted`, `prohibited`, `unresolved` or `not_applicable`; they are never collapsed to one blanket `cleared` flag. Historical `technical_pass` in the research report means structural/runtime evidence, **not** visual or human approval.

**Authority terms:** `world_authority_ref` identifies the existing Home source; `template_id`/`template_version` are immutable geometry/presentation templates; `style_family_id` identifies a calibration artifact with `approved`/`unapproved` status. No visual palette or style is selected here. `production_ready` is **derived**, never manually writable.

## Lifecycle and formal transitions

| From completed stage | Next stage | Required transition condition | Failure action |
|---|---|---|---|
| `spec` | `template` | Authority reference and rights identity recorded; category profile selected. | Stay at `spec`; resolve missing identity or measurements. |
| `template` | `source` | Template has category geometry/layout, authority revision/hash, compatible registration; style calibration approved; needed generation/reference rights scopes permitted. | Stay at `template`; no source production from incomplete template. |
| `source` | `normalized` | Source files/version/hash and input rights trace complete. | Keep source candidate; new source edit creates new version. |
| `normalized` | `structurally_validated` | `V-SCHEMA`, `V-PROVENANCE` and category structural validators passed; `structural=passed`. | Quarantine; no production-world import. |
| `structurally_validated` | `motion_validated` | `motion=passed`, or profile-declared static `not_applicable`. | Remain at previous stage; revise source/version and repeat downstream gates. |
| `motion_validated` | `visual_qa` | Art lead records `visual=passed` with family and cross-family evidence. | Visual veto; no production promotion. |
| `visual_qa` | `preview` | Required neutral, registration, motion/actor and adjacency evidence exported. | Complete evidence before progressing. |
| `preview` | `prefab` | Approved visual bound to existing semantic `GameplayRoot` through `VisualRoot`; no coordinate repair. | Reject binding and revise asset/template. |
| `prefab` | `runtime_validated` | Controlled integration proof passes route, depth, interaction, event and authority-integrity checks; `runtime=passed`. | Return to prior completed stage; preserve failure evidence. |
| `runtime_validated` | `cataloged` | Versioned catalog entry links source, template, preview, all gate records and supersession. | Catalog incomplete; no production approval. |
| `cataloged` | `human_approved` | Human reviewer records `human=passed` from moving-world evidence; rights scopes for intended production/distribution permitted. | Remain cataloged but unapproved. |

A gate may transition `not_started → pending → passed | failed`. A `failed` gate may return to `pending` after a documented correction/review; the failed review record remains. Source-pixel or geometry changes create a new asset/template version and invalidate dependent downstream passes. `not_applicable` can be assigned only by the category profile with evidence. A later authority revision invalidates compatibility until reviewed; it never silently moves art or Home objects. Stage names represent the highest **completed** stage; failure does not advance the stage. No direct stage skips are allowed.

## Environments and promotion

| Environment | Permitted content and minimum gate/rights state | Boundary |
|---|---|---|
| `analysis_preview` | Read-only inventory/metadata and catalog preview; `structural_study` scope recorded, including unresolved production rights. | No production import or generative conditioning. |
| `isolated_asset_sandbox` | Explicit disposable scene for evaluating a candidate; schema identity and requested `dev_runtime` scope permitted. Structurally failed assets may appear **only quarantined here** to diagnose failure. | No continuous Home binding, save identity or production catalog promotion. |
| `integration_proof` | Separate controlled DEV proof after `structural`, applicable `motion` and `visual` pass, `dev_runtime` permitted, template current. Runtime gate is evaluated here with a moving actor. | Does not itself confer production approval. |
| `production_world` | `human_approved`, `production_ready=true` derived, current authority compatibility and required production rights scopes permitted. | Failed, unresolved or visually unapproved assets never enter. |

An empty café screenshot never establishes runtime/visual acceptance. Depth and entrance proof includes a moving actor before/behind layers, through a threshold, around furniture and along the continuous route. The production-world prohibition does not prevent an isolated diagnostic scene.

## Package, template and style-family traceability

Proposed package identity is `family_id/asset_version`. Preserve immutable `spec`, `template`, editable `source`, reproducible `normalized` export, manifest, QA evidence, preview and prefab references. A source records `source_asset_version`, hashes, input references and optional `supersedes`. Its template records `template_id`, `template_version`, `world_authority_ref`, revision or content hash, compatibility authority refs, optional `supersedes` and `invalidation_relationship`. An authority revision change marks dependent assets stale until a compatibility review; the relation is specified here, not implemented. A visual variant never creates a new gameplay identity.

An approved **style-family calibration artifact** is a reference record, not newly generated art. Its typed refs identify projection rules (`projection_rules_ref`), gameplay camera (`gameplay_camera_ref`), actor/object scale (`scale_hierarchy_ref`), contour/edge language (`contour_edge_language_ref`), shadow language (`shadow_language_ref`), material vocabulary (`material_vocabulary_ref`), value hierarchy (`value_hierarchy_ref`), detail frequency (`detail_frequency_ref`), saturation policy (`saturation_policy_ref`), actor/object comparison (`actor_object_comparison_ref`) and cross-family contact sheet (`cross_family_contact_sheet_ref`). `style_family_id` may be present at SPEC while `style_calibration.status=unapproved`; SOURCE requires `approved` with these evidence refs. Jade is not mandatory and Japanese Countryside Storybook is not locked.

Prefab handoff preserves `GameplayRoot` (existing transform, collision, nav, anchors, ID) and binds `VisualRoot` (scale, pivot, direction/frame map). Optional `Shadow` and explicit front occluder follow typed references. Room scripts do not crop or rescale a sheet to hide registration errors. Source and runtime exports remain separately traceable.

## Schema validation versus content validation

`V-SCHEMA` checks JSON syntax, types, nonempty values, stage-required containers and enum values. The following are **specified responsibilities only**; validators are not built by this task. Every validator returns `passed` or `failed` (or profile-authorized `not_applicable`) and emits a versioned review record with evidence refs. Input always includes the manifest/asset version and relevant authority/template revision.

| Validator ID | Categories | Gate | Specific input | Pass/fail criterion | Evidence output / owner role |
|---|---|---|---|---|---|
| `V-SCHEMA` | All | structural | Manifest JSON and stage profile | Draft JSON Schema and stage presence valid. | Parse/profile report; structural validator. |
| `V-PROVENANCE` | All | rights, then each use boundary | Scope assessments, license/creator evidence, intended use | Required scope is `permitted`; `unresolved`/`prohibited` block that use. | Scope decision with source refs; rights owner. |
| `V-REVIEW-EVIDENCE` | All | every gate | Gate statuses and review records | Passed gate has same-version timestamped owner/evidence/result; no self-declared production boolean. | Gate audit report; catalog owner. |
| `V-FRAME` | Animated environment, character, VFX, animated furniture/UI/terrain | structural | Frame map, source cells, durations, export hashes | Counts match; no duplicate/missing frames or gutter clipping. | Frame/contact-sheet report; structural validator. |
| `V-CONNECTOR` | Wall, door, shell, connected terrain | structural | Typed connectors, template geometry, intended neighbors | Reciprocal compatible profiles, orientation, registration and exact join geometry agree under referenced tolerance policy. | Join overlay/report; technical artist. |
| `V-APERTURE` | Door, shell | structural | Typed visual aperture, authoritative walkable opening, nav ref, actor envelope | Visual opening/threshold/occluder align to existing walkable opening; no nav edit. | Aperture overlay and actor crossing refs; technical artist/world owner. |
| `V-LAYER-REGISTRATION` | Building shell | structural | Typed building layers and shared canvas/root | Required semantic roles exist and share registration; exterior-only image fails traversable profile. | Layer composite/depth report; technical artist. |
| `V-TERRAIN-COMPLETE` | Terrain | structural | Supported/required roles, atlas entries, completeness claim | Production-family pass requires `completeness_claim=complete` and every declared required role covered; `partial` remains eligible only for isolated evaluation. | Role coverage matrix; terrain technical artist. |
| `V-ADJACENCY` | Terrain | structural | Neighbor masks, atlas edges/corners, allowed joins | Every declared neighbor combination has intended join and no measured seam/overlap failure. | Neighborhood mosaic/report; terrain technical artist. |
| `V-DIRECTION` | Furniture, character | structural | Authored directions, frame refs, mirror policy, semantic labels | Each required facing present and registered; no inferred mirror/view. | Direction contact sheet; technical artist. |
| `V-MOTION` | Animated environment, character, VFX and animated variants | motion | Root/baseline traces, silhouette/centroid path, frame durations, seam, motion policy | Intent and locks respected; seam/phase/one-shot event reviewed. Numeric limits remain `CANDIDATE_REQUIRES_CALIBRATION`. | Trace and scene-speed loop refs; technical animator. |
| `V-SCALE` | World-bound categories | structural + visual | Family camera reference, world scale, registration, actor comparison | No unintended per-frame/per-direction/cross-family scale drift; unresolved tolerance cannot be auto-passed. | Overlay and camera composite; technical artist/art lead. |
| `V-UI-STATE` | UI | structural + visual | UI states, hit/slice/fill binding, runtime event | Declared semantic states and dynamic fill work and read at portrait size. | State contact sheet and interaction proof; UI/art lead. |
| `V-WORLD-INTEGRITY` | All runtime-bound categories | runtime | Prefab, world authority revision, existing IDs/transforms/nav/anchors | Visual swap preserves authoritative world data and route. | Spatial parity, route and moving-actor captures; runtime owner. |

Visual/art-lead and final human review remain separate human decisions with the same review-record format; no automated validator may set `visual` or `human` to `passed` on its own. Structural and motion diagnostics inform those decisions.

## Production-ready predicate and unresolved measurements

`production_ready` is true only if: stage is `human_approved`; `rights`, `structural`, `visual`, `runtime`, `human` gates are `passed`; `motion` is `passed` or profile-declared `not_applicable`; required production-runtime use scope is `permitted` and publication/distribution scope is `permitted` when shipping; style calibration is `approved`; template/source/world-authority revisions are compatible; required category validators and review evidence pass; prefab/catalog references exist. No manifest boolean can override this predicate.

Canonical module dimensions, wall connector coordinates, door widths, root-drift bounds, scale-drift bounds and animation timing quotas remain **UNMEASURED** or **CANDIDATE_REQUIRES_CALIBRATION**. Extract geometry from the existing Home world authority and calibrate motion against human-approved first-party examples before assigning tolerance-policy values. Unknown numerical policy cannot produce a fabricated automated PASS.
