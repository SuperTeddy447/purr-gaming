class_name CameraController
extends Node2D
## CameraRig controller supporting single-pointer pan, two-finger pinch zoom,
## desktop mouse wheel zoom, gentle smoothing, and world bounds clamping.
## Room configuration is provided via RoomCameraConfig resource or exported properties.

signal camera_zoom_changed(new_zoom: float)
signal camera_panned(new_position: Vector2)
signal tap_unhandled(world_position: Vector2)

@export_group("Room Camera Config")
@export var room_config: RoomCameraConfig:
	set(value):
		room_config = value
		if is_node_ready() and room_config != null:
			apply_room_config(room_config)

@export_group("Target Camera")
@export var camera_node: Camera2D

@export_group("Zoom Limits")
@export_range(0.5, 1.0, 0.01) var min_zoom: float = 0.82
@export_range(0.8, 1.5, 0.01) var default_zoom: float = 1.0
@export_range(1.0, 2.5, 0.01) var max_zoom: float = 1.35
@export var zoom_step_factor: float = 1.08

@export_group("Smoothing & Inertia")
@export var smoothing_speed: float = 12.0
@export var drag_threshold: float = 8.0

@export_group("Pan Bounds")
## World boundary rectangle outside of which the camera cannot pan (defaults to reference design coordinate space).
@export var pan_bounds: Rect2 = Rect2(0, 0, 941, 1672)

# Runtime state
var target_position: Vector2 = Vector2.ZERO
var target_zoom: float = 1.0
var current_zoom: float = 1.0

# Touch & Mouse tracking
var _touch_points: Dictionary = {} # int -> Vector2
var _is_dragging: bool = false
var _drag_start_pos: Vector2 = Vector2.ZERO
var _last_pinch_distance: float = 0.0
var _mouse_down: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO


func _ready() -> void:
	if camera_node == null:
		camera_node = get_node_or_null("Camera2D") as Camera2D
		if camera_node == null:
			camera_node = find_child("Camera2D", false, false) as Camera2D

	if room_config != null:
		apply_room_config(room_config)
	else:
		target_zoom = default_zoom
		current_zoom = default_zoom
		target_position = global_position
		_snap_to_target()


func apply_room_config(config: RoomCameraConfig) -> void:
	min_zoom = config.min_zoom
	default_zoom = config.default_zoom
	max_zoom = config.max_zoom
	pan_bounds = config.pan_bounds
	target_zoom = clampf(config.default_zoom, min_zoom, max_zoom)
	current_zoom = target_zoom
	target_position = clamp_position(config.default_camera_position, target_zoom)
	_snap_to_target()


func _snap_to_target() -> void:
	global_position = target_position
	if camera_node != null:
		camera_node.zoom = Vector2(current_zoom, current_zoom)
	camera_zoom_changed.emit(current_zoom)
	camera_panned.emit(global_position)


func _process(delta: float) -> void:
	if delta <= 0.0:
		return

	# Smooth zoom
	if not is_equal_approx(current_zoom, target_zoom):
		current_zoom = lerpf(current_zoom, target_zoom, clampf(smoothing_speed * delta, 0.0, 1.0))
		if camera_node != null:
			camera_node.zoom = Vector2(current_zoom, current_zoom)
		camera_zoom_changed.emit(current_zoom)

	# Clamped target position based on current zoom
	var clamped_target: Vector2 = clamp_position(target_position, current_zoom)
	target_position = clamped_target

	# Smooth position
	if global_position.distance_squared_to(target_position) > 0.01:
		global_position = global_position.lerp(target_position, clampf(smoothing_speed * delta, 0.0, 1.0))
		camera_panned.emit(global_position)


## Clamps the camera position so the viewport never exposes empty space outside pan_bounds.
func clamp_position(pos: Vector2, zoom: float) -> Vector2:
	if zoom <= 0.001 or not is_inside_tree() or get_viewport() == null:
		return pos

	var vp_size: Vector2 = get_viewport_rect().size
	if vp_size == Vector2.ZERO:
		return pos
	var half_w: float = (vp_size.x * 0.5) / zoom
	var half_h: float = (vp_size.y * 0.5) / zoom

	var bounds_min: Vector2 = pan_bounds.position
	var bounds_max: Vector2 = pan_bounds.end

	var clamped_x: float
	if half_w * 2.0 >= (bounds_max.x - bounds_min.x):
		# Visible area is wider than bounds at this zoom level: lock to center
		clamped_x = (bounds_min.x + bounds_max.x) * 0.5
	else:
		clamped_x = clampf(pos.x, bounds_min.x + half_w, bounds_max.x - half_w)

	var clamped_y: float
	if half_h * 2.0 >= (bounds_max.y - bounds_min.y):
		# Visible area is taller than bounds at this zoom level: lock to center
		clamped_y = (bounds_min.y + bounds_max.y) * 0.5
	else:
		clamped_y = clampf(pos.y, bounds_min.y + half_h, bounds_max.y - half_h)

	return Vector2(clamped_x, clamped_y)


## Unhandled input ensures UI controls consuming input will not accidentally pan or zoom the world.
func _unhandled_input(event: InputEvent) -> void:
	# Touch screen events (Mobile & Emulated Touch)
	if event is InputEventScreenTouch:
		_handle_screen_touch(event as InputEventScreenTouch)
	elif event is InputEventScreenDrag:
		_handle_screen_drag(event as InputEventScreenDrag)
	# Mouse button events (Desktop development)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event as InputEventMouseButton)
	# Mouse motion events (Desktop development)
	elif event is InputEventMouseMotion:
		_handle_mouse_motion(event as InputEventMouseMotion)


func _handle_screen_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touch_points[event.index] = event.position
		if _touch_points.size() == 1:
			_is_dragging = false
			_drag_start_pos = event.position
		elif _touch_points.size() == 2:
			var pts: Array = _touch_points.values()
			_last_pinch_distance = (pts[0] as Vector2).distance_to(pts[1] as Vector2)
			_is_dragging = true
	else:
		if _touch_points.has(event.index):
			_touch_points.erase(event.index)

		if _touch_points.is_empty():
			if not _is_dragging:
				# Clean tap gesture detected
				var world_tap: Vector2 = get_canvas_transform().affine_inverse() * event.position
				tap_unhandled.emit(world_tap)
			_is_dragging = false
			_last_pinch_distance = 0.0
		elif _touch_points.size() == 1:
			# Transition from pinch to single-finger pan seamlessly
			var remaining_pos: Vector2 = _touch_points.values()[0]
			_drag_start_pos = remaining_pos
			_last_pinch_distance = 0.0


func _handle_screen_drag(event: InputEventScreenDrag) -> void:
	_touch_points[event.index] = event.position

	if _touch_points.size() >= 2:
		# Multi-touch pinch zoom
		var pts: Array = _touch_points.values()
		var current_dist: float = (pts[0] as Vector2).distance_to(pts[1] as Vector2)
		if _last_pinch_distance > 0.0 and current_dist > 0.0:
			var ratio: float = current_dist / _last_pinch_distance
			set_zoom_target(target_zoom * ratio)
		_last_pinch_distance = current_dist
	elif _touch_points.size() == 1:
		# Single touch pan
		if not _is_dragging:
			if event.position.distance_to(_drag_start_pos) >= drag_threshold:
				_is_dragging = true

		if _is_dragging:
			var world_delta: Vector2 = event.relative / current_zoom
			target_position -= world_delta
			target_position = clamp_position(target_position, target_zoom)


func _handle_mouse_button(event: InputEventMouseButton) -> void:
	# Mouse wheel zoom
	if event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			set_zoom_target(target_zoom * zoom_step_factor)
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			set_zoom_target(target_zoom / zoom_step_factor)
			get_viewport().set_input_as_handled()
			return

	# Mouse drag pan
	if event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_mouse_down = true
			_is_dragging = false
			_drag_start_pos = event.position
			_last_mouse_pos = event.position
		else:
			if _mouse_down and not _is_dragging:
				var world_tap: Vector2 = get_canvas_transform().affine_inverse() * event.position
				tap_unhandled.emit(world_tap)
			_mouse_down = false
			_is_dragging = false


func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	if _mouse_down:
		if not _is_dragging:
			if event.position.distance_to(_drag_start_pos) >= drag_threshold:
				_is_dragging = true

		if _is_dragging:
			var world_delta: Vector2 = event.relative / current_zoom
			target_position -= world_delta
			target_position = clamp_position(target_position, target_zoom)


func set_zoom_target(new_zoom: float) -> void:
	target_zoom = clampf(new_zoom, min_zoom, max_zoom)
	target_position = clamp_position(target_position, target_zoom)


func reset_to_default() -> void:
	if room_config != null:
		apply_room_config(room_config)
	else:
		target_zoom = default_zoom
		target_position = clamp_position(Vector2(470.5, 836.0), target_zoom)
