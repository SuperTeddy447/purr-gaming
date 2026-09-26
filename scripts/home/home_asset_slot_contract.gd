class_name HomeAssetSlotContract
extends Resource
## Per-instance art contract. Roles are semantic; NodePaths are never identities.

@export var slot_role: StringName = &""
@export var visual_variant: StringName = &"default"
@export var owner_layer: StringName = &""
@export var default_local_position: Vector2 = Vector2.ZERO
@export var target_bounds: Vector2 = Vector2.ZERO
@export_enum("FIT_WITHIN_REFERENCE_BOUNDS", "NATIVE_REFERENCE_SCALE", "PIVOT_LOCKED")
var fit_policy: String = "FIT_WITHIN_REFERENCE_BOUNDS"
@export_enum("CENTER", "FULL_CANVAS_TOP_LEFT", "FLOOR_CONTACT_BOTTOM_CENTER", "COUNTERTOP_BASE_CENTER", "COUNTER_BACK_SURFACE_CENTER", "COUNTER_FRONT_BOTTOM_CENTER", "WALL_MOUNT_CENTER")
var pivot_type: String = "CENTER"
@export var y_sort_required: bool = false
@export var occlusion_role: StringName = &"NONE"
@export var interaction_role: StringName = &"NONE"
@export_enum("REPLACEABLE_VISUAL", "REPLACEABLE_FULL_CANVAS", "STRUCTURAL_RUNTIME")
var replaceability: String = "REPLACEABLE_VISUAL"
@export_enum("TEMP PLACEHOLDER", "FINAL ART", "STRUCTURAL / NO FINAL SPRITE")
var status: String = "TEMP PLACEHOLDER"
@export var final_art_required: bool = true
@export var animation_policy: StringName = &"STATIC"


func has_valid_contract() -> bool:
	return slot_role != &"" and visual_variant != &"" and owner_layer != &"" \
		and target_bounds.x > 0.0 and target_bounds.y > 0.0 \
		and fit_policy in ["FIT_WITHIN_REFERENCE_BOUNDS", "NATIVE_REFERENCE_SCALE", "PIVOT_LOCKED"] \
		and pivot_type in ["CENTER", "FULL_CANVAS_TOP_LEFT", "FLOOR_CONTACT_BOTTOM_CENTER",
			"COUNTERTOP_BASE_CENTER", "COUNTER_BACK_SURFACE_CENTER", "COUNTER_FRONT_BOTTOM_CENTER",
			"WALL_MOUNT_CENTER"] \
		and replaceability in ["REPLACEABLE_VISUAL", "REPLACEABLE_FULL_CANVAS", "STRUCTURAL_RUNTIME"] \
		and status != ""


func uses_floor_contact_pivot() -> bool:
	return pivot_type == "FLOOR_CONTACT_BOTTOM_CENTER" or pivot_type == "COUNTERTOP_BASE_CENTER" \
		or pivot_type == "COUNTER_FRONT_BOTTOM_CENTER"
