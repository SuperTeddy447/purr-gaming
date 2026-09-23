class_name HomeScene
extends Node2D
## Root controller for the WilliCat Home scene (Foundation V1.1 Depth Fix).
## Manages room initialization, dev reference background toggling,
## dynamic sign registration, and debug overlay coordination.


@export_group("Room Setup")
@export var room_id: StringName = GameplayID.ROOM_MAIN_CAFE
@export var room_camera_config: RoomCameraConfig

@export_group("Core Components")
@export var camera_controller: CameraController
@export var debug_overlay: DebugOverlay
@export var dev_reference_node: CanvasItem
@export var bounds_drawer: BoundsDrawer


func _ready() -> void:
	_register_groups()
	_setup_camera()
	_setup_debug_connections()


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


func _setup_camera() -> void:
	if camera_controller == null:
		camera_controller = get_node_or_null("CameraRig") as CameraController

	if camera_controller != null and room_camera_config != null:
		camera_controller.apply_room_config(room_camera_config)


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

	var is_debug: bool = debug_overlay.master_debug_active if debug_overlay != null else false
	_set_debug_geometry_visible(is_debug)

	if bounds_drawer != null and debug_overlay != null:
		bounds_drawer.show_bounds = is_debug and debug_overlay.show_bounds


func _on_master_debug_toggled(is_active: bool) -> void:
	_set_debug_geometry_visible(is_active)
	if bounds_drawer != null and debug_overlay != null:
		bounds_drawer.show_bounds = is_active and debug_overlay.show_bounds


func _set_debug_geometry_visible(visible_state: bool) -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		return
	for node in tree.get_nodes_in_group(&"debug_geometry"):
		if node is CanvasItem:
			(node as CanvasItem).visible = visible_state


func _on_dev_reference_toggled(visible_state: bool) -> void:
	if dev_reference_node != null:
		dev_reference_node.visible = visible_state


func _on_bounds_toggled(visible_state: bool) -> void:
	if bounds_drawer != null and debug_overlay != null:
		bounds_drawer.show_bounds = debug_overlay.master_debug_active and visible_state

