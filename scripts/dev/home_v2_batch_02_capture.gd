extends SceneTree
## Rendered evidence for the V2 counter-floor correction and device-safe bounds.

const SCENE := "res://scenes/dev/home_v2_environment_preview.tscn"
const OUTPUT := "res://artifacts/prototype_review/home_v2_batch_02"

var _viewport: SubViewport
var _home: HomeScene
var _slice: VerticalSliceController
var _worker: MochiScaleTest
var _camera: CameraController
var _debug: DebugOverlay
var _registration: Node2D
var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if OS.has_feature("headless"):
		push_error("Batch 02 screenshots require a rendered Godot viewport.")
		quit(1)
		return
	var directory: String = ProjectSettings.globalize_path(OUTPUT)
	if DirAccess.make_dir_recursive_absolute(directory) != OK and not DirAccess.dir_exists_absolute(directory):
		push_error("Could not create capture directory: %s" % directory)
		quit(1)
		return
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(941, 1672)
	_viewport.disable_3d = true
	_viewport.transparent_bg = false
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_viewport)
	_home = (load(SCENE) as PackedScene).instantiate() as HomeScene
	_slice = _home.get_node("VerticalSliceController") as VerticalSliceController
	_worker = _home.get_node("World/DepthSortedLayer/MochiScaleTestDEV") as MochiScaleTest
	_camera = _home.get_node("CameraRig") as CameraController
	_debug = _home.get_node("UI/DebugOverlay") as DebugOverlay
	_registration = _home.get_node("World/FXLayer/V2CounterRegistrationDebug") as Node2D
	_slice.start_on_ready = false
	_slice.auto_repeat_slice = false
	_viewport.add_child(_home)
	await _frames(8)
	_debug.master_debug_active = false
	_camera.reset_to_default()
	_worker.select_scale_mode(MochiScaleTest.ScaleMode.LARGE)
	_worker.select_test_position(MochiScaleTest.TestPosition.WORKER_IDLE)
	await _frames(4)
	_save("01_worker_idle_clean.png")
	_worker.select_test_position(MochiScaleTest.TestPosition.COFFEE_ACTION)
	await _frames(3)
	_save("02_coffee_action_clean.png")
	_registration.force_visible = true
	_registration.queue_redraw()
	await _frames(3)
	_save("03_coffee_action_debug.png")
	_registration.force_visible = false
	_registration.queue_redraw()
	await _frames(2)
	_worker.select_test_position(MochiScaleTest.TestPosition.WORKER_IDLE)
	_slice.start_slice()
	if not await _until(func() -> bool: return _slice.active_order_id == &"order_coffee_basic_01", "active coffee order"):
		_finish()
		return
	if not _slice.request_coffee_preparation():
		push_error("Manual coffee request rejected during Batch 02 capture.")
		_failed = true
		_finish()
		return
	if not await _until(func() -> bool: return _slice.worker_slice.state == SliceWorker.State.PREPARING_COFFEE, "preparing coffee"):
		_finish()
		return
	await _frames(4)
	_save("04_prepare_clean.png")
	if not await _until(func() -> bool:
		return _slice.worker_slice.state == SliceWorker.State.WALKING_TO_SERVE \
			and _slice.worker_actor.global_position.x <= 190.0 \
			and _slice.worker_actor.global_position.y >= 530.0
	, "carry leaving counter"):
		_finish()
		return
	_save("05_carry_exit_clean.png")
	if not await _until(func() -> bool: return _slice.worker_slice.state == SliceWorker.State.READY_TO_SERVE, "ready to serve"):
		_finish()
		return
	if not _slice.request_serve():
		push_error("Manual serve request rejected during Batch 02 capture.")
		_failed = true
		_finish()
		return
	if not await _until(func() -> bool:
		return _slice.worker_slice.state == SliceWorker.State.RETURNING_TO_IDLE \
			and _slice.worker_actor.global_position.x >= 340.0 \
			and _slice.worker_actor.global_position.y <= 550.0
	, "return behind counter"):
		_finish()
		return
	_save("06_return_clean.png")
	if not await _until(func() -> bool: return _slice.worker_slice.state == SliceWorker.State.IDLE, "worker idle reset"):
		_finish()
		return
	await _frames(3)
	_save("07_return_idle_clean.png")
	await _capture_aspects()
	_finish()


func _capture_aspects() -> void:
	var profiles: Array[Dictionary] = [
		{"name": "08_aspect_9x16_min.png", "size": Vector2i(941, 1672)},
		{"name": "09_aspect_tall_phone_min.png", "size": Vector2i(941, 2039)},
		{"name": "10_aspect_3x4_min.png", "size": Vector2i(1254, 1672)},
		{"name": "11_aspect_desktop_min.png", "size": Vector2i(1280, 720)},
	]
	for profile in profiles:
		_viewport.size = profile["size"]
		await _frames(5)
		_camera.set_zoom_target(_camera.effective_min_zoom)
		await _frames(35)
		_save(profile["name"])
	# At an allowed tighter zoom, ask for the far-right/bottom pan extreme.
	_viewport.size = Vector2i(941, 2039)
	await _frames(4)
	_camera.set_zoom_target(_camera.max_zoom)
	await _frames(35)
	_camera.target_position = _camera.clamp_position(Vector2(9999.0, 9999.0), _camera.target_zoom)
	await _frames(35)
	_save("12_tall_phone_max_pan.png")
	_viewport.size = Vector2i(1254, 1672)
	await _frames(5)
	_camera.target_position = _camera.clamp_position(Vector2(-9999.0, -9999.0), _camera.target_zoom)
	await _frames(35)
	_save("13_aspect_3x4_max_pan.png")


func _until(predicate: Callable, description: String) -> bool:
	for frame in 1200:
		await process_frame
		if predicate.call():
			return true
	push_error("Timed out waiting for %s." % description)
	_failed = true
	return false


func _frames(count: int) -> void:
	for frame in count:
		await process_frame


func _save(filename: String) -> void:
	var path: String = ProjectSettings.globalize_path(OUTPUT.path_join(filename))
	var image: Image = _viewport.get_texture().get_image()
	if image.save_png(path) != OK:
		push_error("Could not save %s" % path)
		_failed = true
	else:
		print("Batch 02 viewport: %s" % path)


func _finish() -> void:
	quit(1 if _failed else 0)
