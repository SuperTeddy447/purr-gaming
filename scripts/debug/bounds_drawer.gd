class_name BoundsDrawer
extends Node2D
## World-space visualizer for CameraController pan bounds and room framing.

@export var camera_controller: CameraController
@export var show_bounds: bool = true:
	set(value):
		show_bounds = value
		queue_redraw()

@export var bounds_color: Color = Color(0.1, 0.85, 0.9, 0.85)
@export var line_width: float = 3.0


func _ready() -> void:
	z_index = 110 # Render on top of world items


func _process(_delta: float) -> void:
	# Keep updated if bounds change
	if show_bounds:
		queue_redraw()


func _draw() -> void:
	if not show_bounds or camera_controller == null:
		return

	var rect: Rect2 = camera_controller.pan_bounds
	draw_rect(rect, bounds_color, false, line_width)

	# Corner accents
	var corner_len: float = 30.0
	var tl: Vector2 = rect.position
	var top_right: Vector2 = Vector2(rect.end.x, rect.position.y)
	var bl: Vector2 = Vector2(rect.position.x, rect.end.y)
	var br: Vector2 = rect.end

	draw_line(tl, tl + Vector2(corner_len, 0), Color.WHITE, line_width + 1.0)
	draw_line(tl, tl + Vector2(0, corner_len), Color.WHITE, line_width + 1.0)
	draw_line(top_right, top_right - Vector2(corner_len, 0), Color.WHITE, line_width + 1.0)
	draw_line(top_right, top_right + Vector2(0, corner_len), Color.WHITE, line_width + 1.0)
	draw_line(bl, bl + Vector2(corner_len, 0), Color.WHITE, line_width + 1.0)
	draw_line(bl, bl - Vector2(0, corner_len), Color.WHITE, line_width + 1.0)
	draw_line(br, br - Vector2(corner_len, 0), Color.WHITE, line_width + 1.0)
	draw_line(br, br - Vector2(0, corner_len), Color.WHITE, line_width + 1.0)

	draw_string(
		ThemeDB.fallback_font,
		rect.position + Vector2(12, 24),
		"PAN BOUNDS: (%.0f, %.0f) - (%.0f, %.0f)" % [rect.position.x, rect.position.y, rect.end.x, rect.end.y],
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		14,
		bounds_color
	)
