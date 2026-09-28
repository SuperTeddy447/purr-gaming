extends Node2D
## V2-only geometry evidence. Invisible in normal gameplay.

var force_visible: bool = false
var _home: Node
var _front: HomeAssetSlot
var _back: HomeAssetSlot
var _worker: MochiScaleTest
var _coffee: Marker2D
var _debug: DebugOverlay
var _front_alpha_edge: PackedVector2Array
var _was_visible: bool = false


func _ready() -> void:
	_home = get_parent().get_parent().get_parent()
	_front = _home.get_node_or_null("World/ForegroundOccluderLayer/CounterFrontSlot") as HomeAssetSlot
	_back = _home.get_node_or_null("World/BackDecorLayer/CounterBackSlot") as HomeAssetSlot
	_worker = _home.get_node_or_null("World/DepthSortedLayer/MochiScaleTestDEV") as MochiScaleTest
	_coffee = _home.get_node_or_null("GameplayNodes/CoffeeAction") as Marker2D
	_debug = _home.get_node_or_null("UI/DebugOverlay") as DebugOverlay
	call_deferred("_rebuild_alpha_edge")


func _process(_delta: float) -> void:
	var should_show: bool = force_visible or (_debug != null and _debug.master_debug_active)
	if should_show or should_show != _was_visible:
		queue_redraw()
	_was_visible = should_show


func _rebuild_alpha_edge() -> void:
	await get_tree().process_frame
	_front_alpha_edge.clear()
	if _front == null or _front.visual_node == null or _front.visual_node.get_child_count() == 0:
		return
	var sprite: Sprite2D = _front.visual_node.get_child(0) as Sprite2D
	if sprite == null or sprite.texture == null:
		return
	var image: Image = sprite.texture.get_image()
	var scale_factor: float = sprite.scale.x
	var left: float = _front.global_position.x - image.get_width() * scale_factor * 0.5
	var top: float = _front.global_position.y - image.get_height() * scale_factor
	for x_px in range(0, image.get_width(), 30):
		for y_px in image.get_height():
			if image.get_pixel(x_px, y_px).a > 0.7:
				_front_alpha_edge.append(Vector2(left + x_px * scale_factor, top + y_px * scale_factor))
				break


func _draw() -> void:
	if not force_visible and (_debug == null or not _debug.master_debug_active):
		return
	if _front == null or _back == null or _worker == null or _coffee == null:
		return
	_draw_slot_bounds(_back, Color(0.12, 0.92, 0.95, 0.9), "CounterBack")
	_draw_slot_bounds(_front, Color(1.0, 0.52, 0.12, 0.9), "CounterFront")
	if _front_alpha_edge.size() >= 2:
		draw_polyline(_front_alpha_edge, Color(1.0, 0.2, 0.6, 0.9), 2.0)
	var root: Vector2 = to_local(_worker.global_position)
	var marker: Vector2 = to_local(_coffee.global_position)
	draw_rect(Rect2(root + Vector2(-45.0, -125.0), Vector2(90.0, 125.0)), Color(0.95, 0.94, 0.1, 0.8), false, 2.0)
	draw_circle(root, 6.0, Color(0.95, 0.94, 0.1))
	draw_line(root + Vector2(-30.0, 0.0), root + Vector2(30.0, 0.0), Color(0.95, 0.94, 0.1), 2.0)
	draw_arc(root, 24.0, 0.0, TAU, 24, Color(0.92, 0.92, 0.1, 0.8), 1.0)
	draw_circle(marker, 5.0, Color(0.6, 0.2, 1.0))
	draw_string(ThemeDB.fallback_font, root + Vector2(32.0, 8.0), "ROOT / FEET / SHADOW / Y-SORT", HORIZONTAL_ALIGNMENT_LEFT, 280.0, 11, Color(1, 1, 0.8))
	draw_string(ThemeDB.fallback_font, marker + Vector2(9.0, 22.0), "CoffeeAction", HORIZONTAL_ALIGNMENT_LEFT, 140.0, 11, Color(0.85, 0.5, 1.0))


func _draw_slot_bounds(slot: HomeAssetSlot, tint: Color, label: String) -> void:
	if slot.visual_node == null or slot.visual_node.get_child_count() == 0:
		return
	var sprite: Sprite2D = slot.visual_node.get_child(0) as Sprite2D
	if sprite == null or sprite.texture == null:
		return
	var size: Vector2 = sprite.texture.get_size() * sprite.scale
	var world_top_left: Vector2 = slot.global_position - Vector2(size.x * 0.5,
		size.y if slot.contract.uses_floor_contact_pivot() else size.y * 0.5)
	var rect := Rect2(to_local(world_top_left), size)
	draw_rect(rect, tint, false, 2.0)
	draw_string(ThemeDB.fallback_font, rect.position + Vector2(0.0, -5.0), label,
		HORIZONTAL_ALIGNMENT_LEFT, 190.0, 11, tint)
