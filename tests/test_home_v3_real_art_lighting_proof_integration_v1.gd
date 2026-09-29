extends SceneTree
## Technical proof only. Visual approval is based on the rendered capture pack.

const PROOF := preload("res://scenes/dev/home_v3_real_art_lighting_proof_v1.tscn")
const ASSET_ROOT := "res://assets/dev/home_v3/real_art_lighting_proof_v1/"
var _ok := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var proof := PROOF.instantiate()
	root.add_child(proof)
	await process_frame
	var slots := {
		"Architecture/ArchitectureSample": ["home_v3_lighting_sample_architecture_v1.png", Vector2i(1400, 920)],
		"Architecture/WindowSample": ["home_v3_lighting_sample_window_v1.png", Vector2i(256, 768)],
		"Architecture/PracticalLamp/LampSample": ["home_v3_lighting_sample_lamp_v1.png", Vector2i(256, 320)],
		"Furniture/ChairSample": ["home_v3_lighting_sample_furniture_v1.png", Vector2i(320, 320)],
		"Characters/OrangeProtagonistSample": ["willi_orange_protagonist_proof_cutout_v1.png", Vector2i(512, 512)],
	}
	for path in slots:
		var slot := proof.get_node(path) as RealArtProofSlot
		var contract: Array = slots[path]
		_check(slot.candidate_texture != null and slot.candidate_texture.resource_path == ASSET_ROOT + contract[0],
			"Wrong candidate texture: %s" % path)
		_check(slot.expected_canvas_px == contract[1] and slot.is_ready_for_capture(),
			"Invalid size/alpha perimeter: %s" % path)
	_check(proof.all_samples_ready(), "Approved candidates did not unlock guarded capture")
	var cat := proof.get_node("Characters/OrangeProtagonistSample") as RealArtProofSlot
	_check(not cat.get_node("OpaqueSourcePreview").visible,
		"Opaque source contact sheet is still visible")
	var window := proof.get_node("Architecture/WindowSample") as RealArtProofSlot
	var frame_texture := window.candidate_texture
	_check(proof.set_proof_state(&"midday", &"clear", AtmosphereLamp.Override.FORCE_OFF),
		"Day/clear state refused")
	_check(proof.set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_OFF),
		"Night/clear state refused")
	var lamp := proof.get_node("Architecture/PracticalLamp") as AtmosphereLamp
	_check(lamp.effective_energy == 0.0, "Night lamp OFF is not dark")
	_check(proof.set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_ON),
		"Night/lamp ON state refused")
	_check(lamp.effective_energy > 0.9 and window.candidate_texture == frame_texture,
		"Runtime lamp or fixed frame texture failed")
	_check(proof.set_proof_state(&"afternoon", &"rain", AtmosphereLamp.Override.AUTO),
		"Rain state refused")
	_check((proof.get_node("Architecture/WindowLighting") as WindowLightingController).current_rain > 0.0
		and window.candidate_texture == frame_texture, "Rain changed the frame or failed")
	var chair := proof.get_node("Furniture/ChairSample") as Node2D
	var chair_shadow := chair.get_node("ContactShadow") as Node2D
	var old_shadow := chair_shadow.global_position
	chair.position += Vector2(52, 0)
	_check(chair_shadow.global_position.is_equal_approx(old_shadow + Vector2(52, 0)),
		"Chair shadow did not follow owner")
	chair.position -= Vector2(52, 0)
	var cat_shadow := cat.get_node("ContactShadow") as Node2D
	_check(cat_shadow.get_parent() == cat, "Character shadow not owner-local")
	_check(proof.get_node("HUD") is CanvasLayer, "HUD not isolated from world tint")
	_check(not (proof.get_node("SunLight") as DirectionalLight2D).shadow_enabled,
		"Directional shadow unexpectedly enabled")
	cat.candidate_texture = null
	_check(not proof.all_samples_ready(), "Capture guard can be bypassed by missing cat")
	proof.queue_free()
	await process_frame
	if _ok:
		print("--- HOME V3 REAL ART LIGHTING PROOF INTEGRATION V1 PASSED (TECHNICAL) ---")
	quit(0 if _ok else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_ok = false
		push_error(message)
