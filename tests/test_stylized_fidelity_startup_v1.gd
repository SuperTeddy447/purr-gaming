extends SceneTree
func _initialize():run.call_deferred()
func run():
 var app=load("res://scenes/dev/stylized_fidelity/stylized_cafe_micro_diorama_v1.tscn").instantiate();root.add_child(app)
 for i in 2400:
  await physics_frame
  if app.ready_for_review and app.actor.phase==HardeningActor.Phase.IDLE and app.actor.global_position.distance_to(Vector2(325,355))<.001:break
 var checks={"automatic_hero_arrival":app.actor.global_position.distance_to(Vector2(325,355))<.001,"existing_navigation_succeeded":not app.actor.failed_navigation,"cat_visible_on_floor":app.cat.visible and app.point_in_presented_floor(app.actor.global_position),"authority_unchanged":app.slice.authority()==app.baseline_authority}
 var okay:bool=checks.values().all(func(v):return v)
 var f:=FileAccess.open(OS.get_cmdline_user_args()[0],FileAccess.WRITE);f.store_string(JSON.stringify({"passed":okay,"count":checks.size(),"checks":checks},"\t"));f.close();print("AUTOMATIC HERO STARTUP ",okay);quit(0 if okay else 1)
