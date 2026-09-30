# WilliCat asset manifest schema V1 — hardened draft

Status: **PROPOSED architecture input, not an implemented validator or approved asset factory.** This replaces the former all-fields-at-SPEC interpretation with `BASE MANIFEST + lifecycle_stage + category profile`. The current continuous Home remains world/spatial authority; source art cannot change its geometry. Canonical stage, gate, scope and category names in this document are used by the other five drafts. No unmeasured geometry or motion tolerance is assigned a number.

## Canonical model

- **Base at `spec`:** `schema_version`, `asset_id`, `asset_version`, `category`, `family_id`, `style_family_id`, `lifecycle_stage`, `provenance`, `gates`. `world_authority_ref` is required by world-bound category profiles; UI instead records `template.ui_layout_authority_ref`.
- **Stage progression:** `spec → template → source → normalized → structurally_validated → motion_validated → visual_qa → preview → prefab → runtime_validated → cataloged → human_approved`. A stage names the **highest completed stage**; the corresponding required gate result and evidence must exist. A failed gate keeps the previous completed stage.
- **Category profile:** one of `terrain`, `wall_module`, `door_or_entrance`, `building_shell`, `furniture`, `animated_environment`, `character`, `vfx`, `ui`. A profile adds required/not-applicable fields and validators to the base. At TEMPLATE it records **planned grammar** from world authority; at NORMALIZED it records actual atlas/layer/clip exports. A profile cannot waive `rights` or `human` review.
- **Canonical gates:** `rights`, `structural`, `motion`, `visual`, `runtime`, `human`. Statuses: `not_started`, `pending`, `passed`, `failed`, `not_applicable`. `not_applicable` is allowed only when the category profile says so, never as a way to evade rights or human signoff.
- **Rights outcomes by use scope:** `permitted`, `prohibited`, `unresolved`, `not_applicable`. A use scope is not a gate result; the `rights` gate evaluates the scopes needed for a specific environment/transition.
- **Derived `production_ready`:** not a writable manifest field. See the ecosystem standard for the full predicate; human review and applicable rights scopes are mandatory.

An approved `style_calibration` must carry references for `projection_rules_ref`, `gameplay_camera_ref`, `scale_hierarchy_ref`, `contour_edge_language_ref`, `shadow_language_ref`, `material_vocabulary_ref`, `value_hierarchy_ref`, `detail_frequency_ref`, `saturation_policy_ref`, `actor_object_comparison_ref` and `cross_family_contact_sheet_ref`. These are calibration evidence references, not embedded provider art or a selected palette.

No empty string, empty list or empty object is valid in place of a semantic value. An optional field is omitted until it has data. `unresolved`, `unapproved` and `CANDIDATE_REQUIRES_CALIBRATION` are explicit assessments/policy references, not invented measurements. The JSON core enforces nonempty strings and collections for most leaf data; cross-field relationships are delegated to named content validators.

## When fields become mandatory

| Stage reached | Newly required data | Gate needed to advance |
|---|---|---|
| `spec` | Base identity, category, style-family ID, provenance source/evidence and at least one use-scope assessment, six gate status records. World-bound profiles require `world_authority_ref`. | Rights identity and requested-scope outcome recorded; unresolved rights may remain for structural study only. |
| `template` | `template.template_id`, `template_version`, authority ref and revision/hash, compatibility/invalidation relationship, approved or unapproved `style_calibration`; world-bound profiles require `template.registration`, UI requires `template.ui_layout`. | Template must be tied to the authoritative revision; unmeasured required geometry blocks SOURCE. |
| `source` | Approved `style_calibration`, `source.source_asset_version`, hashed nonempty files, input references. | Required generation/reference scopes permitted before source creation. |
| `normalized` | Hashed `normalized.exports` and `normalization_record_ref`. | Normalization checks and provenance retained. |
| `structurally_validated` | `gates.structural.status=passed` with completed review record. | Structural content validators pass. |
| `motion_validated` | `gates.motion.status=passed` for animated profiles, or `not_applicable` only for declared static profiles. | Motion content/human motion review as applicable. |
| `visual_qa` | `gates.visual.status=passed` with art-lead evidence. | Visual QA pass is independent of structural/runtime. |
| `preview` | `preview.evidence_refs`; moving-actor evidence where category requires depth interaction. | Preview must show the claimed category grammar. |
| `prefab` | `runtime.godot_prefab_ref`, `visual_root_ref`, `gameplay_root_ref`, `export_refs`; `tileset_ref` only when relevant. | Approved visual bound without moving authoritative roots. |
| `runtime_validated` | `gates.runtime.status=passed` and route/prefab evidence. | Controlled integration proof passes. |
| `cataloged` | `catalog.entry_ref`, `preview_refs`, supersession reference if replacing a version. | Current statuses/provenance visible in catalog. |
| `human_approved` | `gates.human.status=passed` with live-world human evidence. | All applicable gates and scope checks pass; `production_ready` may then derive true. |

The schema's `allOf` stage conditionals enforce the presence of stage containers and selected gate statuses. Stage/category content validators enforce completed review records, authority revision matching, scope permissions, profile fields and nonempty meaningful refs. A `human_approved` value without the required evidence or rights scopes is not a production approval.

## Category profiles (machine validation profiles; no duplicated base)

All profiles inherit base/stage requirements, rights evidence, source/template traceability and final human signoff. “Required” fields below apply **when the indicated stage exists**; optional fields are included only when relevant. “N/A” means the profile forbids interpreting that field as a required semantic contract, not that an empty placeholder should be stored.

| Profile | Required category fields | Optional / not applicable | Required content validators | Human review evidence |
|---|---|---|---|---|
| `terrain` | TEMPLATE: `template.registration`, `template.terrain_plan` with sizes and supported/required roles. NORMALIZED: `terrain.tiles`, adjacency, completeness claim. | Optional `connectors`, `animation` for overlays; N/A apertures, building layers, directions, UI. | `V-TERRAIN-COMPLETE`, `V-ADJACENCY`, `V-SCALE`, `V-WORLD-INTEGRITY`; `V-MOTION` if overlay. | Neighborhood mosaic including every supported join, route with moving actor, bank/threshold if claimed. |
| `wall_module` | TEMPLATE: `template.registration` including `grid_span_cells` and `module_span_world`; `connectors` with exact local geometry and compatible profiles. | Optional occluder refs; N/A terrain grammar, apertures, directions, UI. | `V-CONNECTOR`, `V-SCALE`, `V-WORLD-INTEGRITY`. | Side-by-side joins with every allowed neighbor and actor depth pass. |
| `door_or_entrance` | TEMPLATE: `template.registration`, `apertures`, referenced wall `connectors`. | Optional building layer refs; N/A terrain grammar, directions, UI. | `V-APERTURE`, `V-CONNECTOR`, `V-WORLD-INTEGRITY`. | Actor outside, crossing, inside; threshold and occluder shown at gameplay camera. |
| `building_shell` | TEMPLATE: `template.registration`, `template.building_layer_roles`, `apertures`, wall `connectors`. NORMALIZED: `building_layers` with `rear_base`, `interior_readable`, `front_occluder`, `door_aperture` exports. | `roof_canopy` optional; N/A terrain grammar, UI. | `V-LAYER-REGISTRATION`, `V-APERTURE`, `V-CONNECTOR`, `V-WORLD-INTEGRITY`. | Moving actor through entrance and before/behind front layer; interior readable. |
| `furniture` | TEMPLATE: `template.registration`, `template.direction_plan`, `interaction.anchor_refs`. NORMALIZED: `directions.authored`, `direction_semantics`, `mirror_allowed` and frame refs. | Optional front occluder/shadow, animation if authored; N/A terrain, building layers, apertures, UI. | `V-DIRECTION`, `V-SCALE`, `V-WORLD-INTEGRITY`; `V-MOTION` if animated. | Every authored view at one fixed gameplay root, actor approach/sit/stand/depth. |
| `animated_environment` | TEMPLATE: `template.registration`, `template.motion_plan`. NORMALIZED: `animation.clips` with root/baseline and motion policies. | Optional shadow/occluder refs; N/A apertures, building layers, furniture directions, UI. | `V-FRAME`, `V-MOTION`, `V-SCALE`, `V-WORLD-INTEGRITY`. | Scene-speed loop with moving actor before/behind object; root/shadow contact visible. |
| `character` | TEMPLATE: `template.registration`, `template.direction_plan`, `template.motion_plan`. NORMALIZED: `directions`, `animation.clips` for required idle/walk facings. | Optional `interaction.anchor_refs`; N/A terrain, building layers, apertures, UI. | `V-FRAME`, `V-DIRECTION`, `V-MOTION`, `V-SCALE`, `V-WORLD-INTEGRITY`. | Idle/walk across route, seat/door and depth layers at gameplay camera. |
| `vfx` | TEMPLATE: `template.motion_plan`, semantic trigger through `interaction.anchor_refs`; world VFX require `template.registration`, screen VFX `template.ui_layout`. NORMALIZED: `animation.clips`. | N/A terrain/building layers/apertures; directions optional only if authored. | `V-FRAME`, `V-MOTION`, `V-WORLD-INTEGRITY`. | Triggered one-shot/loop in context, including completion/reset and cozy intensity. |
| `ui` | TEMPLATE: `template.ui_layout`, `template.ui_state_plan`. NORMALIZED: `ui.semantic_states`; `dynamic_fill_binding_ref` for a bar, `slice_regions_ref` for scalable panel. | Animation optional; N/A world footprint, terrain, connectors, apertures, building layers. | `V-UI-STATE`, `V-FRAME` if animated, `V-WORLD-INTEGRITY` for event binding. | Real pressed/disabled/selected states as applicable at portrait size over moving world. |

`V-SCHEMA`, `V-PROVENANCE` and `V-REVIEW-EVIDENCE` apply to **all** profiles. The JSON core conditionally requires several category containers at TEMPLATE or NORMALIZED; nested role/set consistency is checked by the content profiles above, never inferred from sheet geometry. A terrain family can declare unsupported roles, but production-family `V-TERRAIN-COMPLETE` passes only with `completeness_claim=complete` and coverage of its own `required_roles`; a `partial` family stays in isolated evaluation.

## Typed structures and semantic checks

| Structure | Typed contract | Content rule not expressible by simple shape checking |
|---|---|---|
| `connector` | `connector_id`, `connector_role`, `coordinate_space`, exactly one of `exact_local_position`/`exact_local_segment`, `profile_id`, `compatible_profile_ids`, `edge_orientation`, `registration_ref`, `tolerance_policy_ref`. | Intended joins must cite reciprocal compatible profiles, same template/authority registration and exact geometry. Unknown tolerance uses `CANDIDATE_REQUIRES_CALIBRATION` and cannot be asserted as an exact measured pass. |
| `aperture` | `walkable_aperture_world`, `visual_aperture_px`, `opening_width_world`, `opening_baseline_world`, `threshold_region_world`, `left_wall_connector`, `right_wall_connector`, `front_occluder_ref`, `depth_crossing_rule`, `approach_anchor_refs`, `door_interaction_ref`, `navigation_authority_ref`, `registration_ref`. | Project visual polygon through template scale/pivot, compare with referenced authoritative walkable opening and actor crossing. Never edit navigation to make art pass. |
| `building_layer` | `role`, `asset_ref`, `registration_ref`, `canvas_rect_px`, `depth_policy`. | Traversable profile needs rear/interior/front/aperture roles with one shared registration. Transparent pixels in a flat exterior cannot substitute for interior/aperture semantics. |
| `terrain` | `art_tile_px`, `world_tile_span`, `logical_placement_cell_world`, `supported_roles`, `required_roles`, `completeness_claim`, `tiles[]`, optional `coverage_evidence_ref`. Tile: `atlas_rect_px`, `terrain_role`, `neighbor_mask`, optional edge/elevation/connector/shadow/overlay/phase. | Required roles must be a subset of supported roles and have atlas entries; adjacency coverage and complete/partial claim require neighborhood proof. Art tile and logical placement cell are distinct. |
| `motion_clip` | `motion_class`, `motion_intent`, `frame_map`, `durations_ms`, `timing_intent`, `loop_mode`, `rest_frame`, `root_lock`, `baseline_lock`, `transform_policy`, `silhouette_motion_policy`, `loop_seam_policy`, `phase_policy`, `interruptible`, conditional `completion_event`. | Counts/order, root/baseline traces, silhouette trajectory, seam and event completion need content checks and human review. No universal drift/timing quota is embedded. |

For `ambient_sway`, the category profile requires `root_lock=true`, `baseline_lock=true`, `transform_policy.whole_sprite_scale=forbidden`, `silhouette_motion_policy=foliage_led`, `loop_seam_policy.requirement=required`, per-frame `durations_ms` and `timing_intent=authored_arc`. `phase_policy` may be `fixed`, `random_start` or `offset_by_instance` for independent instances. These fields **represent** authored non-linear timing; the motion validator/human review judges the arc. `CANDIDATE_REQUIRES_CALIBRATION` is the current tolerance-policy reference, not a passing numerical threshold.

The exact JSON Schema core follows. It enforces types, nonempty values, stage presence and basic stage gate conditions. Category/geometry/motion/provenance cross-checks belong to the named content validators in the ecosystem standard; this document does not implement them.

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "urn:willicat:asset-manifest:1-draft-hardened",
  "title": "WilliCat asset manifest V1 draft hardened",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "schema_version",
    "asset_id",
    "asset_version",
    "category",
    "family_id",
    "style_family_id",
    "lifecycle_stage",
    "provenance",
    "gates"
  ],
  "properties": {
    "schema_version": {
      "const": "1-draft-hardened"
    },
    "asset_id": {
      "type": "string",
      "minLength": 1
    },
    "asset_version": {
      "type": "string",
      "minLength": 1
    },
    "category": {
      "enum": [
        "terrain",
        "wall_module",
        "door_or_entrance",
        "building_shell",
        "furniture",
        "animated_environment",
        "character",
        "vfx",
        "ui"
      ]
    },
    "family_id": {
      "type": "string",
      "minLength": 1
    },
    "style_family_id": {
      "type": "string",
      "minLength": 1
    },
    "lifecycle_stage": {
      "enum": [
        "spec",
        "template",
        "source",
        "normalized",
        "structurally_validated",
        "motion_validated",
        "visual_qa",
        "preview",
        "prefab",
        "runtime_validated",
        "cataloged",
        "human_approved"
      ]
    },
    "world_authority_ref": {
      "type": "string",
      "minLength": 1
    },
    "provenance": {
      "type": "object",
      "properties": {
        "kind": {
          "enum": [
            "first_party",
            "third_party"
          ]
        },
        "creator": {
          "type": "string",
          "minLength": 1
        },
        "source_reference": {
          "type": "string",
          "minLength": 1
        },
        "evidence_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "use_scopes": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/scope_assessment"
          },
          "minItems": 1
        }
      },
      "required": [
        "kind",
        "creator",
        "source_reference",
        "evidence_refs",
        "use_scopes"
      ],
      "additionalProperties": false
    },
    "gates": {
      "type": "object",
      "properties": {
        "rights": {
          "$ref": "#/$defs/gate"
        },
        "structural": {
          "$ref": "#/$defs/gate"
        },
        "motion": {
          "$ref": "#/$defs/gate"
        },
        "visual": {
          "$ref": "#/$defs/gate"
        },
        "runtime": {
          "$ref": "#/$defs/gate"
        },
        "human": {
          "$ref": "#/$defs/gate"
        }
      },
      "required": [
        "rights",
        "structural",
        "motion",
        "visual",
        "runtime",
        "human"
      ],
      "additionalProperties": false
    },
    "style_calibration": {
      "type": "object",
      "properties": {
        "calibration_ref": {
          "type": "string",
          "minLength": 1
        },
        "status": {
          "enum": [
            "approved",
            "unapproved"
          ]
        },
        "evidence_ref": {
          "type": "string",
          "minLength": 1
        },
        "projection_rules_ref": {
          "type": "string",
          "minLength": 1
        },
        "gameplay_camera_ref": {
          "type": "string",
          "minLength": 1
        },
        "scale_hierarchy_ref": {
          "type": "string",
          "minLength": 1
        },
        "contour_edge_language_ref": {
          "type": "string",
          "minLength": 1
        },
        "shadow_language_ref": {
          "type": "string",
          "minLength": 1
        },
        "material_vocabulary_ref": {
          "type": "string",
          "minLength": 1
        },
        "value_hierarchy_ref": {
          "type": "string",
          "minLength": 1
        },
        "detail_frequency_ref": {
          "type": "string",
          "minLength": 1
        },
        "saturation_policy_ref": {
          "type": "string",
          "minLength": 1
        },
        "actor_object_comparison_ref": {
          "type": "string",
          "minLength": 1
        },
        "cross_family_contact_sheet_ref": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": [
        "calibration_ref",
        "status",
        "evidence_ref"
      ],
      "additionalProperties": false,
      "allOf": [
        {
          "if": {
            "properties": {
              "status": {
                "const": "approved"
              }
            },
            "required": [
              "status"
            ]
          },
          "then": {
            "required": [
              "projection_rules_ref",
              "gameplay_camera_ref",
              "scale_hierarchy_ref",
              "contour_edge_language_ref",
              "shadow_language_ref",
              "material_vocabulary_ref",
              "value_hierarchy_ref",
              "detail_frequency_ref",
              "saturation_policy_ref",
              "actor_object_comparison_ref",
              "cross_family_contact_sheet_ref"
            ]
          }
        }
      ]
    },
    "template": {
      "type": "object",
      "properties": {
        "template_id": {
          "type": "string",
          "minLength": 1
        },
        "template_version": {
          "type": "string",
          "minLength": 1
        },
        "world_authority_ref": {
          "type": "string",
          "minLength": 1
        },
        "ui_layout_authority_ref": {
          "type": "string",
          "minLength": 1
        },
        "world_authority_revision": {
          "type": "string",
          "minLength": 1
        },
        "world_authority_content_hash": {
          "type": "string",
          "minLength": 1
        },
        "ui_layout_authority_revision": {
          "type": "string",
          "minLength": 1
        },
        "registration": {
          "$ref": "#/$defs/registration"
        },
        "ui_layout": {
          "type": "object",
          "properties": {
            "canvas_px": {
              "$ref": "#/$defs/size"
            },
            "origin_px": {
              "$ref": "#/$defs/point"
            },
            "hit_region_px": {
              "$ref": "#/$defs/rect"
            },
            "slice_regions_ref": {
              "type": "string",
              "minLength": 1
            }
          },
          "required": [
            "canvas_px",
            "origin_px",
            "hit_region_px"
          ],
          "additionalProperties": false
        },
        "terrain_plan": {
          "$ref": "#/$defs/terrain_plan"
        },
        "building_layer_roles": {
          "type": "array",
          "items": {
            "enum": [
              "rear_base",
              "interior_readable",
              "front_occluder",
              "door_aperture",
              "roof_canopy"
            ]
          },
          "minItems": 1
        },
        "direction_plan": {
          "type": "object",
          "properties": {
            "required_directions": {
              "type": "array",
              "items": {
                "type": "string",
                "minLength": 1
              },
              "minItems": 1
            },
            "direction_semantics": {
              "type": "string",
              "minLength": 1
            },
            "mirror_allowed": {
              "type": "boolean"
            }
          },
          "required": [
            "required_directions",
            "direction_semantics",
            "mirror_allowed"
          ],
          "additionalProperties": false
        },
        "motion_plan": {
          "type": "object",
          "properties": {
            "motion_classes": {
              "type": "array",
              "items": {
                "enum": [
                  "ambient_sway",
                  "ambient_flutter",
                  "water_loop",
                  "machine_loop",
                  "one_shot_vfx",
                  "character_idle",
                  "character_walk",
                  "ui_feedback"
                ]
              },
              "minItems": 1
            },
            "motion_intent_ref": {
              "type": "string",
              "minLength": 1
            }
          },
          "required": [
            "motion_classes",
            "motion_intent_ref"
          ],
          "additionalProperties": false
        },
        "ui_state_plan": {
          "type": "array",
          "items": {
            "enum": [
              "normal",
              "pressed",
              "selected",
              "disabled",
              "ready",
              "locked",
              "filled"
            ]
          },
          "minItems": 1
        },
        "compatibility": {
          "type": "object",
          "properties": {
            "authority_refs": {
              "type": "array",
              "items": {
                "type": "string",
                "minLength": 1
              },
              "minItems": 1
            },
            "family_versions": {
              "type": "array",
              "items": {
                "type": "string",
                "minLength": 1
              }
            }
          },
          "required": [
            "authority_refs",
            "family_versions"
          ],
          "additionalProperties": false
        },
        "supersedes": {
          "type": "string",
          "minLength": 1
        },
        "invalidation_relationship": {
          "enum": [
            "invalidate_on_authority_revision_change",
            "requires_manual_compatibility_review"
          ]
        }
      },
      "required": [
        "template_id",
        "template_version",
        "compatibility",
        "invalidation_relationship"
      ],
      "additionalProperties": false,
      "anyOf": [
        {
          "required": [
            "world_authority_revision"
          ]
        },
        {
          "required": [
            "world_authority_content_hash"
          ]
        },
        {
          "required": [
            "ui_layout_authority_revision"
          ]
        }
      ]
    },
    "source": {
      "type": "object",
      "properties": {
        "source_asset_version": {
          "type": "string",
          "minLength": 1
        },
        "files": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/asset_file"
          },
          "minItems": 1
        },
        "input_references": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          }
        },
        "supersedes": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": [
        "source_asset_version",
        "files",
        "input_references"
      ],
      "additionalProperties": false
    },
    "normalized": {
      "type": "object",
      "properties": {
        "exports": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/asset_file"
          },
          "minItems": 1
        },
        "normalization_record_ref": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": [
        "exports",
        "normalization_record_ref"
      ],
      "additionalProperties": false
    },
    "connectors": {
      "type": "array",
      "items": {
        "$ref": "#/$defs/connector"
      },
      "minItems": 1
    },
    "apertures": {
      "type": "array",
      "items": {
        "$ref": "#/$defs/aperture"
      },
      "minItems": 1
    },
    "building_layers": {
      "type": "array",
      "items": {
        "$ref": "#/$defs/building_layer"
      },
      "minItems": 1
    },
    "terrain": {
      "$ref": "#/$defs/terrain_family"
    },
    "directions": {
      "type": "object",
      "properties": {
        "authored": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "direction_semantics": {
          "type": "string",
          "minLength": 1
        },
        "mirror_allowed": {
          "type": "boolean"
        },
        "frame_refs": {
          "type": "object",
          "properties": {},
          "required": [],
          "additionalProperties": {
            "type": "array",
            "items": {
              "type": "string",
              "minLength": 1
            },
            "minItems": 1
          }
        }
      },
      "required": [
        "authored",
        "direction_semantics",
        "mirror_allowed",
        "frame_refs"
      ],
      "additionalProperties": false
    },
    "animation": {
      "type": "object",
      "properties": {
        "clips": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/motion_clip"
          },
          "minItems": 1
        }
      },
      "required": [
        "clips"
      ],
      "additionalProperties": false
    },
    "interaction": {
      "type": "object",
      "properties": {
        "semantic_capabilities": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "anchor_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        }
      },
      "required": [
        "semantic_capabilities",
        "anchor_refs"
      ],
      "additionalProperties": false
    },
    "ui": {
      "type": "object",
      "properties": {
        "semantic_states": {
          "type": "array",
          "items": {
            "enum": [
              "normal",
              "pressed",
              "selected",
              "disabled",
              "ready",
              "locked",
              "filled"
            ]
          },
          "minItems": 1
        },
        "dynamic_fill_binding_ref": {
          "type": "string",
          "minLength": 1
        },
        "slice_regions_ref": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": [
        "semantic_states"
      ],
      "additionalProperties": false
    },
    "preview": {
      "type": "object",
      "properties": {
        "evidence_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "moving_actor_evidence_ref": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": [
        "evidence_refs"
      ],
      "additionalProperties": false
    },
    "runtime": {
      "type": "object",
      "properties": {
        "godot_prefab_ref": {
          "type": "string",
          "minLength": 1
        },
        "visual_root_ref": {
          "type": "string",
          "minLength": 1
        },
        "gameplay_root_ref": {
          "type": "string",
          "minLength": 1
        },
        "tileset_ref": {
          "type": "string",
          "minLength": 1
        },
        "export_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        }
      },
      "required": [
        "godot_prefab_ref",
        "visual_root_ref",
        "gameplay_root_ref",
        "export_refs"
      ],
      "additionalProperties": false
    },
    "catalog": {
      "type": "object",
      "properties": {
        "entry_ref": {
          "type": "string",
          "minLength": 1
        },
        "preview_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "supersedes": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": [
        "entry_ref",
        "preview_refs"
      ],
      "additionalProperties": false
    }
  },
  "$defs": {
    "point": {
      "type": "object",
      "properties": {
        "x": {
          "type": "number"
        },
        "y": {
          "type": "number"
        }
      },
      "required": [
        "x",
        "y"
      ],
      "additionalProperties": false
    },
    "size": {
      "type": "object",
      "properties": {
        "width": {
          "type": "number",
          "exclusiveMinimum": 0
        },
        "height": {
          "type": "number",
          "exclusiveMinimum": 0
        }
      },
      "required": [
        "width",
        "height"
      ],
      "additionalProperties": false
    },
    "rect": {
      "type": "object",
      "properties": {
        "x": {
          "type": "number"
        },
        "y": {
          "type": "number"
        },
        "width": {
          "type": "number",
          "exclusiveMinimum": 0
        },
        "height": {
          "type": "number",
          "exclusiveMinimum": 0
        }
      },
      "required": [
        "x",
        "y",
        "width",
        "height"
      ],
      "additionalProperties": false
    },
    "region": {
      "type": "object",
      "properties": {
        "coordinate_space": {
          "enum": [
            "source_px",
            "template_world_local",
            "authoritative_world"
          ]
        },
        "points": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/point"
          },
          "minItems": 3
        }
      },
      "required": [
        "coordinate_space",
        "points"
      ],
      "additionalProperties": false
    },
    "asset_file": {
      "type": "object",
      "properties": {
        "path": {
          "type": "string",
          "minLength": 1
        },
        "sha256": {
          "type": "string",
          "pattern": "^[0-9a-fA-F]{64}$"
        }
      },
      "required": [
        "path",
        "sha256"
      ],
      "additionalProperties": false
    },
    "review_record": {
      "type": "object",
      "properties": {
        "gate_id": {
          "enum": [
            "rights",
            "structural",
            "motion",
            "visual",
            "runtime",
            "human"
          ]
        },
        "owner_role": {
          "type": "string",
          "minLength": 1
        },
        "timestamp": {
          "type": "string",
          "format": "date-time"
        },
        "asset_version": {
          "type": "string",
          "minLength": 1
        },
        "evidence_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "result": {
          "enum": [
            "passed",
            "failed",
            "not_applicable"
          ]
        },
        "notes": {
          "type": "string",
          "minLength": 1
        },
        "tool_version": {
          "type": "string",
          "minLength": 1
        },
        "evaluated_scopes": {
          "type": "array",
          "items": {
            "enum": [
              "structural_study",
              "dev_runtime",
              "production_runtime",
              "modification",
              "raw_redistribution",
              "generative_conditioning_reference",
              "ai_training",
              "publication_distribution"
            ]
          },
          "minItems": 1
        }
      },
      "required": [
        "gate_id",
        "owner_role",
        "timestamp",
        "asset_version",
        "evidence_refs",
        "result",
        "notes"
      ],
      "additionalProperties": false
    },
    "gate": {
      "type": "object",
      "properties": {
        "status": {
          "enum": [
            "not_started",
            "pending",
            "passed",
            "failed",
            "not_applicable"
          ]
        },
        "records": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/review_record"
          }
        }
      },
      "required": [
        "status",
        "records"
      ],
      "additionalProperties": false
    },
    "scope_assessment": {
      "type": "object",
      "properties": {
        "scope": {
          "enum": [
            "structural_study",
            "dev_runtime",
            "production_runtime",
            "modification",
            "raw_redistribution",
            "generative_conditioning_reference",
            "ai_training",
            "publication_distribution"
          ]
        },
        "outcome": {
          "enum": [
            "permitted",
            "prohibited",
            "unresolved",
            "not_applicable"
          ]
        },
        "evidence_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "notes": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": [
        "scope",
        "outcome",
        "evidence_refs",
        "notes"
      ],
      "additionalProperties": false
    },
    "connector": {
      "type": "object",
      "properties": {
        "connector_id": {
          "type": "string",
          "minLength": 1
        },
        "connector_role": {
          "enum": [
            "left_join",
            "right_join",
            "top_join",
            "bottom_join",
            "depth_join",
            "threshold_join",
            "other"
          ]
        },
        "coordinate_space": {
          "enum": [
            "source_px",
            "template_world_local"
          ]
        },
        "exact_local_position": {
          "$ref": "#/$defs/point"
        },
        "exact_local_segment": {
          "type": "object",
          "properties": {
            "start": {
              "$ref": "#/$defs/point"
            },
            "end": {
              "$ref": "#/$defs/point"
            }
          },
          "required": [
            "start",
            "end"
          ],
          "additionalProperties": false
        },
        "profile_id": {
          "type": "string",
          "minLength": 1
        },
        "compatible_profile_ids": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "edge_orientation": {
          "enum": [
            "left",
            "right",
            "top",
            "bottom",
            "interior",
            "depth"
          ]
        },
        "registration_ref": {
          "type": "string",
          "minLength": 1
        },
        "tolerance_policy_ref": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": [
        "connector_id",
        "connector_role",
        "coordinate_space",
        "profile_id",
        "compatible_profile_ids",
        "edge_orientation",
        "registration_ref",
        "tolerance_policy_ref"
      ],
      "additionalProperties": false,
      "oneOf": [
        {
          "required": [
            "exact_local_position"
          ]
        },
        {
          "required": [
            "exact_local_segment"
          ]
        }
      ]
    },
    "aperture": {
      "type": "object",
      "properties": {
        "aperture_id": {
          "type": "string",
          "minLength": 1
        },
        "walkable_aperture_world": {
          "$ref": "#/$defs/region"
        },
        "visual_aperture_px": {
          "$ref": "#/$defs/region"
        },
        "opening_width_world": {
          "type": "number",
          "exclusiveMinimum": 0
        },
        "opening_baseline_world": {
          "$ref": "#/$defs/point"
        },
        "threshold_region_world": {
          "$ref": "#/$defs/region"
        },
        "left_wall_connector": {
          "type": "string",
          "minLength": 1
        },
        "right_wall_connector": {
          "type": "string",
          "minLength": 1
        },
        "front_occluder_ref": {
          "type": "string",
          "minLength": 1
        },
        "depth_crossing_rule": {
          "enum": [
            "actor_between_rear_and_front",
            "y_sort_at_baseline",
            "explicit_layer_order"
          ]
        },
        "approach_anchor_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "door_interaction_ref": {
          "type": "string",
          "minLength": 1
        },
        "navigation_authority_ref": {
          "type": "string",
          "minLength": 1
        },
        "registration_ref": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": [
        "aperture_id",
        "walkable_aperture_world",
        "visual_aperture_px",
        "opening_width_world",
        "opening_baseline_world",
        "threshold_region_world",
        "left_wall_connector",
        "right_wall_connector",
        "front_occluder_ref",
        "depth_crossing_rule",
        "approach_anchor_refs",
        "door_interaction_ref",
        "navigation_authority_ref",
        "registration_ref"
      ],
      "additionalProperties": false
    },
    "building_layer": {
      "type": "object",
      "properties": {
        "role": {
          "enum": [
            "rear_base",
            "interior_readable",
            "front_occluder",
            "door_aperture",
            "roof_canopy"
          ]
        },
        "asset_ref": {
          "type": "string",
          "minLength": 1
        },
        "registration_ref": {
          "type": "string",
          "minLength": 1
        },
        "canvas_rect_px": {
          "$ref": "#/$defs/rect"
        },
        "depth_policy": {
          "enum": [
            "behind_actor",
            "in_front_of_actor",
            "y_sorted",
            "aperture_mask"
          ]
        }
      },
      "required": [
        "role",
        "asset_ref",
        "registration_ref",
        "canvas_rect_px",
        "depth_policy"
      ],
      "additionalProperties": false
    },
    "neighbor_mask": {
      "type": "object",
      "properties": {
        "n": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "ne": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "e": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "se": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "s": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "sw": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "w": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "nw": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        }
      },
      "required": [],
      "additionalProperties": false
    },
    "terrain_tile": {
      "type": "object",
      "properties": {
        "tile_id": {
          "type": "string",
          "minLength": 1
        },
        "atlas_rect_px": {
          "$ref": "#/$defs/rect"
        },
        "terrain_role": {
          "enum": [
            "base",
            "variation",
            "path",
            "edge",
            "inside_corner",
            "outside_corner",
            "threshold",
            "bank",
            "water",
            "elevation",
            "stair",
            "cliff",
            "shadow",
            "animated_overlay"
          ]
        },
        "neighbor_mask": {
          "$ref": "#/$defs/neighbor_mask"
        },
        "edge_orientation": {
          "enum": [
            "n",
            "ne",
            "e",
            "se",
            "s",
            "sw",
            "w",
            "nw",
            "none"
          ]
        },
        "elevation_level_ref": {
          "type": "string",
          "minLength": 1
        },
        "connector_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          }
        },
        "shadow_ref": {
          "type": "string",
          "minLength": 1
        },
        "animated_overlay_clip_ref": {
          "type": "string",
          "minLength": 1
        },
        "phase_policy": {
          "enum": [
            "fixed",
            "random_start",
            "offset_by_instance"
          ]
        }
      },
      "required": [
        "tile_id",
        "atlas_rect_px",
        "terrain_role",
        "neighbor_mask"
      ],
      "additionalProperties": false
    },
    "terrain_family": {
      "type": "object",
      "properties": {
        "art_tile_px": {
          "$ref": "#/$defs/size"
        },
        "world_tile_span": {
          "$ref": "#/$defs/size"
        },
        "logical_placement_cell_world": {
          "$ref": "#/$defs/size"
        },
        "supported_roles": {
          "type": "array",
          "items": {
            "enum": [
              "base",
              "variation",
              "path",
              "edge",
              "inside_corner",
              "outside_corner",
              "threshold",
              "bank",
              "water",
              "elevation",
              "stair",
              "cliff",
              "shadow",
              "animated_overlay"
            ]
          },
          "minItems": 1
        },
        "required_roles": {
          "type": "array",
          "items": {
            "enum": [
              "base",
              "variation",
              "path",
              "edge",
              "inside_corner",
              "outside_corner",
              "threshold",
              "bank",
              "water",
              "elevation",
              "stair",
              "cliff",
              "shadow",
              "animated_overlay"
            ]
          },
          "minItems": 1
        },
        "completeness_claim": {
          "enum": [
            "partial",
            "complete"
          ]
        },
        "tiles": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/terrain_tile"
          },
          "minItems": 1
        },
        "coverage_evidence_ref": {
          "type": "string",
          "minLength": 1
        }
      },
      "required": [
        "art_tile_px",
        "world_tile_span",
        "logical_placement_cell_world",
        "supported_roles",
        "required_roles",
        "completeness_claim",
        "tiles"
      ],
      "additionalProperties": false
    },
    "terrain_plan": {
      "type": "object",
      "properties": {
        "art_tile_px": {
          "$ref": "#/$defs/size"
        },
        "world_tile_span": {
          "$ref": "#/$defs/size"
        },
        "logical_placement_cell_world": {
          "$ref": "#/$defs/size"
        },
        "supported_roles": {
          "type": "array",
          "items": {
            "enum": [
              "base",
              "variation",
              "path",
              "edge",
              "inside_corner",
              "outside_corner",
              "threshold",
              "bank",
              "water",
              "elevation",
              "stair",
              "cliff",
              "shadow",
              "animated_overlay"
            ]
          },
          "minItems": 1
        },
        "required_roles": {
          "type": "array",
          "items": {
            "enum": [
              "base",
              "variation",
              "path",
              "edge",
              "inside_corner",
              "outside_corner",
              "threshold",
              "bank",
              "water",
              "elevation",
              "stair",
              "cliff",
              "shadow",
              "animated_overlay"
            ]
          },
          "minItems": 1
        }
      },
      "required": [
        "art_tile_px",
        "world_tile_span",
        "logical_placement_cell_world",
        "supported_roles",
        "required_roles"
      ],
      "additionalProperties": false
    },
    "frame": {
      "type": "object",
      "properties": {
        "frame_id": {
          "type": "string",
          "minLength": 1
        },
        "source_file_ref": {
          "type": "string",
          "minLength": 1
        },
        "cell_rect_px": {
          "$ref": "#/$defs/rect"
        }
      },
      "required": [
        "frame_id",
        "source_file_ref",
        "cell_rect_px"
      ],
      "additionalProperties": false
    },
    "motion_clip": {
      "type": "object",
      "properties": {
        "clip_id": {
          "type": "string",
          "minLength": 1
        },
        "motion_class": {
          "enum": [
            "ambient_sway",
            "ambient_flutter",
            "water_loop",
            "machine_loop",
            "one_shot_vfx",
            "character_idle",
            "character_walk",
            "ui_feedback"
          ]
        },
        "motion_intent": {
          "type": "string",
          "minLength": 1
        },
        "action": {
          "type": "string",
          "minLength": 1
        },
        "state": {
          "type": "string",
          "minLength": 1
        },
        "direction": {
          "type": "string",
          "minLength": 1
        },
        "variant": {
          "type": "string",
          "minLength": 1
        },
        "frame_map": {
          "type": "array",
          "items": {
            "$ref": "#/$defs/frame"
          },
          "minItems": 1
        },
        "durations_ms": {
          "type": "array",
          "items": {
            "type": "number",
            "exclusiveMinimum": 0
          },
          "minItems": 1
        },
        "timing_intent": {
          "enum": [
            "authored_arc",
            "uniform",
            "event_timed"
          ]
        },
        "loop_mode": {
          "enum": [
            "loop",
            "once",
            "hold",
            "ping_pong"
          ]
        },
        "rest_frame": {
          "type": "integer",
          "minimum": 0
        },
        "root_lock": {
          "type": "boolean"
        },
        "baseline_lock": {
          "type": "boolean"
        },
        "transform_policy": {
          "type": "object",
          "properties": {
            "whole_sprite_scale": {
              "enum": [
                "forbidden",
                "allowed"
              ]
            },
            "whole_sprite_translation": {
              "enum": [
                "forbidden",
                "allowed"
              ]
            },
            "root_rotation": {
              "enum": [
                "forbidden",
                "allowed"
              ]
            }
          },
          "required": [
            "whole_sprite_scale",
            "whole_sprite_translation",
            "root_rotation"
          ],
          "additionalProperties": false
        },
        "silhouette_motion_policy": {
          "enum": [
            "foliage_led",
            "localized",
            "full_body",
            "static_housing_moving_part",
            "not_applicable"
          ]
        },
        "loop_seam_policy": {
          "type": "object",
          "properties": {
            "requirement": {
              "enum": [
                "required",
                "not_applicable"
              ]
            },
            "tolerance_policy_ref": {
              "type": "string",
              "minLength": 1
            }
          },
          "required": [
            "requirement",
            "tolerance_policy_ref"
          ],
          "additionalProperties": false
        },
        "phase_policy": {
          "enum": [
            "fixed",
            "random_start",
            "offset_by_instance"
          ]
        },
        "completion_event": {
          "type": "string",
          "minLength": 1
        },
        "interruptible": {
          "type": "boolean"
        }
      },
      "required": [
        "clip_id",
        "motion_class",
        "motion_intent",
        "frame_map",
        "durations_ms",
        "timing_intent",
        "loop_mode",
        "rest_frame",
        "root_lock",
        "baseline_lock",
        "transform_policy",
        "silhouette_motion_policy",
        "loop_seam_policy",
        "phase_policy",
        "interruptible"
      ],
      "additionalProperties": false
    },
    "registration": {
      "type": "object",
      "properties": {
        "source_canvas_px": {
          "$ref": "#/$defs/size"
        },
        "world_units_per_source_px": {
          "type": "number",
          "exclusiveMinimum": 0
        },
        "pivot_px": {
          "$ref": "#/$defs/point"
        },
        "floor_baseline_px": {
          "type": "number"
        },
        "ground_contact_region_px": {
          "$ref": "#/$defs/rect"
        },
        "footprint_world": {
          "$ref": "#/$defs/size"
        },
        "depth_policy": {
          "enum": [
            "y_sort_root",
            "fixed_back",
            "fixed_front",
            "canvas_layer"
          ]
        },
        "collision_profile_ref": {
          "type": "string",
          "minLength": 1
        },
        "shadow_anchor_world": {
          "$ref": "#/$defs/point"
        },
        "cell_rect_px": {
          "$ref": "#/$defs/rect"
        },
        "padding_px": {
          "$ref": "#/$defs/size"
        },
        "occluder_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "interaction_anchor_refs": {
          "type": "array",
          "items": {
            "type": "string",
            "minLength": 1
          },
          "minItems": 1
        },
        "grid_span_cells": {
          "$ref": "#/$defs/size"
        },
        "module_span_world": {
          "$ref": "#/$defs/size"
        }
      },
      "required": [
        "source_canvas_px",
        "world_units_per_source_px",
        "pivot_px",
        "floor_baseline_px",
        "ground_contact_region_px",
        "footprint_world",
        "depth_policy",
        "collision_profile_ref"
      ],
      "additionalProperties": false
    }
  },
  "allOf": [
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "template",
              "source",
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "template",
          "style_calibration"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "source",
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "source"
        ],
        "properties": {
          "style_calibration": {
            "properties": {
              "status": {
                "const": "approved"
              }
            }
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "normalized"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [],
        "properties": {
          "gates": {
            "properties": {
              "structural": {
                "properties": {
                  "status": {
                    "enum": [
                      "passed"
                    ]
                  }
                }
              }
            }
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [],
        "properties": {
          "gates": {
            "properties": {
              "motion": {
                "properties": {
                  "status": {
                    "enum": [
                      "passed",
                      "not_applicable"
                    ]
                  }
                }
              }
            }
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [],
        "properties": {
          "gates": {
            "properties": {
              "visual": {
                "properties": {
                  "status": {
                    "enum": [
                      "passed"
                    ]
                  }
                }
              }
            }
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [],
        "properties": {
          "gates": {
            "properties": {
              "runtime": {
                "properties": {
                  "status": {
                    "enum": [
                      "passed"
                    ]
                  }
                }
              }
            }
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [],
        "properties": {
          "gates": {
            "properties": {
              "human": {
                "properties": {
                  "status": {
                    "enum": [
                      "passed"
                    ]
                  }
                }
              }
            }
          }
        }
      }
    },
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "preview"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "runtime"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "lifecycle_stage": {
            "enum": [
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "catalog"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "terrain"
          },
          "lifecycle_stage": {
            "enum": [
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "terrain"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "wall_module"
          },
          "lifecycle_stage": {
            "enum": [
              "template",
              "source",
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "connectors"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "door_or_entrance"
          },
          "lifecycle_stage": {
            "enum": [
              "template",
              "source",
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "connectors",
          "apertures"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "building_shell"
          },
          "lifecycle_stage": {
            "enum": [
              "template",
              "source",
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "connectors",
          "apertures"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "building_shell"
          },
          "lifecycle_stage": {
            "enum": [
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "building_layers"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "furniture"
          },
          "lifecycle_stage": {
            "enum": [
              "template",
              "source",
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "interaction"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "furniture"
          },
          "lifecycle_stage": {
            "enum": [
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "directions"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "animated_environment"
          },
          "lifecycle_stage": {
            "enum": [
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "animation"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "character"
          },
          "lifecycle_stage": {
            "enum": [
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "directions",
          "animation"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "vfx"
          },
          "lifecycle_stage": {
            "enum": [
              "template",
              "source",
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "interaction"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "vfx"
          },
          "lifecycle_stage": {
            "enum": [
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "animation"
        ]
      }
    },
    {
      "if": {
        "properties": {
          "category": {
            "const": "ui"
          },
          "lifecycle_stage": {
            "enum": [
              "normalized",
              "structurally_validated",
              "motion_validated",
              "visual_qa",
              "preview",
              "prefab",
              "runtime_validated",
              "cataloged",
              "human_approved"
            ]
          }
        },
        "required": [
          "category",
          "lifecycle_stage"
        ]
      },
      "then": {
        "required": [
          "ui"
        ]
      }
    }
  ]
}
```

## Review evidence and validation ownership

Every completed gate attempt stores a `review_record` with `gate_id`, `owner_role`, ISO timestamp, `asset_version`, nonempty `evidence_refs`, `result`, `notes`, and `tool_version` when a tool ran. A `rights` review additionally records `evaluated_scopes`; `V-PROVENANCE` requires this field for that gate. A failed attempt remains in the history; retry appends a new record. `V-REVIEW-EVIDENCE` checks that a `passed` gate has a matching completed record for the same asset version. Role ownership: rights owner (`rights`), structural validator/tool (`structural`), technical animator (`motion`), art lead (`visual`), runtime owner (`runtime`), human reviewer (`human`). These are roles, not required personal names.

The rights model is a list of use-scope assessments, each with `scope`, `outcome`, `evidence_refs` and `notes`. Scopes are `structural_study`, `dev_runtime`, `production_runtime`, `modification`, `raw_redistribution`, `generative_conditioning_reference`, `ai_training`, `publication_distribution`. `V-PROVENANCE` checks the scopes actually needed at the next stage/environment; it does not turn one permitted use into blanket clearance. Existing unresolved pack determinations remain unchanged.

## Illustrative stage/category instances and limits

No numeric world geometry example is fabricated. A `spec` instance needs identity, category, style-family ID, provenance evidence/scope assessment and gate records; it **does not** contain empty `template`, `source` or `runtime` objects. A world-bound `template` must acquire actual measurements from the referenced Home revision before SOURCE. A `human_approved` instance must carry completed review records and pass the category content profile, which the core JSON Schema alone cannot establish.

The previous Mini Pack 001 chair numbers remain historical measurements, not defaults or visual approval. The previous research document remains evidence, not a current production manifest. No manifest file or validator implementation is created by this hardening task.
