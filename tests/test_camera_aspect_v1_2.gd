extends SceneTree
## Verifies the room camera against logical viewports produced by portrait expand layouts.

const BOUNDS_TOLERANCE: float = 0.05
const ROOM_CONFIG_PATH: String = "res://data/room_main_cafe_camera.tres"


func _init() -> void:
	call_deferred("_run_checks")


func _run_checks() -> void:
	var room_config: RoomCameraConfig = load(ROOM_CONFIG_PATH) as RoomCameraConfig
	if room_config == null:
		_fail("Main Café camera config failed to load")
		return

	var viewport: SubViewport = SubViewport.new()
	viewport.name = "AspectTestViewport"
	viewport.size = Vector2i(941, 1672)
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)

	var camera_rig: CameraController = CameraController.new()
	camera_rig.name = "CameraRig"
	camera_rig.room_config = room_config
	var camera: Camera2D = Camera2D.new()
	camera.name = "Camera2D"
	camera_rig.add_child(camera)
	camera_rig.camera_node = camera
	viewport.add_child(camera_rig)
	camera.make_current()
	camera_rig.set_process(false)
	await process_frame

	var profiles: Array[Dictionary] = [
		{"name": "9:16 baseline", "size": Vector2i(941, 1672)},
		{"name": "9:19.5 tall phone", "size": Vector2i(941, 2039)},
		{"name": "3:4 tablet", "size": Vector2i(1254, 1672)}
	]
	for profile in profiles:
		viewport.size = profile["size"]
		await process_frame
		var viewport_size: Vector2 = camera_rig.get_viewport_rect().size
		var required_zoom: float = maxf(
			room_config.design_min_zoom,
			maxf(viewport_size.x / room_config.pan_bounds.size.x,
				viewport_size.y / room_config.pan_bounds.size.y)
		)
		if not is_equal_approx(camera_rig.effective_min_zoom, required_zoom):
			_fail("%s effective minimum: expected %.5f, got %.5f" % [
				profile["name"], required_zoom, camera_rig.effective_min_zoom
			])
			return
		if camera_rig.current_zoom < camera_rig.effective_min_zoom - 0.0001:
			_fail("%s resize left the rendered camera below its safe zoom" % profile["name"])
			return

		camera_rig.reset_to_default()
		camera.force_update_scroll()
		if camera_rig.current_zoom < camera_rig.effective_min_zoom - 0.0001:
			_fail("%s default framing is below the safe zoom" % profile["name"])
			return
		if not _visible_world_inside_bounds(viewport, camera, room_config.pan_bounds):
			_fail("%s default framing exposes outside-world space" % profile["name"])
			return

		camera_rig.set_zoom_target(camera_rig.max_zoom)
		camera_rig.target_position = room_config.pan_bounds.position + Vector2(-1000.0, 3000.0)
		camera_rig._process(1.0)
		camera.force_update_scroll()
		if not _visible_world_inside_bounds(viewport, camera, room_config.pan_bounds):
			_fail("%s edge pan exposes outside-world space" % profile["name"])
			return

		camera_rig.set_zoom_target(0.01)
		if camera_rig.target_zoom < camera_rig.effective_min_zoom - 0.0001:
			_fail("%s allowed zoom below its effective minimum" % profile["name"])
			return
		for frame in range(20):
			camera_rig._process(1.0 / 60.0)
			camera.force_update_scroll()
			if not _visible_world_inside_bounds(viewport, camera, room_config.pan_bounds):
				_fail("%s zoom-out transition exposes outside-world space on frame %d" % [
					profile["name"], frame
				])
				return

		print("[PASS] %s viewport=%dx%d design_min=%.2f effective_min=%.5f default=%.5f" % [
			profile["name"], int(viewport_size.x), int(viewport_size.y),
			camera_rig.design_min_zoom, camera_rig.effective_min_zoom,
			maxf(camera_rig.default_zoom, camera_rig.effective_min_zoom)
		])

	var expanded_config: RoomCameraConfig = RoomCameraConfig.new()
	expanded_config.default_camera_position = room_config.default_camera_position
	expanded_config.design_min_zoom = room_config.design_min_zoom
	expanded_config.default_zoom = room_config.default_zoom
	expanded_config.max_zoom = room_config.max_zoom
	expanded_config.pan_bounds = Rect2(-300.0, -300.0, 1541.0, 2272.0)
	camera_rig.apply_room_config(expanded_config)
	camera.force_update_scroll()
	if not is_equal_approx(camera_rig.effective_min_zoom, expanded_config.design_min_zoom) or \
		not is_equal_approx(camera_rig.current_zoom, expanded_config.default_zoom) or \
		not _visible_world_inside_bounds(viewport, camera, expanded_config.pan_bounds):
		_fail("Larger room bounds did not preserve independent default framing")
		return
	print("[PASS] Larger production room bounds retain the design minimum and default framing.")

	var wheel_up: InputEventMouseButton = InputEventMouseButton.new()
	wheel_up.button_index = MOUSE_BUTTON_WHEEL_UP
	wheel_up.pressed = true
	camera_rig._handle_mouse_button(wheel_up)
	if camera_rig.target_zoom <= expanded_config.default_zoom:
		_fail("Mouse wheel no longer increases the zoom target")
		return
	camera_rig.reset_to_default()

	var first_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	first_touch.index = 0
	first_touch.position = Vector2(200.0, 600.0)
	first_touch.pressed = true
	camera_rig._handle_screen_touch(first_touch)
	var second_touch: InputEventScreenTouch = InputEventScreenTouch.new()
	second_touch.index = 1
	second_touch.position = Vector2(500.0, 600.0)
	second_touch.pressed = true
	camera_rig._handle_screen_touch(second_touch)
	var pinch_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	pinch_drag.index = 1
	pinch_drag.position = Vector2(550.0, 600.0)
	pinch_drag.relative = Vector2(50.0, 0.0)
	camera_rig._handle_screen_drag(pinch_drag)
	if camera_rig.target_zoom <= expanded_config.default_zoom:
		_fail("Touch pinch no longer increases the zoom target")
		return
	second_touch.pressed = false
	camera_rig._handle_screen_touch(second_touch)
	first_touch.pressed = false
	camera_rig._handle_screen_touch(first_touch)

	camera_rig.reset_to_default()
	camera_rig.set_zoom_target(camera_rig.max_zoom)
	camera_rig._process(1.0)
	var before_mouse_pan: Vector2 = camera_rig.target_position
	var mouse_press: InputEventMouseButton = InputEventMouseButton.new()
	mouse_press.button_index = MOUSE_BUTTON_LEFT
	mouse_press.position = Vector2(500.0, 600.0)
	mouse_press.pressed = true
	camera_rig._handle_mouse_button(mouse_press)
	var mouse_drag: InputEventMouseMotion = InputEventMouseMotion.new()
	mouse_drag.position = Vector2(530.0, 600.0)
	mouse_drag.relative = Vector2(30.0, 0.0)
	camera_rig._handle_mouse_motion(mouse_drag)
	if camera_rig.target_position.x >= before_mouse_pan.x:
		_fail("Mouse drag no longer pans the camera")
		return
	mouse_press.pressed = false
	camera_rig._handle_mouse_button(mouse_press)

	var before_touch_pan: Vector2 = camera_rig.target_position
	first_touch.pressed = true
	camera_rig._handle_screen_touch(first_touch)
	var touch_drag: InputEventScreenDrag = InputEventScreenDrag.new()
	touch_drag.index = 0
	touch_drag.position = Vector2(200.0, 630.0)
	touch_drag.relative = Vector2(0.0, 30.0)
	camera_rig._handle_screen_drag(touch_drag)
	if camera_rig.target_position.y >= before_touch_pan.y:
		_fail("Touch drag no longer pans the camera")
		return
	first_touch.pressed = false
	camera_rig._handle_screen_touch(first_touch)
	print("[PASS] Mouse wheel/drag and touch pinch/pan targets remain responsive.")

	var invalid_viewport_zoom: float = CameraController.calculate_effective_min_zoom(
		Vector2.ZERO, room_config.pan_bounds, room_config.design_min_zoom)
	var invalid_bounds_zoom: float = CameraController.calculate_effective_min_zoom(
		Vector2(941, 1672), Rect2(), room_config.design_min_zoom)
	if not is_equal_approx(invalid_viewport_zoom, room_config.design_min_zoom) or \
		not is_equal_approx(invalid_bounds_zoom, room_config.design_min_zoom):
		_fail("Invalid viewport or bounds geometry did not return the safe design minimum")
		return
	print("[PASS] Zero-sized viewport and bounds are handled without division by zero.")
	print("--- ALL FOUNDATION V1.2 CAMERA ASPECT CHECKS PASSED ---")
	quit(0)


func _visible_world_inside_bounds(viewport: SubViewport, camera: Camera2D, bounds: Rect2) -> bool:
	if not camera.is_current():
		return false
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var viewport_to_world: Transform2D = viewport.get_canvas_transform().affine_inverse()
	var corners: Array[Vector2] = [
		viewport_to_world * Vector2.ZERO,
		viewport_to_world * Vector2(viewport_size.x, 0.0),
		viewport_to_world * Vector2(0.0, viewport_size.y),
		viewport_to_world * viewport_size
	]
	for corner in corners:
		if corner.x < bounds.position.x - BOUNDS_TOLERANCE or corner.x > bounds.end.x + BOUNDS_TOLERANCE:
			return false
		if corner.y < bounds.position.y - BOUNDS_TOLERANCE or corner.y > bounds.end.y + BOUNDS_TOLERANCE:
			return false
	return true


func _fail(message: String) -> void:
	printerr("[FAIL] " + message)
	quit(1)
