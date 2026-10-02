extends SceneTree
var checks:Dictionary={}
func check(value:bool,label:String):checks[label]=value;assert(value,label)
func _initialize():run.call_deferred()
func run():
 var app=load("res://scenes/dev/stylized_fidelity/stylized_cafe_micro_diorama_v1.tscn").instantiate();app.auto_hero=false;root.add_child(app)
 while not app.ready_for_review:await process_frame
 check(not app.point_in_presented_floor(Vector2(320,855)),"outside_floor_rejected")
 check(not app.point_in_presented_floor(Vector2(450,450)),"removed_empty_floor_corner_rejected")
 check(app.point_in_presented_floor(Vector2(325,355)),"hero_floor_accepted")
 var invalid:=InputEventMouseButton.new();invalid.button_index=MOUSE_BUTTON_LEFT;invalid.pressed=true;invalid.position=app.camera.unproject_position(app.project_point(Vector2(450,450)));app._unhandled_input(invalid)
 check(app.click_marker==null,"invalid_pick_cannot_dispatch_navigation")
 var valid:=InputEventMouseButton.new();valid.button_index=MOUSE_BUTTON_LEFT;valid.pressed=true;valid.position=app.camera.unproject_position(app.project_point(Vector2(325,355)));app._unhandled_input(valid)
 check(is_instance_valid(app.click_marker),"valid_pick_dispatches_original_navigation")
 for i in 1800:
  await physics_frame
  if app.actor.phase==HardeningActor.Phase.IDLE:break
 check(not app.actor.failed_navigation and app.actor.global_position.distance_to(Vector2(325,355))<.001,"valid_pick_arrives_original_world_point")
 check(app.slice.authority()==app.baseline_authority,"input_preserves_world_authority")
 var f:=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);f.store_string(JSON.stringify({"passed":checks.values().all(func(v):return v),"count":checks.size(),"checks":checks},"\t"));f.close();print("FLOOR INPUT CHECKS ",checks.size());app.queue_free();for i in 12:await process_frame
 quit()
