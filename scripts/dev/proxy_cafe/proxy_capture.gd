extends SceneTree
## Real renderer proof from the unchanged visit state machine.
const WORLD := preload("res://scenes/dev/proxy_cafe/proxy_playable_world.tscn")
const OUTPUT := "res://artifacts/prototype_review/proxy_asset_kit_cafe_proof_v1/"
const REQUIRED := [
    "01_proxy_shell.png", "02_proxy_cafe_overview.png", "03_proxy_cafe_gameplay.png",
    "04_proxy_service_bar.png", "05_proxy_seating.png", "06_proxy_character_walk.png",
    "07_proxy_character_counter_occlusion.png", "08_proxy_character_scale_check.png"]
var saved: Dictionary = {}
var frame_count := 0

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    root.size = Vector2i(540, 960)
    debug_collisions_hint = false
    var world := WORLD.instantiate() as PlaceholderWorld
    root.add_child(world)
    var out := ProjectSettings.globalize_path(OUTPUT)
    var existing := DirAccess.open(out + "frames")
    if existing != null:
        for old_file in existing.get_files():
            if old_file.begins_with("frame_") and old_file.ends_with(".png"):
                existing.remove(old_file)
    if DirAccess.make_dir_recursive_absolute(out + "frames") != OK:
        push_error("Could not create proxy capture directory")
        quit(1)
        return
    for i in 8:
        await process_frame
    var cafe := world.room as PlaceholderCafe
    var customer := cafe.actors.get_node("Customer") as HardeningActor
    var worker := cafe.actors.get_node("Worker") as HardeningActor
    var camera_input := cafe.camera_input as PlaceholderCameraInput
    _hide_hud(world, cafe)
    camera_input.set_preset(&"overview")
    await _save("01_proxy_shell.png")
    for frame in 4400:
        await process_frame
        _hide_hud(world, cafe)
        if frame % 12 == 0 and frame_count < 180:
            await _save_frame(out)
        if customer.visible and customer.velocity.length_squared() > 20.0:
            var y := customer.global_position.y
            if y < 930.0 and y > 850.0:
                await _save_once("08_proxy_character_scale_check.png")
            if y < 730.0 and y > 670.0:
                await _save_once("06_proxy_character_walk.png")
            if y < 690.0 and y > 580.0:
                await _save_once("03_proxy_cafe_gameplay.png")
            if y < 560.0 and y > 430.0:
                await _save_once("02_proxy_cafe_overview.png")
        if customer.visible and customer.phase == HardeningActor.Phase.ACTION and customer.last_action == &"order":
            await _save_once("04_proxy_service_bar.png")
        if worker.phase == HardeningActor.Phase.ACTION and worker.last_action == &"serve":
            await _save_once("07_proxy_character_counter_occlusion.png")
        if customer.visible and customer.phase == HardeningActor.Phase.ACTION and customer.last_action == &"sit":
            await _save_once("05_proxy_seating.png")
        if world.session["coins"] == 1 and not cafe.loop_active:
            print("PROXY_VISIT completed frame=", frame)
            break
    var complete: bool = int(world.session["coins"]) == 1 and not cafe.loop_active
    for file in REQUIRED:
        if not saved.has(file):
            push_error("Missing live screenshot: " + file)
            complete = false
    print("PROXY_CAPTURE frames=", frame_count, " visit=", world.session["coins"], " complete=", complete)
    quit(0 if complete else 1)

func _hide_hud(world: PlaceholderWorld, cafe: PlaceholderCafe) -> void:
    world.get_node("HUD").visible = false
    cafe.get_node("HUD").visible = false
    (cafe.get_node("DepthSortedLayer/Characters/Customer/OrderBubble") as Label).modulate.a = 0.0

func _save_once(file: String) -> void:
    if saved.has(file):
        return
    await _save(file)

func _save(file: String) -> void:
    await process_frame
    var image := root.get_texture().get_image()
    if image == null or image.is_empty():
        push_error("Real viewport was empty")
        return
    var result := image.save_png(ProjectSettings.globalize_path(OUTPUT + file))
    if result == OK:
        saved[file] = true
        print("PROXY_CAPTURE ", file)
    else:
        push_error("Failed to save " + file)

func _save_frame(out: String) -> void:
    var image := root.get_texture().get_image()
    if image == null or image.is_empty():
        return
    if image.save_png(out + "frames/frame_%03d.png" % frame_count) == OK:
        frame_count += 1
