class_name PrototypeTimingConfig
extends Resource
## Small, centralized timing set for the Home functional prototype.

@export_enum("NORMAL", "FAST") var preset: String = "NORMAL"
@export_range(0.01, 10.0, 0.01) var customer_order_delay: float = 0.8
@export_range(0.0, 10.0, 0.01) var customer_arrival_pause: float = 0.18
@export_range(0.01, 10.0, 0.01) var coffee_preparation_duration: float = 2.0
@export_range(0.01, 10.0, 0.01) var serve_duration: float = 0.45
@export_range(0.01, 10.0, 0.01) var served_reaction_duration: float = 1.3
@export_range(0.0, 10.0, 0.01) var customer_exit_delay: float = 0.18
@export_range(0.01, 10.0, 0.01) var door_hold_open_duration: float = 0.35
@export_range(0.01, 5.0, 0.01) var door_transition_duration: float = 0.18
@export_range(0.01, 20.0, 0.01) var next_customer_delay: float = 3.0
@export_range(0.05, 1.0, 0.05) var fast_multiplier: float = 0.2


func resolve_duration(normal_duration: float) -> float:
	var multiplier: float = fast_multiplier if preset == "FAST" else 1.0
	return maxf(normal_duration * multiplier, 0.001)


func toggle_preset() -> void:
	preset = "FAST" if preset == "NORMAL" else "NORMAL"


func set_preset(next_preset: String) -> void:
	if next_preset in ["NORMAL", "FAST"]:
		preset = next_preset


func duplicate_for_testing() -> PrototypeTimingConfig:
	return duplicate(true) as PrototypeTimingConfig
