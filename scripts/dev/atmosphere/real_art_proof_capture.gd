extends Node
## Future proof capture. Refuses placeholder/opaque/incorrect-canvas assets.

@export_dir var output_dir := "res://artifacts/prototype_review/home_v3_real_art_lighting_proof_v1"
@export var capture_dimmed := false
var running := false
var saved: Array[String] = []
@onready var world := get_parent()


func _ready() -> void:
	if "--capture-real-art-proof" in OS.get_cmdline_user_args():
		call_deferred("run_capture")


func run_capture() -> void:
	if running:
		return
	if not world.all_samples_ready():
		push_warning("REAL ART PROOF CAPTURE BLOCKED: all five approved transparent candidates are required")
		print("REAL ART PROOF CAPTURE BLOCKED: candidate art/alpha/canvas incomplete")
		if "--capture-real-art-proof" in OS.get_cmdline_user_args():
			get_tree().quit(2)
		return
	running = true
	_capture_sequence()


func _capture_sequence() -> void:
	saved.clear()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	world.set_camera_shot(&"room")
	world.set_neutral()
	await _save("01_neutral.png")
	world.set_proof_state(&"midday", &"clear", AtmosphereLamp.Override.FORCE_OFF)
	await _save("02_day_clear.png")
	world.set_proof_state(&"sunset", &"clear", AtmosphereLamp.Override.AUTO)
	await _save("03_sunset_clear.png")
	world.set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_OFF)
	await _save("04_night_lamp_off.png")
	world.set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_ON)
	await _save("05_night_lamp_on.png")
	if capture_dimmed:
		world.lamp.set_manual_override(AtmosphereLamp.Override.DIMMED)
		await _save("05b_night_lamp_dimmed.png")
	world.set_proof_state(&"afternoon", &"rain", AtmosphereLamp.Override.AUTO)
	await _save("06_rainy_afternoon.png")
	world.set_proof_state(&"night", &"rain", AtmosphereLamp.Override.FORCE_ON)
	await _save("07_rainy_night_lamp_on.png")
	world.set_camera_shot(&"character")
	await _save("08_character_close.png")
	world.set_proof_state(&"midday", &"clear", AtmosphereLamp.Override.FORCE_OFF)
	world.set_camera_shot(&"window")
	await _save("09a_window_day.png")
	world.set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_OFF)
	await _save("09b_window_night.png")
	world.set_proof_state(&"sunset", &"clear", AtmosphereLamp.Override.FORCE_OFF)
	await _save("09c_window_sunset.png")
	world.set_proof_state(&"afternoon", &"clear", AtmosphereLamp.Override.FORCE_OFF)
	await _save("09d_window_clear.png")
	world.set_proof_state(&"afternoon", &"rain", AtmosphereLamp.Override.AUTO)
	await _save("09e_window_rain.png")
	world.set_camera_shot(&"furniture")
	await _save("10a_chair_shadow_before.png")
	var chair := world.get_node("Furniture/ChairSample") as Node2D
	var original_position := chair.position
	chair.position += Vector2(52, 0)
	await _save("10b_chair_shadow_moved.png")
	chair.position = original_position
	if (chair as RealArtProofSlot).optional_normal_map != null:
		(chair as RealArtProofSlot).use_normal_map = false
		await _save("11a_chair_base_light.png")
		(chair as RealArtProofSlot).use_normal_map = true
		await _save("11b_chair_normal_light.png")
		(chair as RealArtProofSlot).use_normal_map = false
	world.set_camera_shot(&"room")
	print("REAL ART PROOF CAPTURE COMPLETE %d images" % saved.size())
	running = false
	if "--capture-real-art-proof" in OS.get_cmdline_user_args():
		var expected := (17 if (chair as RealArtProofSlot).optional_normal_map != null else 15) \
			+ (1 if capture_dimmed else 0)
		get_tree().quit(0 if saved.size() == expected else 1)


func _save(filename: String) -> void:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var result := get_viewport().get_texture().get_image().save_png(output_dir.path_join(filename))
	if result == OK:
		saved.append(filename)
	else:
		push_error("Real art proof PNG failed: %s code=%d" % [filename, result])
