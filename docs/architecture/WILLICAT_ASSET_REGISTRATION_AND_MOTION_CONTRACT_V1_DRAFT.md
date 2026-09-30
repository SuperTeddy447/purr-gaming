# WilliCat registration and motion contract V1 — hardened draft

**PROPOSED; no art or world change authorized.** The current Home's transforms, navigation, gameplay roots, save IDs, camera and semantic anchors are read-only authority. Templates are created from that geometry before SOURCE. Canonical category/stage/gate vocabulary and JSON types are in the [manifest schema](WILLICAT_ASSET_MANIFEST_SCHEMA_V1_DRAFT.md); validator responsibilities and environment boundaries are in the [ecosystem standard](WILLICAT_ASSET_ECOSYSTEM_STANDARD_V1_DRAFT.md).

## Registration and authority trace

At `template`, every world-bound category records `template_id`, `template_version`, `world_authority_ref`, `world_authority_revision` **or** `world_authority_content_hash`, `compatibility`, `invalidation_relationship` and typed `registration`. The registration holds `source_canvas_px`, `world_units_per_source_px`, `pivot_px`, `floor_baseline_px`, `ground_contact_region_px`, `footprint_world`, `depth_policy`, `collision_profile_ref`; optional `shadow_anchor_world`, `cell_rect_px`, `padding_px`, `occluder_refs`, `interaction_anchor_refs` are required by a category only when its declared function needs them. A visual's alpha bounds never substitute for footprint/collision. `GameplayRoot` owns Y sort and existing semantics; `VisualRoot` owns rendering.

**UNMEASURED** geometry stays at `spec` until extracted from Home data and captured in a versioned template. The previously measured Home 32-unit logical placement cell, Tiny Swords 64-pixel art tile and Mini Pack 256-pixel export/64-world-unit mapping are evidence that art pixels, world span and logical placement are independent, **not** default production dimensions. If Home geometry changes, assets referencing the old authority revision become stale under `invalidation_relationship`; compatibility must be reviewed, never repaired by moving world objects.

## Typed connector contract

Each `connectors[]` item has `connector_id`, `connector_role`, `coordinate_space` (`source_px` or `template_world_local`), exactly one of `exact_local_position` or `exact_local_segment`, `profile_id`, nonempty `compatible_profile_ids`, `edge_orientation`, `registration_ref`, and `tolerance_policy_ref`. The role/edge identifies left, right, top, bottom, depth or threshold joins. A validator can test declared reciprocal profile compatibility, transform each connector through the shared registration, compare exact local endpoints/segments and verify the intended neighbor. `tolerance_policy_ref=EXACT` is a valid exact policy; any uncalibrated policy is recorded as `CANDIDATE_REQUIRES_CALIBRATION`, which cannot be treated as a measured pass.

For `wall_module`, the template fixes canonical module dimensions in `template.registration.source_canvas_px` and `footprint_world`, plus `grid_span_cells` and `module_span_world` extracted from the authority reference, `floor_baseline_px`, left and right connector records, top/bottom/depth connectors if applicable, allowed neighbors via compatible profiles, and front/rear occluder refs/depth policy. The exact numeric dimensions and connector coordinates are **UNMEASURED** in this draft. `V-CONNECTOR` checks every declared neighbor seam before a module can be promoted. A common canvas alone cannot prove that trim, floor edge or architecture joins.

## Typed door aperture and building layers

Each `apertures[]` item has `aperture_id`, `walkable_aperture_world` (authoritative-world region), `visual_aperture_px` (source-pixel region), `opening_width_world`, `opening_baseline_world`, `threshold_region_world`, `left_wall_connector`, `right_wall_connector`, `front_occluder_ref`, `depth_crossing_rule`, `approach_anchor_refs`, `door_interaction_ref`, `navigation_authority_ref` and `registration_ref`. `V-APERTURE` transforms the visual polygon with the template pivot/scale, compares it with the referenced world opening and actor envelope, and produces an overlay/crossing proof. It may reject art; it may not rewrite navigation. The opening's numeric width/baseline remains **UNMEASURED** until extracted from Home.

At TEMPLATE the `building_shell` declares `template.building_layer_roles`. At NORMALIZED, each `building_layers[]` export has semantic `role`, `asset_ref`, `registration_ref`, `canvas_rect_px`, `depth_policy`. A traversable shell requires shared registration for `rear_base`, `interior_readable`, `front_occluder`, `door_aperture`; `roof_canopy` is optional. `V-LAYER-REGISTRATION` verifies matching canvas/root and meaningful interior/foreground roles. A flat exterior image with transparent pixels cannot satisfy these typed roles. Actor proof requires outside, threshold crossing, interior and front-occluder depth positions.

## Furniture and terrain registration

Furniture keeps `GameplayRoot`, footprint, collision, seat/service anchors and world transform fixed. `template.direction_plan` declares required views before art; NORMALIZED `directions.authored`, `direction_semantics`, `mirror_allowed` and frame refs record actual raster views. `mirror_allowed=false` unless a specific family receives human approval. Direction switching changes only `VisualRoot`; each view shares the approved pivot/baseline and declared occluder/shadow relationship. `V-DIRECTION` and `V-WORLD-INTEGRITY` test every view with actor approach/sit/stand/depth at one world transform. Chair, loveseat and booth need their own footprint and slot model.

Terrain TEMPLATE records `template.terrain_plan` with `art_tile_px`, `world_tile_span`, `logical_placement_cell_world` and required/supported roles. NORMALIZED `terrain` records actual atlas rectangles, roles, neighbor masks and optional edge/elevation/shadow/overlay refs. `V-TERRAIN-COMPLETE` and `V-ADJACENCY` enforce declared grammar and join coverage. Animated overlays share static bank/ground registration; terrain art never determines nav/collision. The detailed grammar is in the [terrain standard](WILLICAT_TERRAIN_ANIMATION_VFX_UI_STANDARD_V1_DRAFT.md).

## Five independent animation axes

`direction` is authored facing, `action` is activity, `state` is condition, `variant` is alternate look/size/palette, and `timeline` is an ordered `frame_map` plus `durations_ms`. Character `walk/down` is an action/direction clip; chair `N…NW` is a set of static directions; fire `small/medium/large` is a variant family; machine `off → idle → brewing → completed` is a state sequence. Sheet shape or suffix never establishes any of these axes. Missing views are not synthesized by implicit rotation or mirroring.

## Motion clip and quality contract

At TEMPLATE, `template.motion_plan` declares intended motion classes and intent reference. At NORMALIZED, every animated `motion_clip` carries `clip_id`, `motion_class`, `motion_intent`, `frame_map`, `durations_ms`, `timing_intent`, `loop_mode`, `rest_frame`, `root_lock`, `baseline_lock`, `transform_policy`, `silhouette_motion_policy`, `loop_seam_policy`, `phase_policy`, `interruptible`; action/state/direction/variant are added where meaningful, and `completion_event` is required for one-shot VFX. The named policies express intent; `V-FRAME` checks counts/order and `V-MOTION` checks contact traces, silhouette arc and loop seam. Per-frame durations permit authored non-linear timing; no universal frame quota or 100 ms rule applies.

| Motion class | Category-specific behavior and evidence |
|---|---|
| `ambient_sway` | Trunk/root and baseline locked; foliage-led lateral/bending arc, legible rest/acceleration/eased extreme/hold/return/possible overshoot/settle; whole-sprite scale pulse forbidden, rigid equal-distance ping-pong discouraged. Loop seam required, separate ground shadow registered, actor crossing reviewed. |
| `ambient_flutter` | Local flutter/travel with region/depth/phase declared; no synchronized repeated pattern by accident. |
| `water_loop` | Static nav surface plus visual ripple/foam overlay; edge registration and seam; independent instances may use phase offsets. |
| `machine_loop` | Stable housing and moving part; off/idle/brewing/completed states, transitions and interruption declared. |
| `one_shot_vfx` | Onset/peak/dissipation, semantic trigger, completion event and hide/reset behavior. |
| `character_idle`, `character_walk` | Fixed logical floor root, direction-specific frame and foot baseline; transitions respect existing velocity/collision. |
| `ui_feedback` | Normal/pressed/selected/disabled semantic state and timed response, legible over world. |

`ambient_sway` can encode `root_lock=true`, `baseline_lock=true`, `transform_policy.whole_sprite_scale=forbidden`, `silhouette_motion_policy=foliage_led`, `loop_seam_policy.requirement=required`, `timing_intent=authored_arc`, and independent `phase_policy` (`fixed`, `random_start`, `offset_by_instance`). A fixed canvas or frame count cannot establish motion quality. Tiny Swords' equal documented 100 ms source rhythm is not evidence that asymmetric durations are universally required; Mini Pack's registered four-frame loop still failed human motion judgment. Root-drift, silhouette-area, centroid and seam thresholds remain **CANDIDATE_REQUIRES_CALIBRATION** from human-approved first-party examples and gameplay-camera review. No numerical pass is invented here.
