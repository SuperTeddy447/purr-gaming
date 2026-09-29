extends SceneTree
## The prepared proof contract remains valid after candidate integration.

const PROOF := preload("res://scenes/dev/home_v3_real_art_lighting_proof_v1.tscn")
const LOCKED := preload("res://scenes/dev/home_v3_level_design_pass_01.tscn")
var _ok := true


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var proof := PROOF.instantiate()
	root.add_child(proof)
	await process_frame
	var locked := LOCKED.instantiate() as HomeV3Pass01World
	root.add_child(locked)
	await physics_frame
	_check(not proof is HomeV3World, "Proof accidentally instantiates Home gameplay world")
	_check(proof.get_node("Furniture/ChairSample").position.is_equal_approx(
		locked.find_object(&"chair_b").position), "Chair proof root drifted from locked chair B")
	_check(proof.get_node("Characters/OrangeProtagonistSample").position.is_equal_approx(
		locked.actors.get_node("Worker").position), "Character proof root drifted from worker")
	_check(proof.get_node("Architecture/WindowLighting").position == Vector2(585, 446),
		"Window is not registered to locked Home V3 opening")
	var director := proof.get_node("AtmosphereDirector") as WorldAtmosphereDirector
	var lamp := proof.get_node("Architecture/PracticalLamp") as AtmosphereLamp
	var window := proof.get_node("Architecture/WindowLighting") as WindowLightingController
	_check(director.catalog != null and director.state != null, "Existing catalog was not reused")
	_check(proof.get_node("HUD") is CanvasLayer, "HUD lacks independent canvas")
	_check(not (proof.get_node("SunLight") as DirectionalLight2D).shadow_enabled,
		"Unbounded directional shadows enabled")
	_check(proof.set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_OFF)
		and lamp.effective_energy == 0.0, "Night lamp OFF failed")
	_check(proof.set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_ON)
		and lamp.effective_energy > 0.9, "Night lamp ON failed")
	lamp.set_manual_override(AtmosphereLamp.Override.DIMMED)
	_check(is_equal_approx(lamp.effective_energy, 0.35), "DIMMED policy failed")
	_check(proof.set_proof_state(&"afternoon", &"rain", AtmosphereLamp.Override.AUTO)
		and window.current_rain > 0.0, "Rain/window state failed")
	proof.set_neutral()
	_check((proof.get_node("WorldTint") as CanvasModulate).color == Color.WHITE,
		"Neutral reference did not clear world tint")
	var cat := proof.get_node("Characters/OrangeProtagonistSample") as RealArtProofSlot
	var pose := cat.get_node("OpaqueSourcePreview") as Sprite2D
	_check(pose.texture is AtlasTexture and not pose.visible,
		"Opaque source preview should hide when approved cutout is loaded")
	_check((pose.texture as AtlasTexture).atlas.resource_path.ends_with(
		"WILLICAT_ORANGE_PROTAGONIST_FINAL_MASTER_V1.png"),
		"Reference pose does not use the approved master")
	var source := Image.load_from_file(ProjectSettings.globalize_path(
		"res://docs/references/characters/WILLICAT_ORANGE_PROTAGONIST_FINAL_MASTER_V1.png"))
	_check(source.get_size() == Vector2i(1448, 1086)
		and source.get_pixel(0, 0).a > 0.99, "Master contact-sheet audit changed")
	_check(proof.all_samples_ready() and cat.is_ready_for_capture(),
		"Five candidate textures did not pass exact-canvas/alpha gate")
	var original_cat_texture := cat.candidate_texture
	cat.candidate_texture = null
	_check(not proof.all_samples_ready() and not cat.is_ready_for_capture(),
		"Capture guard allowed a missing character cutout")
	cat.candidate_texture = original_cat_texture
	var chair := proof.get_node("Furniture/ChairSample") as RealArtProofSlot
	var shadow := chair.get_node("ContactShadow") as Node2D
	var before := shadow.global_position
	chair.position += Vector2(52, 0)
	_check(shadow.global_position.is_equal_approx(before + Vector2(52, 0)),
		"Movable chair left its shadow behind")
	chair.position -= Vector2(52, 0)
	var test_image := Image.create(320, 320, false, Image.FORMAT_RGBA8)
	test_image.fill(Color.TRANSPARENT)
	test_image.set_pixel(160, 160, Color.WHITE)
	chair.candidate_texture = ImageTexture.create_from_image(test_image)
	_check(chair.is_ready_for_capture() and proof.all_samples_ready(),
		"Technical chair candidate should preserve entire proof readiness")
	var flat_normal := Image.create(320, 320, false, Image.FORMAT_RGBA8)
	flat_normal.fill(Color(0.5, 0.5, 1.0, 1.0))
	chair.optional_normal_map = ImageTexture.create_from_image(flat_normal)
	chair.use_normal_map = true
	_check(chair.get_node("Visual").texture is CanvasTexture,
		"Optional chair normal-map path was not prepared")
	chair.use_normal_map = false
	_check(not chair.get_node("Visual").texture is CanvasTexture,
		"Painted-base chair comparison did not restore")
	test_image.set_pixel(0, 100, Color.WHITE)
	chair.candidate_texture = ImageTexture.create_from_image(test_image)
	_check(not chair.is_ready_for_capture(), "Opaque perimeter pixel bypassed alpha gate")
	chair.candidate_texture = null
	chair.optional_normal_map = null
	_check(not proof.all_samples_ready(), "Capture guard allowed missing chair")
	proof.set_camera_shot(&"character")
	_check(proof.get_node("Camera").position == cat.position, "Close character framing missing")
	proof.set_camera_shot(&"room")
	_check(proof.get_node("Camera").position == Vector2(320, 540),
		"Proof camera did not restore")
	proof.queue_free()
	locked.queue_free()
	await process_frame
	if _ok:
		print("--- HOME V3 REAL ART LIGHTING PROOF PREP V1 PASSED ---")
	quit(0 if _ok else 1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		_ok = false
		push_error(message)
