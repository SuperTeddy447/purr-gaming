class_name HomeScene
extends Node2D
## Root controller for the modular WilliCat Home visual mock.
## Coordinates reference comparison, dynamic signs, and debug visualization.


@export_group("Room Setup")
@export var room_id: StringName = GameplayID.ROOM_MAIN_CAFE

@export_group("Core Components")
@export var debug_overlay: DebugOverlay
@export var dev_reference_node: CanvasItem
@export var bounds_drawer: BoundsDrawer
@export var dev_visual_master_node: Sprite2D


func _ready() -> void:
	_register_groups()
	_setup_debug_connections()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F6:
		toggle_dev_visual_master()
		get_viewport().set_input_as_handled()


func toggle_dev_visual_master() -> void:
	if dev_visual_master_node == null:
		return
	if dev_visual_master_node.visible:
		dev_visual_master_node.visible = false
		_set_modular_visuals_visible(dev_reference_node == null or not dev_reference_node.visible)
		print("Home environment comparison: MODULAR HOME MOCK.")
	else:
		if dev_reference_node != null and dev_reference_node.visible:
			dev_reference_node.visible = false
			if debug_overlay != null:
				debug_overlay.dev_reference_visible = false
		dev_visual_master_node.visible = true
		_set_modular_visuals_visible(false)
		print("Home environment comparison: locked style master.")


func _register_groups() -> void:
	# Group all markers under GameplayNodes
	var gameplay_nodes: Node = get_node_or_null("GameplayNodes")
	if gameplay_nodes != null:
		_add_children_to_group(gameplay_nodes, &"gameplay_markers")

	# Group all dynamic signs
	var dynamic_signs: Node = get_node_or_null("DynamicSignage")
	if dynamic_signs != null:
		_add_children_to_group(dynamic_signs, &"dynamic_signs")


func _add_children_to_group(parent: Node, group_name: StringName) -> void:
	for child in parent.get_children():
		child.add_to_group(group_name)
		if child.get_child_count() > 0:
			_add_children_to_group(child, group_name)


func _setup_debug_connections() -> void:
	if debug_overlay == null:
		debug_overlay = get_node_or_null("UI/DebugOverlay") as DebugOverlay

	if debug_overlay != null:
		debug_overlay.master_debug_toggled.connect(_on_master_debug_toggled)
		debug_overlay.dev_reference_toggled.connect(_on_dev_reference_toggled)
		debug_overlay.bounds_toggled.connect(_on_bounds_toggled)

	# Initial state sync
	if dev_reference_node != null and debug_overlay != null:
		dev_reference_node.visible = debug_overlay.dev_reference_visible
	_set_modular_visuals_visible(dev_visual_master_node == null or not dev_visual_master_node.visible)

	var is_debug: bool = debug_overlay.master_debug_active if debug_overlay != null else false
	_set_debug_geometry_visible(is_debug)

	if bounds_drawer != null and debug_overlay != null:
		bounds_drawer.show_bounds = is_debug and debug_overlay.show_bounds


func _on_master_debug_toggled(is_active: bool) -> void:
	_set_debug_geometry_visible(is_active)
	for node in get_tree().get_nodes_in_group(&"home_asset_slots"):
		if node is HomeAssetSlot:
			(node as HomeAssetSlot).set_debug_label_visible(is_active)
	if bounds_drawer != null and debug_overlay != null:
		bounds_drawer.show_bounds = is_active and debug_overlay.show_bounds


func _set_debug_geometry_visible(visible_state: bool) -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		return
	for node in tree.get_nodes_in_group(&"debug_geometry"):
		if node is CanvasItem:
			(node as CanvasItem).visible = visible_state
			_set_debug_controls_mouse_ignored(node)


func _set_debug_controls_mouse_ignored(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_debug_controls_mouse_ignored(child)


func _on_dev_reference_toggled(visible_state: bool) -> void:
	if dev_reference_node != null:
		dev_reference_node.visible = visible_state
	if visible_state:
		if dev_visual_master_node != null:
			dev_visual_master_node.visible = false
		_set_modular_visuals_visible(false)
	else:
		_set_modular_visuals_visible(dev_visual_master_node == null or not dev_visual_master_node.visible)


func _set_modular_visuals_visible(is_visible: bool) -> void:
	if not is_inside_tree():
		return
	for node in get_tree().get_nodes_in_group(&"home_modular_visuals"):
		if node is CanvasItem:
			(node as CanvasItem).visible = is_visible


func _on_bounds_toggled(visible_state: bool) -> void:
	if bounds_drawer != null and debug_overlay != null:
		bounds_drawer.show_bounds = debug_overlay.master_debug_active and visible_state
