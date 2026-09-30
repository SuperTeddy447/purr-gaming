extends SceneTree
## All proof PNGs are read from a live Godot viewport.

const BASE := preload("res://scenes/dev/home_continuous_proxy/home_continuous_world_v1.tscn")
const LAB := preload("res://scenes/dev/visual_proxy_lab/home_visual_proxy_lab_v1.tscn")
const BUILDING := preload("res://scenes/dev/visual_proxy_lab/building_layer_experiment.tscn")
const OUT := "res://artifacts/prototype_review/visual_proxy_world_asset_lab_v1/"
const REQUIRED := [
	"01_current_pixel_crawler_baseline.png", "02_directional_cafe_upgrade.png",
	"03_seating_direction_check.png", "04_building_layer_test.png",
	"05_front_plaza_living_world.png", "06_back_garden_animated_environment.png",
	"07_riverside.png", "08_character_depth_route.png", "09_home_overview.png",
]
var saved: Dictionary = {}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(540, 960)
	debug_collisions_hint = false
	var output := ProjectSettings.globalize_path(OUT)
	if DirAccess.make_dir_recursive_absolute(output) != OK:
		quit(1)
		return
	var baseline := BASE.instantiate() as HomeContinuousWorld
	baseline.autoplay_route = false
	root.add_child(baseline)
	await _settle(8)
	_prepare_cafe_view(baseline)
	await _save("01_current_pixel_crawler_baseline.png")
	baseline.queue_free()
	await process_frame
	var lab := LAB.instantiate() as HomeContinuousWorld
	lab.autoplay_route = false
	root.add_child(lab)
	await _settle(8)
	_prepare_cafe_view(lab)
	var visitor := lab.actors.get_node("Visitor") as HardeningActor
	if not visitor.navigate_to_marker(lab.spawn(&"cafe_return")):
		push_error("Café visual walk could not start")
		quit(1)
		return
	for i in 1400:
		await process_frame
		if visitor.velocity.length_squared() > 4.0 and visitor.global_position.y < 720.0:
			await _save_once("02_directional_cafe_upgrade.png")
		if visitor.velocity.length_squared() > 4.0 and visitor.global_position.y < 545.0:
			lab.get_node("Camera").global_position = Vector2(320, 490)
			lab.get_node("Camera").zoom = Vector2.ONE * 1.75
			await _save_once("03_seating_direction_check.png")
		if not visitor.phase in [HardeningActor.Phase.APPROACH, HardeningActor.Phase.EXIT, HardeningActor.Phase.ROUTE]:
			break
	lab.queue_free()
	await process_frame
	var building := BUILDING.instantiate()
	root.add_child(building)
	var camera := Camera2D.new()
	camera.position = Vector2(300, 300)
	camera.zoom = Vector2.ONE * 1.7
	building.add_child(camera)
	camera.make_current()
	await _settle(65)
	var walker := building.get_node("MovingProxyCharacter") as AnimatedSprite2D
	var first_x := walker.position.x
	await _settle(18)
	if absf(walker.position.x - first_x) < 1.0:
		push_error("Building character did not move")
	await _save("04_building_layer_test.png")
	building.queue_free()
	await process_frame
	var world := LAB.instantiate() as HomeContinuousWorld
	world.autoplay_route = false
	root.add_child(world)
	await _settle(8)
	world.get_node("HUD").visible = false
	(world.get_node("DepthSortedLayer/Characters/Customer/OrderBubble") as Label).modulate.a = 0.0
	world.gameplay_view()
	if not world.run_required_route():
		push_error("Lab route could not start")
		quit(1)
		return
	visitor = world.actors.get_node("Visitor") as HardeningActor
	for frame in 10000:
		await process_frame
		var pos := visitor.global_position
		if visitor.velocity.length_squared() > 4.0:
			if world.current_area == &"front_plaza" and pos.y > 1180.0:
				await _save_once("05_front_plaza_living_world.png")
			if world.current_area == &"back_garden" and pos.y < -250.0:
				await _save_once("06_back_garden_animated_environment.png")
			if world.current_area == &"riverside" and pos.x < -450.0:
				await _save_once("07_riverside.png")
			if world.route_step.contains("river behind depth") and absf(pos.x + 378.0) < 18.0 and pos.y < 1225.0:
				await _save_once("08_character_depth_route.png")
		if not world.route_active:
			break
	if world.route_succeeded:
		world.overview()
		await _save("09_home_overview.png")
	var complete := world.route_succeeded
	for file in REQUIRED:
		if not saved.has(file):
			complete = false
			push_error("Missing live capture: " + file)
	print("VISUAL_LAB_CAPTURE saved=%d route=%s" % [saved.size(), world.route_succeeded])
	world.queue_free()
	await process_frame
	quit(0 if complete else 1)


func _prepare_cafe_view(world: HomeContinuousWorld) -> void:
	world.get_node("HUD").visible = false
	(world.get_node("DepthSortedLayer/Characters/Customer/OrderBubble") as Label).modulate.a = 0.0
	world._view_mode = &"overview"
	world.get_node("Camera").global_position = Vector2(320, 520)
	world.get_node("Camera").zoom = Vector2.ONE * 1.15


func _settle(count: int) -> void:
	for i in count:
		await process_frame


func _save_once(file: String) -> void:
	if not saved.has(file):
		await _save(file)


func _save(file: String) -> void:
	await process_frame
	var picture := root.get_texture().get_image()
	if picture == null or picture.is_empty() or picture.save_png(ProjectSettings.globalize_path(OUT + file)) != OK:
		push_error("Could not save rendered viewport: " + file)
		return
	saved[file] = true
	print("VISUAL_LAB_CAPTURE ", file)
