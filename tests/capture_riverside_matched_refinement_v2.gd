extends SceneTree
var out:String
func _initialize():call_deferred("run")
func snap(name:String):
 for i in 12:await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(out.path_join(name+".png"))
func run():
 out=OS.get_cmdline_user_args()[0];DirAccess.make_dir_recursive_absolute(out)
 for version in ["V1","V2"]:
  var path:String="res://scenes/dev/riverside_translation/DEV_WILLICAT_RIVERSIDE_3D_TRANSLATION_PROOF_V1.tscn" if version=="V1" else "res://scenes/dev/riverside_refinement_v2/DEV_WILLICAT_RIVERSIDE_3D_ART_REFINEMENT_V2.tscn"
  var s=load(path).instantiate();root.add_child(s)
  for i in 240:await physics_frame
  s.controls.visible=false;s.water.material_override.set_shader_parameter("current_speed",0.0)
  if version=="V1":
   for role in ["Foliage","Foliage_Light","Foliage_Dark"]:s.materials[role].set_shader_parameter("wind_amount",0.0)
  else:
   for m in s.representative_wind_materials:m.set_shader_parameter("wind_amount",0.0)
  await snap("GAMEPLAY_"+version)
  if version=="V1":
   s.camera.size=13.2;s.camera.position=Vector3(8.35,16.5,21);s.camera.look_at(Vector3(1.05,.75,2.8));s.cat.scale.y=1/absf(s.camera.global_basis.y.y)
   await snap("V1_WITH_V2_CAMERA_CONTROL")
  for row in [["CAFE",Vector3(1.0,6.8,11.4),Vector3(-3.25,1.2,2.1),6.2,Vector2(-214,325)],["BRIDGE",Vector3(7.8,7.3,12.6),Vector3(3.5,-.2,3),6.4,Vector2(344,215)],["BANK",Vector3(7.1,4.4,10),Vector3(2.15,-.2,6.8),4.8,Vector2(85,360)],["VEGETATION",Vector3(1.4,4.0,13),Vector3(-3.2,1.3,8.6),4.6,Vector2(-15,840)]]:
   s.camera.size=row[3];s.camera.position=row[1];s.camera.look_at(row[2]);s.actor.position=row[4];s.cat.scale.y=1/absf(s.camera.global_basis.y.y);await snap(row[0]+"_"+version)
  s.queue_free();await process_frame
 quit()
