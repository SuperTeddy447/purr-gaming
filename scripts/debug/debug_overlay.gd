class_name DebugOverlay
extends CanvasLayer
## Debug overlay providing two clearly distinct visual states:
## - NORMAL DEV VIEW: Clean V2.1 reference café, minimal runtime placeholders, zero debug clutter.
## - DEBUG VIEW: Marker targets, camera bounds, safe areas, depth test helpers, occluder guides, stats.
## Toggled via F1 or D key, or the on-screen master toggle button.

signal master_debug_toggled(is_active: bool)
signal dev_reference_toggled(visible: bool)
signal markers_toggled(visible: bool)
signal bounds_toggled(visible: bool)
signal safe_areas_toggled(visible: bool)
signal camera_reset_requested

@export var camera_controller: CameraController
@export var master_debug_active: bool = false:
	set(value):
		master_debug_active = value
		_apply_master_debug_state()

@export var show_markers: bool = true
@export var show_bounds: bool = true
@export var show_safe_areas: bool = true
@export var dev_reference_visible: bool = true

var _stats_panel: PanelContainer
var _stats_label: Label
var _safe_area_top: ColorRect
var _safe_area_bottom: ColorRect
var _button_container: HBoxContainer
var _master_debug_btn: Button


func _ready() -> void:
	layer = 120
	_build_ui()
	_apply_master_debug_state()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_F1, KEY_D:
				toggle_master_debug()
				get_viewport().set_input_as_handled()
			KEY_R:
				toggle_dev_reference()
				get_viewport().set_input_as_handled()
			KEY_M:
				if master_debug_active:
					toggle_markers()
					get_viewport().set_input_as_handled()
			KEY_B:
				if master_debug_active:
					toggle_bounds()
					get_viewport().set_input_as_handled()
			KEY_S:
				if master_debug_active:
					toggle_safe_areas()
					get_viewport().set_input_as_handled()
			KEY_SPACE:
				reset_camera()
				get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	if not master_debug_active or _stats_label == null:
		return

	if camera_controller != null:
		var zoom_val: float = camera_controller.current_zoom
		var target_zoom_val: float = camera_controller.target_zoom
		var pos_val: Vector2 = camera_controller.global_position
		var bounds: Rect2 = camera_controller.pan_bounds

		_stats_label.text = (
			"=== WilliCat Foundation [DEBUG VIEW] ===\n" +
			"Camera Zoom: %.2fx (Target: %.2fx | Min: %.2f | Max: %.2f)\n" % [
				zoom_val, target_zoom_val, camera_controller.min_zoom, camera_controller.max_zoom
			] +
			"Camera Pos: (%.1f, %.1f)\n" % [pos_val.x, pos_val.y] +
			"Pan Bounds: X[%.0f..%.0f] Y[%.0f..%.0f]\n" % [
				bounds.position.x, bounds.end.x, bounds.position.y, bounds.end.y
			] +
			"Shortcuts: [F1/D] Toggle Debug | [R] Ref Art | [M] Markers | [B] Bounds | [S] Safe | [Space] Reset"
		)


func _build_ui() -> void:
	# Root container
	var root: Control = Control.new()
	root.name = "DebugRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# Master Debug Toggle Button (top right, always accessible)
	_master_debug_btn = Button.new()
	_master_debug_btn.name = "MasterDebugButton"
	_master_debug_btn.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_master_debug_btn.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_master_debug_btn.position = Vector2(-160, 20)
	_master_debug_btn.custom_minimum_size = Vector2(144, 32)
	_master_debug_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_master_debug_btn.pressed.connect(toggle_master_debug)
	root.add_child(_master_debug_btn)

	# Stats Panel (top left)
	_stats_panel = PanelContainer.new()
	_stats_panel.name = "StatsPanel"
	_stats_panel.position = Vector2(16, 20)
	_stats_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_stats_panel)

	_stats_label = Label.new()
	_stats_label.name = "StatsLabel"
	_stats_label.add_theme_font_size_override("font_size", 12)
	_stats_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 0.95))
	_stats_panel.add_child(_stats_label)

	# Button Bar (bottom right, above bottom safe area)
	_button_container = HBoxContainer.new()
	_button_container.name = "ButtonBar"
	_button_container.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_button_container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_button_container.grow_vertical = Control.GROW_DIRECTION_BEGIN
	_button_container.position = Vector2(-16, -200)
	_button_container.add_theme_constant_override("separation", 6)
	root.add_child(_button_container)

	_create_button("Ref [R]", Callable(self, "toggle_dev_reference"))
	_create_button("Markers [M]", Callable(self, "toggle_markers"))
	_create_button("Bounds [B]", Callable(self, "toggle_bounds"))
	_create_button("Safe [S]", Callable(self, "toggle_safe_areas"))
	_create_button("Reset [Space]", Callable(self, "reset_camera"))

	# Safe area visualization overlays
	_safe_area_top = ColorRect.new()
	_safe_area_top.name = "SafeAreaTopVisual"
	_safe_area_top.color = Color(0.15, 0.45, 0.9, 0.22)
	_safe_area_top.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_safe_area_top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_safe_area_top.anchor_bottom = 0.11
	root.add_child(_safe_area_top)

	var top_label: Label = Label.new()
	top_label.text = "TOP HUD SAFE AREA (~11%)"
	top_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	top_label.add_theme_font_size_override("font_size", 12)
	top_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0, 0.8))
	top_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_safe_area_top.add_child(top_label)

	_safe_area_bottom = ColorRect.new()
	_safe_area_bottom.name = "SafeAreaBottomVisual"
	_safe_area_bottom.color = Color(0.15, 0.45, 0.9, 0.22)
	_safe_area_bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_safe_area_bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_safe_area_bottom.anchor_top = 0.89
	root.add_child(_safe_area_bottom)

	var bottom_label: Label = Label.new()
	bottom_label.text = "BOTTOM NAV SAFE AREA (~11%)"
	bottom_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	bottom_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	bottom_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	bottom_label.add_theme_font_size_override("font_size", 12)
	bottom_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0, 0.8))
	bottom_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_safe_area_bottom.add_child(bottom_label)


func _create_button(btn_text: String, callback: Callable) -> Button:
	var btn: Button = Button.new()
	btn.text = btn_text
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.pressed.connect(callback)
	_button_container.add_child(btn)
	return btn


func toggle_master_debug() -> void:
	master_debug_active = not master_debug_active


func _apply_master_debug_state() -> void:
	if _master_debug_btn != null:
		_master_debug_btn.text = "Debug [F1]: " + ("ON" if master_debug_active else "OFF")

	if _stats_panel != null:
		_stats_panel.visible = master_debug_active

	if _button_container != null:
		_button_container.visible = master_debug_active

	if _safe_area_top != null:
		_safe_area_top.visible = master_debug_active and show_safe_areas

	if _safe_area_bottom != null:
		_safe_area_bottom.visible = master_debug_active and show_safe_areas

	_update_markers_state()
	master_debug_toggled.emit(master_debug_active)


func toggle_dev_reference() -> void:
	dev_reference_visible = not dev_reference_visible
	dev_reference_toggled.emit(dev_reference_visible)


func toggle_markers() -> void:
	show_markers = not show_markers
	_update_markers_state()
	markers_toggled.emit(show_markers)


func toggle_bounds() -> void:
	show_bounds = not show_bounds
	bounds_toggled.emit(show_bounds)


func toggle_safe_areas() -> void:
	show_safe_areas = not show_safe_areas
	if _safe_area_top != null:
		_safe_area_top.visible = master_debug_active and show_safe_areas
	if _safe_area_bottom != null:
		_safe_area_bottom.visible = master_debug_active and show_safe_areas
	safe_areas_toggled.emit(show_safe_areas)


func reset_camera() -> void:
	if camera_controller != null:
		camera_controller.reset_to_default()
	camera_reset_requested.emit()


func _update_markers_state() -> void:
	var tree: SceneTree = get_tree()
	if tree == null:
		return

	var markers_visible: bool = master_debug_active and show_markers
	for node in tree.get_nodes_in_group(&"gameplay_markers"):
		if node is GameplayMarker:
			(node as GameplayMarker).show_debug_gizmo = markers_visible

	for node in tree.get_nodes_in_group(&"dynamic_signs"):
		if node is DynamicSign:
			(node as DynamicSign).show_debug_surface = markers_visible
