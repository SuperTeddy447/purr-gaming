extends SceneTree
## Candidate visual integration invariants; existing Home tests cover gameplay.

const PREVIEW: PackedScene = preload("res://scenes/dev/home_v2_environment_preview.tscn")
var _failed: bool = false


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var home: HomeScene = PREVIEW.instantiate() as HomeScene
	var slice: VerticalSliceController = home.get_node("VerticalSliceController") as VerticalSliceController
	slice.start_on_ready = false
	root.add_child(home)
	for index in 4:
		await process_frame
	var installer: Node = home.get_node("V2VisualInstaller")
	_check(installer.installed_count == 19, "V2 skin should reuse 19 semantic slots")
	_check((home.get_node("World/StructuralBase/HomeBakedBaseSlot") as HomeAssetSlot).asset_id == &"architecture_home_01",
		"Architecture stable ID must remain unchanged")
	_check((home.get_node("World/DepthSortedLayer") as Node2D).y_sort_enabled,
		"Existing depth owner must remain Y-sorted")
	_check(home.get_node("World/ForegroundOccluderLayer/CounterFrontSlot") is HomeAssetSlot,
		"Counter front remains in the existing foreground layer")
	var anchors: Array[Node] = get_nodes_in_group(&"home_v2_cat_life_anchor")
	_check(anchors.size() == 6, "Six semantic cat-life anchors must exist")
	var ambient: LivingCafeAmbientController = home.get_node("LivingCafeAmbientController") as LivingCafeAmbientController
	_check(ambient.agents.size() == 3, "V2 must reuse the three Living Café cats")
	var explorer: LivingCafeAmbientController.Agent = ambient.agent_for(&"PrototypeCatB")
	var bubble: Node2D = explorer.actor.get_node("ReactionBubbleAnchor/ReactionBubble") as Node2D
	_check(bubble != null and not bubble.visible, "Bubble starts hidden and follows the cat")
	bubble.call("show_reaction", &"question", 0.5)
	_check(bubble.visible, "Semantic reaction appears")
	var steam: Node2D = home.get_node("World/FXLayer/V2EspressoSteam") as Node2D
	_check(not steam.steam_active, "Steam begins inactive")
	steam.call("_on_lifecycle_event", &"worker_prepares")
	_check(steam.steam_active, "Steam uses existing prepare event")
	steam.call("_on_lifecycle_event", &"coffee_prepared")
	_check(not steam.steam_active, "Steam stops on existing prepared event")
	if not _failed:
		print("--- HOME V2 PRODUCTION BATCH 01 INVARIANTS PASSED ---")
	quit(1 if _failed else 0)


func _check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		_failed = true
