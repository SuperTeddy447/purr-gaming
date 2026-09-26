class_name CharacterPlaceholder
extends Node2D
## Visual placeholder character to verify scale, foot-pivot Y-sorting,
## counter occlusion, and camera behavior in Foundation V1.
## Structured with foot-pivot at (0, 0) for seamless drop-in replacement
## with AnimatedSprite2D character scenes later.

@export_group("Character Info")
@export var character_id: StringName = &"worker_01"
@export var character_name: String = "Barista Cat"
@export_enum("Worker", "Customer", "Ambient") var role: String = "Worker"
@export var facing_right: bool = true:
	set(value):
		facing_right = value
		queue_redraw()

@export_group("Visuals")
@export var primary_color: Color = Color(0.96, 0.65, 0.35) # Warm cat orange
@export var secondary_color: Color = Color(0.98, 0.94, 0.88) # Cream
@export var accent_color: Color = Color(0.18, 0.35, 0.28) # Barista green apron
@export var character_scale: float = 1.0
@export var idle_bob_enabled: bool = true
@export var show_role_badge: bool = true

var _time_elapsed: float = 0.0


func _ready() -> void:
	# Randomize phase so characters don't bob in sync
	_time_elapsed = randf() * TAU
	queue_redraw()


func _process(delta: float) -> void:
	if idle_bob_enabled:
		_time_elapsed += delta * 3.0
		queue_redraw()


func _draw() -> void:
	var flip: float = 1.0 if facing_right else -1.0
	var bob_offset: float = sin(_time_elapsed) * 2.0 if idle_bob_enabled else 0.0

	# Dimensions (proportional to ~130px tall cat in reference design coordinate space)
	var body_w: float = 38.0 * character_scale
	var body_h: float = 70.0 * character_scale
	var head_r: float = 28.0 * character_scale

	# Foot shadow on floor (centered at foot pivot (0, 0))
	var shadow_radius_x: float = body_w * 0.8
	var shadow_radius_y: float = 8.0 * character_scale
	var shadow_points := PackedVector2Array()
	for i in range(24):
		var angle: float = TAU * float(i) / 24.0
		shadow_points.append(Vector2(cos(angle) * shadow_radius_x, sin(angle) * shadow_radius_y))
	draw_colored_polygon(shadow_points, Color(0.05, 0.05, 0.05, 0.35))

	# Bob the character art while keeping the floor shadow and Y-sort foot pivot stable.
	draw_set_transform(Vector2(0.0, bob_offset), 0.0, Vector2.ONE)

	# Body (standing upwards from feet at Y=0 towards Y=-body_h)
	var body_rect: Rect2 = Rect2(-body_w * 0.5, -body_h, body_w, body_h)
	draw_rect(body_rect, primary_color, true)

	# Apron / clothes if worker or customer
	if role == "Worker":
		var apron_rect: Rect2 = Rect2(-body_w * 0.45, -body_h * 0.75, body_w * 0.9, body_h * 0.6)
		draw_rect(apron_rect, accent_color, true)
		# Paw badge on apron
		draw_circle(Vector2(0, -body_h * 0.45), 5.0 * character_scale, Color(0.9, 0.85, 0.4))
	elif role == "Customer":
		var scarf_rect: Rect2 = Rect2(-body_w * 0.5, -body_h * 0.95, body_w, 12.0 * character_scale)
		draw_rect(scarf_rect, Color(0.85, 0.3, 0.35), true)

	# Head (center at Y = -body_h - head_r * 0.7)
	var head_center: Vector2 = Vector2(0.0, -body_h - head_r * 0.7)
	draw_circle(head_center, head_r, primary_color)

	# Ears
	var ear_left: PackedVector2Array = [
		head_center + Vector2(-head_r * 0.75 * flip, -head_r * 0.4),
		head_center + Vector2(-head_r * 0.5 * flip, -head_r * 1.35),
		head_center + Vector2(-head_r * 0.1 * flip, -head_r * 0.85)
	]
	var ear_right: PackedVector2Array = [
		head_center + Vector2(head_r * 0.1 * flip, -head_r * 0.85),
		head_center + Vector2(head_r * 0.5 * flip, -head_r * 1.35),
		head_center + Vector2(head_r * 0.75 * flip, -head_r * 0.4)
	]
	draw_colored_polygon(ear_left, primary_color)
	draw_colored_polygon(ear_right, primary_color)

	# Eyes
	var eye_offset_x: float = head_r * 0.35 * flip
	var eye_y: float = head_center.y - 2.0 * character_scale
	draw_circle(Vector2(eye_offset_x - 6.0 * flip, eye_y), 3.5 * character_scale, Color.BLACK)
	draw_circle(Vector2(eye_offset_x + 6.0 * flip, eye_y), 3.5 * character_scale, Color.BLACK)
	# Eye highlights
	draw_circle(Vector2(eye_offset_x - 5.0 * flip, eye_y - 1.0), 1.2 * character_scale, Color.WHITE)
	draw_circle(Vector2(eye_offset_x + 7.0 * flip, eye_y - 1.0), 1.2 * character_scale, Color.WHITE)

	# Muzzle & Nose
	draw_circle(Vector2(eye_offset_x, eye_y + 8.0 * character_scale), 6.0 * character_scale, secondary_color)
	draw_circle(Vector2(eye_offset_x, eye_y + 6.0 * character_scale), 2.0 * character_scale, Color(0.9, 0.4, 0.5))

	if show_role_badge:
		var badge_y: float = head_center.y - head_r - 12.0 * character_scale
		var badge_text: String = "[%s] %s" % [role, character_name]
		draw_string(ThemeDB.fallback_font, Vector2(-70.0, badge_y), badge_text,
			HORIZONTAL_ALIGNMENT_CENTER, 140.0, 11, Color(1.0, 1.0, 1.0, 0.9))

	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
