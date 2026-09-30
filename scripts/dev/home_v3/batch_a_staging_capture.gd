extends Node
## Captures only the real Godot viewport of the inherited, locked greybox.

const OUTPUT := "res://artifacts/prototype_review/home_v3_production_art_batch_a_prep_v1/"
const SCENE := "res://scenes/dev/home_v3_production_art_batch_a_staging_v1.tscn"
const SHOTS := [
	["01_locked_home_ownership.png", 1],
	["02_floor_envelope.png", 2],
	["03_wall_shell_envelope.png", 3],
	["04_signature_window.png", 4],
	["05_service_fixed_vs_interactive.png", 5],
	["06_runtime_signage_surfaces.png", 6],
	["07_depth_grouping.png", 7],
	["08_staging_9x16.png", 1],
]


func _ready() -> void:
	if get_viewport() == get_tree().root and OS.get_cmdline_user_args().has("--capture-batch-a"):
		call_deferred("_capture_pack")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F3:
		get_viewport().set_input_as_handled()
		call_deferred("_capture_pack")


func _capture_pack() -> void:
	var dir_error := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	if dir_error != OK:
		push_error("Batch A capture directory failed: %d" % dir_error)
		get_tree().quit(1)
		return
	var guide := get_parent().get_node("BatchAGuide")
	for shot in SHOTS:
		guide.guide_mode = shot[1]
		await get_tree().process_frame
		if not await _save(get_viewport(), shot[0]):
			get_tree().quit(1)
			return
	var tall := SubViewport.new()
	tall.size = Vector2i(539, 1168)
	tall.world_2d = World2D.new()
	tall.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_tree().root.add_child(tall)
	var room := (load(SCENE) as PackedScene).instantiate()
	tall.add_child(room)
	(room.get_node("Camera") as Camera2D).zoom = Vector2(0.84, 0.84)
	room.get_node("BatchAGuide").guide_mode = 1
	await get_tree().process_frame
	await get_tree().process_frame
	var tall_ok := await _save(tall, "09_staging_tall_phone.png")
	tall.queue_free()
	guide.guide_mode = 1
	print("BATCH A STAGING CAPTURE COMPLETE" if tall_ok else "BATCH A STAGING CAPTURE FAILED")
	get_tree().quit(0 if tall_ok else 1)


func _save(source: Viewport, filename: String) -> bool:
	await RenderingServer.frame_post_draw
	var image := source.get_texture().get_image()
	var path := ProjectSettings.globalize_path(OUTPUT + filename)
	var error := image.save_png(path)
	if error != OK:
		push_error("Batch A capture %s failed: %d" % [filename, error])
		return false
	print("BATCH A CAPTURE %s %dx%d" % [filename, image.get_width(), image.get_height()])
	return true
