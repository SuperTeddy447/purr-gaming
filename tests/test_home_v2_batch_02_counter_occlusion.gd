extends SceneTree
## Guard the V2 floor-contact correction without changing the locked Home base.

const PREVIEW: PackedScene = preload("res://scenes/dev/home_v2_environment_preview.tscn")
const BASE: PackedScene = preload("res://scenes/home/home_scene.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var base: HomeScene = BASE.instantiate() as HomeScene
	if not _check(base.get_node("GameplayNodes/CoffeeAction").position == Vector2(402, 445), "Base Home CoffeeAction changed"):
		quit(1)
		return
	base.free()
	var home: HomeScene = PREVIEW.instantiate() as HomeScene
	root.add_child(home)
	await process_frame
	await process_frame
	var coffee: Marker2D = home.get_node("GameplayNodes/CoffeeAction") as Marker2D
	var idle: Marker2D = home.get_node("GameplayNodes/WorkerIdle") as Marker2D
	var rear: Marker2D = home.get_node("SliceWaypoints/CounterExitRear") as Marker2D
	var back: HomeAssetSlot = home.get_node("World/BackDecorLayer/CounterBackSlot") as HomeAssetSlot
	var front: HomeAssetSlot = home.get_node("World/ForegroundOccluderLayer/CounterFrontSlot") as HomeAssetSlot
	var worker: Node2D = home.get_node("World/DepthSortedLayer/MochiScaleTestDEV") as Node2D
	var valid: bool = true
	valid = _check(coffee.position == Vector2(402, 525), "CoffeeAction floor anchor") and valid
	valid = _check(idle.position == Vector2(620, 525), "WorkerIdle floor anchor") and valid
	valid = _check(rear.position == Vector2(165, 525), "Rear exit floor corridor") and valid
	valid = _check(back.position == Vector2(465, 520) and front.position == Vector2(465, 625), "Counter modules moved") and valid
	valid = _check(back.get_parent().z_index < worker.get_parent().z_index and worker.get_parent().z_index < front.get_parent().z_index, "Locked layer order changed") and valid
	valid = _check(front.visual_node != null and front.visual_node.get_child_count() == 1, "Counter front texture missing") and valid
	if valid:
		var sprite: Sprite2D = front.visual_node.get_child(0) as Sprite2D
		valid = _check(sprite != null and sprite.texture != null, "Counter front sprite missing") and valid
		if sprite != null and sprite.texture != null:
			var image: Image = sprite.texture.get_image()
			var world_left: float = front.global_position.x - image.get_width() * sprite.scale.x * 0.5
			var world_top: float = front.global_position.y - image.get_height() * sprite.scale.y
			for marker in [coffee, idle]:
				var sample_x: int = roundi((marker.global_position.x - world_left) / sprite.scale.x)
				var sample_y: int = roundi((marker.global_position.y - world_top) / sprite.scale.y)
				valid = _check(sample_x >= 0 and sample_x < image.get_width() and sample_y >= 0 and sample_y < image.get_height(), "Worker root outside front canvas") and valid
				if sample_x >= 0 and sample_x < image.get_width() and sample_y >= 0 and sample_y < image.get_height():
					valid = _check(image.get_pixel(sample_x, sample_y).a > 0.7, "Counter front not opaque at worker feet") and valid
	home.queue_free()
	await process_frame
	if valid:
		print("--- HOME V2 BATCH 02 COUNTER OCCLUSION PASSED ---")
	quit(0 if valid else 1)


func _check(condition: bool, reason: String) -> bool:
	if not condition:
		push_error(reason)
	return condition
