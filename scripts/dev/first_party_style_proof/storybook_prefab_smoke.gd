extends SceneTree
## Loads every promised reusable first-party target and executes its ready binding.

const BASE := "res://scenes/dev/first_party_style_proof/"
const NAMES := ["willicat_tree_home_01.tscn", "willicat_cafe_chair_home_01.tscn",
	"willicat_cafe_table_round_home_01.tscn", "willicat_cafe_shell_proof_01.tscn",
	"willicat_water_edge_loop_01.tscn", "willicat_coffee_complete_fx_01.tscn",
	"willicat_interaction_button_01.tscn"]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var passed := true
	for name in NAMES:
		var scene := load(BASE + name) as PackedScene
		if scene == null:
			push_error("Missing prefab: " + name)
			passed = false
			continue
		var instance := scene.instantiate()
		root.add_child(instance)
		await process_frame
		print("PREFAB_READY " + name)
		instance.queue_free()
	var actor_scene := load("res://scenes/dev/world_hardening/actor.tscn") as PackedScene
	var visual_scene := load(BASE + "willicat_orange_protagonist_visual_01.tscn") as PackedScene
	if actor_scene == null or visual_scene == null:
		passed = false
	else:
		var actor := actor_scene.instantiate()
		actor.add_child(visual_scene.instantiate())
		root.add_child(actor)
		await process_frame
		print("PREFAB_READY orange_character_visual")
		actor.queue_free()
	for file in ["willicat_grass_tileset_01.tres", "willicat_river_tileset_01.tres", "willicat_river_bank_tileset_01.tres"]:
		if load(BASE + file) == null:
			push_error("Missing TileSet: " + file)
			passed = false
		else:
			print("PREFAB_READY " + file)
	await process_frame
	quit(0 if passed else 1)
