extends SceneTree
## Captures the dev café from a real rendered viewport for visual review.

const WORLD := preload("res://scenes/dev/playable_placeholder/playable_world.tscn")
const OUTPUT := "res://artifacts/prototype_review/asset_first_main_cafe_assembly_fix_v1/"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(540, 960)
	var world := WORLD.instantiate() as PlaceholderWorld
	root.add_child(world)
	var output := ProjectSettings.globalize_path(OUTPUT)
	if DirAccess.make_dir_recursive_absolute(output) != OK:
		push_error("Could not create assembly capture directory")
		quit(1)
		return
	for frame in 45:
		await process_frame
	var cafe := world.room as PlaceholderCafe
	world.get_node("HUD").visible = false
	cafe.get_node("HUD").visible = false
	cafe.get_node("DepthSortedLayer/Characters/Customer/OrderBubble").visible = false
	var worker := cafe.actors.get_node("Worker") as HardeningActor
	var customer := cafe.actors.get_node("Customer") as HardeningActor
	var captured_serve := false
	var captured_seat := false
	for frame in 4400:
		if not captured_serve and worker.phase == HardeningActor.Phase.ACTION and worker.last_action == &"serve":
			if not await _save("04_counter_occlusion.png"):
				quit(1)
				return
			captured_serve = true
		if not captured_seat and customer.phase == HardeningActor.Phase.ACTION and customer.last_action == &"sit":
			if not await _save("05_seat_occlusion.png"):
				quit(1)
				return
			captured_seat = true
		if world.session["coins"] == 1 and not cafe.loop_active:
			break
		await physics_frame
	if world.session["coins"] != 1 or not captured_serve or not captured_seat:
		push_error("Café loop or occlusion evidence did not complete before assembly capture")
		quit(1)
		return
	for frame in 6:
		await process_frame
	var camera_input := cafe.camera_input as PlaceholderCameraInput
	camera_input.set_preset(&"default")
	print("ASSEMBLY_CAMERA default %s %s" % [cafe.get_node("Camera").zoom, cafe.get_node("Camera").position])
	if not await _save("01_default_gameplay.png"):
		quit(1)
		return
	camera_input.set_preset(&"overview")
	print("ASSEMBLY_CAMERA overview %s %s" % [cafe.get_node("Camera").zoom, cafe.get_node("Camera").position])
	if not await _save("02_overview.png"):
		quit(1)
		return
	camera_input.set_preset(&"focus", Vector2(335, 330))
	print("ASSEMBLY_CAMERA focus %s %s" % [cafe.get_node("Camera").zoom, cafe.get_node("Camera").position])
	if not await _save("03_service_focus.png"):
		quit(1)
		return
	quit(0)


func _save(filename: String) -> bool:
	for frame in 8:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Assembly capture needs the rendered Godot viewport")
		return false
	var path := ProjectSettings.globalize_path(OUTPUT + filename)
	var result := image.save_png(path)
	print("ASSEMBLY_CAPTURE %s %s %s" % [filename, image.get_size(), error_string(result)])
	return result == OK
