extends SceneTree
const APP = preload("res://scenes/dev/focus_retreat/focus_retreat_v1.tscn")
const MODEL = preload("res://scripts/dev/focus_retreat/focus_session.gd")
var app
var output: String
var recording := false
var accumulator := 0.0
var frames := 0
var trace: Array = []
var checks: Dictionary = {}
var events: Array = []
var initial_position: Vector2
var before: Dictionary
var frame_times: Array = []

func _initialize() -> void:
	output=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(output+"/frames");call_deferred("run")
func save_json(path: String,value) -> void:
	var f:=FileAccess.open(output+"/"+path,FileAccess.WRITE);f.store_string(JSON.stringify(value,"\t",true,true));f.close()
func capture(path: String) -> void:
	await RenderingServer.frame_post_draw
	var im:=root.get_texture().get_image();assert(im!=null and not im.is_empty());assert(im.save_png(output+"/"+path)==OK)
func _process(delta: float) -> bool:
	if not recording: return false
	accumulator+=delta
	var actor=app.companion.actor
	trace.append({"time_ms":Time.get_ticks_msec(),"state":app.service.model.data.state,"actor_xy":[actor.global_position.x,actor.global_position.y],"actor_velocity":[actor.velocity.x,actor.velocity.y],"actor_behind_tree":actor.global_position.y<app.world.find_object(&"river_depth_tree").global_position.y,"tree_frame":app.companion.sprite.frame,"remaining_ms":app.service.model.remaining(app.service.now_ms())})
	if accumulator>=.1:
		frame_times.append(Time.get_ticks_msec())
		accumulator=0;capture.call_deferred("frames/%05d.png" % frames);frames+=1
	return false
func settle(seconds: float) -> void: await create_timer(seconds).timeout
func run() -> void:
	app=APP.instantiate();root.add_child(app)
	app.service.save_path=output+"/preview_test_session.save"
	app.service.model=MODEL.new()
	app.service.world_event.connect(func(event:Dictionary):events.append(event))
	for i in 120:
		await process_frame
		if app.world_ready: break
	assert(app.world_ready)
	app.task_edit.text="Finish one meaningful thing"
	app._preset(2)
	await settle(.5)
	await capture("01_ready_desktop.png")
	var tree=app.world.find_object(&"river_depth_tree")
	before={"tree_position":tree.global_position,"trunk_position":tree.get_node("TrunkFootprint").global_position,"shadow_position":tree.get_node("ShadowVisual").position}
	initial_position=app.companion.actor.global_position
	checks.actor_starts_at_authored_marker=initial_position==app.world.get_node("Spawns/river_front_depth").global_position
	recording=true
	app.primary.pressed.emit()
	await settle(4.2)
	await capture("02_running_desktop.png")
	checks.start_button_starts_timer=app.service.model.data.state=="running"
	checks.actual_actor_motion=app.companion.actor.global_position.distance_to(initial_position)>5
	app.primary.pressed.emit()
	await settle(.3)
	var paused_ms: int=app.service.model.remaining(app.service.now_ms())
	var paused_pos: Vector2=app.companion.actor.global_position
	await settle(1.2)
	checks.pause_freezes_time=app.service.model.remaining(app.service.now_ms())==paused_ms
	checks.pause_stops_actor=app.companion.actor.global_position==paused_pos and app.companion.actor.velocity==Vector2.ZERO
	await capture("03_paused_desktop.png")
	app.primary.pressed.emit()
	await settle(.5)
	checks.resume_button_resumes_timer=app.service.model.data.state=="running"
	# Real wall-time 30-second demo; no artificial advance in this visible proof.
	for i in 400:
		await settle(.1)
		if app.service.model.data.state=="completed":break
	checks.completion_real_timer=app.service.model.data.state=="completed"
	await settle(.8)
	await capture("04_complete_desktop.png")
	checks.one_reward=app.service.model.data.seeds==1 and app.service.model.data.receipts.size()==1
	app.service.tick();checks.repeat_tick_no_extra_reward=app.service.model.data.seeds==1
	checks.progress_persisted=app.service._read(app.service.save_path).seeds==1
	recording=false
	root.size=Vector2i(480,960);root.content_scale_size=Vector2i(480,960)
	await settle(.8)
	await capture("05_complete_phone.png")
	checks.portrait_layout=app.portrait
	var rect: Rect2=app.primary.get_global_rect()
	checks.portrait_primary_button_on_screen=Rect2(Vector2.ZERO,Vector2(480,960)).encloses(rect)
	checks.world_authority_unchanged=before.tree_position==tree.global_position and before.trunk_position==tree.get_node("TrunkFootprint").global_position and before.shadow_position==tree.get_node("ShadowVisual").position
	checks.tree_frames_unchanged=app.companion.sprite.sprite_frames.get_frame_count("wind")==23
	checks.front_and_behind=trace.any(func(r):return r.actor_behind_tree) and trace.any(func(r):return not r.actor_behind_tree)
	checks.completion_event_once=events.filter(func(e):return e.type=="session_complete").size()==1
	var completed_snapshot: Dictionary=app.service.model.data.duplicate(true)
	checks.task_text_readable=app.task_edit.get_theme_color("font_color")==app.INK
	app.primary.pressed.emit()
	await settle(.4)
	checks.portrait_active_controls_on_screen=Rect2(Vector2.ZERO,Vector2(480,960)).encloses(app.primary.get_global_rect()) and Rect2(Vector2.ZERO,Vector2(480,960)).encloses(app.stop_button.get_global_rect())
	await capture("06_running_phone.png")
	app.stop_button.pressed.emit()
	await settle(.1)
	checks.cancel_dialog_opened=app.cancel_dialog.visible
	app.cancel_dialog.confirmed.emit();app.cancel_dialog.hide()
	await settle(.1)
	checks.cancel_button_no_new_reward=app.service.model.data.state=="cancelled" and app.service.model.data.seeds==1
	save_json("focus_runtime_proof.json",{"scope":"development-only focus gameplay proof, not production publication","checks":checks,"events":events,"trace":trace,"captured_frames":frames,"session_snapshot":completed_snapshot,"final_cancel_probe_snapshot":app.service.model.data,"capture_frame_times_ms":frame_times,"native_godot_version":Engine.get_version_info(),"actual_demo_duration_s":30})
	var passed:=true
	for value in checks.values():passed=passed and value
	print("FOCUS PLAYABLE PROOF ","PASS" if passed else "FAIL"," checks=",checks.size()," frames=",frames)
	quit(0 if passed else 1)
