class_name HardeningCameraInput
extends Node
## Lab-only stand-in for the existing Home CameraRig ownership boundary.

@export var camera: Camera2D
var input_enabled := true
var _dragging := false


func pan_by(world_delta: Vector2) -> bool:
	if not input_enabled or camera == null:
		return false
	camera.global_position += world_delta
	return true


func zoom_by(factor: float) -> bool:
	if not input_enabled or camera == null:
		return false
	var next := clampf(camera.zoom.x * factor, 1.0, 2.0)
	camera.zoom = Vector2.ONE * next
	return true


func _unhandled_input(event: InputEvent) -> void:
	if not input_enabled:
		_dragging = false
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = event.pressed
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_by(1.08)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_by(1.0 / 1.08)
	elif event is InputEventMouseMotion and _dragging:
		pan_by(-event.relative / camera.zoom.x)
