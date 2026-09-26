class_name MochiLayeredIdleConfig
extends Resource
## Timing and registration contract for Mochi's layered procedural idle.

@export_group("Breathing")
@export_range(0.0, 0.02, 0.0005) var breathing_amount: float = 0.002
@export_range(1.0, 12.0, 0.1) var breathing_period: float = 4.8

@export_group("Blink")
@export_range(1.0, 20.0, 0.1) var blink_interval_min: float = 3.2
@export_range(1.0, 30.0, 0.1) var blink_interval_max: float = 6.4
@export_range(0.01, 0.3, 0.005) var blink_half_duration: float = 0.075
@export_range(0.01, 0.3, 0.005) var blink_closed_duration: float = 0.08

@export_group("Tail")
@export_range(1.0, 40.0, 0.1) var tail_interval_min: float = 6.0
@export_range(1.0, 60.0, 0.1) var tail_interval_max: float = 11.0
@export_range(-12.0, 0.0, 0.1) var tail_angle_min_degrees: float = -3.0
@export_range(0.0, 12.0, 0.1) var tail_angle_max_degrees: float = 3.0
@export_range(0.05, 2.0, 0.01) var tail_motion_duration: float = 0.42
@export_range(0.05, 2.0, 0.01) var tail_return_duration: float = 0.58

@export_group("Ear")
@export_range(1.0, 60.0, 0.1) var ear_interval_min: float = 10.0
@export_range(1.0, 90.0, 0.1) var ear_interval_max: float = 19.0
@export_range(-8.0, 8.0, 0.1) var ear_angle_degrees: float = 2.0
@export_range(0.03, 1.0, 0.01) var ear_twitch_duration: float = 0.12
@export_range(0.05, 1.0, 0.01) var ear_return_duration: float = 0.24

@export_group("Profiles and determinism")
@export_range(1.0, 3.0, 0.05) var ambient_activity_multiplier: float = 1.4
@export var rng_seed: int = 734021

@export_group("Layer artwork")
@export var body_base_texture: Texture2D
@export var tail_texture: Texture2D
@export var ear_twitch_texture: Texture2D
@export var eyes_open_texture: Texture2D
@export var eyes_half_texture: Texture2D
@export var eyes_closed_texture: Texture2D

## Sprite2D offsets are measured from Mochi's floor-contact origin. For trimmed
## PNGs, include the source crop's placement in these registration values.
@export var body_base_offset: Vector2 = Vector2.ZERO
@export var tail_pivot_position: Vector2 = Vector2(-44.0, -205.0)
@export var tail_sprite_offset: Vector2 = Vector2.ZERO
@export var ear_pivot_position: Vector2 = Vector2(12.0, -410.0)
@export var ear_sprite_offset: Vector2 = Vector2.ZERO
@export var eyes_patch_position: Vector2 = Vector2.ZERO
@export var eyes_sprite_offset: Vector2 = Vector2.ZERO
