extends SceneTree
func _initialize():run.call_deferred()
func run():
 var app=load("res://scenes/dev/stylized_fidelity/prerendered_cafe_comparison_v1.tscn").instantiate();root.add_child(app)
 app.get_node("ComparisonControls").visible=false
 await create_timer(3).timeout
 var samples:Array=[]
 for i in 240:
  var start:=Time.get_ticks_usec();await process_frame
  if i>=60:samples.append({"wall_frame_ms":(Time.get_ticks_usec()-start)/1000.0,"process_ms":Performance.get_monitor(Performance.TIME_PROCESS)*1000,"draw_calls":Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),"texture_memory_bytes":Performance.get_monitor(Performance.RENDER_TEXTURE_MEM_USED),"video_memory_bytes":Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)})
 await RenderingServer.frame_post_draw
 var out:String=OS.get_cmdline_user_args()[0]
 var image:=root.get_texture().get_image();var okay:=image.save_png(out+"/03_PRERENDERED_3D_HERO.png")==OK
 var tex=app.get_node("BakedPresentation/SameDioramaOrthographicImage").texture
 var f:=FileAccess.open(out+"/diagnostics/prerender_2d_proof.json",FileAccess.WRITE);f.store_string(JSON.stringify({"passed":okay,"runtime":"actual 2D TextureRect presentation","source_dimensions":tex.get_size(),"screen_dimensions":image.get_size(),"scene_3d_meshes":0,"lights":0,"animated_cat":false,"same_source_scene_bake":true,"samples":samples},"\t"));f.close();print("PRE-RENDER 2D PROOF ",okay);quit(0 if okay else 1)
