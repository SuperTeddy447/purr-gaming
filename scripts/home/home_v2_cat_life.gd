extends Node2D
## Candidate V2 destinations and one non-verbal moment using Living Café's agent.

const ANCHORS := {
	&"cat_rest_01": Vector2(775.0, 1045.0),
	&"cat_window_watch_01": Vector2(100.0, 680.0),
	&"cat_inspect_basket_01": Vector2(760.0, 680.0),
	&"cat_jump_stool_01": Vector2(760.0, 1120.0),
	&"cat_sniff_plant_01": Vector2(880.0, 1140.0),
	&"cat_scratch_stretch_01": Vector2(895.0, 1040.0),
}
const BubbleScript = preload("res://scripts/home/home_v2_reaction_bubble.gd")

var guides_visible: bool = false
var _ambient: LivingCafeAmbientController
var _bubble: Node2D


func _ready() -> void:
	var home: Node = get_parent()
	_ambient = home.get_node_or_null("LivingCafeAmbientController") as LivingCafeAmbientController
	var depth: Node2D = home.get_node_or_null("World/DepthSortedLayer") as Node2D
	if _ambient == null or depth == null:
		return
	for anchor_id: StringName in ANCHORS:
		var marker := Marker2D.new()
		marker.name = String(anchor_id)
		marker.position = ANCHORS[anchor_id]
		marker.add_to_group(&"home_v2_cat_life_anchor")
		add_child(marker)
		_ambient.register_optional_zone(anchor_id, ANCHORS[anchor_id])
	_place_prop(depth, &"cat_bed_home_v2_01", ANCHORS[&"cat_rest_01"], Vector2(155.0, 120.0))
	_place_prop(depth, &"cat_inspection_basket_home_v2_01", ANCHORS[&"cat_inspect_basket_01"], Vector2(105.0, 72.0))
	_place_prop(depth, &"cat_rest_cushion_home_v2_01", Vector2(820.0, 1270.0), Vector2(225.0, 122.0))
	_place_prop(depth, &"cat_scratch_post_home_v2_01", ANCHORS[&"cat_scratch_stretch_01"], Vector2(72.0, 145.0))
	_place_prop(depth, &"cat_window_perch_home_v2_01", ANCHORS[&"cat_window_watch_01"], Vector2(180.0, 112.0))
	_place_prop(depth, &"stool_home_v2_01", ANCHORS[&"cat_jump_stool_01"], Vector2(68.0, 80.0))
	_place_prop(depth, &"plant_small_home_v2_01", ANCHORS[&"cat_sniff_plant_01"], Vector2(72.0, 92.0))
	var explorer: LivingCafeAmbientController.Agent = _ambient.agent_for(&"PrototypeCatB")
	if explorer != null:
		var anchor := Node2D.new()
		anchor.name = "ReactionBubbleAnchor"
		anchor.position = Vector2(0.0, -125.0)
		explorer.actor.add_child(anchor)
		_bubble = BubbleScript.new() as Node2D
		_bubble.name = "ReactionBubble"
		_bubble.visible = false
		anchor.add_child(_bubble)
		call_deferred("_run_silent_story")


func _place_prop(depth: Node2D, asset_id: StringName, floor_position: Vector2, bounds: Vector2) -> void:
	var texture: Texture2D = load("res://assets/environment/home_v2/%s.png" % String(asset_id)) as Texture2D
	if texture == null:
		return
	var visual := Node2D.new()
	visual.name = String(asset_id)
	visual.position = floor_position
	visual.add_to_group(&"home_modular_visuals")
	visual.set_meta(&"asset_id", asset_id)
	visual.set_meta(&"slot_role", &"cat_life_floor_prop")
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = false
	sprite.offset = Vector2(-texture.get_width() * 0.5, -texture.get_height())
	sprite.scale = Vector2.ONE * minf(bounds.x / texture.get_width(), bounds.y / texture.get_height())
	visual.add_child(sprite)
	depth.add_child(visual)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_G:
		guides_visible = not guides_visible
		queue_redraw()
		get_viewport().set_input_as_handled()


func _draw() -> void:
	if not guides_visible:
		return
	for anchor_id: StringName in ANCHORS:
		var point: Vector2 = ANCHORS[anchor_id]
		draw_circle(point, 6.0, Color(0.15, 0.8, 0.65, 0.8))
		draw_string(ThemeDB.fallback_font, point + Vector2(10.0, -8.0), String(anchor_id),
			HORIZONTAL_ALIGNMENT_LEFT, 220.0, 12, Color(0.1, 0.3, 0.25))


func _run_silent_story() -> void:
	if _ambient == null or _bubble == null:
		return
	await get_tree().create_timer(2.0).timeout
	var started: bool = false
	for attempt in 8:
		if _ambient.begin_external_ambient_moment(&"PrototypeCatB", &"cat_inspect_basket_01"):
			started = true
			break
		await get_tree().create_timer(1.0).timeout
	if not started:
		push_warning("V2 basket story could not reserve the ambient cat; base Living Café continues.")
		return
	_bubble.call("show_reaction", &"question", 1.3)
	var agent: LivingCafeAmbientController.Agent = _ambient.agent_for(&"PrototypeCatB")
	while agent != null and agent.mover.is_moving:
		await get_tree().process_frame
	_bubble.call("show_reaction", &"surprise", 0.8)
	await get_tree().create_timer(0.9).timeout
	_bubble.call("show_reaction", &"heart", 1.1)
	await get_tree().create_timer(1.2).timeout
	_ambient.end_external_ambient_moment(&"PrototypeCatB")
