extends SceneTree
# Isolated development evidence only. No canonical gate, world or resource edits.
var world
var actor
var tree
var sprite: AnimatedSprite2D
var output: String
var trace: Array = []
var timing: Array = []
var legs: Array = []
var capture_enabled := false
var elapsed := 0.0
var frame_index := 0
var capture_accumulator := 0.0
var current_leg := ""
var last_sprite_frame := -1
var before: Dictionary
var root_samples: Array = []
var captures: Array = []
var behind_captured := false
var crossing_captured := false
var front_captured := false
func _initialize() -> void:
	output = OS.get_cmdline_user_args()[0]
	DirAccess.make_dir_recursive_absolute(output + "/frames")
	call_deferred("run")
func transform_values(t: Transform2D) -> Array:
	return [t.x.x,t.x.y,t.y.x,t.y.y,t.origin.x,t.origin.y]
func authority_snapshot() -> Dictionary:
	var foot = tree.get_node("TrunkFootprint")
	var shadow = tree.get_node("ShadowVisual")
	var depth: Array = []
	var parent = tree
	while parent != world.get_parent():
		if parent is Node2D:
			depth.append({"path":String(world.get_path_to(parent)),"y_sort_enabled":parent.y_sort_enabled,"z_index":parent.z_index,"z_as_relative":parent.z_as_relative})
		parent = parent.get_parent()
	var outline: Array = []
	for point in foot.navigation_outline(): outline.append([point.x,point.y])
	return {"projection_schema_version":"tree-authority-1","world_id":"willicat_home_continuous_v1","stable_id":String(tree.stable_id),"node_path":String(world.get_path_to(tree)),"global_transform":transform_values(tree.global_transform),"attachment":{"visual_root_path":String(tree.get_path_to(tree.get_node("VisualRoot"))),"local_transform":transform_values(tree.get_node("VisualRoot").transform)},"depth_chain":depth,"shadow":{"node_path":String(tree.get_path_to(shadow)),"local_transform":transform_values(shadow.transform),"z_index":shadow.z_index,"z_as_relative":shadow.z_as_relative},"collision":{"node_path":String(tree.get_path_to(foot)),"global_transform":transform_values(foot.global_transform),"footprint_size":[foot.footprint_size.x,foot.footprint_size.y],"collision_layer":foot.collision_layer,"collision_mask":foot.collision_mask,"navigation_outline":outline},"navigation":{"region_path":String(world.get_path_to(world.navigation)),"agent_clearance":world.navigation.agent_clearance,"navigation_layers":world.navigation.navigation_layers,"obstruction_ref":String(world.get_path_to(foot))},"semantic_event_ids":[]}
func save_json(path: String, value) -> void:
	var f = FileAccess.open(path,FileAccess.WRITE)
	assert(f != null)
	f.store_string(JSON.stringify(value,"\t",true,true)); f.close()
func capture(path: String) -> void:
	await RenderingServer.frame_post_draw
	var im = root.get_texture().get_image()
	assert(im != null and not im.is_empty(),"Actual rendered viewport required")
	assert(im.save_png(output + "/" + path) == OK)
func occlusion_samples(prefix: String) -> void:
	# Render actual comparison pixels at a frozen pose; never alter authority data.
	var was_capture = capture_enabled
	capture_enabled = false
	world.process_mode = Node.PROCESS_MODE_DISABLED
	await capture(prefix + "_combined.png")
	actor.visible = false
	await capture(prefix + "_tree_only.png")
	actor.visible = true
	tree.visible = false
	await capture(prefix + "_actor_only.png")
	actor.visible = false
	await capture(prefix + "_background.png")
	actor.visible = true
	tree.visible = true
	world.process_mode = Node.PROCESS_MODE_INHERIT
	for i in 2: await process_frame
	capture_enabled = was_capture
func _process(delta: float) -> bool:
	if sprite != null:
		elapsed += delta
		if sprite.frame != last_sprite_frame:
			timing.append({"frame":sprite.frame,"engine_elapsed_seconds":elapsed,"playing_speed":sprite.get_playing_speed()})
			last_sprite_frame = sprite.frame
	if capture_enabled:
		trace.append({"time":elapsed,"leg":current_leg,"actor_xy":[actor.global_position.x,actor.global_position.y],"actor_velocity":[actor.velocity.x,actor.velocity.y],"actor_behind_tree":actor.global_position.y < tree.global_position.y,"tree_frame":sprite.frame})
		root_samples.append({"tree_transform":transform_values(tree.global_transform),"sprite_transform":transform_values(sprite.transform),"shadow_transform":transform_values(tree.get_node("ShadowVisual").transform)})
		capture_accumulator += delta
		if capture_accumulator >= 0.05:
			capture_accumulator -= 0.05
			var name = "frames/%05d.png" % frame_index
			frame_index += 1
			capture.call_deferred(name)
		if current_leg == "river_behind_depth" and actor.global_position.y < tree.global_position.y - 55 and not behind_captured:
			behind_captured = true
			capture.call_deferred("02_actor_behind_tree.png")
			captures.append({"file":"02_actor_behind_tree.png","actor_xy":[actor.global_position.x,actor.global_position.y],"tree_xy":[tree.global_position.x,tree.global_position.y]})
		if current_leg == "river_behind_depth" and abs(actor.global_position.y - tree.global_position.y) < 6 and not crossing_captured:
			crossing_captured = true
			capture.call_deferred("03_actor_depth_crossing.png")
	return false
func run() -> void:
	world = load("res://scenes/dev/first_party_style_proof/home_first_party_style_proof_001.tscn").instantiate()
	world.autoplay_route = false
	root.add_child(world)
	for i in 10: await process_frame
	tree = world.find_object(&"river_depth_tree")
	actor = world.get_node("DepthSortedLayer/Characters/Visitor")
	before = authority_snapshot()
	sprite = tree.get_node("VisualRoot/AnimatedSprite2D")
	sprite.sprite_frames = load("res://assets/__DEV_DIAGNOSTIC_tree_pilot_v1__/tree_frames.tres")
	sprite.play(&"dev_wind")
	tree.get_node("ShadowVisual").texture = load("res://assets/__DEV_DIAGNOSTIC_tree_pilot_v1__/shadow.png")
	var expected: Array = [200,120,100,100,100,120,140,190,120,110,100,90,90,90,110,160,210,160,130,110,100,160,220]
	var recovered: Array = []
	for i in sprite.sprite_frames.get_frame_count(&"dev_wind"):
		recovered.append(sprite.sprite_frames.get_frame_duration(&"dev_wind",i) / sprite.sprite_frames.get_animation_speed(&"dev_wind") * 1000.0)
	assert(sprite.sprite_frames.get_animation_speed(&"dev_wind") == 1000.0)
	assert(recovered.size() == expected.size())
	for i in expected.size():
		assert(sprite.sprite_frames.get_frame_duration(&"dev_wind",i) == float(expected[i]),"Exact integer frame weights must survive Godot resource loading")
	# Existing authored navigation markers, no actor teleport or navigation edits.
	for id in ["front_threshold","front_plaza","river_front_depth"]:
		current_leg = id
		var ok: bool = await world._walk_leg(id)
		legs.append({"marker":id,"success":ok,"actor_xy":[actor.global_position.x,actor.global_position.y]})
		assert(ok,"Existing route leg failed: " + id)
	world._view_mode = &"overview"
	var camera: Camera2D = world.get_node("Camera")
	camera.global_position = tree.global_position + Vector2(0,-100)
	camera.zoom = Vector2(1.35,1.35)
	var hud = world.get_node_or_null("HUD")
	if hud != null: hud.visible = false
	var layer = CanvasLayer.new(); root.add_child(layer)
	var label = Label.new(); label.position = Vector2(18,14); label.text = "DEV_DIAGNOSTIC  |  TREE PILOT / HUMAN REVIEWS PENDING"; label.add_theme_color_override("font_color",Color("fff5e5")); label.add_theme_color_override("font_shadow_color",Color("30271f")); label.add_theme_constant_override("shadow_offset_x",2); label.add_theme_constant_override("shadow_offset_y",2); layer.add_child(label)
	for i in 10: await process_frame
	capture_enabled = true
	await capture("01_actor_in_front.png")
	captures.append({"file":"01_actor_in_front.png","actor_xy":[actor.global_position.x,actor.global_position.y],"tree_xy":[tree.global_position.x,tree.global_position.y]})
	await occlusion_samples("front")
	for i in 90: await physics_frame
	current_leg = "river_behind_depth"
	var ok: bool = await world._walk_leg(current_leg)
	legs.append({"marker":current_leg,"success":ok,"actor_xy":[actor.global_position.x,actor.global_position.y]}); assert(ok)
	await capture("04_actor_behind_rest.png")
	await occlusion_samples("behind")
	for i in 120: await physics_frame
	current_leg = "river_front_depth"
	ok = await world._walk_leg(current_leg)
	legs.append({"marker":current_leg,"success":ok,"actor_xy":[actor.global_position.x,actor.global_position.y]}); assert(ok)
	await capture("05_actor_in_front_return.png")
	for i in 120: await physics_frame
	capture_enabled = false
	for i in 3: await process_frame
	# Complete the existing physical Home route without recording a canonical proof.
	for id in ["riverside","return_plaza","cafe_return","rear_threshold","back_garden","final_cafe"]:
		current_leg = id
		ok = await world._walk_leg(id)
		legs.append({"marker":id,"success":ok,"actor_xy":[actor.global_position.x,actor.global_position.y]})
		assert(ok,"Continuous Home route failed: " + id)
	var after = authority_snapshot()
	save_json(output + "/authority_before.json",before)
	save_json(output + "/authority_after.json",after)
	save_json(output + "/diagnostic_runtime_observations.json",{"scope":"diagnostic_runtime_proof","canonical_integration_proof":false,"canonical_motion_gate":"pending","canonical_visual_gate":"pending","routes":legs,"captures":captures,"timing_weights_ms":recovered,"frame_change_observations":timing,"actor_trace":trace,"registration_samples":root_samples,"captured_frames":frame_index,"render_size_px":[root.size.x,root.size.y],"godot_version":Engine.get_version_info(),"route_markers":"Existing Spawns nodes; no reauthored coordinates","camera":"Diagnostic fixed camera using existing outdoor gameplay zoom","result":"completed_observations_only"})
	print("DEV_DIAGNOSTIC_COMPLETED frames=",frame_index," routes=",legs.size())
	quit(0)
