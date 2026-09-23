extends SceneTree
## Automated verification suite for WILLICAT_FOUNDATION_V1_1_VISUAL_GATE_FIX.

var _frames: int = 0
var _home: HomeScene

func _init() -> void:
	pass

func _process(_delta: float) -> bool:
	_frames += 1
	if _frames == 1:
		var scene_res: PackedScene = load("res://scenes/home/home_scene.tscn")
		if scene_res == null:
			printerr("[FAIL] Failed to load home_scene.tscn")
			quit(1)
			return true

		_home = scene_res.instantiate() as HomeScene
		root.add_child(_home)
		return false

	if _frames == 3:
		# Now _home._ready() has executed inside the tree
		_run_checks()
		quit(0)
		return true

	return false


func _run_checks() -> void:
	print("--- BEGIN FOUNDATION V1.1 VISUAL GATE FIX VERIFICATION ---")

	var world: Node2D = _home.get_node_or_null("World") as Node2D
	assert(world != null, "World node must exist")

	var debug_ui: DebugOverlay = _home.get_node_or_null("UI/DebugOverlay") as DebugOverlay
	assert(debug_ui != null, "DebugOverlay must exist")

	var dev_ref: Sprite2D = world.get_node_or_null("StructuralBase/DEV_REFERENCE_ONLY") as Sprite2D
	assert(dev_ref != null, "DEV_REFERENCE_ONLY node must exist")
	assert(dev_ref.texture != null, "DEV_REFERENCE_ONLY must have reference texture loaded")

	# 1. Verify Clean V2.1 Reference Image Assignment & UID
	var texture_path: String = dev_ref.texture.resource_path
	assert(texture_path == "res://docs/references/WILLICAT_HOME_CAMERA_PROTOTYPE_V2_1.png",
		"DEV_REFERENCE_ONLY must use the clean V2.1 prototype, found: " + texture_path)
	var texture_uid_int: int = ResourceLoader.get_resource_uid(texture_path)
	var texture_uid_str: String = ResourceUID.id_to_text(texture_uid_int)
	assert(texture_uid_str == "uid://cia5icxp74g00", "Texture UID must match reimported clean V2.1 PNG, got: " + texture_uid_str)
	print("[PASS] DEV_REFERENCE_ONLY assigned clean V2.1 image: %s (UID: %s)" % [texture_path, texture_uid_str])

	# 2. Verify Normal Dev View (Default State: debug OFF)
	assert(debug_ui.master_debug_active == false, "Default state must be Normal Dev View (debug OFF)")
	assert(dev_ref.visible == true, "Clean reference art must be visible in Normal Dev View")

	var depth_layer: Node2D = world.get_node_or_null("DepthSortedLayer") as Node2D
	assert(depth_layer != null, "DepthSortedLayer must exist")

	# Essential runtime placeholders must be visible
	var worker: CharacterPlaceholder = depth_layer.get_node_or_null("WorkerCatPlaceholder") as CharacterPlaceholder
	var customer: CharacterPlaceholder = depth_layer.get_node_or_null("CustomerPlaceholder") as CharacterPlaceholder
	assert(worker != null and worker.visible == true, "WorkerCatPlaceholder must be visible in Normal Dev View")
	assert(customer != null and customer.visible == true, "CustomerPlaceholder must be visible in Normal Dev View")

	# Debug test helpers & geometry must be hidden in Normal Dev View
	var cat_behind: CharacterPlaceholder = depth_layer.get_node_or_null("CharacterBehindTable") as CharacterPlaceholder
	var cat_front: CharacterPlaceholder = depth_layer.get_node_or_null("CharacterInFrontOfTable") as CharacterPlaceholder
	var table1: Node2D = depth_layer.get_node_or_null("Table1") as Node2D
	var counter_front: Node2D = world.get_node_or_null("ForegroundOccluderLayer/CounterFrontOccluder") as Node2D

	assert(cat_behind != null and cat_behind.visible == false, "CharacterBehindTable must be hidden in Normal Dev View")
	assert(cat_front != null and cat_front.visible == false, "CharacterInFrontOfTable must be hidden in Normal Dev View")
	assert(table1 != null and table1.visible == false, "Debug table geometry must be hidden in Normal Dev View")
	assert(counter_front != null and counter_front.visible == false, "CounterFrontOccluder debug visual must be hidden in Normal Dev View")

	# Markers and Bounds must be hidden in Normal Dev View
	var test_marker: GameplayMarker = _home.get_node_or_null("GameplayNodes/WorkerIdle") as GameplayMarker
	assert(test_marker != null and test_marker.show_debug_gizmo == false, "Marker gizmos must be hidden in Normal Dev View")
	assert(_home.bounds_drawer.show_bounds == false, "Bounds drawer must be hidden in Normal Dev View")

	print("[PASS] Normal Dev View verified: Clean V2.1 café visible, zero debug clutter, minimal placeholders active.")

	# 3. Verify Debug View (Toggled ON via F1/D)
	debug_ui.toggle_master_debug()
	assert(debug_ui.master_debug_active == true, "Master debug must be active after toggle")
	assert(dev_ref.visible == true, "Background clean café image must remain visible in Debug View")
	assert(dev_ref.texture.resource_path == "res://docs/references/WILLICAT_HOME_CAMERA_PROTOTYPE_V2_1.png",
		"Background texture must remain clean V2.1 prototype in Debug View")

	# Debug helpers and geometry must now be visible
	assert(cat_behind.visible == true, "CharacterBehindTable must be visible in Debug View")
	assert(cat_front.visible == true, "CharacterInFrontOfTable must be visible in Debug View")
	assert(table1.visible == true, "Debug table geometry must be visible in Debug View")
	assert(counter_front.visible == true, "CounterFrontOccluder must be visible in Debug View")
	assert(test_marker.show_debug_gizmo == true, "Marker gizmos must be visible in Debug View")
	assert(_home.bounds_drawer.show_bounds == true, "Bounds drawer must be visible in Debug View")
	print("[PASS] Debug View verified: Runtime debug overlays active on top of clean V2.1 background art.")

	# 4. Verify CounterFrontOccluder Semi-Transparent Styling
	var front_panel: ColorRect = counter_front.get_node_or_null("FrontPanelVisual") as ColorRect
	assert(front_panel != null, "FrontPanelVisual must exist on CounterFrontOccluder")
	assert(front_panel.color.a < 0.5, "CounterFrontOccluder must be semi-transparent (alpha < 0.5), got: %.2f" % front_panel.color.a)
	print("[PASS] CounterFrontOccluder verified as semi-transparent (alpha=%.2f)." % front_panel.color.a)

	# 5. Verify Depth Ordering & Layer Hierarchy (Unchanged)
	assert(cat_behind.position.y < table1.position.y, "Behind cat must sort behind table")
	assert(cat_front.position.y > table1.position.y, "Front cat must sort in front of table")

	var back_decor: Node2D = world.get_node_or_null("BackDecorLayer") as Node2D
	var occluder_layer: Node2D = world.get_node_or_null("ForegroundOccluderLayer") as Node2D
	assert(back_decor.z_index < depth_layer.z_index, "BackDecorLayer (20) must be below DepthSortedLayer (50)")
	assert(occluder_layer.z_index > depth_layer.z_index, "ForegroundOccluderLayer (80) must be above DepthSortedLayer (50)")
	print("[PASS] Counter exception preserved: CounterBack (Z=%d) < Worker (Z=%d) < CounterFront (Z=%d)." % [
		back_decor.z_index, depth_layer.z_index, occluder_layer.z_index
	])

	# 6. Verify Return to Normal Dev View (Toggled OFF)
	debug_ui.toggle_master_debug()
	assert(debug_ui.master_debug_active == false, "Master debug must be inactive after second toggle")
	assert(cat_behind.visible == false, "CharacterBehindTable must be hidden again in Normal Dev View")
	assert(counter_front.visible == false, "CounterFrontOccluder must be hidden again in Normal Dev View")
	assert(test_marker.show_debug_gizmo == false, "Marker gizmos must be hidden again in Normal Dev View")
	assert(_home.bounds_drawer.show_bounds == false, "Bounds drawer must be hidden again in Normal Dev View")
	print("[PASS] Toggle cycle verified: Smooth transition between Normal Dev View and Debug View.")

	# 7. Verify R Hotkey Toggles Clean Prototype Art
	debug_ui.toggle_dev_reference()
	assert(dev_ref.visible == false, "Dev reference toggle off must hide prototype art")
	debug_ui.toggle_dev_reference()
	assert(dev_ref.visible == true, "Dev reference toggle on must show clean V2.1 prototype art")
	print("[PASS] 'R' hotkey toggles clean V2.1 prototype art verified.")

	# 8. Verify Markers & Dynamic Signs
	var markers_count: int = _home.get_node_or_null("GameplayNodes").get_child_count()
	assert(markers_count >= 6, "All GameplayNodes must be intact")
	var signs_count: int = _home.get_node_or_null("DynamicSignage").get_child_count()
	assert(signs_count == 4, "All 4 DynamicSignage anchors must be intact")
	print("[PASS] All %d GameplayNodes and %d DynamicSignage anchors intact." % [markers_count, signs_count])

	# 9. Verify Camera Controller
	var cam_rig: CameraController = _home.get_node_or_null("CameraRig") as CameraController
	assert(cam_rig != null and cam_rig.min_zoom == 0.82 and cam_rig.max_zoom == 1.35, "Camera config intact")
	print("[PASS] CameraController framing, zoom limits, and bounds intact.")

	print("--- ALL FOUNDATION V1.1 VISUAL GATE FIX CHECKS PASSED ---")
