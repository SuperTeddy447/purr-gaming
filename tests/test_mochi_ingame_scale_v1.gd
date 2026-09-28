extends SceneTree
## Verifies canonical Mochi scale, semantic test locations, zoom response, and depth layers.

const HOME_SCENE: String = "res://scenes/home/home_scene.tscn"
const CANONICAL_TEXTURE: String = "res://docs/references/mochi/MOCHI_HOUSE_STYLE_LOCK_V1_1_FINAL_TRANSPARENT.png"
const TEST_HEIGHTS_PX: Array[float] = [100.0, 132.0, 150.0]
const SCALE_MODES: Array[MochiScaleTest.ScaleMode] = [
	MochiScaleTest.ScaleMode.SMALL, MochiScaleTest.ScaleMode.TARGET, MochiScaleTest.ScaleMode.LARGE
]
const TEST_POSITIONS: Array[MochiScaleTest.TestPosition] = [
	MochiScaleTest.TestPosition.WORKER_IDLE, MochiScaleTest.TestPosition.COFFEE_ACTION,
	MochiScaleTest.TestPosition.SERVE_POINT, MochiScaleTest.TestPosition.OPEN_FLOOR
]
const POSITION_IDS: Array[StringName] = [
	GameplayID.WORKER_IDLE, GameplayID.STATION_COFFEE,
	GameplayID.COUNTER_SERVE, GameplayID.AMBIENT_MAIN_A
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(540, 960)
	var home: HomeScene = (load(HOME_SCENE) as PackedScene).instantiate() as HomeScene
	root.add_child(home)
	await process_frame
	var mochi: MochiScaleTest = home.get_node("World/DepthSortedLayer/MochiScaleTestDEV") as MochiScaleTest
	var camera: CameraController = home.get_node("CameraRig") as CameraController
	var sprite: Sprite2D = mochi.sprite
	if mochi.scale_mode != MochiScaleTest.ScaleMode.LARGE or \
		absf(mochi.rendered_height_px() - 150.0) > 1.0:
		_fail("The modular Home mock must begin at the canonical 150 px Mochi scale")
		return
	if sprite.texture.resource_path != CANONICAL_TEXTURE:
		_fail("Mochi must use the exact transparent canonical reference PNG")
		return
	if mochi.get_parent() != home.get_node("World/DepthSortedLayer") or sprite.texture.get_image().get_used_rect().size.y != 476:
		_fail("Mochi test must use the alpha-bounded foot pivot under DepthSortedLayer")
		return

	for debug_active in [false, true]:
		home.debug_overlay.master_debug_active = debug_active
		for index in range(SCALE_MODES.size()):
			_send_key(mochi, [KEY_1, KEY_2, KEY_3][index])
			if mochi.scale_mode != SCALE_MODES[index]:
				_fail("Scale hotkey %d did not select %s with Debug %s" % [
					index + 1, MochiScaleTest.ScaleMode.keys()[SCALE_MODES[index]],
					"ON" if debug_active else "OFF"
				])
				return
		print("[PASS] 1/2/3 scale hotkeys work with Debug %s." % ("ON" if debug_active else "OFF"))

	home.debug_overlay.master_debug_active = true
	for index in range(TEST_POSITIONS.size()):
		_send_key(mochi, [KEY_F2, KEY_F3, KEY_F4, KEY_F5][index])
		if mochi.test_position != TEST_POSITIONS[index]:
			_fail("Position shortcut F%d no longer selects %s" % [
				index + 2, MochiScaleTest.TestPosition.keys()[TEST_POSITIONS[index]]
			])
			return
	print("[PASS] F2-F5 position shortcuts remain intact with Debug ON.")

	var baseline_zoom: float = maxf(camera.default_zoom, camera.effective_min_zoom)
	var camera_keys: Array[int] = [KEY_Z, KEY_X, KEY_C, KEY_V]
	var camera_key_names: Array[String] = ["Z", "X", "C", "V"]
	var camera_zoom_targets: Array[float] = [
		baseline_zoom, camera.effective_min_zoom,
		clampf(1.2, camera.effective_min_zoom, maxf(camera.max_zoom, camera.effective_min_zoom)),
		maxf(camera.max_zoom, camera.effective_min_zoom)
	]
	for index in range(camera_keys.size()):
		_send_key(mochi, camera_keys[index])
		if absf(camera.target_zoom - camera_zoom_targets[index]) > 0.001:
			_fail("Camera shortcut %s no longer selects zoom %.2fx" % [
				camera_key_names[index], camera_zoom_targets[index]
			])
			return
	print("[PASS] Z/X/C/V camera shortcuts remain intact with Debug ON.")

	mochi.select_test_position(MochiScaleTest.TestPosition.OPEN_FLOOR)
	for index in range(TEST_HEIGHTS_PX.size()):
		mochi.select_scale_mode(SCALE_MODES[index])
		if absf(mochi.rendered_height_px() - TEST_HEIGHTS_PX[index]) > 1.0:
			_fail("Scale mode %s renders %.2fpx, expected %.0fpx" % [
				mochi.scale_mode_name(), mochi.rendered_height_px(), TEST_HEIGHTS_PX[index]
			])
			return
		print("[PASS] %s %.0fpx visible height, Sprite2D scale %.4f." % [
			mochi.scale_mode_name(), mochi.rendered_height_px(), sprite.scale.x
		])

	mochi.select_scale_mode(MochiScaleTest.ScaleMode.TARGET)
	for index in range(TEST_POSITIONS.size()):
		mochi.select_test_position(TEST_POSITIONS[index])
		var marker: GameplayMarker = _find_marker(home.get_node("GameplayNodes"), POSITION_IDS[index])
		if marker == null or mochi.global_position.distance_to(marker.global_position) > 0.01:
			_fail("Test position %s did not resolve by semantic marker ID" % String(POSITION_IDS[index]))
			return
	print("[PASS] WorkerIdle, CoffeeAction, ServePoint, and open-floor marker selection use semantic IDs.")

	var depth_layer: Node2D = home.get_node("World/DepthSortedLayer") as Node2D
	var foreground_layer: Node2D = home.get_node("World/ForegroundOccluderLayer") as Node2D
	var counter_front: Node2D = home.get_node("World/ForegroundOccluderLayer/CounterFrontOccluder") as Node2D
	mochi.select_test_position(MochiScaleTest.TestPosition.COFFEE_ACTION)
	home.debug_overlay.master_debug_active = true
	await process_frame
	if not depth_layer.y_sort_enabled or mochi.z_index != 0 or \
		depth_layer.z_index >= foreground_layer.z_index or not counter_front.visible:
		_fail("CoffeeAction test does not pass behind the existing counter foreground layer")
		return
	print("[PASS] CoffeeAction uses normal Y-sort and DepthSortedLayer < CounterFrontOccluder; no Mochi z override.")

	# Device-safe CameraRig clamps a requested 1.2x when the effective minimum
	# exceeds it (for this viewport, 1.2195x). Test the request AND its clamp.
	var requested_mid_zoom: float = 1.2
	var effective_max: float = maxf(camera.max_zoom, camera.effective_min_zoom)
	var zoom_targets: Array[float] = [baseline_zoom, camera.effective_min_zoom,
		clampf(requested_mid_zoom, camera.effective_min_zoom, effective_max), effective_max]
	var zoom_names: Array[String] = ["default", "effective minimum", "requested 1.2x clamp", "maximum"]
	for index in range(zoom_targets.size()):
		if index == 0:
			camera.reset_to_default()
		else:
			camera.set_zoom_target(requested_mid_zoom if index == 2 else zoom_targets[index])
		if absf(camera.target_zoom - zoom_targets[index]) > 0.001:
			_fail("Camera target did not clamp the %s zoom request" % zoom_names[index])
			return
		if not await _wait_for_zoom(camera, zoom_targets[index], 240):
			_fail("Camera did not reach the %s test zoom" % zoom_names[index])
			return
		var expected_height: float = TEST_HEIGHTS_PX[MochiScaleTest.ScaleMode.TARGET] * camera.current_zoom / baseline_zoom
		if absf(mochi.rendered_height_px() - expected_height) > 1.0:
			_fail("Mochi height at %s zoom was %.2fpx, expected %.2fpx" % [
				zoom_names[index], mochi.rendered_height_px(), expected_height
			])
			return
		print("[PASS] %s zoom %.2fx, Mochi visible height %.1fpx." % [
			zoom_names[index], camera.current_zoom, mochi.rendered_height_px()
		])

	home.queue_free()
	await process_frame
	print("--- ALL MOCHI IN-GAME SCALE TESTS PASSED ---")
	quit(0)


func _wait_for_zoom(camera: CameraController, target: float, max_frames: int) -> bool:
	for frame in range(max_frames):
		await process_frame
		if absf(camera.current_zoom - target) < 0.001:
			return true
	return false


func _find_marker(node: Node, marker_id: StringName) -> GameplayMarker:
	if node is GameplayMarker and (node as GameplayMarker).marker_id == marker_id:
		return node as GameplayMarker
	for child in node.get_children():
		var found: GameplayMarker = _find_marker(child, marker_id)
		if found != null:
			return found
	return null


func _send_key(mochi: MochiScaleTest, keycode: int) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = keycode
	event.pressed = true
	mochi._unhandled_input(event)


func _fail(message: String) -> void:
	printerr("[FAIL] " + message)
	quit(1)
