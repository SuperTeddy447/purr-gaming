class_name AmbientTimingConfig
extends Resource
## Development-only pacing for the Living Café prototype.

@export var deterministic_seed: int = 41021
@export_range(0.1, 30.0, 0.1) var idle_min: float = 3.0
@export_range(0.1, 30.0, 0.1) var idle_max: float = 7.0
@export_range(0.1, 30.0, 0.1) var activity_min: float = 4.0
@export_range(0.1, 30.0, 0.1) var activity_max: float = 9.0
@export_range(0.1, 20.0, 0.1) var roam_delay: float = 2.0
@export_range(0.1, 10.0, 0.1) var social_duration: float = 1.5
@export_range(1.0, 1000.0, 1.0) var ambient_move_speed: float = 105.0


func duration(rng: RandomNumberGenerator, minimum: float, maximum: float) -> float:
	return rng.randf_range(minimum, maxf(minimum, maximum))
