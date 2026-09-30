extends SceneTree
## Captures the four real-rendered views required by the café visible milestone.

const WORLD := preload("res://scenes/dev/playable_placeholder/playable_world.tscn")
const OUTPUT := "res://artifacts/prototype_review/asset_first_cafe_visible_milestone_v1/"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(540, 960)
	debug_collisions_hint = false
	var world := WORLD.instantiate() as PlaceholderWorld
	root.add_child(world)
	var output := ProjectSettings.globalize_path(OUTPUT)
	if DirAccess.make_dir_recursive_absolute(output) != OK:
		push_error("Could not create café milestone capture directory")
		quit(1)
		return
	for frame in 45:
		await process_frame
	var cafe := world.room as PlaceholderCafe
	world.get_node("HUD").visible = false
	cafe.get_node("HUD").visible = false
	var order_bubble := cafe.get_node("DepthSortedLayer/Characters/Customer/OrderBubble") as Label
	var worker := cafe.actors.get_node("Worker") as HardeningActor
	var captured_occlusion := false
	for frame in 4400:
		if not captured_occlusion and worker.phase == HardeningActor.Phase.ACTION \
				and worker.last_action == &"serve":
			order_bubble.visible = false
			if not await _save("04_main_cafe_actor_occlusion.png"):
				quit(1)
				return
			captured_occlusion = true
		if world.session["coins"] == 1 and not cafe.loop_active:
			break
		await physics_frame
	if world.session["coins"] != 1 or not captured_occlusion:
		push_error("Café loop or actor-occlusion capture did not complete")
		quit(1)
		return
	for frame in 6:
		await process_frame
	var camera_input := cafe.camera_input as PlaceholderCameraInput
	camera_input.set_preset(&"overview")
	if not await _save("01_main_cafe_overview.png"):
		quit(1)
		return
	camera_input.set_preset(&"default")
	if not await _save("02_main_cafe_gameplay.png"):
		quit(1)
		return
	camera_input.set_preset(&"focus", Vector2(335, 330))
	if not await _save("03_main_cafe_service_focus.png"):
		quit(1)
		return
	quit(0)


func _save(filename: String) -> bool:
	for frame in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Milestone capture requires a rendered Godot viewport")
		return false
	var path := ProjectSettings.globalize_path(OUTPUT + filename)
	var result := image.save_png(path)
	print("CAFE_MILESTONE_CAPTURE %s %s %s" % [filename, image.get_size(), error_string(result)])
	return result == OK
