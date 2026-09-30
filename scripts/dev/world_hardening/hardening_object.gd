@tool
class_name HardeningWorldObject
extends Node2D
## Small reusable object identity and shared-capacity boundary for the dev lab.

@export var stable_id: StringName = &""
@export_enum("counter", "espresso", "table", "chair", "bed", "plant", "scratch", "seasonal", "grinder", "pos", "pastry", "perch", "entrance", "waiting") var kind := "table":
	set(value):
		kind = value
		queue_redraw()
@export_range(0, 8) var shared_capacity := 0

var _shared_holders: Dictionary = {}


func can_accept_actor(actor: Node) -> bool:
	return shared_capacity <= 0 or _shared_holders.has(actor.get_instance_id()) \
		or _shared_holders.size() < shared_capacity


func claim_actor(actor: Node) -> bool:
	if not can_accept_actor(actor):
		return false
	_shared_holders[actor.get_instance_id()] = true
	return true


func release_actor(actor_id: int) -> void:
	_shared_holders.erase(actor_id)


func shared_use_count() -> int:
	return _shared_holders.size()


func _draw() -> void:
	if has_node("RuntimeVisual"):
		if Engine.is_editor_hint() or get_tree().debug_collisions_hint:
			draw_string(ThemeDB.fallback_font, Vector2(-55, -82), String(stable_id), HORIZONTAL_ALIGNMENT_CENTER, 110, 10, Color("#4b3c35"))
		return
	match kind:
		"counter":
			draw_rect(Rect2(-112, -54, 224, 62), Color("#8d6e5c"))
			draw_rect(Rect2(-112, -54, 224, 10), Color("#d7b182"))
		"espresso":
			draw_rect(Rect2(-36, -65, 72, 60), Color("#6e716c"))
			draw_rect(Rect2(-28, -56, 56, 15), Color("#b5b6a6"))
			draw_circle(Vector2(0, -18), 8, Color("#b66f48"))
		"table":
			draw_rect(Rect2(-8, -43, 16, 48), Color("#765945"))
			draw_circle(Vector2(0, -44), 52, Color("#ab7c56"))
			draw_circle(Vector2(0, -44), 39, Color("#d4aa78"))
		"chair":
			draw_rect(Rect2(-24, -39, 48, 34), Color("#6b9282"))
			draw_rect(Rect2(-21, -5, 42, 10), Color("#477966"))
		"bed":
			draw_ellipse_shape(Vector2(-2, -6), Vector2(46, 25), Color("#9c7267"))
			draw_ellipse_shape(Vector2(-2, -8), Vector2(36, 17), Color("#e2c5a1"))
		"plant":
			draw_rect(Rect2(-13, -25, 26, 27), Color("#b47a56"))
			for x in [-20, 0, 20]:
				draw_circle(Vector2(x, -42), 18, Color("#73987a"))
		"scratch":
			draw_rect(Rect2(-22, -7, 44, 10), Color("#8e6d51"))
			draw_rect(Rect2(-7, -73, 14, 66), Color("#b9966e"))
		"seasonal":
			draw_rect(Rect2(-27, -57, 54, 54), Color("#b48a85"))
			draw_circle(Vector2(0, -67), 15, Color("#e3b6bf"))
		"grinder":
			draw_rect(Rect2(-24, -54, 48, 51), Color("#86817b"))
			draw_circle(Vector2(0, -54), 15, Color("#b3a69a"))
		"pos":
			draw_rect(Rect2(-29, -46, 58, 43), Color("#6e7c78"))
			draw_rect(Rect2(-21, -39, 42, 23), Color("#b9cabd"))
		"pastry":
			draw_rect(Rect2(-44, -52, 88, 49), Color("#ad8e72"))
			draw_rect(Rect2(-38, -45, 76, 30), Color("#e2c8a0"))
		"perch":
			draw_rect(Rect2(-43, -47, 86, 44), Color("#a2b8ad"))
			draw_rect(Rect2(-38, -42, 76, 27), Color("#d0dfd7"))
		"entrance":
			draw_rect(Rect2(-49, -66, 98, 68), Color("#a57d63"), false, 4)
			draw_rect(Rect2(-7, -65, 14, 65), Color("#c49c7e"))
		"waiting":
			draw_arc(Vector2.ZERO, 29, 0, TAU, 32, Color("#94aaa1"), 3.0)
	if Engine.is_editor_hint() or get_tree().debug_collisions_hint:
		draw_string(ThemeDB.fallback_font, Vector2(-55, -82), String(stable_id), HORIZONTAL_ALIGNMENT_CENTER, 110, 10, Color("#4b3c35"))


func draw_ellipse_shape(center: Vector2, radii: Vector2, fill: Color) -> void:
	var points := PackedVector2Array()
	for i in 20:
		var angle := TAU * float(i) / 20.0
		points.append(center + Vector2(cos(angle) * radii.x, sin(angle) * radii.y))
	draw_colored_polygon(points, fill)
