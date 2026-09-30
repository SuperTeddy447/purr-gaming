extends SceneTree
## Vignette registration proof; visual judgement comes from the Godot capture pack.

const BASE := preload("res://scenes/dev/home_v3_real_art_lighting_proof_v1.tscn")
const REVISION := preload("res://scenes/dev/home_v3_real_art_lighting_proof_revision_v1.tscn")
var _ok := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var base := BASE.instantiate()
	var revised := REVISION.instantiate()
	root.add_child(base)
	root.add_child(revised)
	await process_frame
	_check(not revised is HomeV3World, "Revision instantiated production Home")
	_check(base.get_node("Architecture/ArchitectureSample").position == Vector2(340, 350),
		"Original V1 proof was moved")
	_check(base.get_node("Architecture/WindowSample").position == Vector2(585, 446),
		"Original V1 window was moved")
	_check(base.all_samples_ready() and revised.all_samples_ready(),
		"Both proof scenes must keep the five-asset capture guard")
	var paths := ["Architecture/ArchitectureSample", "Architecture/WindowSample",
		"Architecture/PracticalLamp/LampSample", "Furniture/ChairSample",
		"Characters/OrangeProtagonistSample"]
	for path in paths:
		var a := base.get_node(path) as RealArtProofSlot
		var b := revised.get_node(path) as RealArtProofSlot
		_check(a.candidate_texture == b.candidate_texture and b.is_ready_for_capture(),
			"Revision changed the approved texture/canvas: %s" % path)
	var architecture := revised.get_node(paths[0]) as RealArtProofSlot
	var window := revised.get_node(paths[1]) as RealArtProofSlot
	var lamp := revised.get_node("Architecture/PracticalLamp") as AtmosphereLamp
	var chair := revised.get_node(paths[3]) as RealArtProofSlot
	var cat := revised.get_node(paths[4]) as RealArtProofSlot
	_check(architecture.position == Vector2(320, 500) and architecture.world_scale == 0.55,
		"Micro-room wall registration drifted")
	_check(window.position == Vector2(495, 330) and window.world_scale == 0.32,
		"Window no longer shares the representative wall")
	_check(lamp.position == Vector2(235, 310) and lamp.radius == 210.0,
		"Practical light no longer mounts above the wall rail")
	_check(chair.position == Vector2(420, 552) and cat.position == Vector2(300, 550),
		"Chair/cat no longer share the representative floor")
	var ratio := (186.0 * chair.world_scale) / (368.0 * cat.world_scale)
	_check(ratio >= 0.30 and ratio <= 0.45,
		"Chair/cat visible ratio left the locked handoff band")
	_check(revised.get_node("Camera").zoom == Vector2(2.7, 2.7),
		"Revision camera framing drifted")
	var capture := revised.get_node("CaptureHarness")
	_check(capture.capture_dimmed and capture.output_dir.ends_with("home_v3_real_art_lighting_proof_revision_v1"),
		"Revision capture pack was not isolated")
	var frame_texture := window.candidate_texture
	_check(revised.set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_OFF)
		and lamp.effective_energy == 0.0, "Night lamp OFF failed")
	_check(revised.set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_ON)
		and lamp.effective_energy > 0.9, "Night lamp ON failed")
	lamp.set_manual_override(AtmosphereLamp.Override.DIMMED)
	_check(is_equal_approx(lamp.effective_energy, 0.35), "DIMMED failed")
	_check(revised.set_proof_state(&"afternoon", &"rain", AtmosphereLamp.Override.AUTO)
		and window.candidate_texture == frame_texture
		and (revised.get_node("Architecture/WindowLighting") as WindowLightingController).current_rain > 0.0,
		"Separate rain/exterior state changed frame or failed")
	var shadow := chair.get_node("ContactShadow") as Node2D
	var before := shadow.global_position
	chair.position += Vector2(52, 0)
	_check(shadow.global_position.is_equal_approx(before + Vector2(52, 0)),
		"Chair shadow did not follow its owner")
	chair.position -= Vector2(52, 0)
	cat.candidate_texture = null
	_check(not revised.all_samples_ready(), "Missing cat bypassed revision capture guard")
	base.queue_free()
	revised.queue_free()
	await process_frame
	if _ok:
		print("--- HOME V3 REAL ART LIGHTING PROOF REVISION V1 PASSED (TECHNICAL) ---")
	quit(0 if _ok else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_ok = false
		push_error(message)
