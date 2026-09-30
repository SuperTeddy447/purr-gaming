extends SceneTree
## Frame sequence for a moving-character review; screenshots come only from the live viewport.

const WORLD := preload("res://scenes/dev/visual_proxy_lab/home_visual_proxy_lab_v1.tscn")
const OUT := "res://artifacts/prototype_review/visual_proxy_world_asset_lab_v1/motion_frames/"
var count := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.size = Vector2i(540, 960)
	debug_collisions_hint = false
	var world := WORLD.instantiate() as HomeContinuousWorld
	world.autoplay_route = false
	root.add_child(world)
	var output := ProjectSettings.globalize_path(OUT)
	if DirAccess.make_dir_recursive_absolute(output) != OK:
		quit(1)
		return
	for i in 8:
		await process_frame
	world.get_node("HUD").visible = false
	(world.get_node("DepthSortedLayer/Characters/Customer/OrderBubble") as Label).modulate.a = 0.0
	world.gameplay_view()
	if not world.run_required_route():
		quit(1)
		return
	var visitor := world.actors.get_node("Visitor") as HardeningActor
	var moving_frames := 0
	for frame in 10000:
		await process_frame
		if visitor.velocity.length_squared() > 4.0:
			moving_frames += 1
		if frame % 50 == 0 and count < 110:
			var image := root.get_texture().get_image()
			if image == null or image.is_empty() or image.save_png(output + "frame_%03d.png" % count) != OK:
				push_error("Motion frame capture failed")
				quit(1)
				return
			count += 1
		if not world.route_active:
			break
	print("VISUAL_LAB_MOTION frames=%d moving_frames=%d route=%s" % [count, moving_frames, world.route_succeeded])
	var complete := world.route_succeeded and count >= 30 and moving_frames >= 100
	world.queue_free()
	await process_frame
	quit(0 if complete else 1)
