extends SceneTree
## Development-only canonical composition and True Slice capture pack.
## Every image is saved from the running Godot SubViewport; no image is composed externally.

const SCENE := "res://scenes/dev/home_v2_environment_preview.tscn"
const OUTPUT := "res://artifacts/prototype_review/home_v2_batch_03"
const CANONICAL_SIZE := Vector2i(941, 1672)
const TALL_PHONE_SIZE := Vector2i(941, 2039)
const WIDE_DEVICE_SIZE := Vector2i(1254, 1672)
const DESKTOP_SIZE := Vector2i(1280, 720)

var viewport: SubViewport
var home: HomeScene
var camera: CameraController
var slice: VerticalSliceController
var mochi: MochiScaleTest


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if OS.has_feature("headless"):
		_fail("Batch 03 requires a real rendered Godot viewport; headless captures are not accepted.")
		return
	var output_dir: String = ProjectSettings.globalize_path(OUTPUT)
	if DirAccess.make_dir_recursive_absolute(output_dir) != OK and not DirAccess.dir_exists_absolute(output_dir):
		_fail("Could not create capture directory: %s" % output_dir)
		return
	viewport = SubViewport.new()
	viewport.name = "HomeV2Batch03CaptureViewport"
	viewport.size = CANONICAL_SIZE
	viewport.disable_3d = true
	viewport.transparent_bg = false
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	home = (load(SCENE) as PackedScene).instantiate() as HomeScene
	slice = home.get_node("VerticalSliceController") as VerticalSliceController
	slice.start_on_ready = false
	slice.auto_repeat_slice = false
	slice.customer_move_speed = 10000.0
	slice.worker_move_speed = 10000.0
	slice.interaction_mode = VerticalSliceController.InteractionMode.MANUAL
	slice.timing_config = slice.timing_config.duplicate_for_testing()
	slice.timing_config.set_preset("FAST")
	slice.timing_config.customer_arrival_pause = 0.04
	slice.timing_config.customer_order_delay = 0.08
	slice.timing_config.coffee_preparation_duration = 1.0
	slice.timing_config.serve_duration = 0.8
	slice.timing_config.served_reaction_duration = 0.04
	slice.timing_config.customer_exit_delay = 0.04
	slice.timing_config.door_transition_duration = 0.08
	slice.timing_config.door_hold_open_duration = 0.04
	(home.get_node("PrototypeDoorController") as PrototypeDoorController).timing_config = slice.timing_config
	viewport.add_child(home)
	await _frames(12)
	camera = home.get_node("CameraRig") as CameraController
	mochi = home.get_node("World/DepthSortedLayer/MochiScaleTestDEV") as MochiScaleTest
	mochi.select_scale_mode(MochiScaleTest.ScaleMode.LARGE)
	mochi.select_test_position(MochiScaleTest.TestPosition.WORKER_IDLE)
	_set_debug(false)
	_set_guides(false)
	_set_camera(camera.room_config.default_camera_position, maxf(camera.default_zoom, camera.effective_min_zoom))
	await _frames(4)
	_save("03_iteration_3.png")
	_save("10_final_runtime_clean.png")
	_set_guides(true)
	await _frames(2)
	_save("11_final_runtime_guides.png")
	_set_guides(false)

	await _capture_zone("12_counter_zone.png", Vector2(465.0, 520.0))
	await _capture_zone("13_left_table_zone.png", Vector2(250.0, 860.0))
	await _capture_zone("14_lower_center_zone.png", Vector2(535.0, 1190.0))
	await _capture_zone("15_right_lounge_zone.png", Vector2(820.0, 1150.0))
	await _capture_zone("16_entrance_zone.png", Vector2(470.0, 1510.0))

	await _capture_device("20_9x16.png", CANONICAL_SIZE)
	await _capture_device("21_tall_phone.png", TALL_PHONE_SIZE)
	await _capture_device("22_wide_device.png", WIDE_DEVICE_SIZE)
	await _capture_device("23_desktop.png", DESKTOP_SIZE)
	viewport.size = CANONICAL_SIZE
	await _frames(3)
	_set_debug(false)
	_set_camera(camera.room_config.default_camera_position, maxf(camera.default_zoom, camera.effective_min_zoom))
	await _frames(3)
	if not await _capture_true_slice():
		return
	print("--- HOME V2 BATCH 03 REAL-VIEWPORT CAPTURE PACK COMPLETE ---")
	quit(0)


func _capture_true_slice() -> bool:
	slice.start_slice()
	if not await _until(func() -> bool: return slice.active_order_id == &"order_coffee_basic_01"):
		_fail("Timed out waiting for the existing Vertical Slice order.")
		return false
	if not slice.request_coffee_preparation():
		_fail("Existing Vertical Slice rejected the manual coffee request.")
		return false
	if not await _until(func() -> bool: return slice.worker_slice.state == SliceWorker.State.PREPARING_COFFEE):
		_fail("Timed out waiting for the existing worker's coffee preparation state.")
		return false
	await _frames(6)
	_save("24_coffee_action.png")
	if not await _until(func() -> bool: return slice.worker_slice.state == SliceWorker.State.READY_TO_SERVE):
		_fail("Timed out waiting for the existing worker's serve-ready state.")
		return false
	if not slice.request_serve():
		_fail("Existing Vertical Slice rejected the manual serve request.")
		return false
	await _frames(2)
	_save("25_serve.png")
	if not await _until(func() -> bool: return slice.customer == null and slice.completed_cycles == 1):
		_fail("Timed out waiting for the existing Vertical Slice to return and complete.")
		return false
	if slice.worker_slice.state != SliceWorker.State.IDLE:
		_fail("Worker did not return to idle after the captured loop.")
		return false
	if slice.door_controller.state != PrototypeDoorController.State.CLOSED:
		_fail("Entrance door did not return to closed after the captured loop.")
		return false
	if slice.active_order_id != &"" or slice.wallet.coins <= 0:
		_fail("Captured loop left stale order state or did not grant its reward.")
		return false
	await _frames(3)
	_save("26_return.png")
	return true


func _capture_zone(filename: String, center: Vector2) -> void:
	_set_debug(false)
	_set_camera(center, maxf(camera.max_zoom, camera.effective_min_zoom))
	await _frames(3)
	_save(filename)


func _capture_device(filename: String, size: Vector2i) -> void:
	viewport.size = size
	await _frames(3)
	camera._on_viewport_size_changed()
	camera.reset_to_default()
	await _frames(4)
	_save(filename)


func _set_camera(position: Vector2, zoom: float) -> void:
	var safe_zoom := clampf(zoom, camera.effective_min_zoom, maxf(camera.max_zoom, camera.effective_min_zoom))
	camera.current_zoom = safe_zoom
	camera.target_zoom = safe_zoom
	camera.global_position = camera.clamp_position(position, safe_zoom)
	camera.target_position = camera.global_position
	camera.camera_node.zoom = Vector2.ONE * safe_zoom
	camera.camera_node.force_update_scroll()


func _set_debug(active: bool) -> void:
	var overlay := home.get_node("UI/DebugOverlay") as DebugOverlay
	overlay.master_debug_active = active
	var worker := home.get_node("World/DepthSortedLayer/MochiScaleTestDEV/SliceWorker") as SliceWorker
	worker.set_debug_action_label_visible(active)


func _set_guides(active: bool) -> void:
	var guides := home.get_node("World/FXLayer/V2CompositionGuides") as Node2D
	guides.set("force_visible", active)
	guides.queue_redraw()


func _until(predicate: Callable, max_frames: int = 1200) -> bool:
	for _frame in max_frames:
		await process_frame
		if predicate.call():
			return true
	return false


func _frames(count: int) -> void:
	for _frame in count:
		await process_frame


func _save(filename: String) -> void:
	var output_path := ProjectSettings.globalize_path(OUTPUT.path_join(filename))
	var image := viewport.get_texture().get_image()
	var result := image.save_png(output_path)
	if result != OK:
		_fail("Could not save real Godot viewport image: %s" % output_path)
	else:
		print("Batch 03 real viewport %dx%d: %s" % [image.get_width(), image.get_height(), output_path])


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
