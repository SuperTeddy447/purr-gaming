extends "res://tests/capture_stylized_fidelity_v1.gd"
func run():
 var mode:String=OS.get_cmdline_user_args()[1]
 var scenes={"approved_2d":"res://scenes/dev/cafe_visual_recovery/cafe_visual_recovery_v1.tscn","previous_hybrid":"res://scenes/dev/hybrid_diorama/hybrid_cafe_diorama_v1.tscn","stylized_hybrid":"res://scenes/dev/stylized_fidelity/stylized_cafe_micro_diorama_v1.tscn","prerendered_static_2d":"res://scenes/dev/stylized_fidelity/prerendered_cafe_comparison_v1.tscn"}
 app=load(scenes[mode]).instantiate()
 if mode=="stylized_hybrid":app.auto_hero=false
 root.add_child(app)
 for i in 240:
  await process_frame
  if mode=="approved_2d" and app.get_node("CafeInteriorVisualSlice").projection_applied:break
  if mode in ["previous_hybrid","stylized_hybrid"] and app.ready_for_review:break
  if mode=="prerendered_static_2d":break
 if mode=="stylized_hybrid":await navigate(Vector2(325,300));await navigate(Vector2(325,355))
 await create_timer(3).timeout;await sample(mode)
 save_json("diagnostics/fresh_performance_"+mode+".json",{"metrics":metrics,"method":"one fresh Godot process per branch to detect cross-scene texture-memory counter underflow; 3s warmup, 1.3s settling, 240frames discard60; desktop vsync, not GPU/phone timing"})
 app.queue_free();for i in 12:await process_frame
 quit()
