@tool
class_name RealArtProofSlot
extends Node2D
## Authored world root stays fixed; only a transparent candidate texture is swapped.

@export var asset_id: StringName = &"":
	set(value):
		asset_id = value
		queue_redraw()
@export var expected_canvas_px := Vector2i(512, 512)
@export var pivot_px := Vector2i(256, 448)
@export var world_scale := 0.25
@export var placeholder_rect := Rect2(-25, -40, 50, 40)
@export var placeholder_color := Color(0.55, 0.61, 0.57, 0.8)
@export var candidate_texture: Texture2D:
	set(value):
		candidate_texture = value
		_sync()
@export var optional_normal_map: Texture2D:
	set(value):
		optional_normal_map = value
		_sync()
@export var use_normal_map := false:
	set(value):
		use_normal_map = value
		_sync()


func _ready() -> void:
	_sync()


func _sync() -> void:
	var visual := get_node_or_null("Visual") as Sprite2D
	if visual:
		var display_texture := candidate_texture
		if candidate_texture != null and use_normal_map and optional_normal_map != null \
				and optional_normal_map.get_size() == candidate_texture.get_size():
			var canvas_texture := CanvasTexture.new()
			canvas_texture.diffuse_texture = candidate_texture
			canvas_texture.normal_texture = optional_normal_map
			display_texture = canvas_texture
		visual.texture = display_texture
		visual.centered = false
		visual.position = -Vector2(pivot_px) * world_scale
		visual.scale = Vector2.ONE * world_scale
		visual.visible = candidate_texture != null
	var source_preview := get_node_or_null("OpaqueSourcePreview") as CanvasItem
	if source_preview:
		source_preview.visible = candidate_texture == null
	var source_warning := get_node_or_null("SourceWarning") as CanvasItem
	if source_warning:
		source_warning.visible = candidate_texture == null
	queue_redraw()


func _draw() -> void:
	if candidate_texture != null:
		return
	draw_rect(placeholder_rect, placeholder_color, true)
	draw_rect(placeholder_rect, Color(0.19, 0.28, 0.26, 0.85), false, 1.5)
	draw_line(Vector2(-8, 0), Vector2(8, 0), Color(0.86, 0.47, 0.22), 2)
	draw_line(Vector2(0, -8), Vector2(0, 8), Color(0.86, 0.47, 0.22), 2)


func is_ready_for_capture() -> bool:
	if candidate_texture == null:
		return false
	if candidate_texture.get_size() != Vector2(expected_canvas_px):
		return false
	var image := candidate_texture.get_image()
	if image == null or image.is_empty():
		return false
	var w := image.get_width()
	var h := image.get_height()
	# Full perimeter, not just four corners. Final silhouette/style still need human review.
	for x in w:
		if image.get_pixel(x, 0).a > 0.01 or image.get_pixel(x, h - 1).a > 0.01:
			return false
	for y in h:
		if image.get_pixel(0, y).a > 0.01 or image.get_pixel(w - 1, y).a > 0.01:
			return false
	return true
