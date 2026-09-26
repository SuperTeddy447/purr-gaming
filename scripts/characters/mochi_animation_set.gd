class_name MochiAnimationSet
extends Resource
## Semantic clip contract. Source filenames never enter gameplay or action selection.

const ACTIONS: Array[StringName] = [
	&"idle", &"ambient_idle", &"walk", &"prepare_coffee",
	&"carry_coffee", &"serve", &"return_idle"
]
const FALLBACK_ACTION: Dictionary = {
	&"ambient_idle": &"idle",
	&"prepare_coffee": &"idle",
	&"carry_coffee": &"walk",
	&"serve": &"idle",
	&"return_idle": &"walk",
	&"walk": &"idle"
}
const CONTRACTS: Dictionary = {
	&"idle": {"loop": true, "duration": "indefinite", "interruptible": true, "event": &"none", "asset_dir": "idle"},
	&"ambient_idle": {"loop": true, "duration": "3–9 s ambient hold", "interruptible": true, "event": &"none", "asset_dir": "ambient_idle"},
	&"walk": {"loop": true, "duration": "mover-driven", "interruptible": true, "event": &"none", "asset_dir": "walk"},
	&"prepare_coffee": {"loop": true, "duration": "~2.0 s gameplay timer", "interruptible": false, "event": &"coffee_prepare_completed", "asset_dir": "prepare_coffee"},
	&"carry_coffee": {"loop": true, "duration": "route/serve-tap driven", "interruptible": false, "event": &"coffee_pickup", "asset_dir": "carry_coffee"},
	&"serve": {"loop": false, "duration": "~0.45 s gameplay timer", "interruptible": false, "event": &"coffee_served", "asset_dir": "serve"},
	&"return_idle": {"loop": true, "duration": "mover-driven", "interruptible": true, "event": &"worker_returned_idle", "asset_dir": "walk"}
}

@export var final_frames: SpriteFrames
@export var temp_frames: SpriteFrames
## Disable if Mochi's asymmetric details must use dedicated left-facing frames.
@export var allow_side_mirror: bool = true
## Optional registration metadata, keyed by SpriteFrames clip name. A clip's frames
## must share one foot registration even when other clips have different canvases.
@export var foot_y_by_clip: Dictionary = {}
@export var visible_height_by_clip: Dictionary = {}


func is_semantic_action(action_id: StringName) -> bool:
	return ACTIONS.has(action_id)


func fallback_for(action_id: StringName) -> StringName:
	return FALLBACK_ACTION.get(action_id, &"") as StringName


func contract_for(action_id: StringName) -> Dictionary:
	return CONTRACTS.get(action_id, {}) as Dictionary


func direction_suffix(direction: StringName) -> String:
	match direction:
		&"LEFT", &"RIGHT", &"SIDE": return "side"
		&"UP": return "up"
		&"DOWN": return "down"
	return ""


func resolve(action_id: StringName, direction: StringName) -> Dictionary:
	var result: Dictionary = {
		"source": &"STATIC", "clip": &"", "resolved_action": &"idle",
		"flip_h": direction == &"LEFT" and allow_side_mirror, "used_fallback": true
	}
	if not is_semantic_action(action_id):
		return result
	var current: StringName = action_id
	var visited: Dictionary = {}
	while current != &"" and not visited.has(current):
		visited[current] = true
		var candidates: Array[Dictionary] = []
		match direction:
			&"LEFT":
				candidates.append({"clip": StringName("%s_left" % String(current)), "flip_h": false})
				if allow_side_mirror:
					candidates.append({"clip": StringName("%s_side" % String(current)), "flip_h": true})
			&"RIGHT":
				candidates.append({"clip": StringName("%s_right" % String(current)), "flip_h": false})
				candidates.append({"clip": StringName("%s_side" % String(current)), "flip_h": false})
			&"UP", &"DOWN":
				candidates.append({"clip": StringName("%s_%s" % [String(current), direction_suffix(direction)]), "flip_h": false})
			&"SIDE":
				candidates.append({"clip": StringName("%s_side" % String(current)), "flip_h": false})
		candidates.append({"clip": current, "flip_h": direction == &"LEFT" and allow_side_mirror})
		for source in [&"FINAL", &"TEMP"]:
			var frames: SpriteFrames = final_frames if source == &"FINAL" else temp_frames
			for candidate in candidates:
				var clip: StringName = candidate["clip"]
				if _has_usable_clip(frames, clip):
					return {
						"source": source, "clip": clip, "resolved_action": current,
						"flip_h": candidate["flip_h"], "used_fallback": current != action_id or candidate != candidates[0]
					}
		current = fallback_for(current)
	return result


func frames_for(source: StringName) -> SpriteFrames:
	return final_frames if source == &"FINAL" else temp_frames if source == &"TEMP" else null


func validate_fallback_chain() -> bool:
	for action_id in ACTIONS:
		if not CONTRACTS.has(action_id):
			return false
		var current: StringName = action_id
		var visited: Dictionary = {}
		while current != &"":
			if not is_semantic_action(current) or visited.has(current):
				return false
			visited[current] = true
			current = fallback_for(current)
	return true


func _has_usable_clip(frames: SpriteFrames, clip: StringName) -> bool:
	return frames != null and frames.has_animation(clip) and frames.get_frame_count(clip) > 0
