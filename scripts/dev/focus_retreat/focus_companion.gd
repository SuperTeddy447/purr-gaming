extends Node
## Visual reactions consume committed focus events; world geometry remains authoritative.
var world: HomeContinuousWorld
var actor: HardeningActor
var sprite: AnimatedSprite2D
var service: WilliCatFocusService
var route_index := 0
var rest_s := 1.5
var mood := "ready"
var paths := ["river_behind_depth","riverside","river_front_depth"]
var emote: Label

func bind(host: HomeContinuousWorld, source: WilliCatFocusService) -> void:
	world = host; service = source
	world.autoplay_route = false
	world._view_mode = &"overview"
	world.get_node("HUD").visible = false
	world.get_node("CameraInput").set_process_unhandled_input(false)
	world.set_process_unhandled_input(false)
	actor = world.get_node("DepthSortedLayer/Characters/Visitor")
	for name in ["Worker","Customer","Cat"]:
		world.actors.get_node(name).visible = false
	actor.cancel_action(&"focus_preview_init")
	# Initial placement consumes an existing authored spawn; no invented world coordinate.
	actor.global_position = world.get_node("Spawns/river_front_depth").global_position
	var tree = world.find_object(&"river_depth_tree")
	var visual = tree.get_node("VisualRoot")
	var old = visual.get_node("AnimatedSprite2D"); visual.remove_child(old);old.queue_free()
	old = tree.get_node("ShadowVisual");tree.remove_child(old);old.queue_free()
	var candidate = load("res://assets/first_party/tree_pilot_v1/tree_visual.tscn").instantiate()
	visual.add_child(candidate)
	var shadow = candidate.get_node("ShadowVisual");shadow.reparent(tree,false);shadow.name="ShadowVisual"
	sprite = candidate.get_node("AnimatedSprite2D");sprite.play("wind")
	# Old unapproved ambient tree motion is held at its existing rest image in this DEV view.
	for id in ["plaza_tree_west","plaza_tree_east","garden_tree_west","garden_tree_east","river_tree_north"]:
		var other = world.find_object(StringName(id))
		if other!=null:
			var old_animation = other.get_node("VisualRoot/AnimatedSprite2D")
			old_animation.stop();old_animation.frame=0
	emote = Label.new();emote.position=Vector2(-40,-97);emote.size=Vector2(80,35);emote.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;emote.add_theme_font_size_override("font_size",25);emote.add_theme_color_override("font_color",Color("#352c28"));actor.add_child(emote)
	service.world_event.connect(on_event)
	mood = str(service.model.data.state)
	set_process(true)

func on_event(event: Dictionary) -> void:
	match event.type:
		"focus_started","focus_resumed":
			mood="running";rest_s=0.1;emote.text=""
		"focus_paused":
			mood="paused";actor.cancel_action(&"focus_paused");emote.text="..."
		"focus_cancelled":
			mood="ready";actor.cancel_action(&"focus_cancelled");emote.text=""
		"session_complete":
			mood="completed";actor.cancel_action(&"focus_complete");emote.text="♥"
			actor.navigate_to_marker(world.get_node("Spawns/river_front_depth"))

func _process(delta: float) -> void:
	if actor==null: return
	if mood!="running" or actor.phase!=HardeningActor.Phase.IDLE: return
	rest_s -= delta
	if rest_s<=0:
		var marker = world.get_node("Spawns/"+str(paths[route_index]))
		if actor.navigate_to_marker(marker): route_index = (route_index+1)%paths.size()
		rest_s = 2.0
