extends SceneTree
## Real-rendered evidence capture for the Main Café production assembly lock.

const WORLD := preload("res://scenes/dev/playable_placeholder/playable_world.tscn")
const OUTPUT := "res://artifacts/prototype_review/willicat_main_cafe_production_assembly_lock_v1/"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(540, 960)
	debug_collisions_hint = false
	var world := WORLD.instantiate() as PlaceholderWorld
	root.add_child(world)
	var output := ProjectSettings.globalize_path(OUTPUT)
	if DirAccess.make_dir_recursive_absolute(output) != OK:
		push_error("Could not create Main Café assembly capture directory")
		quit(1)
		return
	for frame in 45:
		await process_frame
	var cafe := world.room as PlaceholderCafe
	_hide_review_overlays(world, cafe)
	var camera_input := cafe.camera_input as PlaceholderCameraInput
	for frame in 4400:
		if world.session["coins"] == 1 and not cafe.loop_active:
			break
		await physics_frame
	if world.session["coins"] != 1 or cafe.loop_active:
		push_error("Main Café visit did not complete before clean captures")
		quit(1)
		return
	for frame in 6:
		await process_frame

	camera_input.set_preset(&"overview")
	if not await _save("01_clean_overview.png"):
		quit(1)
		return
	camera_input.set_preset(&"default")
	if not await _save("02_default_gameplay.png"):
		quit(1)
		return
	camera_input.set_preset(&"focus", Vector2(335, 330))
	if not await _save("03_service_bar.png"):
		quit(1)
		return
	camera_input.set_preset(&"default")
	cafe.get_node("Camera").global_position = Vector2(320, 520)
	(cafe.actors.get_node("Customer") as HardeningActor).visible = false
	if not await _save("04_seating_groups.png"):
		quit(1)
		return

	# Start a fresh visit so the occlusion proof contains a live actor.
	if not world.start_loop():
		push_error("Could not start Main Café occlusion proof visit")
		quit(1)
		return
	camera_input.set_preset(&"default")
	cafe.get_node("Camera").global_position = Vector2(320, 500)
	var worker := cafe.actors.get_node("Worker") as HardeningActor
	for frame in 4400:
		cafe.get_node("DepthSortedLayer/Characters/Customer/OrderBubble").visible = false
		if worker.phase == HardeningActor.Phase.ACTION and worker.last_action == &"serve":
			if not await _save("05_actor_occlusion.png"):
				quit(1)
				return
			quit(0)
		await physics_frame
	push_error("Main Café actor occlusion proof did not reach serve")
	quit(1)


func _hide_review_overlays(world: PlaceholderWorld, cafe: PlaceholderCafe) -> void:
	world.get_node("HUD").visible = false
	cafe.get_node("HUD").visible = false
	cafe.get_node("DepthSortedLayer/Characters/Customer/OrderBubble").visible = false


func _save(filename: String) -> bool:
	for frame in 8:
		await process_frame
	var image := root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Main Café assembly capture requires a rendered viewport")
		return false
	var path := ProjectSettings.globalize_path(OUTPUT + filename)
	var result := image.save_png(path)
	print("MAIN_CAFE_ASSEMBLY_CAPTURE %s %s %s" % [filename, image.get_size(), error_string(result)])
	return result == OK
