extends Node2D
## Small fixed-location visual study. No WorldRoot/gameplay logic is instantiated.

@onready var atmosphere: WorldAtmosphereDirector = $AtmosphereDirector
@onready var lamp: AtmosphereLamp = $Architecture/PracticalLamp
@onready var camera: Camera2D = $Camera
@onready var status: Label = $HUD/Status

const BASE_CAMERA_POSITION := Vector2(320, 540)
const BASE_CAMERA_ZOOM := Vector2(1.8, 1.8)


func _ready() -> void:
	camera.position = BASE_CAMERA_POSITION
	camera.zoom = BASE_CAMERA_ZOOM
	_update_status()


func _process(_delta: float) -> void:
	var bulb := $Architecture/PracticalLamp/LampSample/BulbVisual as Sprite2D
	bulb.visible = bulb.texture != null and lamp.effective_energy > 0.01
	bulb.modulate.a = lamp.effective_energy


func _unhandled_key_input(event: InputEvent) -> void:
	if not (event is InputEventKey and event.pressed and not event.echo):
		return
	match event.keycode:
		KEY_1: set_neutral()
		KEY_2: set_proof_state(&"midday", &"clear", AtmosphereLamp.Override.FORCE_OFF)
		KEY_3: set_proof_state(&"sunset", &"clear", AtmosphereLamp.Override.AUTO)
		KEY_4: set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_OFF)
		KEY_5: set_proof_state(&"night", &"clear", AtmosphereLamp.Override.FORCE_ON)
		KEY_6: set_proof_state(&"afternoon", &"rain", AtmosphereLamp.Override.AUTO)
		KEY_7: set_proof_state(&"night", &"rain", AtmosphereLamp.Override.FORCE_ON)
		KEY_8: set_camera_shot(&"character")
		KEY_9: set_camera_shot(&"window")
		KEY_0: set_camera_shot(&"furniture")
		KEY_R: set_camera_shot(&"room")
		KEY_N:
			var chair := $Furniture/ChairSample as RealArtProofSlot
			chair.use_normal_map = not chair.use_normal_map
		KEY_F6: $CaptureHarness.run_capture()
	_update_status()


func set_neutral() -> void:
	atmosphere.set_neutral_base()
	lamp.set_manual_override(AtmosphereLamp.Override.FORCE_OFF)
	_update_status()


func set_proof_state(time_id: StringName, weather_id: StringName,
		lamp_override: AtmosphereLamp.Override) -> bool:
	var state := AtmosphereState.new()
	state.location_id = &"japan_reference"
	state.season_id = &"spring"
	state.time_id = time_id
	state.weather_id = weather_id
	if not atmosphere.apply_state(state):
		return false
	lamp.set_manual_override(lamp_override)
	_update_status()
	return true


func set_camera_shot(shot: StringName) -> void:
	match shot:
		&"character":
			camera.position = $Characters/OrangeProtagonistSample.position
			camera.zoom = Vector2(3.0, 3.0)
		&"window":
			camera.position = $Architecture/WindowLighting.position
			camera.zoom = Vector2(2.7, 2.7)
		&"furniture":
			camera.position = $Furniture/ChairSample.position
			camera.zoom = Vector2(2.7, 2.7)
		_:
			camera.position = BASE_CAMERA_POSITION
			camera.zoom = BASE_CAMERA_ZOOM
	_update_status()


func all_samples_ready() -> bool:
	for path in ["Architecture/ArchitectureSample", "Architecture/WindowSample",
			"Architecture/PracticalLamp/LampSample", "Furniture/ChairSample",
			"Characters/OrangeProtagonistSample"]:
		if not (get_node(path) as RealArtProofSlot).is_ready_for_capture():
			return false
	return true


func _update_status() -> void:
	if status == null:
		return
	status.text = "REAL ART PROOF | %s\n1–7 LIGHT  8/9/0 FOCUS  R RESET  N NORMAL  F6 CAPTURE" % [
		"CANDIDATES READY" if all_samples_ready() else "CANDIDATES MISSING"]
