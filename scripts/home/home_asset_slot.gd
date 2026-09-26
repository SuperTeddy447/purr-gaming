class_name HomeAssetSlot
extends Node2D
## Replaceable visual ownership boundary for one Home object.

@export var catalog: HomeAssetCatalog
@export var asset_id: StringName = &""
@export var slot_role: StringName = &""
@export var variant_override: StringName = &""
@export var display_label: String = ""

var definition: HomeAssetDefinition
var contract: HomeAssetSlotContract
var visual_node: Node2D


func _ready() -> void:
	add_to_group(&"production_asset_slot")
	add_to_group(&"home_modular_visuals")
	add_to_group(&"home_asset_slots")
	definition = catalog.find_asset(asset_id) if catalog != null else null
	if definition == null:
		push_error("HomeAssetSlot has no catalog definition for '%s' at %s" % [String(asset_id), get_path()])
		return
	contract = definition.find_slot_contract(slot_role)
	if contract == null or not contract.has_valid_contract():
		push_error("HomeAssetSlot has no valid slot contract '%s' for '%s' at %s" % [
			String(slot_role), String(asset_id), get_path()
		])
		return
	var selected_variant: StringName = variant_override if variant_override != &"" else definition.visual_variant
	if selected_variant != contract.visual_variant:
		push_error("HomeAssetSlot '%s' variant '%s' does not match contract '%s'." % [
			String(slot_role), String(selected_variant), String(contract.visual_variant)
		])
		return
	_validate_placement()
	var selected_texture: Texture2D = definition.texture_variants.get(selected_variant, definition.texture) as Texture2D
	if selected_texture != null:
		visual_node = Node2D.new()
		visual_node.name = "FinalTextureVisual"
		var sprite := Sprite2D.new()
		sprite.texture = selected_texture
		var floor_pivot: bool = contract.uses_floor_contact_pivot()
		var top_left_pivot: bool = contract.pivot_type == "FULL_CANVAS_TOP_LEFT"
		sprite.centered = not floor_pivot and not top_left_pivot
		var source_size: Vector2 = selected_texture.get_size()
		if source_size.x > 0.0 and source_size.y > 0.0:
			if contract.fit_policy == "NATIVE_REFERENCE_SCALE":
				sprite.scale = Vector2.ONE
			else:
				var uniform_scale: float = minf(contract.target_bounds.x / source_size.x,
					contract.target_bounds.y / source_size.y)
				sprite.scale = Vector2.ONE * uniform_scale
		if floor_pivot:
			sprite.offset = Vector2(-source_size.x * 0.5, -source_size.y)
		elif top_left_pivot:
			sprite.offset = Vector2.ZERO
		visual_node.add_child(sprite)
		add_child(visual_node)
		move_child(visual_node, 0)
	elif definition.visual_scene != null:
		visual_node = definition.visual_scene.instantiate() as Node2D
		if visual_node == null:
			push_error("Home asset visual scene for '%s' must have a Node2D root." % String(asset_id))
			return
		visual_node.name = "TemporaryVisual"
		add_child(visual_node)
		move_child(visual_node, 0)
		if visual_node.has_method("configure"):
			visual_node.call("configure", definition, selected_variant, display_label)
	else:
		push_error("Home asset '%s' has no visual scene or texture." % String(asset_id))


func _validate_placement() -> void:
	var actual_layer: StringName = _resolved_layer()
	if actual_layer != &"" and actual_layer != contract.owner_layer:
		push_error("Home asset slot '%s' is under %s; contract expects %s." % [
			String(slot_role), String(actual_layer), String(contract.owner_layer)
		])
	if position.distance_to(contract.default_local_position) > 0.01:
		push_error("Home asset slot '%s' moved from its contracted anchor %s." % [
			String(slot_role), str(contract.default_local_position)
		])
	if contract.y_sort_required and not _has_y_sort_owner():
		push_error("Home asset slot '%s' requires the existing Y-sort owner." % String(slot_role))


func _resolved_layer() -> StringName:
	var current: Node = get_parent()
	while current != null:
		if current.name in [&"StructuralBase", &"RoomSkinLayer", &"BackDecorLayer", &"DepthSortedLayer",
			&"ForegroundOccluderLayer", &"FXLayer"]:
			return StringName(current.name)
		current = current.get_parent()
	return &""


func _has_y_sort_owner() -> bool:
	var current: Node = get_parent()
	while current != null:
		if current is Node2D and (current as Node2D).y_sort_enabled:
			return true
		current = current.get_parent()
	return false


func contract_debug_summary() -> String:
	if contract == null:
		return "Slot contract: MISSING"
	return "Target bounds: %.0f×%.0f | Pivot: %s | Layer: %s | Y-sort: %s | Replaceable: %s\nStatus: %s | Final art required: %s | Default local: (%.0f, %.0f)" % [
		contract.target_bounds.x, contract.target_bounds.y, contract.pivot_type,
		String(contract.owner_layer), "YES" if contract.y_sort_required else "NO",
		contract.replaceability, contract.status, "YES" if contract.final_art_required else "NO",
		contract.default_local_position.x, contract.default_local_position.y
	]


func set_tint(color: Color) -> void:
	if definition == null or not definition.tintable_candidate:
		return
	if visual_node.has_method("set_tint"):
		visual_node.call("set_tint", color)
	elif visual_node is CanvasItem:
		(visual_node as CanvasItem).modulate = color


func set_debug_label_visible(is_visible: bool) -> void:
	if visual_node != null and visual_node.has_method("set_debug_label_visible"):
		visual_node.call("set_debug_label_visible", is_visible)
