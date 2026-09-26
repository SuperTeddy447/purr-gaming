class_name SliceRewardFX
extends Node2D
## Short world-space reward callout rendered by FXLayer.

var amount: int = 0
var lifetime: float = 1.25
var _elapsed: float = 0.0
var _start_position: Vector2


func _ready() -> void:
	_start_position = position
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	position = _start_position + Vector2(0.0, -42.0 * minf(_elapsed / lifetime, 1.0))
	queue_redraw()
	if _elapsed >= lifetime:
		queue_free()


func _draw() -> void:
	var opacity: float = 1.0 - minf(_elapsed / lifetime, 1.0)
	draw_rect(Rect2(-58.0, -18.0, 116.0, 34.0), Color(0.10, 0.22, 0.13, 0.82 * opacity), true)
	draw_string(ThemeDB.fallback_font, Vector2(-50.0, 5.0), "+%d COINS" % amount,
		HORIZONTAL_ALIGNMENT_CENTER, 100.0, 17, Color(1.0, 0.88, 0.38, opacity))
