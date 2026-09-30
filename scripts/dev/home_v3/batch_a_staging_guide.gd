@tool
extends Node2D
## Dev-only production envelopes. Values match this staging scene's empty art slots.

@export_range(0, 7) var guide_mode := 1:
	set(value):
		guide_mode = value
		queue_redraw()

const FLOOR := Rect2(0, 0, 640, 1320)
const NORTH := Rect2(0, 0, 640, 240)
const LEFT := Rect2(0, 156, 48, 1110)
const RIGHT := Rect2(592, 156, 48, 1110)
const SERVICE := Rect2(48, 188, 536, 280)
const WINDOW := Rect2(552, 348, 64, 192)
const WINDOW_OPENING := Rect2(565, 360, 40, 172)
const NAME_SAFE := Rect2(82, 98, 176, 38)
const MENU_SAFE := Rect2(340, 190, 164, 34)


func _draw() -> void:
	if guide_mode == 0:
		return
	match guide_mode:
		1:
			_box(FLOOR, "A1 FLOOR / ROOM 640 x 1320", Color.CYAN)
			_box(NORTH, "A2 NORTH WALL", Color.DARK_ORANGE)
			_box(LEFT, "A2 LEFT", Color.DARK_ORANGE)
			_box(RIGHT, "A2 RIGHT", Color.DARK_ORANGE)
			_box(SERVICE, "A4 SERVICE / FIXED ONLY", Color.MAGENTA)
			_box(WINDOW, "A3 WINDOW", Color.SPRING_GREEN)
			_object_roots(true)
		2:
			_box(FLOOR, "A1 FLOOR / OPAQUE / NO CAST SHADOWS", Color.CYAN)
			_box(Rect2(25, 100, 590, 1190), "NAV BOUNDS: NOT A PAINT MASK", Color.YELLOW)
			_object_roots(false)
		3:
			_box(NORTH, "A2 NORTH WALL", Color.DARK_ORANGE)
			_box(LEFT, "A2 LEFT BOUNDARY", Color.DARK_ORANGE)
			_box(RIGHT, "A2 RIGHT BOUNDARY", Color.DARK_ORANGE)
			_box(WINDOW_OPENING, "CUT OUT FOR A3", Color.SPRING_GREEN)
		4:
			_box(WINDOW, "A3 FRAME 64 x 192 WORLD", Color.SPRING_GREEN)
			_box(WINDOW_OPENING, "TRANSPARENT VIEW-THROUGH", Color.CYAN)
			_mark_object("WindowPerch", "PERCH OWNED SEPARATELY")
			_mark_object("Plant", "PLANT OWNED SEPARATELY")
		5:
			_box(SERVICE, "A4 FIXED WALL / NO MACHINES", Color.MAGENTA)
			_box(Rect2(310, 285, 235, 180), "BREW / CUP QUIET ZONE", Color.CYAN)
			for object_name in ["CounterShell", "EspressoStation", "GrinderStation", "POSStation", "PastryCase"]:
				_mark_object(object_name, "INTERACTIVE " + object_name)
		6:
			_box(NAME_SAFE, "BLANK NAME TEXT SAFE", Color.YELLOW)
			_box(MENU_SAFE, "BLANK MENU TEXT SAFE", Color.YELLOW)
			draw_rect(SERVICE, Color.MAGENTA, false, 2.0)
		7:
			_box(NORTH, "FIXED BACK", Color.DARK_ORANGE)
			_box(SERVICE, "FIXED BACK", Color.MAGENTA)
			_box(WINDOW, "FIXED FRAME; EXTERIOR BEHIND", Color.SPRING_GREEN)
			_mark_object("CounterShell", "COUNTER OWNS FRONT LIP")
			_note(Vector2(65, 1260), "NO ROOM-WIDE FRONT MASK / ACTORS KEEP Y-SORT", Color.YELLOW)


func _box(rect: Rect2, label: String, color: Color) -> void:
	draw_rect(rect, Color(color.r, color.g, color.b, 0.11))
	draw_rect(rect, color, false, 2.0)
	var label_at := rect.position + Vector2(3, 15)
	if rect.position.x > 500:
		label_at = Vector2(rect.position.x - 175, rect.position.y + 15)
	_note(label_at, label, color)


func _note(at: Vector2, label: String, color: Color) -> void:
	var font := ThemeDB.fallback_font
	draw_string_outline(font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, 3, Color.BLACK)
	draw_string(font, at, label, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, color)


func _object_roots(all_objects: bool) -> void:
	var names := ["CounterShell", "EspressoStation", "GrinderStation", "POSStation", "PastryCase"]
	if all_objects:
		names.append_array(["TableA", "TableB", "ChairA", "ChairB", "ChairC", "ChairD", "CatBed", "WindowPerch", "Plant", "ScratchPost", "EntranceDoor", "SeasonalDisplay"])
	for i in names.size():
		var node := get_parent().find_child(names[i], true, false) as Node2D
		if node == null:
			continue
		var at := to_local(node.global_position)
		draw_circle(at, 5.0, Color.YELLOW)
		_note(at + Vector2(7, -5), str(i + 1), Color.WHITE)


func _mark_object(object_name: String, label: String) -> void:
	var root := get_parent()
	var node := root.find_child(object_name, true, false) as Node2D
	if node == null:
		return
	var at := to_local(node.global_position)
	draw_circle(at, 4.0, Color.YELLOW)
	var label_at := at + Vector2(6, -4)
	if at.x > 480:
		label_at = at + Vector2(-175, -4)
	_note(label_at, label, Color.WHITE)
