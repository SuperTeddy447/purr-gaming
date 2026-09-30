extends SceneTree
# Read-only extraction in an isolated copy, never a Home scene editor.
func _initialize() -> void:
	call_deferred("run")
func transform_values(t: Transform2D) -> Array:
	return [t.x.x,t.x.y,t.y.x,t.y.y,t.origin.x,t.origin.y]
func run() -> void:
	var world = load("res://scenes/dev/first_party_style_proof/home_first_party_style_proof_001.tscn").instantiate()
	world.autoplay_route = false
	root.add_child(world)
	for i in 6: await process_frame
	var tree = world.find_object(&"river_depth_tree")
	assert(tree != null)
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
	var snapshot = {
		"projection_schema_version":"tree-authority-1","world_id":"willicat_home_continuous_v1",
		"stable_id":String(tree.stable_id),"node_path":String(world.get_path_to(tree)),
		"global_transform":transform_values(tree.global_transform),
		"attachment":{"visual_root_path":String(tree.get_path_to(tree.get_node("VisualRoot"))),"local_transform":transform_values(tree.get_node("VisualRoot").transform)},
		"depth_chain":depth,
		"shadow":{"node_path":String(tree.get_path_to(shadow)),"local_transform":transform_values(shadow.transform),"z_index":shadow.z_index,"z_as_relative":shadow.z_as_relative},
		"collision":{"node_path":String(tree.get_path_to(foot)),"global_transform":transform_values(foot.global_transform),"footprint_size":[foot.footprint_size.x,foot.footprint_size.y],"collision_layer":foot.collision_layer,"collision_mask":foot.collision_mask,"navigation_outline":outline},
		"navigation":{"region_path":String(world.get_path_to(world.navigation)),"agent_clearance":world.navigation.agent_clearance,"navigation_layers":world.navigation.navigation_layers,"obstruction_ref":String(world.get_path_to(foot))},
		"semantic_event_ids":[],
		"diagnostic_presentation":{"sprite_transform":transform_values(tree.get_node("VisualRoot/AnimatedSprite2D").transform),"shadow_alpha":shadow.modulate.a,"source_frame_count":4,"source_frame_size_px":[512,640],"fps":5.0},
		"unrelated_decoration":"excluded"
	}
	var args = OS.get_cmdline_user_args()
	var file = FileAccess.open(args[0],FileAccess.WRITE)
	file.store_string(JSON.stringify(snapshot,"\t",true,true))
	file.close()
	print("PHASE0_AUTHORITY_EXTRACTED stable_id=",tree.stable_id)
	world.queue_free()
	await process_frame
	quit(0)
