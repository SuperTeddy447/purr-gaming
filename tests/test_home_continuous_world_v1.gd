extends SceneTree
const WORLD := preload("res://scenes/dev/home_continuous_proxy/home_continuous_world_v1.tscn")
const TEST_SAVE := "user://willicat_home_continuous_test_v1.save"
var okay := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := WORLD.instantiate() as HomeContinuousWorld
	world.autoplay_route = false
	root.add_child(world)
	await physics_frame
	await physics_frame
	check(world.get_node("Architecture/OutdoorTerrain/SharedGrass") is TileMapLayer,
		"Outdoor terrain must be TileMapLayer")
	check(world.get_node("Architecture/OutdoorTerrain/RiversideArea/Water") is TileMapLayer,
		"River water tile layer missing")
	check(world.find_object(&"cat_sniff") != null, "Garden sniff semantic object missing")
	check(world.find_object(&"river_look") != null, "Riverside interest anchor missing")
	var tree := world.find_object(&"river_depth_tree") as HomeAnimatedTreeProp
	check(tree != null and tree.get_node("VisualRoot/AnimatedSprite2D") is AnimatedSprite2D,
		"Animated tree prefab missing")
	var sprite := tree.get_node("VisualRoot/AnimatedSprite2D") as AnimatedSprite2D
	var first_frame := sprite.frame
	for i in 10:
		await process_frame
	check(sprite.frame != first_frame, "Authored tree frames did not advance")
	var visitor := world.actors.get_node("Visitor") as HardeningActor
	check(visitor.global_position.y < 1024, "Visitor must start inside café")
	check(world.run_required_route(), "Required route did not start")
	var seen := {"front_plaza": false, "riverside": false, "back_garden": false, "cafe": false}
	var previous_position := visitor.global_position
	var max_frame_step := 0.0
	for i in 10000:
		await physics_frame
		max_frame_step = maxf(max_frame_step, previous_position.distance_to(visitor.global_position))
		previous_position = visitor.global_position
		seen[String(world.current_area)] = true
		if not world.route_active:
			break
	check(world.route_succeeded, "Route failed: " + world.route_error)
	check(max_frame_step < 22.0, "Visitor jumped between areas instead of walking: " + str(max_frame_step))
	check(seen["front_plaza"] and seen["riverside"] and seen["back_garden"] and seen["cafe"],
		"Not every physical area was visited")
	check(world.last_sniff_completed, "Garden sniff did not complete")
	check(int(world.session["coins"]) == 1, "Café service reward missing")
	check(world.session["unlocked_room_ids"].has("home_cafe_garden"),
		"Existing Garden progression flag was not preserved")
	check(world.current_area == &"cafe", "Save/load did not return to Home café")
	check(FileAccess.file_exists(HomeContinuousWorld.SAVE_PATH), "Home save file missing")
	var chair := world.find_object(&"chair_b")
	var old := chair.position
	check(world.confirm_furniture_move(&"chair_b", chair.global_position + Vector2(12, 0), 0),
		"Café furniture move rejected")
	check(world.save_game(TEST_SAVE), "Moved furniture save failed")
	chair.position = old
	check(world.load_game(TEST_SAVE), "Moved furniture load failed")
	check(chair.position.distance_to(old + Vector2(12, 0)) < 0.1,
		"Moved furniture was not restored")
	check(world.area_states["cafe"] == "active", "Area activation state incorrect")
	check(visitor.navigate_to_marker(world.spawn(&"back_garden")), "Garden save probe route did not start")
	for i in 1800:
		await physics_frame
		if visitor.phase == HardeningActor.Phase.IDLE:
			break
	check(world.current_area == &"back_garden" and not visitor.failed_navigation,
		"Garden save probe did not physically arrive")
	check(world.save_game(TEST_SAVE + ".garden"), "Garden-area save failed")
	check(visitor.navigate_to_marker(world.spawn(&"final_cafe")), "Return probe did not start")
	for i in 1800:
		await physics_frame
		if visitor.phase == HardeningActor.Phase.IDLE:
			break
	check(world.current_area == &"cafe" and not visitor.failed_navigation,
		"Return probe did not reach café")
	check(world.load_game(TEST_SAVE + ".garden"), "Garden-area load failed")
	check(world.current_area == &"back_garden" and world.session["current_area"] == "back_garden",
		"Saved Home area or position did not restore")
	world.queue_free()
	await process_frame
	if okay:
		print("--- HOME CONTINUOUS WORLD V1 PASSED ---")
	quit(0 if okay else 1)


func check(condition: bool, message: String) -> void:
	if not condition:
		okay = false
		push_error(message)
