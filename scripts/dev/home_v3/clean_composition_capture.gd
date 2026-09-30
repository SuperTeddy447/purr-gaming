extends SceneTree

func _init():
	call_deferred("_run_capture")

func _run_capture():
	print("Starting clean composition capture...")
	var dir = DirAccess.open("res://")
	dir.make_dir_recursive("artifacts/prototype_review/home_v3_clean_godot_composition_guide_v1")
	
	# 9x16 Capture
	var view_9x16 = _create_view(959)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var img_9x16 = view_9x16.get_texture().get_image()
	var err1 = img_9x16.save_png("res://artifacts/prototype_review/home_v3_clean_godot_composition_guide_v1/01_clean_9x16.png")
	print("Saved 9x16 with err: ", err1)
	view_9x16.queue_free()
	
	# Tall phone Capture
	var view_tall = _create_view(1168)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var img_tall = view_tall.get_texture().get_image()
	var err2 = img_tall.save_png("res://artifacts/prototype_review/home_v3_clean_godot_composition_guide_v1/02_clean_tall_phone.png")
	print("Saved tall phone with err: ", err2)
	view_tall.queue_free()
	
	print("Done capturing.")
	quit()

func _create_view(height: int) -> SubViewport:
	var view = SubViewport.new()
	view.size = Vector2i(539, height)
	view.world_2d = World2D.new()
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	
	var scene = load("res://scenes/dev/home_v3_production_art_batch_a_staging_v1.tscn")
	var room = scene.instantiate()
	view.add_child(room)
	
	# Hide all text and guides
	if room.has_node("HUD"):
		room.get_node("HUD").hide()
	if room.has_node("BatchAGuide"):
		room.get_node("BatchAGuide").hide()
	if room.has_node("BatchACapture"):
		room.get_node("BatchACapture").queue_free()
		
	# Hide character labels/debug if any exist on the characters
	if room.has_node("DepthSortedLayer/Characters"):
		var chars = room.get_node("DepthSortedLayer/Characters")
		for c in chars.get_children():
			c.hide()
			
	# Adjust camera zoom like in pass01_capture.gd
	if room.has_node("Camera"):
		var cam = room.get_node("Camera") as Camera2D
		cam.zoom = Vector2(0.84, 0.84)
		
	return view
