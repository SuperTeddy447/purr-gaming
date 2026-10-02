extends SceneTree
func _initialize():run.call_deferred()
func run():
 var app=load("res://scenes/dev/hybrid_cafe_hero_replacement/hybrid_cafe_hero_replacement_v1.tscn").instantiate();root.add_child(app)
 for i in 400:
  await process_frame
  if app.ready_for_review:break
 var checks:Dictionary={};checks["ready"]=app.ready_for_review
 var point:=Vector2(325,355);var e:=InputEventMouseButton.new();e.position=app.camera.unproject_position(app.project_point(point));e.button_index=MOUSE_BUTTON_LEFT;e.pressed=true;Input.parse_input_event(e)
 await process_frame
 checks["actual_screen_click_creates_gameplay_marker"]=is_instance_valid(app.click_marker)
 for i in 1800:
  await physics_frame
  if app.actor.phase==HardeningActor.Phase.IDLE:break
 checks["click_navigation_reaches_floor_target"]=not app.actor.failed_navigation and app.actor.global_position.distance_to(point)<2
 checks["authority_unchanged"]=app.slice.authority()==app.baseline_authority
 checks["fixed_orthographic"]=app.camera.projection==Camera3D.PROJECTION_ORTHOGONAL
 var f=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);f.store_string(JSON.stringify({"count":checks.size(),"passed":checks.values().all(func(x):return x),"checks":checks},"\t"));f.close();print("KIT INPUT ",checks);quit(0 if checks.values().all(func(x):return x) else 1)
