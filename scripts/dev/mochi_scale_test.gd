class_name MochiScaleTest
extends Node2D
## Canonical Sprite2D fallback and dev scale/depth controls; clips live in MochiVisualPresenter.

enum ScaleMode { SMALL, TARGET, LARGE }
enum TestPosition { WORKER_IDLE, COFFEE_ACTION, SERVE_POINT, OPEN_FLOOR }

const TARGET_HEIGHTS_PX: Array[float] = [100.0, 132.0, 150.0]
const POSITION_IDS: Array[StringName] = [
	GameplayID.WORKER_IDLE, GameplayID.STATION_COFFEE,
	GameplayID.COUNTER_SERVE, GameplayID.AMBIENT_MAIN_A
]
const POSITION_LABELS: Array[String] = ["WorkerIdle", "CoffeeAction", "ServePoint", "Open Floor"]

@export var sprite: Sprite2D
@export var marker_root: Node
@export var camera_controller: CameraController
@export var debug_overlay: DebugOverlay
@export var visual_presenter: MochiVisualPresenter

var scale_mode: ScaleMode = ScaleMode.TARGET
var test_position: TestPosition = TestPosition.OPEN_FLOOR
var _alpha_bounds: Rect2i
var _stretch_scale_y: float = 1.0


func _ready() -> void:
	add_to_group(&"dev_scale_test")
	if sprite == null or sprite.texture == null or marker_root == null or camera_controller == null or visual_presenter == null:
		push_error("Mochi scale test is missing its sprite, markers, or camera reference.")
		return
	var scale_reference: Texture2D = visual_presenter.canonical_reference_texture if visual_presenter.canonical_reference_texture != null else sprite.texture
	var source_image: Image = scale_reference.get_image()
	_alpha_bounds = source_image.get_used_rect()
	if _alpha_bounds.size.y <= 0:
		push_error("Canonical Mochi texture has no visible alpha bounds.")
		return
	# LayeredIdleVisual owns texture registration; this actor remains anchored at the feet.
	get_viewport().size_changed.connect(_refresh_scale)
	# Calibrate before the first draw; the deferred pass reconciles the camera's
	# final aspect-specific zoom once the sibling CameraRig has finished _ready().
	_refresh_scale()
	call_deferred("_initialize_test")


func _initialize_test() -> void:
	select_test_position(test_position)
	_refresh_scale()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	# Scale selection is the core of this visual test, so it stays available in
	# the clean normal view as well as Debug View.
	if event.keycode == KEY_1 or event.keycode == KEY_2 or event.keycode == KEY_3:
		match event.keycode:
			KEY_1:
				select_scale_mode(ScaleMode.SMALL)
			KEY_2:
				select_scale_mode(ScaleMode.TARGET)
			KEY_3:
				select_scale_mode(ScaleMode.LARGE)
		get_viewport().set_input_as_handled()
		return

	# Location and camera inspection shortcuts remain debug-only.
	if debug_overlay == null or not debug_overlay.master_debug_active:
		return
	match event.keycode:
		KEY_F2:
			select_test_position(TestPosition.WORKER_IDLE)
		KEY_F3:
			select_test_position(TestPosition.COFFEE_ACTION)
		KEY_F4:
			select_test_position(TestPosition.SERVE_POINT)
		KEY_F5:
			select_test_position(TestPosition.OPEN_FLOOR)
		KEY_Z:
			camera_controller.reset_to_default()
		KEY_X:
			camera_controller.set_zoom_target(camera_controller.effective_min_zoom)
		KEY_C:
			camera_controller.set_zoom_target(1.2)
		KEY_V:
			camera_controller.set_zoom_target(camera_controller.max_zoom)
		_:
			return
	get_viewport().set_input_as_handled()


func select_scale_mode(mode: ScaleMode) -> void:
	scale_mode = mode
	_refresh_scale()


func select_test_position(position_mode: TestPosition) -> void:
	test_position = position_mode
	var marker: GameplayMarker = _find_marker(marker_root, POSITION_IDS[test_position])
	if marker == null:
		push_error("Missing Mochi test position marker ID: %s" % String(POSITION_IDS[test_position]))
		return
	global_position = marker.global_position


func set_facing_right(facing_right: bool) -> void:
	if sprite != null:
		sprite.flip_h = not facing_right
	if visual_presenter != null:
		visual_presenter.set_direction(&"RIGHT" if facing_right else &"LEFT")


func _refresh_scale() -> void:
	if sprite == null or camera_controller == null or _alpha_bounds.size.y <= 0:
		return
	_stretch_scale_y = absf(get_viewport().get_stretch_transform().y.y)
	if _stretch_scale_y <= 0.0:
		_stretch_scale_y = 1.0
	var baseline_zoom: float = maxf(camera_controller.default_zoom, camera_controller.effective_min_zoom)
	var visible_height_at_baseline: float = float(_alpha_bounds.size.y) * _stretch_scale_y * baseline_zoom
	var target_height: float = TARGET_HEIGHTS_PX[scale_mode]
	var uniform_scale: float = target_height / visible_height_at_baseline
	if visual_presenter != null:
		visual_presenter.set_character_scale(uniform_scale)
	else:
		sprite.scale = Vector2.ONE * uniform_scale


func rendered_height_px() -> float:
	if sprite == null or camera_controller == null:
		return 0.0
	return float(_alpha_bounds.size.y) * absf(sprite.scale.y) * _stretch_scale_y * camera_controller.current_zoom


func scale_mode_name() -> String:
	return ScaleMode.keys()[scale_mode]


func position_name() -> String:
	return POSITION_LABELS[test_position]


func debug_summary() -> String:
	return "Mochi DEV SCALE TEST: %s | %.0f px | Zoom %.2fx | %s\nKeys: 1/2/3 scale, F2-F5 position, Z/X/C/V camera" % [
		scale_mode_name(), rendered_height_px(), camera_controller.current_zoom, position_name()
	]


func _find_marker(node: Node, marker_id: StringName) -> GameplayMarker:
	if node is GameplayMarker and (node as GameplayMarker).marker_id == marker_id:
		return node as GameplayMarker
	for child in node.get_children():
		var found: GameplayMarker = _find_marker(child, marker_id)
		if found != null:
			return found
	return null
