@tool
extends Node2D
## Neutral greybox zones. Authored object/slot nodes, not this drawing, own gameplay.

const ROOM := Rect2(0, 0, 640, 1320)


func _draw() -> void:
	draw_rect(ROOM, Color("#e7dfd1"))
	draw_rect(Rect2(24, 124, 592, 252), Color("#d7c9b5"))
	draw_rect(Rect2(24, 388, 592, 390), Color("#e5d8c5"))
	draw_rect(Rect2(24, 790, 592, 250), Color("#dce1d3"))
	draw_rect(Rect2(24, 1052, 592, 238), Color("#ddd5c8"))
	draw_rect(Rect2(288, 382, 64, 704), Color("#efeadf"))
	draw_rect(ROOM, Color("#8e8578"), false, 5.0)
	_draw_zone("SERVICE / WORK", Vector2(34, 151))
	_draw_zone("CUSTOMER / CIRCULATION", Vector2(34, 415))
	_draw_zone("CAT LIFE / IDLE", Vector2(34, 818))
	_draw_zone("ENTRY / STORY / EVENT", Vector2(34, 1080))


func _draw_zone(label: String, at: Vector2) -> void:
	draw_string(ThemeDB.fallback_font, at, label, HORIZONTAL_ALIGNMENT_LEFT, 400, 16,
		Color("#655a50"))
