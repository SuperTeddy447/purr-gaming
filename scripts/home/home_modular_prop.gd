class_name HomeModularProp
extends Node2D
## Clean geometry-only TEMP V0 art. Replace this scene's visual with a texture
## or production PackedScene through HomeAssetDefinition without moving anchors.

const WALL: Color = Color("#e7b979")
const WALL_LIGHT: Color = Color("#f2ce91")
const JADE: Color = Color("#29483f")
const JADE_LIGHT: Color = Color("#3d6655")
const JADE_DARK: Color = Color("#1e3832")
const WOOD: Color = Color("#9b5d34")
const WOOD_LIGHT: Color = Color("#d18a48")
const BRASS: Color = Color("#e7ad48")
const CREAM: Color = Color("#f7e4bd")
const SHADOW: Color = Color("#5b382d")

var definition: HomeAssetDefinition
var variant: StringName = &"default"
var label: String = ""
var _debug_label_visible: bool = false
var _tint: Color = Color.WHITE
var _tint_enabled: bool = false


func configure(asset_definition: HomeAssetDefinition, visual_variant: StringName, debug_label: String = "") -> void:
	definition = asset_definition
	variant = visual_variant
	label = debug_label if not debug_label.is_empty() else asset_definition.display_name.to_upper()
	queue_redraw()


func set_debug_label_visible(is_visible: bool) -> void:
	_debug_label_visible = is_visible
	queue_redraw()


func set_tint(color: Color) -> void:
	_tint = color
	_tint_enabled = true
	queue_redraw()


func occlusion_regions_local() -> Array[Rect2]:
	if variant == &"counter_front":
		return [Rect2(-280.0, -218.0, 560.0, 22.0), Rect2(-270.0, -190.0, 540.0, 197.0)]
	return []


func _draw() -> void:
	if definition == null:
		return
	match String(variant):
		"architecture":
			_draw_architecture()
		"counter_back":
			_draw_counter_back()
		"counter_front":
			_draw_counter_front()
		"espresso":
			_draw_espresso()
		"grinder":
			_draw_grinder()
		"pos":
			_draw_pos()
		"pastry_case":
			_draw_pastry_case()
		"croissant":
			_draw_pastry(Color("#d68739"), "croissant")
		"muffin":
			_draw_pastry(Color("#9a5638"), "muffin")
		"tart":
			_draw_pastry(Color("#d5a64b"), "tart")
		"round_table":
			_draw_table()
		"chair_left", "chair_right":
			_draw_chair()
		"plant_floor", "plant_counter":
			_draw_plant()
		"vase":
			_draw_vase()
		"door_left", "door_right":
			_draw_door_leaf()
		"entrance_frame":
			_draw_entrance_frame()
		"sign_main", "sign_hanging", "sign_menu", "sign_freestanding":
			_draw_sign()
		"pastry_glass_front":
			_draw_pastry_glass_front()
	if _debug_label_visible and not label.is_empty():
		draw_string(ThemeDB.fallback_font, Vector2(-65.0, -8.0), label, HORIZONTAL_ALIGNMENT_LEFT, 150.0, 12, Color("#fff6d8"))


func _draw_architecture() -> void:
	# 941x1672 is the composition canvas. Only fixed architecture and surfaces live here.
	draw_rect(Rect2(0, 0, 941, 1672), Color("#d69a60"))
	draw_rect(Rect2(0, 0, 941, 680), WALL)
	draw_rect(Rect2(0, 0, 941, 26), JADE)
	draw_rect(Rect2(0, 26, 941, 10), BRASS)
	# Fixed framed work wall, deliberately empty of signs and equipment.
	draw_rect(Rect2(182, 22, 382, 326), JADE_DARK)
	draw_rect(Rect2(194, 34, 358, 302), BRASS)
	draw_rect(Rect2(202, 42, 342, 286), JADE)
	draw_rect(Rect2(214, 54, 318, 238), Color("#3a3028"))
	draw_rect(Rect2(214, 296, 318, 32), JADE_LIGHT)
	draw_rect(Rect2(0, 345, 941, 145), WALL_LIGHT)
	# Tile backsplash; no objects, logos or copy baked into the architecture.
	for x in range(194, 761, 48):
		draw_line(Vector2(x, 354), Vector2(x, 484), Color("#d7b57c"), 2.0)
	for y in [386, 418, 450, 482]:
		draw_line(Vector2(188, y), Vector2(764, y), Color("#d7b57c"), 2.0)
	draw_rect(Rect2(0, 490, 941, 16), JADE)
	# Side wall paneling and the right-hand bright stair/arch passage.
	draw_rect(Rect2(0, 506, 152, 174), JADE)
	for y in range(522, 680, 38):
		draw_line(Vector2(0, y), Vector2(152, y), JADE_LIGHT, 3.0)
	draw_rect(Rect2(791, 0, 150, 680), Color("#f0bf79"))
	draw_rect(Rect2(782, 0, 16, 680), JADE)
	draw_rect(Rect2(922, 0, 19, 680), JADE)
	for i in range(7):
		var y: float = 150.0 + float(i) * 67.0
		draw_rect(Rect2(800.0 + float(i) * 4.0, y, 141.0 - float(i) * 4.0, 10.0), WOOD_LIGHT)
	# Floor transition and subtle plank rhythm.
	draw_rect(Rect2(0, 680, 941, 18), WOOD)
	for y in range(698, 1672, 88):
		draw_line(Vector2(0, y), Vector2(941, y), Color("#bd8150", 0.55), 2.0)
		var offset: float = 0.0 if (y / 88) % 2 == 0 else 110.0
		for x in range(-1, 11):
			var plank_x: float = float(x) * 150.0 + offset
			draw_line(Vector2(plank_x, y), Vector2(plank_x, y + 88), Color("#bd8150", 0.45), 1.5)
	# A quiet rug footprint anchors the counter but remains a separate surface treatment.
	draw_rect(Rect2(202, 765, 540, 145), JADE_DARK)
	draw_rect(Rect2(211, 774, 522, 127), Color("#385447"))
	draw_rect(Rect2(222, 785, 500, 105), Color("#385447"), false, 2.0)
	# Fixed door opening / wall threshold; the actual leaves remain modular.
	draw_rect(Rect2(222, 1288, 408, 384), JADE_DARK)
	draw_rect(Rect2(237, 1304, 378, 368), Color("#8e6240"))
	draw_rect(Rect2(255, 1322, 342, 350), Color("#e7bd7d"))
	draw_rect(Rect2(222, 1288, 408, 18), BRASS)
	draw_rect(Rect2(222, 1288, 16, 384), JADE)
	draw_rect(Rect2(614, 1288, 16, 384), JADE)


func _draw_counter_back() -> void:
	var jade: Color = JADE_LIGHT.lerp(_tint, 0.65) if _tint_enabled else JADE_LIGHT
	draw_rect(Rect2(-270, -26, 540, 136), SHADOW)
	draw_rect(Rect2(-264, -35, 528, 118), jade)
	draw_rect(Rect2(-264, -35, 528, 12), JADE_DARK)
	draw_rect(Rect2(-264, 73, 528, 10), WOOD)
	for x in [-200.0, -70.0, 70.0, 200.0]:
		draw_rect(Rect2(x - 42, -8, 84, 68), JADE_DARK)
		draw_rect(Rect2(x - 37, -3, 74, 58), jade)
	draw_rect(Rect2(-270, -77, 540, 45), WOOD)
	draw_rect(Rect2(-270, -80, 540, 9), WOOD_LIGHT)


func _draw_counter_front() -> void:
	var jade: Color = JADE.lerp(_tint, 0.72) if _tint_enabled else JADE
	# Top edge crosses the CoffeeAction floor pivot so the front covers the lower
	# character silhouette while leaving the head and upper body visible.
	draw_rect(Rect2(-280, -210, 560, 28), SHADOW)
	draw_rect(Rect2(-280, -218, 560, 22), WOOD_LIGHT)
	draw_rect(Rect2(-270, -190, 540, 197), jade)
	draw_rect(Rect2(-270, -190, 540, 14), JADE_LIGHT)
	draw_rect(Rect2(-270, -10, 540, 13), WOOD)
	for x in [-198.0, -65.0, 68.0, 201.0]:
		draw_rect(Rect2(x - 55, -158, 110, 88), JADE_DARK)
		draw_rect(Rect2(x - 49, -152, 98, 76), jade)
		draw_rect(Rect2(x - 45, -148, 90, 68), WOOD_LIGHT, false, 1.0)
	draw_rect(Rect2(-276, -3, 552, 10), WOOD_LIGHT)


func _draw_espresso() -> void:
	draw_rect(Rect2(-55, -118, 110, 112), SHADOW)
	draw_rect(Rect2(-53, -126, 106, 111), JADE_DARK)
	draw_rect(Rect2(-47, -120, 94, 53), JADE_LIGHT)
	draw_rect(Rect2(-41, -112, 82, 28), JADE)
	for x in [-26.0, 0.0, 26.0]:
		draw_circle(Vector2(x, -98), 5.0, BRASS)
	draw_rect(Rect2(-43, -66, 86, 7), BRASS)
	draw_rect(Rect2(-37, -58, 74, 27), Color("#514439"))
	for x in [-25.0, 24.0]:
		draw_line(Vector2(x, -54), Vector2(x * 1.25, -23), WOOD_LIGHT, 4.0)
	draw_rect(Rect2(-32, -20, 64, 10), JADE_LIGHT)
	draw_rect(Rect2(-49, -14, 98, 10), WOOD)


func _draw_grinder() -> void:
	draw_rect(Rect2(-35, -92, 70, 89), SHADOW)
	draw_rect(Rect2(-31, -85, 62, 79), JADE_DARK)
	draw_rect(Rect2(-27, -78, 54, 44), Color("#3b3530"))
	draw_colored_polygon(PackedVector2Array([Vector2(-26, -106), Vector2(26, -106), Vector2(18, -80), Vector2(-18, -80)]), Color("#47392d"))
	draw_rect(Rect2(-20, -121, 40, 16), Color("#5b4835"))
	draw_circle(Vector2(0, -48), 7.0, BRASS)
	draw_rect(Rect2(-21, -6, 42, 7), WOOD)


func _draw_pos() -> void:
	draw_rect(Rect2(-36, -65, 72, 63), WOOD)
	draw_rect(Rect2(-31, -61, 62, 50), JADE_DARK)
	draw_rect(Rect2(-27, -56, 54, 35), Color("#d5c6a5"))
	draw_line(Vector2(-23, -49), Vector2(22, -49), JADE, 3.0)
	draw_line(Vector2(-23, -39), Vector2(10, -39), JADE_LIGHT, 2.0)
	draw_rect(Rect2(-34, -7, 68, 8), BRASS)


func _draw_pastry_case() -> void:
	draw_rect(Rect2(-98, -136, 196, 139), SHADOW)
	draw_rect(Rect2(-93, -139, 186, 132), JADE_DARK)
	draw_rect(Rect2(-82, -130, 164, 103), Color("#f0cc8d", 0.42))
	draw_rect(Rect2(-82, -27, 164, 12), WOOD_LIGHT)
	draw_rect(Rect2(-94, -11, 188, 12), JADE)
	draw_rect(Rect2(-94, -4, 188, 7), WOOD)
	draw_line(Vector2(-82, -80), Vector2(82, -80), BRASS, 3.0)
	draw_line(Vector2(-82, -47), Vector2(82, -47), BRASS, 3.0)
	draw_line(Vector2(-90, -127), Vector2(-90, -12), WOOD_LIGHT, 4.0)
	draw_line(Vector2(90, -127), Vector2(90, -12), WOOD_LIGHT, 4.0)


func _draw_pastry(color: Color, shape: String) -> void:
	if shape == "croissant":
		draw_arc(Vector2.ZERO, 16.0, PI, TAU, 14, WOOD, 9.0, true)
		draw_line(Vector2(-13, -2), Vector2(-7, -9), CREAM, 2.0)
		draw_line(Vector2(2, -10), Vector2(8, -2), CREAM, 2.0)
	elif shape == "muffin":
		draw_rect(Rect2(-13, -11, 26, 20), WOOD)
		draw_circle(Vector2(0, -12), 13.0, color)
		draw_circle(Vector2(-5, -15), 2.2, CREAM)
		draw_circle(Vector2(4, -8), 2.0, Color("#8e4e32"))
	else:
		draw_circle(Vector2.ZERO, 14.0, WOOD)
		draw_circle(Vector2(0, -2), 11.0, color)
		draw_circle(Vector2.ZERO, 4.0, Color("#f1d27a"))
	draw_line(Vector2(-18, 8), Vector2(18, 8), WOOD, 3.0)


func _draw_table() -> void:
	draw_ellipse_shape(Vector2(0, -7), Vector2(71, 20), Color("#60402d", 0.35))
	draw_rect(Rect2(-9, -45, 18, 42), SHADOW)
	draw_ellipse_shape(Vector2(0, -3), Vector2(33, 11), JADE_DARK)
	draw_ellipse_shape(Vector2(0, -58), Vector2(70, 21), WOOD)
	draw_ellipse_shape(Vector2(0, -64), Vector2(70, 19), WOOD_LIGHT)
	draw_arc(Vector2(0, -64), 56.0, PI + 0.1, TAU - 0.1, 22, Color("#e3a35b"), 2.0, true)


func _draw_chair() -> void:
	var direction: float = -1.0 if variant == &"chair_left" else 1.0
	var seat_x: float = 5.0 * direction
	draw_rect(Rect2(seat_x - 25, -42, 50, 34), WOOD)
	draw_rect(Rect2(seat_x - 22, -45, 44, 27), JADE)
	draw_rect(Rect2(seat_x - 25, -80, 16, 42), WOOD)
	draw_rect(Rect2(seat_x - 21, -77, 10, 34), JADE_LIGHT)
	draw_rect(Rect2(seat_x + 12, -12, 9, 12), WOOD)
	draw_line(Vector2(seat_x - 18, -12), Vector2(seat_x - 22, 0), WOOD, 5.0)
	draw_line(Vector2(seat_x + 18, -12), Vector2(seat_x + 22, 0), WOOD, 5.0)


func _draw_plant() -> void:
	var floor_plant: bool = variant == &"plant_floor"
	var pot_width: float = 52.0 if floor_plant else 36.0
	var pot_height: float = 42.0 if floor_plant else 30.0
	draw_ellipse_shape(Vector2(0, -2), Vector2(pot_width * 0.85, 7), Color("#49362d", 0.25))
	draw_colored_polygon(PackedVector2Array([Vector2(-pot_width * 0.5, -pot_height), Vector2(pot_width * 0.5, -pot_height), Vector2(pot_width * 0.38, -2), Vector2(-pot_width * 0.38, -2)]), Color("#bd774b"))
	draw_rect(Rect2(-pot_width * 0.54, -pot_height - 5, pot_width * 1.08, 8), WOOD_LIGHT)
	var leaf_color: Color = Color("#356c45")
	for i in range(8):
		var angle: float = -PI * 0.78 + float(i) * 0.22
		var tip: Vector2 = Vector2(cos(angle) * (40.0 if floor_plant else 28.0), -pot_height - sin(absf(angle) + 0.75) * (80.0 if floor_plant else 56.0))
		var base: Vector2 = Vector2(0, -pot_height - 2)
		draw_line(base, tip, leaf_color, 7.0 if floor_plant else 5.0)
		draw_ellipse_shape(tip, Vector2(10.0, 5.0), JADE_LIGHT)


func _draw_vase() -> void:
	draw_rect(Rect2(-6, -43, 12, 12), WOOD_LIGHT)
	draw_colored_polygon(PackedVector2Array([Vector2(-6, -34), Vector2(6, -34), Vector2(19, -7), Vector2(14, 0), Vector2(-14, 0), Vector2(-19, -7)]), Color("#688b65"))
	draw_line(Vector2(-13, -7), Vector2(13, -7), BRASS, 2.0)


func _draw_door_leaf() -> void:
	var side: float = -1.0 if variant == &"door_left" else 1.0
	var x: float = -75.0 if side < 0.0 else 0.0
	draw_rect(Rect2(x, -155, 75, 155), JADE_DARK)
	draw_rect(Rect2(x + 6, -149, 63, 143), WOOD)
	draw_rect(Rect2(x + 11, -144, 53, 62), Color("#e5bd7b"))
	draw_rect(Rect2(x + 11, -72, 53, 60), Color("#e5bd7b"))
	draw_rect(Rect2(x + (58.0 if side < 0.0 else 10.0), -78, 4, 8), BRASS)


func _draw_entrance_frame() -> void:
	draw_rect(Rect2(-213, -344, 426, 20), JADE_DARK)
	draw_rect(Rect2(-205, -336, 410, 10), BRASS)
	draw_rect(Rect2(-213, -344, 18, 360), JADE_DARK)
	draw_rect(Rect2(195, -344, 18, 360), JADE_DARK)
	draw_rect(Rect2(-195, -328, 10, 334), WOOD_LIGHT)
	draw_rect(Rect2(185, -328, 10, 334), WOOD_LIGHT)
	draw_rect(Rect2(-224, -2, 448, 16), WOOD)


func _draw_sign() -> void:
	var bounds: Rect2
	match String(variant):
		"sign_main": bounds = Rect2(-175, -65, 350, 130)
		"sign_hanging": bounds = Rect2(-75, -35, 150, 70)
		"sign_menu": bounds = Rect2(-80, -52, 160, 104)
		_: bounds = Rect2(-65, -170, 130, 150)
	draw_rect(bounds.grow(6), JADE_DARK)
	draw_rect(bounds, Color("#3b3029"))
	draw_rect(bounds.grow(-8), BRASS, false, 3.0)
	if variant == &"sign_freestanding":
		draw_line(Vector2(-48, -19), Vector2(-55, 0), WOOD, 9.0)
		draw_line(Vector2(48, -19), Vector2(55, 0), WOOD, 9.0)
	if variant == &"sign_hanging":
		draw_line(Vector2(-38, -48), Vector2(-38, -35), BRASS, 3.0)
		draw_line(Vector2(38, -48), Vector2(38, -35), BRASS, 3.0)


func _draw_pastry_glass_front() -> void:
	draw_rect(Rect2(-88, -132, 176, 110), Color("#e3f0e9", 0.12))
	draw_line(Vector2(-87, -131), Vector2(-70, -22), Color("#fff1d2", 0.58), 3.0)
	draw_line(Vector2(87, -131), Vector2(70, -22), Color("#fff1d2", 0.58), 3.0)


func draw_ellipse_shape(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(32):
		var angle: float = TAU * float(i) / 32.0
		points.append(center + Vector2(cos(angle) * radius.x, sin(angle) * radius.y))
	draw_colored_polygon(points, color)
