extends "res://scripts/dev/atmosphere/real_art_proof_world.gd"
## Composition-only micro-room. Does not own Home gameplay or locked world roots.

const ROOM_CAMERA_POSITION := Vector2(320, 425)
const ROOM_CAMERA_ZOOM := Vector2(2.7, 2.7)


func _ready() -> void:
	super._ready()
	set_camera_shot(&"room")


func set_camera_shot(shot: StringName) -> void:
	match shot:
		&"character":
			camera.position = $Characters/OrangeProtagonistSample.position
			camera.zoom = Vector2(3.3, 3.3)
		&"window":
			camera.position = $Architecture/WindowLighting.position
			camera.zoom = Vector2(3.2, 3.2)
		&"furniture":
			camera.position = $Furniture/ChairSample.position
			camera.zoom = Vector2(3.2, 3.2)
		_:
			camera.position = ROOM_CAMERA_POSITION
			camera.zoom = ROOM_CAMERA_ZOOM
	_update_status()


func _update_status() -> void:
	if status == null:
		return
	status.text = "REAL ART MICRO-ROOM | %s\n1–7 LIGHT  8/9/0 FOCUS  R RESET  N NORMAL  F6 CAPTURE" % [
		"CANDIDATES READY" if all_samples_ready() else "CANDIDATES MISSING"]
