extends Node2D
## Capture-only world-space labels for Batch 03 composition review.

var force_visible: bool = false
var _home: Node

const ZONES := [
	{"rect": Rect2(170.0, 310.0, 600.0, 360.0), "label": "SERVICE / COUNTER"},
	{"rect": Rect2(65.0, 700.0, 330.0, 285.0), "label": "LEFT TABLE"},
	{"rect": Rect2(390.0, 710.0, 285.0, 335.0), "label": "OPEN CIRCULATION"},
	{"rect": Rect2(390.0, 1045.0, 340.0, 300.0), "label": "LOWER-CENTER TABLE"},
	{"rect": Rect2(690.0, 880.0, 245.0, 455.0), "label": "RIGHT LOUNGE / CAT LIFE"},
	{"rect": Rect2(170.0, 1400.0, 600.0, 250.0), "label": "ENTRANCE / FOREGROUND"},
]


func _ready() -> void:
	_home = get_parent().get_parent().get_parent()
	set_process(false)


func _draw() -> void:
	if not force_visible:
		return
	var colors := [Color(0.12, 0.9, 1.0, 0.85), Color(0.25, 1.0, 0.55, 0.85),
		Color(1.0, 0.86, 0.25, 0.85), Color(0.35, 0.75, 1.0, 0.85),
		Color(1.0, 0.48, 0.7, 0.85), Color(1.0, 0.55, 0.2, 0.85)]
	for index in ZONES.size():
		var zone: Dictionary = ZONES[index]
		var rect: Rect2 = zone["rect"]
		draw_rect(rect, colors[index], false, 2.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(5.0, 17.0),
			String(zone["label"]), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 10.0, 13, colors[index])
	if _home == null:
		return
	for path in ["GameplayNodes/Seats/SeatA", "GameplayNodes/Seats/SeatB",
		"GameplayNodes/Seats/SeatC", "GameplayNodes/Seats/SeatD",
		"GameplayNodes/WorkerIdle", "GameplayNodes/CoffeeAction", "GameplayNodes/ServePoint"]:
		var marker := _home.get_node_or_null(path) as Node2D
		if marker == null:
			continue
		var point := to_local(marker.global_position)
		draw_circle(point, 7.0, Color(1.0, 0.95, 0.3, 0.9))
		draw_line(point + Vector2(-12.0, 0.0), point + Vector2(12.0, 0.0), Color.WHITE, 1.5)
		draw_line(point + Vector2(0.0, -12.0), point + Vector2(0.0, 12.0), Color.WHITE, 1.5)
