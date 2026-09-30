extends SceneTree
## Captures only live Godot viewport pixels while the required route runs.

const WORLD := preload("res://scenes/dev/home_continuous_proxy/home_continuous_world_v1.tscn")
const OUT := "res://artifacts/prototype_review/home_continuous_world_tiny_swords_proof_v1/"
const REQUIRED := [
	"01_home_location_overview.png", "02_cafe_to_plaza.png",
	"03_animated_tree_depth.png", "04_back_garden.png", "05_riverside.png",
	"06_character_world_scale.png", "07_cafe_gameplay_preserved.png",
	"08_save_load_return.png",
]
var saved: Dictionary = {}
var frame_count := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(540, 960)
	debug_collisions_hint = false
	var world := WORLD.instantiate() as HomeContinuousWorld
	world.autoplay_route = false
	root.add_child(world)
	var output := ProjectSettings.globalize_path(OUT)
	if DirAccess.make_dir_recursive_absolute(output + "frames") != OK:
		push_error("Could not create render proof directory")
		quit(1)
		return
	var frame_directory := DirAccess.open(output + "frames")
	for old_file in frame_directory.get_files():
		if old_file.begins_with("frame_") and old_file.ends_with(".png"):
			frame_directory.remove(old_file)
	for i in 8:
		await process_frame
	world.get_node("HUD").visible = false
	(world.get_node("DepthSortedLayer/Characters/Customer/OrderBubble") as Label).modulate.a = 0.0
	world.overview()
	await _save("01_home_location_overview.png")
	world.gameplay_view()
	if not world.run_required_route():
		push_error("Route did not start for render proof")
		quit(1)
		return
	var visitor := world.actors.get_node("Visitor") as HardeningActor
	var customer := world.actors.get_node("Customer") as HardeningActor
	for frame in 10000:
		await process_frame
		if frame % 38 == 0 and frame_count < 160:
			_save_frame(output)
		var pos := visitor.global_position
		var step := world.route_step
		if visitor.velocity.length_squared() > 4.0:
			if pos.y >= 1030.0 and pos.y <= 1090.0 and absf(pos.x - 320.0) < 50.0:
				await _save_once("02_cafe_to_plaza.png")
			if world.current_area == &"front_plaza" and pos.y > 1180.0 and pos.x > 130.0:
				await _save_once("06_character_world_scale.png")
			if step.contains("river front depth") and absf(pos.x + 320.0) < 18.0 and pos.y > 1295.0:
				await _save_once("03_animated_tree_depth.png")
			if step.contains("river behind depth") and absf(pos.x + 378.0) < 18.0 and pos.y < 1225.0:
				await _save_once("03b_character_behind_tree.png")
			if world.current_area == &"riverside" and pos.x < -450.0:
				await _save_once("05_riverside.png")
			if world.current_area == &"back_garden" and pos.y < -250.0:
				await _save_once("04_back_garden.png")
		if customer.visible and customer.last_action == &"order" and \
				customer.phase == HardeningActor.Phase.ACTION and not saved.has("07_cafe_gameplay_preserved.png"):
			world._view_mode = &"overview"
			world.get_node("Camera").global_position = Vector2(320, 500)
			world.get_node("Camera").zoom = Vector2.ONE * 1.15
			await _save_once("07_cafe_gameplay_preserved.png")
			world.gameplay_view()
		if not world.route_active:
			break
	if world.route_succeeded:
		world._view_mode = &"overview"
		world.get_node("Camera").global_position = Vector2(320, 500)
		world.get_node("Camera").zoom = Vector2.ONE * 1.15
		world.get_node("HUD").visible = true
		await _save("08_save_load_return.png")
	var complete := world.route_succeeded
	for file in REQUIRED:
		if not saved.has(file):
			push_error("Missing live screenshot: " + file)
			complete = false
	print("HOME_CAPTURE frames=%d saved=%d route=%s" % [frame_count, saved.size(), world.route_succeeded])
	world.queue_free()
	await process_frame
	quit(0 if complete else 1)


func _save_once(file: String) -> void:
	if not saved.has(file):
		await _save(file)


func _save(file: String) -> void:
	await process_frame
	var picture := root.get_texture().get_image()
	if picture == null or picture.is_empty():
		push_error("Real viewport was empty")
		return
	if picture.save_png(ProjectSettings.globalize_path(OUT + file)) == OK:
		saved[file] = true
		print("HOME_CAPTURE ", file)
	else:
		push_error("Could not save live frame " + file)


func _save_frame(output: String) -> void:
	var picture := root.get_texture().get_image()
	if picture == null or picture.is_empty():
		return
	if picture.save_png(output + "frames/frame_%03d.png" % frame_count) == OK:
		frame_count += 1
