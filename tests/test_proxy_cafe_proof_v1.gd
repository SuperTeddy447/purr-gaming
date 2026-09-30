extends SceneTree
## End-to-end dev proof: visit, placement, two rooms, cat state, save/load.

const WORLD := preload("res://scenes/dev/proxy_cafe/proxy_playable_world.tscn")
const TEST_SAVE := "user://willicat_proxy_cafe_test_v1.save"
var _ok := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := WORLD.instantiate() as PlaceholderWorld
	root.add_child(world)
	await physics_frame
	await physics_frame
	_check(world.room.room_id == &"home_cafe_main", "Main Café did not launch")
	_check(world.room.get_node("Architecture/FloorTiles") is TileMapLayer, "Proxy floor TileMapLayer missing")
	_check(world.room.get_node("Architecture/WallTiles") is TileMapLayer, "Proxy wall TileMapLayer missing")
	_check(world.room.get_node("DepthSortedLayer/Characters/Customer/VisualRoot/TemporaryProxySprite") is AnimatedSprite2D, "Walking proxy visual missing")
	var proxy_grid := ProxyPlacementGrid.new()
	_check(proxy_grid.world_to_cell(Vector2(65, 97)) == Vector2i(2, 3), "Placement grid world-to-cell failed")
	_check(proxy_grid.cell_to_world(Vector2i(2, 3)) == Vector2(80, 112), "Placement grid cell-to-world failed")
	_check(proxy_grid.occupy(&"probe", Vector2i(2, 3), Vector2i(2, 2)) and not proxy_grid.can_place(Vector2i(3, 4), Vector2i(1, 1)), "Placement grid overlap failed")
	_check(not proxy_grid.can_place(Vector2i(-1, 1), Vector2i(1, 1)), "Placement grid accepted out-of-bounds cell")
	_check(world.room.find_object(&"counter_shell") != null, "Counter missing")
	_check(world.room.find_object(&"pos_station") != null, "POS missing")
	_check(world.room.find_object(&"pastry_case") != null, "Pastry case missing")
	_check(world.room.find_object(&"grinder_station") != null, "Grinder missing")
	_check(world.room.find_object(&"espresso_station") != null, "Espresso missing")
	_check(world.room.find_object(&"table_a") != null and world.room.find_object(&"table_b") != null,
		"Two tables missing")
	var input := world.room.camera_input as PlaceholderCameraInput
	input.set_preset(&"overview")
	var overview_zoom: float = (world.room.get_node("Camera") as Camera2D).zoom.x
	input.set_preset(&"default")
	_check(world.room.get_node("Camera").zoom.x > overview_zoom, "Camera presets do not differ")
	input.pan_by(Vector2(10000, 10000))
	_check(world.room.get_node("Camera").global_position.x <= 640,
		"Pan escaped room bounds")
	for frame in 4400:
		if world.session["coins"] == 1 and not (world.room as PlaceholderCafe).loop_active:
			break
		await physics_frame
	_check(world.session["coins"] == 1, "Coffee visit did not grant one reward")
	_check(world.session["unlocked_room_ids"].has("home_cafe_garden"),
		"Garden did not unlock after first completed order")
	_check(not (world.room as PlaceholderCafe).loop_active, "Coffee visit did not finish")
	var receipts: Array = world.session["rewarded_orders"]
	_check(receipts.size() == 1, "Reward receipt missing")
	world._grant_reward(receipts[0])
	_check(world.session["coins"] == 1, "Duplicate reward was granted")
	_check(not world.room.get_node("DepthSortedLayer/Characters/Customer/OrderBubble").visible,
		"Order bubble survived visit")
	_check(not world.room.get_node("DepthSortedLayer/Characters/Worker/CarryCup").visible,
		"Carry cup survived visit")
	var chair := world.room.find_object(&"chair_b")
	var old_pos := chair.global_position
	var seat := chair.get_node("SeatSlot/ActionAnchor") as Marker2D
	var old_anchor := seat.global_position
	_check(world.room.confirm_furniture_move(&"chair_b", old_pos + Vector2(12, 0), 0),
		"Valid chair move rejected")
	_check(seat.global_position.distance_to(old_anchor + Vector2(12, 0)) < 0.1,
		"Chair-owned seat anchor did not move")
	_check(not world.room.confirm_furniture_move(&"chair_b", Vector2(-100, -100), 0),
		"Out-of-bounds chair move accepted")
	_check(chair.global_position.distance_to(old_pos + Vector2(12, 0)) < 0.1,
		"Rejected placement was not rolled back")
	var expected := chair.position
	_check(world.save_game(TEST_SAVE), "Save failed")
	var door_screen: Vector2 = world.room.get_canvas_transform() \
		* world.room.find_object(&"back_door").global_position
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = door_screen
	world._unhandled_input(press)
	var drag := InputEventMouseMotion.new()
	drag.position = door_screen + Vector2(35, 0)
	world._unhandled_input(drag)
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = door_screen
	world._unhandled_input(release)
	_check(world.room.room_id == &"home_cafe_main", "Drag incorrectly activated portal")
	world._unhandled_input(press)
	world._unhandled_input(release)
	_check(world.room.room_id == &"home_cafe_garden", "Back-door tap did not enter garden")
	await physics_frame
	_check(world.room.room_id == &"home_cafe_garden", "Garden did not activate")
	_check(world.session["cats"]["mochi"]["room_id"] == "home_cafe_garden",
		"Cat logical room not updated")
	_check(world.room.find_object(&"sun_spot") != null and world.room.find_object(&"cat_sniff") != null,
		"Garden cat points missing")
	_check(world.save_game(TEST_SAVE + ".garden"), "Garden save failed")
	var garden_door_screen: Vector2 = world.room.get_canvas_transform() \
		* world.room.find_object(&"garden_door").global_position
	press.position = garden_door_screen
	release.position = garden_door_screen
	world._unhandled_input(press)
	world._unhandled_input(release)
	_check(world.room.room_id == &"home_cafe_main", "Garden-door tap did not return to café")
	await physics_frame
	_check(not (world.room.actors.get_node("Cat") as HardeningActor).visible,
		"Garden cat incorrectly appeared in café")
	_check(world.room.find_object(&"chair_b").position.distance_to(expected) < 0.1,
		"Chair move lost on room reentry")
	_check(world.load_game(TEST_SAVE + ".garden"), "Garden load failed")
	_check(world.room.room_id == &"home_cafe_garden", "Saved garden room not restored")
	_check((world.room.actors.get_node("Cat") as HardeningActor).visible,
		"Saved garden cat actor not restored")
	for frame in 3:
		await physics_frame
	_check((world.room.actors.get_node("Cat") as HardeningActor).phase != HardeningActor.Phase.IDLE,
		"Saved garden sniff activity did not reacquire its semantic slot")
	_check(world.load_game(TEST_SAVE), "Load failed")
	await physics_frame
	_check(world.room.room_id == &"home_cafe_main", "Saved current room not restored")
	_check((world.room.actors.get_node("Cat") as HardeningActor).visible,
		"Saved cat room state not restored")
	_check(world.room.find_object(&"chair_b").position.distance_to(expected) < 0.1,
		"Saved chair delta not restored")
	_check(world.session["coins"] == 1, "Saved progression/reward not restored")
	_check(world.session["room_deltas"]["home_cafe_main"].size() == 1,
		"Save contains unchanged authored furniture")
	_check(world.start_loop(), "Second customer did not start")
	for frame in 4400:
		if world.session["coins"] == 2 and not (world.room as PlaceholderCafe).loop_active:
			break
		await physics_frame
	_check(world.session["coins"] == 2 and world.session["rewarded_orders"].size() == 2,
		"Repeated café loop did not award exactly once per order")
	world.queue_free()
	await process_frame
	if _ok:
		print("--- PROXY CAFE PROOF V1 PASSED ---")
	quit(0 if _ok else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_ok = false
		push_error(message)
