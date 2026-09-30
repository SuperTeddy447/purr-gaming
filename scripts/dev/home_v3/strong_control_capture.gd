extends SceneTree

const OUT_DIR = "res://artifacts/prototype_review/home_v3_strong_control_composition_guide_v1/"

func _init():
	call_deferred("_run_capture")

func _run_capture():
	print("Starting strong control capture...")
	var dir = DirAccess.open("res://")
	dir.make_dir_recursive("artifacts/prototype_review/home_v3_strong_control_composition_guide_v1")
	
	var view = _create_view()
	var room = view.get_child(0)
	
	await process_frame
	await process_frame
	
	# ---------------------------------------------------------
	# 01 — CLEAN STRUCTURAL GUIDE
	# ---------------------------------------------------------
	_hide_chars_and_ui(room)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	if not FileAccess.file_exists(OUT_DIR + "01_clean_structural_9x16.png"):
		var err1 = view.get_texture().get_image().save_png(OUT_DIR + "01_clean_structural_9x16.png")
		print("Pass 1 saved: ", err1)
	else:
		print("Pass 1 preserved: existing structural guide")
	
	# ---------------------------------------------------------
	# 02 — HARD ZONE CONTROL MASK
	# ---------------------------------------------------------
	# Create a black background to block out the scene
	var bg = ColorRect.new()
	bg.size = Vector2(10000, 10000)
	bg.position = Vector2(-5000, -5000)
	bg.color = Color.BLACK
	bg.z_index = 100 # Put it above everything
	room.add_child(bg)
	
	var zone_drawer = _create_zone_drawer(room)
	zone_drawer.z_index = 101
	room.add_child(zone_drawer)
	
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var err2 = view.get_texture().get_image().save_png(OUT_DIR + "02_zone_control_mask_9x16.png")
	print("Pass 2 saved: ", err2)
	
	zone_drawer.queue_free()
	
	# ---------------------------------------------------------
	# 03 — OBJECT FOOTPRINT CONTROL
	# ---------------------------------------------------------
	var foot_drawer = _create_footprint_drawer(room)
	foot_drawer.z_index = 101
	room.add_child(foot_drawer)
	
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var err3 = view.get_texture().get_image().save_png(OUT_DIR + "03_object_footprint_control_9x16.png")
	print("Pass 3 saved: ", err3)
	
	print("Done capturing.")
	quit()

func _create_view() -> SubViewport:
	var view = SubViewport.new()
	view.size = Vector2i(539, 959)
	view.world_2d = World2D.new()
	view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(view)
	
	var scene = load("res://scenes/dev/home_v3_level_design_pass_01.tscn")
	var room = scene.instantiate()
	view.add_child(room)
	
	if room.has_node("Camera"):
		var cam = room.get_node("Camera") as Camera2D
		cam.zoom = Vector2(0.84, 0.84)
		
	return view

func _hide_chars_and_ui(room: Node):
	if room.has_node("HUD"):
		room.get_node("HUD").hide()
	if room.has_node("BatchAGuide"):
		room.get_node("BatchAGuide").hide()
	if room.has_node("BatchACapture"):
		room.get_node("BatchACapture").queue_free()
	if room.has_node("DebugOverlay"):
		room.get_node("DebugOverlay").hide()
	
	var chars = room.get_node_or_null("DepthSortedLayer/Characters")
	if chars:
		for c in chars.get_children():
			c.hide()

func _create_zone_drawer(room: Node) -> Node2D:
	var drawer = ControlDrawer.new()
	drawer.mode = "ZONES"
	drawer.room = room
	return drawer

func _create_footprint_drawer(room: Node) -> Node2D:
	var drawer = ControlDrawer.new()
	drawer.mode = "FOOTPRINTS"
	drawer.room = room
	return drawer

class ControlDrawer extends Node2D:
	var mode: String
	var room: Node
	
	func _draw():
		var objs = room.get_node("DepthSortedLayer/WorldObjects")
		var floor_rect = Rect2(25, 100, 590, 1190) # from Navigation walkable_bounds
		
		# Draw Circulation (Background of the play area)
		if mode == "ZONES":
			draw_rect(floor_rect, Color("#333333")) # Dark grey for circulation
		
		# Service Zone
		var service = objs.get_node_or_null("CounterServiceZone")
		if service:
			_draw_group_bounds([service], Color("#558855"), mode) # Green
			
		# Seating A
		var seat_a = []
		if objs.has_node("TableA"): seat_a.append(objs.get_node("TableA"))
		if objs.has_node("ChairA"): seat_a.append(objs.get_node("ChairA"))
		if objs.has_node("ChairB"): seat_a.append(objs.get_node("ChairB"))
		_draw_group_bounds(seat_a, Color("#aa5555"), mode) # Red
		
		# Seating B
		var seat_b = []
		if objs.has_node("TableB"): seat_b.append(objs.get_node("TableB"))
		if objs.has_node("ChairC"): seat_b.append(objs.get_node("ChairC"))
		if objs.has_node("ChairD"): seat_b.append(objs.get_node("ChairD"))
		_draw_group_bounds(seat_b, Color("#aa5555"), mode) # Red
		
		# Cat Rest
		if objs.has_node("CatBed"):
			_draw_group_bounds([objs.get_node("CatBed")], Color("#5555aa"), mode) # Blue
			
		# Scratch
		if objs.has_node("ScratchPost"):
			_draw_group_bounds([objs.get_node("ScratchPost")], Color("#55aaaa"), mode) # Cyan
			
		# Window/Perch
		var window_nodes = []
		if objs.has_node("WindowPerch"): window_nodes.append(objs.get_node("WindowPerch"))
		if objs.has_node("Plant"): window_nodes.append(objs.get_node("Plant"))
		_draw_group_bounds(window_nodes, Color("#aaaa55"), mode) # Yellow
		
		# Entrance
		var ent_nodes = []
		if objs.has_node("EntranceDoor"): ent_nodes.append(objs.get_node("EntranceDoor"))
		_draw_group_bounds(ent_nodes, Color("#aa55aa"), mode) # Magenta

	func _draw_group_bounds(nodes: Array, color: Color, draw_mode: String):
		if draw_mode == "ZONES":
			# Draw a bounding box for the entire group
			var min_pos = Vector2(10000, 10000)
			var max_pos = Vector2(-10000, -10000)
			var found = false
			for n in nodes:
				var desc = _get_descendants(n)
				for d in desc:
					if d is HardeningFootprint:
						var outline = d.navigation_outline()
						for p in outline:
							var gp = to_local(p)
							if gp.x < min_pos.x: min_pos.x = gp.x
							if gp.y < min_pos.y: min_pos.y = gp.y
							if gp.x > max_pos.x: max_pos.x = gp.x
							if gp.y > max_pos.y: max_pos.y = gp.y
						found = true
			if found:
				# Pad the bounding box a bit to represent a zone
				var rect = Rect2(min_pos - Vector2(20,20), (max_pos - min_pos) + Vector2(40,40))
				draw_rect(rect, color)
				
		elif draw_mode == "FOOTPRINTS":
			# Draw the exact footprints of the group
			for n in nodes:
				var desc = _get_descendants(n)
				for d in desc:
					if d is HardeningFootprint:
						var outline = d.navigation_outline()
						var poly = PackedVector2Array()
						for p in outline:
							poly.append(to_local(p))
						# Need closed polygon
						draw_colored_polygon(poly, color)
						
	func _get_descendants(node: Node) -> Array:
		var arr = [node]
		for c in node.get_children():
			arr.append_array(_get_descendants(c))
		return arr
