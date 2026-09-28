extends SceneTree
## Guards the V2-only composition registration, anchor attachment and locked depth/camera contracts.

const PREVIEW: PackedScene = preload("res://scenes/dev/home_v2_environment_preview.tscn")
const BASE: PackedScene = preload("res://scenes/home/home_scene.tscn")

var _valid := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var base := BASE.instantiate() as HomeScene
	_check((base.get_node("GameplayNodes/CoffeeAction") as Marker2D).position == Vector2(402, 445),
		"The source Home scene was changed by V2 composition work.")
	base.free()

	var home := PREVIEW.instantiate() as HomeScene
	root.add_child(home)
	await process_frame
	await process_frame
	var back := home.get_node("World/BackDecorLayer/CounterBackSlot") as HomeAssetSlot
	var front := home.get_node("World/ForegroundOccluderLayer/CounterFrontSlot") as HomeAssetSlot
	var tables := [
		["World/DepthSortedLayer/Table1Slot", Vector2(250, 860), 1.32],
		["World/DepthSortedLayer/Table2Slot", Vector2(535, 1190), 1.38],
	]
	for entry in tables:
		var slot := home.get_node(entry[0]) as HomeAssetSlot
		_check(slot.position == entry[1], "%s registration changed unexpectedly." % entry[0])
		_check(is_equal_approx(slot.scale.x, entry[2]) and is_equal_approx(slot.scale.y, entry[2]),
			"%s no longer uses its recorded V2 scale." % entry[0])

	var chair_pairs := [
		["World/DepthSortedLayer/ChairTable1LeftSlot", "GameplayNodes/Seats/SeatA", Vector2(155, 895)],
		["World/DepthSortedLayer/ChairTable2LeftSlot", "GameplayNodes/Seats/SeatB", Vector2(430, 1220)],
		["World/DepthSortedLayer/ChairTable2RightSlot", "GameplayNodes/Seats/SeatC", Vector2(680, 1235)],
		["World/DepthSortedLayer/AdditionalLeftTableChair", "GameplayNodes/Seats/SeatD", Vector2(335, 900)],
	]
	for pair in chair_pairs:
		var chair := home.get_node(pair[0]) as Node2D
		var seat := home.get_node(pair[1]) as Marker2D
		_check(chair.position == pair[2] and seat.position == pair[2],
			"Seat anchor is not registered to its chair: %s." % pair[1])
		_check(chair.get_parent() == home.get_node("World/DepthSortedLayer"),
			"Chair lost its existing depth-sorted owner: %s." % pair[0])

	_check(back.position == Vector2(465, 520) and front.position == Vector2(465, 625),
		"Batch 02 counter registration moved.")
	_check(home.get_node("GameplayNodes/CoffeeAction").position == Vector2(402, 525),
		"Batch 02 CoffeeAction floor anchor moved.")
	_check(home.get_node("GameplayNodes/WorkerIdle").position == Vector2(620, 525),
		"Batch 02 WorkerIdle floor anchor moved.")
	_check(home.get_node("SliceWaypoints/CounterExitRear").position == Vector2(165, 525),
		"Batch 02 rear worker corridor moved.")
	_check(back.get_parent().z_index < home.get_node("World/DepthSortedLayer").z_index and
			home.get_node("World/DepthSortedLayer").z_index < front.get_parent().z_index,
		"CounterBack < depth-sorted character < CounterFront layer order changed.")
	_check(home.get_node("World/DepthSortedLayer").y_sort_enabled,
		"DepthSortedLayer Y-sort was disabled.")

	var cat_anchors := home.get_node("V2CatLife")
	var expected_cat_positions := {
		"cat_rest_01": Vector2(775, 1045),
		"cat_window_watch_01": Vector2(100, 680),
		"cat_inspect_basket_01": Vector2(760, 680),
		"cat_jump_stool_01": Vector2(760, 1120),
		"cat_sniff_plant_01": Vector2(880, 1140),
		"cat_scratch_stretch_01": Vector2(895, 1040),
	}
	for anchor_id: String in expected_cat_positions:
		var marker := cat_anchors.get_node(anchor_id) as Marker2D
		_check(marker.position == expected_cat_positions[anchor_id], "%s anchor drifted." % anchor_id)
	var bed := home.get_node("World/DepthSortedLayer/cat_bed_home_v2_01") as Node2D
	var basket := home.get_node("World/DepthSortedLayer/cat_inspection_basket_home_v2_01") as Node2D
	var cushion := home.get_node("World/DepthSortedLayer/cat_rest_cushion_home_v2_01") as Node2D
	_check(bed.position == expected_cat_positions["cat_rest_01"], "Bed is detached from rest anchor.")
	_check(basket.position == expected_cat_positions["cat_inspect_basket_01"], "Basket is detached from inspection anchor.")
	_check(cushion.position == Vector2(820, 1270), "Right rest cushion registration changed.")
	for prop in home.get_tree().get_nodes_in_group(&"home_modular_visuals"):
		if prop is Node2D and prop.name in ["AdditionalLeftTableChair", "cat_bed_home_v2_01",
			"cat_inspection_basket_home_v2_01", "cat_rest_cushion_home_v2_01",
			"cat_scratch_post_home_v2_01", "cat_window_perch_home_v2_01",
			"stool_home_v2_01", "plant_small_home_v2_01"]:
			_check((prop as Node2D).get_parent() == home.get_node("World/DepthSortedLayer"),
				"A floor prop left the shared Y-sort owner: %s." % prop.name)

	var room_config := (home.get_node("CameraRig") as CameraController).room_config
	_check(room_config.default_camera_position == Vector2(470.5, 836), "Camera center changed.")
	_check(is_equal_approx(room_config.design_min_zoom, 0.82) and
		is_equal_approx(room_config.default_zoom, 1.0) and
		is_equal_approx(room_config.max_zoom, 1.35), "Camera zoom contract changed.")
	_check(room_config.pan_bounds == Rect2(0, 0, 941, 1672), "Camera bounds changed.")
	var guides := home.get_node("World/FXLayer/V2CompositionGuides") as Node2D
	_check(not guides.get("force_visible"), "Composition guides leaked into normal view.")
	var master := home.dev_visual_master_node
	_check(master != null and not master.visible, "Visual master is on in the candidate normal view.")
	home.toggle_dev_visual_master()
	_check(master.visible, "F6 composition comparison no longer shows the locked master.")
	home.toggle_dev_visual_master()
	_check(not master.visible, "F6 composition comparison did not return to modular runtime.")

	home.queue_free()
	await process_frame
	if _valid:
		print("--- HOME V2 BATCH 03 COMPOSITION REGISTRATION PASSED ---")
	quit(0 if _valid else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_valid = false
		push_error(message)
