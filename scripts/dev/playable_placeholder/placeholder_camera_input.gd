class_name PlaceholderCameraInput
extends HardeningCameraInput
## The CameraDirector remains focus-shot owner; this handles gameplay gestures.

var room_bounds := Rect2(0, 0, 640, 1000)
@export var assembled_cafe_profile := false
var _touches: Dictionary = {}
var _last_pinch_distance := 0.0
var _mouse_pan := false


func _minimum_zoom() -> float:
	var size := camera.get_viewport_rect().size
	return maxf(size.x / room_bounds.size.x, size.y / room_bounds.size.y)


func _clamp_camera() -> void:
	var half := camera.get_viewport_rect().size * 0.5 / camera.zoom
	camera.global_position = Vector2(
		clampf(camera.global_position.x, room_bounds.position.x + half.x, room_bounds.end.x - half.x),
		clampf(camera.global_position.y, room_bounds.position.y + half.y, room_bounds.end.y - half.y))


func set_preset(preset: StringName, focus: Vector2 = Vector2.ZERO) -> void:
	var minimum := _minimum_zoom()
	match preset:
		&"overview": camera.zoom = Vector2.ONE * minimum
		&"default":
			camera.zoom = Vector2.ONE * (minf(3.0, minimum * 1.06) if assembled_cafe_profile
				else minf(2.1, maxf(minimum * 1.15, 1.25)))
		&"focus":
			camera.zoom = Vector2.ONE * (minf(3.0, minimum * 1.22) if assembled_cafe_profile
				else minf(2.1, maxf(minimum * 1.25, 1.8)))
			camera.global_position = focus
	_clamp_camera()


func pan_by(world_delta: Vector2) -> bool:
	if not super.pan_by(world_delta):
		return false
	_clamp_camera()
	return true


func zoom_by(factor: float) -> bool:
	if not input_enabled or camera == null:
		return false
	var zoom := clampf(camera.zoom.x * factor, _minimum_zoom(), 3.0 if assembled_cafe_profile else 2.1)
	camera.zoom = Vector2.ONE * zoom
	_clamp_camera()
	return true


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		_mouse_pan = false
		_touches.clear()
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE or event.button_index == MOUSE_BUTTON_LEFT:
			_mouse_pan = event.pressed
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_by(1.08)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_by(1.0 / 1.08)
	elif event is InputEventMouseMotion and _mouse_pan:
		pan_by(-event.relative / camera.zoom.x)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_touches[event.index] = event.position
		else:
			_touches.erase(event.index)
		_last_pinch_distance = 0.0
	elif event is InputEventScreenDrag:
		var previous: Vector2 = _touches.get(event.index, event.position)
		_touches[event.index] = event.position
		if _touches.size() == 1:
			pan_by((previous - event.position) / camera.zoom.x)
		elif _touches.size() == 2:
			var values := _touches.values()
			var distance := (values[0] as Vector2).distance_to(values[1] as Vector2)
			if _last_pinch_distance > 1.0:
				zoom_by(distance / _last_pinch_distance)
			_last_pinch_distance = distance
