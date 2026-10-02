extends SceneTree
func _initialize():run.call_deferred()
func run():
 var app=load("res://scenes/dev/hybrid_cafe_kit/hybrid_cafe_asset_kit_v1.tscn").instantiate();root.add_child(app)
 for i in 400:
  await process_frame
  if app.ready_for_review:break
 app.camera.size=7.65;app.get_node("DiagnosticControls").visible=false
 for point in [Vector2(325,300),Vector2(325,355)]:
  var marker:=Marker2D.new();marker.position=point;app.slice.add_child(marker);assert(app.actor.navigate_to_marker(marker))
  for i in 1800:
   await physics_frame
   if app.actor.phase==HardeningActor.Phase.IDLE:break
  assert(not app.actor.failed_navigation);marker.queue_free()
 await RenderingServer.frame_post_draw
 assert(root.get_texture().get_image().save_png(OS.get_cmdline_user_args()[0]+"/01_HYBRID_BEFORE.png")==OK)
 var f=FileAccess.open(OS.get_cmdline_user_args()[0]+"/diagnostics/before_camera.json",FileAccess.WRITE);f.store_string(JSON.stringify({"transform":app.camera.transform,"size":app.camera.size,"actor_root":app.actor.global_position,"source":"unchanged existing V1 kit, only common comparison camera size","world_authority_unchanged":app.slice.authority()==app.baseline_authority},"\t"));f.close();quit()
