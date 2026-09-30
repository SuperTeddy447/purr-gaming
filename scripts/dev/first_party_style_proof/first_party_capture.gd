extends SceneTree
## Capture actual viewport pixels while the existing required route executes.

const WORLD := preload("res://scenes/dev/first_party_style_proof/home_first_party_style_proof_001.tscn")
const OUT := "res://artifacts/prototype_review/first_party_storybook_mini_pack_001/"
const REQUIRED := ["01_first_party_terrain.png", "02_animated_tree.png", "03_riverside_water.png",
	"04_directional_seating.png", "05_cafe_shell_depth.png", "06_protagonist_walk.png",
	"07_coffee_fx.png", "08_ui_state_test.png", "09_home_world_overview.png"]
var saved := {}
var sampled := 0
var fx_sampled := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(540, 960)
	debug_collisions_hint = false
	var world := WORLD.instantiate() as HomeContinuousWorld
	world.autoplay_route = false
	root.add_child(world)
	var output := ProjectSettings.globalize_path(OUT)
	if DirAccess.make_dir_recursive_absolute(output + "frames") != OK or \
			DirAccess.make_dir_recursive_absolute(output + "fx_frames") != OK:
		push_error("Could not create first-party proof output")
		quit(1)
		return
	for i in 10:
		await process_frame
	world.overview()
	await _save("09_home_world_overview.png")
	world._view_mode = &"overview"
	world.get_node("Camera").global_position = Vector2(320, 500)
	world.get_node("Camera").zoom = Vector2.ONE * 1.15
	await _save("04_directional_seating.png")
	var route_button: Button
	for node in world.get_node("HUD").find_children("*", "Button", true, false):
		if (node as Button).text == "ROUTE":
			route_button = node as Button
			break
	if route_button == null:
		push_error("First-party ROUTE button missing")
		quit(1)
		return
	route_button.toggle_mode = true
	route_button.button_pressed = true
	await _save("08_ui_state_test.png")
	route_button.button_pressed = false
	route_button.toggle_mode = false
	world.gameplay_view()
	route_button.pressed.emit()
	if not world.route_active:
		push_error("Styled ROUTE button did not start the existing route")
		quit(1)
		return
	var visitor := world.get_node("DepthSortedLayer/Characters/Visitor") as HardeningActor
	var installer := world.get_node("FirstPartyStyleInstaller")
	for frame in 15000:
		await process_frame
		var pos := visitor.global_position
		if frame % 75 == 0 and sampled < 120:
			var image := root.get_texture().get_image()
			if image != null and not image.is_empty():
				image.save_png(output + "frames/frame_%03d.png" % sampled)
				sampled += 1
		if visitor.velocity.length_squared() > 4.0:
			if world.current_area == &"front_plaza" and pos.y > 1180 and pos.x > 130:
				await _save_once("01_first_party_terrain.png")
				await _save_once("06_protagonist_walk.png")
			if pos.y >= 1030 and pos.y <= 1090 and absf(pos.x - 320) < 50:
				await _save_once("05_cafe_shell_depth.png")
			if world.route_step.contains("river front depth") and pos.x < -300 and pos.y > 1270:
				await _save_once("02_animated_tree.png")
			if world.route_step.contains("river behind depth") and pos.y <= 1265 and pos.y >= 1255:
				await _save_once("02b_character_behind_tree.png")
			if world.route_step.contains("river behind depth") and pos.y <= 1240 and pos.y >= 1230:
				await _save_once("02c_character_behind_tree.png")
			if world.current_area == &"riverside" and pos.x < -450:
				await _save_once("03_riverside_water.png")
		var fx := installer.get("coffee_fx") as AnimatedSprite2D
		if fx != null and fx.visible and fx.frame >= 1:
			await _save_once("07_coffee_fx.png")
		if fx != null and fx.visible and frame % 3 == 0 and fx_sampled < 8:
			var fx_image := root.get_texture().get_image()
			if fx_image != null and not fx_image.is_empty():
				fx_image.save_png(output + "fx_frames/fx_%02d.png" % fx_sampled)
				fx_sampled += 1
		if not world.route_active:
			break
	var success := world.route_succeeded
	for file in REQUIRED:
		if not saved.has(file):
			push_error("Missing Godot screenshot: " + file)
			success = false
	print("FIRST_PARTY_CAPTURE route=%s saved=%d frames=%d fx_frames=%d error=%s" % [world.route_succeeded, saved.size(), sampled, fx_sampled, world.route_error])
	world.queue_free()
	await process_frame
	quit(0 if success else 1)


func _save_once(file: String) -> void:
	if not saved.has(file):
		await _save(file)


func _save(file: String) -> void:
	await process_frame
	var picture := root.get_texture().get_image()
	if picture == null or picture.is_empty():
		push_error("Empty viewport for " + file)
		return
	if picture.save_png(ProjectSettings.globalize_path(OUT + file)) == OK:
		saved[file] = true
		print("FIRST_PARTY_CAPTURE " + file)
