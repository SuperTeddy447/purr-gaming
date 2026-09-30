# WilliCat Asset Factory input contract V1 — draft

Purpose: define the information a future first-party, non-pixel asset-producing agent must receive **before** drawing/exporting an asset. This document does not implement that agent or choose an art generator. The requesting world/technical artist supplies these values; the factory must reject missing required fields rather than infer them from a reference PNG.

## Request envelope

| Field | Required | Meaning / validation |
| --- | --- | --- |
| `asset_id`, `version`, `category` | Yes | Stable unique identifier and semantic category: terrain, building, furniture, character, ambient prop, UI, FX. No filename-only identity. |
| `style_family`, `style_reference_ids` | Yes | Approved first-party visual language and exact references. No mixing an unrelated proxy pack merely because it is available. |
| `rights_record` | Yes | Creator/owner, source provenance, permitted derivative/export uses, and any reference restrictions. Stop if unclear. |
| `projection`, `camera_reference` | Yes | Elevated three-quarter/top-down/etc., viewing angle, portrait reference, no free rotation unless explicitly allowed. |
| `canonical_world_footprint` | Yes | Width/depth in Godot world units and intended logical placement-cell occupancy; separate from image extent. |
| `frame_canvas`, `transparent_padding` | Yes | Source pixel canvas per frame and minimum clear margins; may be chosen for a first-party family, but must then stay consistent within that family. |
| `world_scale`, `pivot`, `baseline` | Yes | Explicit source-to-world mapping, source-pixel floor contact and stable Y-sort baseline. No room-specific scale correction. |
| `alpha_bounds_expectation` | Yes | Permitted silhouette region and clipping margin; not used as collision. |
| `output_naming`, `output_paths`, `Godot_target_prefab` | Yes | Source, export, manifest and target semantic/visual scenes. |
| `acceptance_scene`, `acceptance_actions` | Yes | Moving-character test context and exact checks to pass. |

## Category details

### Terrain

Supply tile/world span, atlas cell map, straight/corner/edge transition requirements, neighbor rules, walkable surfaces, nav boundary and any animated-cell frame/timing map. State whether a water tile is visual-only, a blocked region or an interaction edge. Include café door and river-bank joins in the acceptance scene.

### Building

Supply base/back/interior/front layer list, shared registration canvas, world floor pivot, exterior footprint, collision shell, doorway aperture width/location, front/rear approach anchors, occluder mask, draw order and upgrade compatibility rule. Identify whether a “Front” layer is a sparse duplicated foreground subset or a separate façade. Supply a character path through/behind the relevant layer; a complete opaque exterior cannot be assumed traversable.

### Furniture

Supply `directions` as an explicit ordered list from N/NE/E/SE/S/SW/W/NW; define whether each direction names the seat occupant's facing. Supply `frame_canvas` or per-direction image registration, common ground pivot, target silhouette/world scale, collision footprint, seat count, `SeatSlot` approach/action/exit anchors, permitted occupants, sitting facing, front occluder and shadow. If a family contains chair, loveseat and booth variants, provide separate footprints and slot counts. Visual switching must preserve the semantic root and footprint.

### Character

Supply `animation_names`, direction list per clip, `frame_count`, frame order, fps or per-frame milliseconds, loop/reversal rule, action transition policy and opt-in mirroring policy. Supply stable logical root, frame-specific visual baseline, body/world scale, shadow profile, semantic head/carry/camera anchors, cosmetic constraints and sitting/interaction offsets. A front/back-only sheet does not satisfy four-direction movement without additional authored views.

### Animated prop and FX

Supply static/state/loop classification, frame map, duration, pivot, shadow, trunk/base collision (if any), Y-sort/crown occlusion, start-phase behavior and reduced-motion behavior. Distinguish a grid of visual states from a timeline. Declare which layer an actor may pass behind.

### UI

Supply semantic interaction purpose, regular/pressed/disabled/selected states, size constraints, nine-slice or panel-slot geometry, icon placement, fill behavior, cursor feedback, input/touch target and contrast requirements. UI state structure is independent of a proxy pack's visual identity.

## Output manifest shape

The future factory returns the source, exported images/sheets and a machine-readable manifest whose keys directly match this request. A compact furniture example describes structure, not final dimensions:

```yaml
asset_id: home_cafe_chair_wood_v1
category: furniture
style_family: willicat_first_party_non_pixel_v1
projection: elevated_three_quarter
canonical_world_footprint: {width: approved_world_units, depth: approved_world_units}
directions: [n, ne, e, se, s, sw, w, nw]
direction_semantics: seated_occupant_faces
frame_canvas: {width_px: approved_canvas, height_px: approved_canvas}
pivot: {x_px: approved_ground_x, y_px: approved_ground_y}
world_scale: approved_units_per_source_pixel
baseline: floor_contact_at_semantic_root
collision: {profile_id: chair_small}
interaction_anchors: {seat_slot: required, approach: required, exit: required}
shadow: {asset_id: optional_shadow_asset, ground_registered: true}
Godot_target_prefab: scenes/home/furniture/CafeChair.tscn
acceptance_actions: [switch_all_directions, sit_enter_idle_exit, move_save_load]
```

`approved_*` placeholders must be resolved by the art/world owner before production. The measured proxy values (Cozy 384×384 cells or Tiny Swords 64×64 terrain) are evidence of registration practices, not default first-party dimensions.

## Factory completion gate

Accept only when a manifest validator can locate every declared file and atlas cell; alpha bounds do not clip art; pivots/baselines remain stable across directions and frames; frame timing is specified; the Godot prefab imports without hand-tuning in a room; and a moving actor passes the declared seat, door, foreground and ambient-depth cases. A rendered empty scene alone never satisfies the gate.
