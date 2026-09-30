extends SceneTree

const WORLD := preload("res://scenes/dev/visual_proxy_lab/home_visual_proxy_lab_v1.tscn")
const TEST_SAVE := "user://willicat_visual_proxy_lab_v1.save"
var okay := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := WORLD.instantiate() as HomeContinuousWorld
	world.autoplay_route = false
	root.add_child(world)
	await physics_frame
	await physics_frame
	for name in ["ChairA", "ChairB", "ChairC", "ChairD"]:
		var chair := world.get_node("DepthSortedLayer/WorldObjects/" + name) as HardeningWorldObject
		var visual := chair.get_node("VisualRoot/DirectionalFurnitureVisual") as VisualLabDirectionalFurniture
		var before_position := chair.global_position
		var footprint := chair.get_node("PhysicalFootprint") as HardeningFootprint
		var before_bounds := footprint.global_bounds()
		check(visual != null and visual.sprite.texture is AtlasTexture,
			"Missing authored directional frame for " + name)
		var expected: StringName = &"ne" if name in ["ChairA", "ChairC"] else &"nw"
		check(visual.direction == expected, "Chair orientation does not face its table: " + name)
		check(visual.set_direction(&"s"), "Authored south frame missing")
		check(visual.set_direction(expected), "Could not restore authored direction")
		check(not visual.set_direction(&"diagonal_fake"), "Adapter accepted un-authored direction")
		check(chair.global_position == before_position and footprint.global_bounds() == before_bounds,
			"Visual direction changed semantic transform or footprint: " + name)
	for name in ["TableA", "TableB"]:
		check(world.get_node("DepthSortedLayer/WorldObjects/" + name + "/VisualRoot/RetroInteriorTableVisual") is Sprite2D,
			"Reusable table composition missing: " + name)
	check(world.find_object(&"river_depth_tree") is HomeAnimatedTreeProp,
		"Outdoor animated tree regressed")
	check(world.run_required_route(), "Continuous route did not start")
	for i in 10000:
		await physics_frame
		if not world.route_active:
			break
	check(world.route_succeeded, "Visual lab route failed: " + world.route_error)
	check(world.current_area == &"cafe" and int(world.session["coins"]) == 1,
		"Café loop or saved Home state regressed")
	var chair_b := world.find_object(&"chair_b") as HardeningWorldObject
	var moved := chair_b.global_position + Vector2(12, 0)
	check(world.confirm_furniture_move(&"chair_b", moved, 0), "Furniture move failed")
	check(world.save_game(TEST_SAVE), "Visual lab save failed")
	chair_b.global_position -= Vector2(12, 0)
	check(world.load_game(TEST_SAVE), "Visual lab load failed")
	check(chair_b.global_position.distance_to(moved) < 0.1,
		"Visual lab furniture delta failed to restore")
	world.queue_free()
	await process_frame
	if okay:
		print("--- VISUAL PROXY WORLD AND ASSET LAB V1 PASSED ---")
	quit(0 if okay else 1)


func check(condition: bool, message: String) -> void:
	if not condition:
		okay = false
		push_error(message)
