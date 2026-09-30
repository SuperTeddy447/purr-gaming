extends SceneTree
var sprite: AnimatedSprite2D
var transitions: Array = []
var start_usec: int
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var args = OS.get_cmdline_user_args()
	var frames = load("res://assets/first_party/__phase0_diagnostic_tree__/tree_frames.tres") as SpriteFrames
	assert(frames != null)
	var intended = [100,300,150,450]
	var recovered: Array = []
	for i in 4:
		var duration = frames.get_frame_duration(&"diagnostic_nonuniform",i) / frames.get_animation_speed(&"diagnostic_nonuniform") * 1000.0
		assert(duration == float(intended[i]))
		recovered.append(duration)
	sprite = load("res://assets/first_party/__phase0_diagnostic_tree__/tree.tscn").instantiate().get_node("AnimatedSprite2D")
	# Prefab has only presentation; an existing GameplayRoot would own collision and placement.
	var prefab = sprite.get_parent()
	root.add_child(prefab)
	sprite.frame_changed.connect(record_change)
	start_usec = Time.get_ticks_usec()
	sprite.play(&"diagnostic_nonuniform")
	await create_timer(2.3).timeout
	var playing_speed = sprite.get_playing_speed()
	sprite.pause()
	assert(transitions.size() >= 8)
	assert(transitions[0]["frame"] == 1 and transitions[1]["frame"] == 2 and transitions[2]["frame"] == 3 and transitions[3]["frame"] == 0)
	var observed: Array = []
	for i in range(3,7): observed.append(transitions[i+1]["elapsed_usec"]-transitions[i]["elapsed_usec"])
	assert(observed[0] < observed[2] and observed[2] < observed[1] and observed[1] < observed[3])
	var result = {"godot_version":Engine.get_version_info().string,"recipe":"godot-ms-weight-1","manifest_durations_ms":intended,"recovered_durations_ms":recovered,"resource_speed":frames.get_animation_speed(&"diagnostic_nonuniform"),"runtime_playing_speed":playing_speed,"observed_second_loop_hold_usec":observed,"transitions":transitions,"loop_ms":1000,"result":"passed","scope":"DIAGNOSTIC TIMING ONLY; NOT ART OR MOTION APPROVAL"}
	FileAccess.open(args[0],FileAccess.WRITE).store_string(JSON.stringify(result,"\t"))
	print("PHASE0_TIMING_ROUND_TRIP_PASSED ",recovered)
	prefab.queue_free()
	await process_frame
	quit(0)
func record_change() -> void:
	transitions.append({"frame":sprite.frame,"elapsed_usec":Time.get_ticks_usec()-start_usec})
