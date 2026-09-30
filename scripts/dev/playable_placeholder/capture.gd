extends SceneTree
## Run with the normal renderer; screenshots come from the live game viewport.

const WORLD := preload("res://scenes/dev/playable_placeholder/playable_world.tscn")
const OUTPUT := "res://artifacts/prototype_review/playable_placeholder_reset_v1/"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(540, 960)
	var world := WORLD.instantiate() as PlaceholderWorld
	root.add_child(world)
	for frame in 80:
		await process_frame
	await process_frame
	_save("01_main_cafe.png")
	for frame in 4400:
		if world.session["coins"] == 1 and not (world.room as PlaceholderCafe).loop_active:
			break
		await physics_frame
	if world.session["coins"] != 1:
		push_error("Cannot capture garden: café visit did not finish")
		quit(1)
		return
	await process_frame
	await process_frame
	_save("02_cafe_after_loop.png")
	if not world.enter_garden():
		push_error("Cannot capture garden: transition failed")
		quit(1)
		return
	for frame in 90:
		await process_frame
	await process_frame
	await process_frame
	_save("03_back_garden.png")
	quit(0)


func _save(filename: String) -> void:
	var image := root.get_texture().get_image()
	var path := OUTPUT + filename
	var result := image.save_png(path)
	print("PLACEHOLDER_CAPTURE %s %s %s" % [filename, image.get_size(), error_string(result)])
