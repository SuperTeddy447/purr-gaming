extends SceneTree
## Art-slot registration and inherited-layout guard; no production artwork required.

const LOCKED := preload("res://scenes/dev/home_v3_level_design_pass_01.tscn")
const STAGING := preload("res://scenes/dev/home_v3_production_art_batch_a_staging_v1.tscn")
const SLOTS := {
	"FloorBaseSlot": [Rect2(0, 0, 640, 1320), Vector2i(960, 1980), 0.666667],
	"NorthWallSlot": [Rect2(0, 0, 640, 240), Vector2i(960, 360), 0.666667],
	"LeftBoundarySlot": [Rect2(0, 156, 48, 1110), Vector2i(72, 1665), 0.666667],
	"RightBoundarySlot": [Rect2(592, 156, 48, 1110), Vector2i(72, 1665), 0.666667],
	"ServiceWallSlot": [Rect2(48, 188, 536, 280), Vector2i(804, 420), 0.666667],
	"SignatureWindowSlot": [Rect2(552, 348, 64, 192), Vector2i(256, 768), 0.25],
}

var _ok := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var locked := LOCKED.instantiate() as HomeV3Pass01World
	var staging := STAGING.instantiate() as HomeV3Pass01World
	root.add_child(locked)
	root.add_child(staging)
	await physics_frame
	await physics_frame
	var locked_objects := _objects(locked)
	var staging_objects := _objects(staging)
	_check(locked_objects.size() == 20 and staging_objects.size() == 20,
		"Staging changed stable-object inventory")
	for id in locked_objects:
		_check(staging_objects.has(id), "Staging lost object %s" % id)
		if staging_objects.has(id):
			_check(staging_objects[id].position.is_equal_approx(locked_objects[id].position),
				"Staging moved object %s" % id)
	_check(staging.navigation.walkable_bounds == locked.navigation.walkable_bounds,
		"Staging changed navigation bounds")
	var locked_camera := locked.get_node("Camera") as Camera2D
	var staging_camera := staging.get_node("Camera") as Camera2D
	_check(staging_camera.position == locked_camera.position
		and staging_camera.zoom == locked_camera.zoom
		and staging_camera.limit_left == locked_camera.limit_left
		and staging_camera.limit_right == locked_camera.limit_right
		and staging_camera.limit_top == locked_camera.limit_top
		and staging_camera.limit_bottom == locked_camera.limit_bottom,
		"Staging changed locked camera")
	var slot_root := staging.get_node("Architecture/BatchAArtSlots")
	_check(slot_root.get_child_count() == SLOTS.size(), "Unexpected Batch A slot count")
	for slot_name in SLOTS:
		var node := slot_root.get_node_or_null(slot_name) as Node2D
		_check(node != null, "Missing art slot: %s" % slot_name)
		if node == null:
			continue
		var spec: Array = SLOTS[slot_name]
		var rect := node.get_meta("world_bounds") as Rect2
		var canvas := node.get_meta("source_canvas") as Vector2i
		_check(rect == spec[0] and canvas == spec[1], "Slot metadata mismatch: %s" % slot_name)
		_check(node.position == rect.position, "Slot pivot mismatch: %s" % slot_name)
		var sprite_name := "FrameTexture" if slot_name == "SignatureWindowSlot" else "Texture"
		var sprite := node.get_node(sprite_name) as Sprite2D
		_check(sprite.texture == null and not sprite.centered,
			"Staging slot should be empty and top-left: %s" % slot_name)
		_check(is_equal_approx(sprite.scale.x, spec[2])
			and is_equal_approx(sprite.scale.y, spec[2]),
			"Slot scale mismatch: %s" % slot_name)
		_check((Vector2(canvas) * sprite.scale).is_equal_approx(rect.size),
			"Source canvas does not match world display rect: %s" % slot_name)
	_check(staging.get_node("Architecture/BatchAArtSlots/SignatureWindowSlot/ExteriorBackdrop") != null
		and staging.get_node("Architecture/BatchAArtSlots/SignatureWindowSlot/WeatherOverlay") != null
		and staging.get_node("Architecture/BatchAArtSlots/SignatureWindowSlot/GlassOverlay") != null
		and staging.get_node("Architecture/BatchAArtSlots/SignatureWindowSlot/WindowLightContribution") != null,
		"Window runtime attachment points missing")
	locked.queue_free()
	staging.queue_free()
	await process_frame
	if _ok:
		print("--- HOME V3 BATCH A PREP V1 PASSED ---")
	quit(0 if _ok else 1)


func _objects(world: Node) -> Dictionary:
	var result := {}
	_collect(world, result)
	return result


func _collect(node: Node, result: Dictionary) -> void:
	if node is HardeningWorldObject:
		var object := node as HardeningWorldObject
		result[object.stable_id] = object
	for child in node.get_children():
		_collect(child, result)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_ok = false
		push_error(message)
