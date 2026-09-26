extends SceneTree
## Deterministic evidence capture for Home Functional Prototype V1.
## Runs the real Home scene and its existing state machines in a rendered SubViewport.

const HOME_SCENE_PATH: String = "res://scenes/home/home_scene.tscn"
const OUTPUT_DIR: String = "res://artifacts/prototype_review/functional_v1"
const READABILITY_OUTPUT_DIR: String = "res://artifacts/prototype_review/readability_v1"
const SPATIAL_OUTPUT_DIR: String = "res://artifacts/prototype_review/spatial_v1"
const BASELINE_SIZE: Vector2i = Vector2i(941, 1672)
const TALL_PHONE_SIZE: Vector2i = Vector2i(941, 2039)
const TABLET_SIZE: Vector2i = Vector2i(1254, 1672)
const STATE_TIMEOUT_FRAMES: int = 3600

var _viewport: SubViewport
var _home: HomeScene
var _slice: VerticalSliceController
var _worker: MochiScaleTest
var _debug: DebugOverlay
var _camera: CameraController
var _failures: Array[String] = []
var _output_dir: String = OUTPUT_DIR
var _readability_mode: bool = false
var _spatial_mode: bool = false


func _initialize() -> void:
	call_deferred("_run_capture_pack")


func _run_capture_pack() -> void:
	_readability_mode = OS.get_cmdline_user_args().has("readability-v1")
	_spatial_mode = OS.get_cmdline_user_args().has("spatial-v1")
	_output_dir = SPATIAL_OUTPUT_DIR if _spatial_mode else READABILITY_OUTPUT_DIR if _readability_mode else OUTPUT_DIR
	if OS.has_feature("headless"):
		_failures.append("Capture requires a normal rendered Godot run, not --headless.")
		_finish()
		return

	var output_absolute: String = ProjectSettings.globalize_path(_output_dir)
	var directory_error: Error = DirAccess.make_dir_recursive_absolute(output_absolute)
	if directory_error != OK and not DirAccess.dir_exists_absolute(output_absolute):
		_failures.append("Could not create artifact directory: %s" % output_absolute)
		_finish()
		return

	_viewport = SubViewport.new()
	_viewport.name = "FunctionalPrototypeCaptureViewport"
	_viewport.size = BASELINE_SIZE
	_viewport.disable_3d = true
	_viewport.transparent_bg = false
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_viewport)

	var home_scene: PackedScene = load(HOME_SCENE_PATH) as PackedScene
	if home_scene == null:
		_failures.append("Could not load current Home scene: %s" % HOME_SCENE_PATH)
		_finish()
		return
	_home = home_scene.instantiate() as HomeScene
	_slice = _home.get_node_or_null("VerticalSliceController") as VerticalSliceController
	_worker = _home.get_node_or_null("World/DepthSortedLayer/MochiScaleTestDEV") as MochiScaleTest
	_debug = _home.get_node_or_null("UI/DebugOverlay") as DebugOverlay
	_camera = _home.get_node_or_null("CameraRig") as CameraController
	if _slice == null or _worker == null or _debug == null or _camera == null:
		_failures.append("Home scene is missing a required existing prototype controller.")
		_finish()
		return

	# Keep the Home scene's real state machines, but start the loop explicitly so
	# the baseline captures are stable and the same single customer is used below.
	_slice.start_on_ready = false
	_slice.auto_repeat_slice = false
	_viewport.add_child(_home)
	await _settle_frames(4)
	_debug.master_debug_active = false
	_camera.reset_to_default()
	_worker.select_scale_mode(MochiScaleTest.ScaleMode.LARGE)
	_worker.select_test_position(MochiScaleTest.TestPosition.WORKER_IDLE)
	await _settle_frames(2)

	await _save_capture("01_home_default_debug_off.png")
	_debug.master_debug_active = true
	await _settle_frames(2)
	await _save_capture("02_home_default_debug_on.png")
	_debug.master_debug_active = false

	seed(1001)
	_slice.start_slice()
	if not await _wait_until(func() -> bool:
		return _slice.customer_slice != null and _slice.customer_slice.state == SliceCustomer.State.WALKING_TO_SEAT
	, "customer entering"):
		_finish()
		return
	await _settle_frames(2)
	await _save_capture("03_customer_entering.png")

	if not await _wait_until(func() -> bool:
		return _slice.customer_slice != null and _slice.customer_slice.state == SliceCustomer.State.WAITING_FOR_SERVICE
	, "customer seated with active order"):
		_finish()
		return
	_debug.master_debug_active = false
	await _settle_frames(2)
	await _save_capture("04_customer_seated_order.png")
	if _spatial_mode:
		_debug.master_debug_active = true
		await _settle_frames(2)
		await _save_capture("04b_debug_route_overview.png")
		_debug.master_debug_active = false

	if not _slice.request_coffee_preparation():
		_failures.append("Existing manual prototype rejected coffee preparation in the active-order state.")
		_finish()
		return
	if _spatial_mode:
		if not await _wait_until(func() -> bool:
			return _slice.worker_slice.state == SliceWorker.State.WALKING_TO_COFFEE and \
				_slice.worker_actor.global_position.distance_to(_slice.get_marker_position(GameplayID.WORKER_IDLE)) >= 45.0
		, "Mochi moving from WorkerIdle toward CoffeeAction"):
			_finish()
			return
		await _settle_frames(2)
		await _save_capture("02_worker_to_coffee.png")
	if not await _wait_until(func() -> bool:
		return _slice.worker_slice != null and _slice.worker_slice.state == SliceWorker.State.PREPARING_COFFEE
	, "coffee preparation"):
		_finish()
		return
	await _settle_frames(8)
	_debug.master_debug_active = false
	await _save_capture("05_mochi_coffee_action.png")
	_debug.master_debug_active = true
	await _settle_frames(2)
	await _save_capture("06_coffee_preparing_debug.png")
	_debug.master_debug_active = false

	if not await _wait_until(func() -> bool:
		return _slice.worker_slice != null \
			and _slice.worker_slice.state == SliceWorker.State.WALKING_TO_SERVE \
			and _slice.worker_actor.global_position.distance_to( \
				_slice.get_marker_position(GameplayID.STATION_COFFEE)) >= 72.0
	, "Mochi visibly carrying coffee on the route to the service point"):
		_finish()
		return
	await _settle_frames(2)
	await _save_capture("07_mochi_carrying_coffee.png")
	if _spatial_mode:
		if not await _wait_until(func() -> bool:
			return _slice.worker_slice.state == SliceWorker.State.WALKING_TO_SERVE and \
				_slice.worker_actor.global_position.x < 190.0 and \
				_slice.worker_actor.global_position.y > 550.0
		, "Mochi taking the authored side exit"):
			_finish()
			return
		await _settle_frames(2)
		await _save_capture("07a_counter_side_exit.png")
		if not await _wait_until(func() -> bool:
			return _slice.worker_slice.state == SliceWorker.State.WALKING_TO_SERVE and \
				_slice.worker_actor.global_position.distance_to(_slice.get_marker_position(GameplayID.COUNTER_SERVE)) < 12.0
		, "Mochi reaching the front-floor ServePoint"):
			_finish()
			return
		await _settle_frames(1)
		await _save_capture("07c_serve_lane.png")
	if not await _wait_until(func() -> bool:
		return _slice.worker_slice != null and _slice.worker_slice.state == SliceWorker.State.READY_TO_SERVE
	, "Mochi reaches the service point"):
		_finish()
		return
	if _readability_mode or _spatial_mode:
		await _settle_frames(2)
		await _save_capture("07b_ready_serve_target.png")

	var reward_seen: Array[bool] = [false]
	var reward_callback: Callable = func(event_name: StringName) -> void:
		if event_name == &"reward_granted":
			reward_seen[0] = true
	_slice.lifecycle_event.connect(reward_callback)
	if not _slice.request_serve():
		_failures.append("Existing manual prototype rejected serve in the ready-to-serve state.")
		_finish()
		return
	if not await _wait_until(func() -> bool:
		return _slice.worker_slice != null and _slice.worker_slice.state == SliceWorker.State.SERVING
	, "serving"):
		_slice.lifecycle_event.disconnect(reward_callback)
		_finish()
		return
	await _settle_frames(1)
	await _save_capture("08_serving_customer.png")

	if not await _wait_until(func() -> bool: return reward_seen[0], "one reward granted"):
		_slice.lifecycle_event.disconnect(reward_callback)
		_finish()
		return
	_slice.lifecycle_event.disconnect(reward_callback)
	await _settle_frames(1)
	await _save_capture("09_reward_feedback.png")

	if not await _wait_until(func() -> bool:
		return _slice.customer_slice != null and _slice.customer_slice.state == SliceCustomer.State.LEAVING \
			and _slice.customer != null \
			and _slice.customer.global_position.distance_to(_slice.customer_entry_waypoint.global_position) < 110.0
	, "customer crossing the entrance"):
		_finish()
		return
	await _settle_frames(2)
	await _save_capture("10_customer_leaving.png")

	if not await _wait_until(func() -> bool:
		return _slice.completed_cycles >= 1 and _slice.customer == null \
			and _slice.worker_slice != null and _slice.worker_slice.state == SliceWorker.State.IDLE \
			and _slice.door_controller != null \
			and _slice.door_controller.state == PrototypeDoorController.State.CLOSED
	, "loop reset: idle worker, no customer, closed door"):
		_finish()
		return
	await _settle_frames(2)
	await _save_capture("11_loop_reset_idle.png")
	if _spatial_mode:
		_finish()
		return

	# Existing debug-only table/depth test nodes in the real scene are used here.
	# They are enabled one pair at a time; no z-index or gameplay transforms change.
	await _capture_table_depth_pair()
	await _capture_counter_occlusion()
	if not _failures.is_empty():
		_finish()
		return

	_debug.master_debug_active = false
	_camera.reset_to_default()
	_worker.visible = true
	_worker.select_test_position(MochiScaleTest.TestPosition.WORKER_IDLE)
	await _set_viewport_size(BASELINE_SIZE)
	_camera.set_zoom_target(_camera.effective_min_zoom)
	await _wait_for_camera_target()
	await _save_capture("15_camera_effective_min.png")

	_camera.reset_to_default()
	await _settle_frames(2)
	await _save_capture("16_camera_default.png")

	_camera.set_zoom_target(_camera.max_zoom)
	await _wait_for_camera_target()
	await _save_capture("17_camera_max_zoom.png")

	_camera.reset_to_default()
	_home.toggle_dev_visual_master()
	await _settle_frames(2)
	await _save_capture("18_visual_master.png")
	_home.toggle_dev_visual_master()
	await _settle_frames(2)

	await _capture_aspect_profile("20_aspect_9x16.png", BASELINE_SIZE)
	await _capture_aspect_profile("21_aspect_tall_phone.png", TALL_PHONE_SIZE)
	await _capture_aspect_profile("22_aspect_3x4.png", TABLET_SIZE)

	_finish()


func _capture_table_depth_pair() -> void:
	_debug.master_debug_active = false
	_camera.reset_to_default()
	var depth_layer: Node = _home.get_node("World/DepthSortedLayer")
	var mochi: CanvasItem = depth_layer.get_node("MochiScaleTestDEV") as CanvasItem
	var cat_behind: CanvasItem = depth_layer.get_node("CharacterBehindTable") as CanvasItem
	var cat_front: CanvasItem = depth_layer.get_node("CharacterInFrontOfTable") as CanvasItem
	var table_1: CanvasItem = depth_layer.get_node("Table1") as CanvasItem
	var chair_1: CanvasItem = depth_layer.get_node("ChairTable1_Left") as CanvasItem
	var table_2: CanvasItem = depth_layer.get_node("Table2") as CanvasItem
	var chair_2_left: CanvasItem = depth_layer.get_node("ChairTable2_Left") as CanvasItem
	var chair_2_right: CanvasItem = depth_layer.get_node("ChairTable2_Right") as CanvasItem
	mochi.visible = false
	table_1.visible = true
	chair_1.visible = true
	table_2.visible = false
	chair_2_left.visible = false
	chair_2_right.visible = false
	cat_front.visible = false
	cat_behind.visible = true
	await _settle_frames(2)
	await _save_capture("12_depth_table_behind.png")
	cat_behind.visible = false
	cat_front.visible = true
	await _settle_frames(2)
	await _save_capture("13_depth_table_front.png")
	cat_front.visible = false
	table_1.visible = false
	chair_1.visible = false
	mochi.visible = true


func _capture_counter_occlusion() -> void:
	_debug.master_debug_active = true
	var depth_layer: Node = _home.get_node("World/DepthSortedLayer")
	for helper_name in ["CharacterBehindTable", "CharacterInFrontOfTable", "Table1",
		"ChairTable1_Left", "Table2", "ChairTable2_Left", "ChairTable2_Right"]:
		var helper: CanvasItem = depth_layer.get_node(helper_name) as CanvasItem
		if helper != null:
			helper.visible = false
	var foreground_test_plants: CanvasItem = _home.get_node_or_null("World/ForegroundOccluderLayer/ForegroundPlants") as CanvasItem
	if foreground_test_plants != null:
		foreground_test_plants.visible = false
	if _debug.show_markers:
		_debug.toggle_markers()
	if _debug.show_bounds:
		_debug.toggle_bounds()
	if _debug.show_safe_areas:
		_debug.toggle_safe_areas()
	_worker.visible = true
	_worker.select_test_position(MochiScaleTest.TestPosition.COFFEE_ACTION)
	await _settle_frames(2)
	await _save_capture("14_counter_occlusion_test.png")
	_worker.select_test_position(MochiScaleTest.TestPosition.WORKER_IDLE)
	_debug.master_debug_active = false


func _capture_aspect_profile(filename: String, viewport_size: Vector2i) -> void:
	_debug.master_debug_active = false
	_home.dev_visual_master_node.visible = false
	_home.dev_reference_node.visible = false
	_home._set_modular_visuals_visible(true)
	_worker.select_test_position(MochiScaleTest.TestPosition.WORKER_IDLE)
	await _set_viewport_size(viewport_size)
	_camera.reset_to_default()
	await _wait_for_camera_target()
	await _save_capture(filename)


func _set_viewport_size(viewport_size: Vector2i) -> void:
	_viewport.size = viewport_size
	await _settle_frames(2)
	_camera.reset_to_default()
	await _wait_for_camera_target()


func _wait_for_camera_target() -> void:
	for _frame in range(240):
		if is_equal_approx(_camera.current_zoom, _camera.target_zoom):
			break
		await process_frame
	await _settle_frames(2)


func _wait_until(predicate: Callable, description: String) -> bool:
	for _frame in range(STATE_TIMEOUT_FRAMES):
		if predicate.call():
			return true
		await process_frame
	_failures.append("Timed out waiting for %s." % description)
	return false


func _settle_frames(count: int) -> void:
	for _frame in range(count):
		await process_frame
		await RenderingServer.frame_post_draw


func _save_capture(filename: String) -> bool:
	if _spatial_mode and filename not in [
		"01_home_default_debug_off.png", "02_worker_to_coffee.png", "03_customer_entering.png",
		"04_customer_seated_order.png", "04b_debug_route_overview.png", "05_mochi_coffee_action.png",
		"07_mochi_carrying_coffee.png", "07a_counter_side_exit.png", "07b_ready_serve_target.png",
		"07c_serve_lane.png", "09_reward_feedback.png", "10_customer_leaving.png", "11_loop_reset_idle.png"
	]:
		return true
	await process_frame
	await RenderingServer.frame_post_draw
	var image: Image = _viewport.get_texture().get_image()
	if image == null or image.is_empty() or image.get_size() != _viewport.size:
		_failures.append("%s: viewport returned no image or an unexpected size." % filename)
		return false
	if not _has_visible_image_variation(image):
		_failures.append("%s: rendered viewport appears blank or single-color." % filename)
		return false
	var absolute_path: String = ProjectSettings.globalize_path("%s/%s" % [_output_dir, filename])
	var save_error: Error = image.save_png(absolute_path)
	if save_error != OK:
		_failures.append("%s: save_png returned %s." % [filename, error_string(save_error)])
		return false
	print("[CAPTURE PASS] %s | %dx%d | zoom=%.4f | debug=%s | mode=%s" % [
		filename, image.get_width(), image.get_height(), _camera.current_zoom,
		"ON" if _debug.master_debug_active else "OFF",
		"MANUAL" if _slice.is_manual_mode() else "AUTO LOOP"
	])
	return true


func _has_visible_image_variation(image: Image) -> bool:
	var distinct_samples: Dictionary = {}
	var x_step: int = maxi(1, image.get_width() / 24)
	var y_step: int = maxi(1, image.get_height() / 32)
	for y in range(0, image.get_height(), y_step):
		for x in range(0, image.get_width(), x_step):
			var color: Color = image.get_pixel(x, y)
			var sample_key: Vector3i = Vector3i(roundi(color.r * 15.0), roundi(color.g * 15.0), roundi(color.b * 15.0))
			distinct_samples[sample_key] = true
			if distinct_samples.size() >= 8:
				return true
	return false


func _finish() -> void:
	if _failures.is_empty():
		var pack_name: String = "SPATIAL V1" if _spatial_mode else "READABILITY V1" if _readability_mode else "FUNCTIONAL PROTOTYPE"
		print("--- %s VISUAL CAPTURE PACK COMPLETE ---" % pack_name)
		quit(0)
		return
	for failure in _failures:
		printerr("[CAPTURE FAIL] " + failure)
	printerr("--- FUNCTIONAL PROTOTYPE VISUAL CAPTURE PACK INCOMPLETE ---")
	quit(1)
