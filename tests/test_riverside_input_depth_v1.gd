extends SceneTree
var scene:Node3D
var rows:Array=[]
var out:String
func _initialize():call_deferred("run")
func check(name:String,ok:bool,detail:Variant=null):rows.append({"test":name,"passed":ok,"details":detail})
func settle():
 for i in 12:await process_frame
 await RenderingServer.frame_post_draw
func snap(name:String):
 await settle();root.get_texture().get_image().save_png(out.path_join(name+".png"))
func run():
 out=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(out)
 scene=load("res://scenes/dev/riverside_translation/DEV_WILLICAT_RIVERSIDE_3D_TRANSLATION_PROOF_V1.tscn").instantiate();root.add_child(scene)
 for i in 240:
  await physics_frame
  if scene.ready_for_review:break
 scene.controls.visible=false;await settle()
 var target:=Vector2(-20,650);var pos:Vector2=scene.camera.unproject_position(scene.point(target))
 var click:=InputEventMouseButton.new();click.position=pos;click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;root.push_input(click)
 for i in 3:await physics_frame
 check("native_mouse_input_starts_route",scene.actor.phase!=HardeningActor.Phase.IDLE)
 for i in 1000:
  await physics_frame
  if scene.actor.phase==HardeningActor.Phase.IDLE:break
 check("native_mouse_input_reaches_ground_target",not scene.actor.failed_navigation and scene.actor.position.distance_to(target)<10,scene.actor.position)
 var water_pos:Vector2=scene.camera.unproject_position(Vector3(3.44,0,6.8));click=InputEventMouseButton.new();click.position=water_pos;click.button_index=MOUSE_BUTTON_LEFT;click.pressed=true;root.push_input(click)
 for i in 3:await physics_frame
 check("native_mouse_input_rejects_water",scene.actor.phase==HardeningActor.Phase.IDLE)
 var touch:=InputEventScreenTouch.new();touch.position=scene.camera.unproject_position(Vector3(.65,0,6.4));touch.pressed=true;touch.index=0;root.push_input(touch)
 for i in 3:await physics_frame
 check("native_touch_input_starts_route",scene.actor.phase!=HardeningActor.Phase.IDLE)
 for i in 1000:
  await physics_frame
  if scene.actor.phase==HardeningActor.Phase.IDLE:break
 check("native_touch_input_reaches_target",not scene.actor.failed_navigation and scene.actor.position.distance_to(Vector2(65,640))<10,scene.actor.position)
 # Four-layer static diagnostic controls; freeze only environmental shaders for pixel parity.
 scene.water.material_override.set_shader_parameter("current_speed",0.0)
 for role in ["Foliage","Foliage_Light","Foliage_Dark"]:scene.materials[role].set_shader_parameter("wind_amount",0.0)
 scene.contact.visible=false;scene.source_sprite.pause();scene.source_sprite.frame=0
 for row in [["bridge",Vector2(344,270)],["entrance",Vector2(-214,224)]]:
  scene.actor.position=row[1];scene.geometry.visible=true;scene.cat.visible=true;await snap(row[0]+"_full")
  scene.cat.visible=false;await snap(row[0]+"_environment")
  scene.geometry.visible=false;scene.cat.visible=true;await snap(row[0]+"_actor_only")
  scene.cat.visible=false;await snap(row[0]+"_empty")
 scene.geometry.visible=true;scene.cat.visible=true;scene.actor.position=Vector2(85,360);scene.contact.visible=true
 for size in [Vector2i(540,960),Vector2i(360,640)]:
  root.content_scale_size=size;root.size=size;await settle()
  scene.geometry.visible=false;scene.contact.visible=false;await snap("scale_%d_actor"%size.x)
  scene.cat.visible=false;await snap("scale_%d_empty"%size.x);scene.cat.visible=true;scene.geometry.visible=true
 FileAccess.open(out.path_join("native_input_report.json"),FileAccess.WRITE).store_string(JSON.stringify({"checks":rows,"passed":rows.filter(func(r):return r.passed).size(),"failed":rows.filter(func(r):return not r.passed).size()},"  "))
 print("RIVERSIDE_INPUT passed=",rows.filter(func(r):return r.passed).size()," failed=",rows.filter(func(r):return not r.passed).size())
 quit(1 if rows.any(func(r):return not r.passed) else 0)
