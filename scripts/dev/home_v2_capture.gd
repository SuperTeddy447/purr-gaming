extends SceneTree
## Rendered evidence of the candidate V2 skin using the real playable Home scene.

const SCENE := "res://scenes/dev/home_v2_environment_preview.tscn"
const OUTPUT := "res://artifacts/prototype_review/home_v2_batch_01"

var _viewport: SubViewport
var _home: HomeScene
var _failed: bool = false


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	if OS.has_feature("headless"):
		push_error("V2 capture needs a rendered Godot viewport; do not use --headless.")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	_viewport = SubViewport.new()
	_viewport.size = Vector2i(941, 1672)
	_viewport.disable_3d = true
	_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(_viewport)
	var scene: PackedScene = load(SCENE) as PackedScene
	if scene == null:
		push_error("Could not load V2 Home preview scene.")
		quit(1)
		return
	_home = scene.instantiate() as HomeScene
	var slice: VerticalSliceController = _home.get_node("VerticalSliceController") as VerticalSliceController
	slice.start_on_ready = false
	slice.auto_repeat_slice = false
	_viewport.add_child(_home)
	await _frames(6)
	var debug: DebugOverlay = _home.get_node("UI/DebugOverlay") as DebugOverlay
	debug.master_debug_active = false
	await _frames(3)
	_save("01_home_v2_default.png")
	debug.master_debug_active = true
	await _frames(3)
	_save("02_home_v2_debug.png")
	debug.master_debug_active = false
	_home.toggle_dev_visual_master()
	await _frames(3)
	_save("03_v2_style_reference.png")
	_home.toggle_dev_visual_master()
	var cat_life: Node2D = _home.get_node("V2CatLife") as Node2D
	cat_life.guides_visible = true
	cat_life.queue_redraw()
	await _frames(2)
	_save("06_cat_life_anchor_guides.png")
	cat_life.guides_visible = false
	cat_life.queue_redraw()
	var ambient: LivingCafeAmbientController = _home.get_node("LivingCafeAmbientController") as LivingCafeAmbientController
	var explorer: LivingCafeAmbientController.Agent = ambient.agent_for(&"PrototypeCatB")
	for index in 900:
		await process_frame
		if explorer != null and explorer.work_priority:
			await _frames(2)
			_save("07_silent_story_reaction.png")
			break
	slice.start_slice()
	var reached: bool = false
	for index in 600:
		await process_frame
		if slice.customer_slice != null and slice.customer_slice.state == SliceCustomer.State.WAITING_FOR_SERVICE:
			reached = true
			break
	if reached:
		_save("04_customer_order_v2.png")
		if slice.request_coffee_preparation():
			for index in 600:
				await process_frame
				if slice.worker_slice.state == SliceWorker.State.PREPARING_COFFEE:
					_save("05_counter_occlusion_v2.png")
					break
	else:
		push_error("V2 capture did not reach customer order state.")
		_failed = true
	quit(1 if _failed else 0)


func _frames(count: int) -> void:
	for index in count:
		await process_frame


func _save(filename: String) -> void:
	var path: String = ProjectSettings.globalize_path(OUTPUT.path_join(filename))
	var image: Image = _viewport.get_texture().get_image()
	var result: Error = image.save_png(path)
	if result != OK:
		push_error("Could not save V2 screenshot: %s" % path)
		_failed = true
	else:
		print("V2 capture: %s" % path)
