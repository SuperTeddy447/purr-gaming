extends SceneTree
## Focused ownership, stable-ID, composition-toggle, and depth guard for Home Mock V0.

const HOME_SCENE: String = "res://scenes/home/home_scene.tscn"
const CATALOG_PATH: String = "res://data/home_visual_asset_catalog.tres"
const MASTER_TEXTURE: String = "res://docs/references/home/WILLICAT_HOME_ENVIRONMENT_STYLE_LOCK_V1.png"
const REQUIRED_IDS: Array[StringName] = [
	&"architecture_home_01", &"counter_basic_01", &"espresso_basic_01",
	&"grinder_basic_01", &"pos_basic_01", &"pastry_case_basic_01",
	&"pastry_set_basic_01", &"table_round_01", &"chair_jade_01",
	&"plant_floor_01", &"plant_counter_01", &"vase_basic_01",
	&"entrance_door_01", &"sign_main_01", &"sign_hanging_01",
	&"sign_menu_01", &"sign_freestanding_01"
]


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	var catalog := load(CATALOG_PATH) as HomeAssetCatalog
	if catalog == null or not catalog.validate_unique_ids():
		_fail("Home visual catalog failed to load or contains duplicate/empty IDs")
		return
	for asset_id in REQUIRED_IDS:
		if catalog.find_asset(asset_id) == null:
			_fail("Required stable visual ID is missing: %s" % String(asset_id))
			return
	if catalog.definitions.size() != REQUIRED_IDS.size():
		_fail("Catalog must contain exactly the initial stable ID set")
		return
	print("[PASS] All 17 initial stable asset IDs exist exactly once.")
	var counter_definition := catalog.find_asset(&"counter_basic_01").duplicate(true) as HomeAssetDefinition
	var replacement_image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	replacement_image.fill(Color.WHITE)
	var replacement_texture := ImageTexture.create_from_image(replacement_image)
	counter_definition.texture_variants = {&"counter_front": replacement_texture}
	var replacement_catalog := HomeAssetCatalog.new()
	replacement_catalog.definitions = [counter_definition]
	var replacement_slot := HomeAssetSlot.new()
	replacement_slot.catalog = replacement_catalog
	replacement_slot.asset_id = &"counter_basic_01"
	replacement_slot.slot_role = &"counter_front"
	replacement_slot.variant_override = &"counter_front"
	replacement_slot.position = Vector2(465.0, 625.0)
	root.add_child(replacement_slot)
	await process_frame
	var replacement_visual := replacement_slot.get_child(0) as Node2D
	var replacement_sprite := replacement_visual.get_child(0) as Sprite2D if replacement_visual != null else null
	if replacement_visual == null or replacement_visual.name != "FinalTextureVisual" or \
		replacement_sprite == null or replacement_sprite.texture != replacement_texture \
		or not is_equal_approx(replacement_sprite.scale.x, replacement_sprite.scale.y) \
		or replacement_sprite.centered or replacement_sprite.offset != Vector2(-8.0, -16.0):
		_fail("A variant texture must preserve aspect ratio and its contracted counter-front bottom pivot")
		return
	replacement_slot.queue_free()
	var architecture_definition := catalog.find_asset(&"architecture_home_01").duplicate(true) as HomeAssetDefinition
	architecture_definition.texture = replacement_texture
	var architecture_catalog := HomeAssetCatalog.new()
	architecture_catalog.definitions = [architecture_definition]
	var architecture_slot := HomeAssetSlot.new()
	architecture_slot.catalog = architecture_catalog
	architecture_slot.asset_id = &"architecture_home_01"
	architecture_slot.slot_role = &"architecture_full_canvas"
	root.add_child(architecture_slot)
	await process_frame
	var architecture_sprite := (architecture_slot.get_child(0).get_child(0) as Sprite2D)
	if architecture_sprite == null or architecture_sprite.centered or architecture_sprite.offset != Vector2.ZERO \
		or architecture_sprite.scale != Vector2.ONE:
		_fail("Full-canvas architecture replacement must preserve its native scale and top-left origin")
		return
	architecture_slot.queue_free()
	await process_frame
	print("[PASS] Variant texture replacement works in-place, and full-canvas art retains its top-left origin.")

	root.size = Vector2i(540, 960)
	var home := (load(HOME_SCENE) as PackedScene).instantiate() as HomeScene
	root.add_child(home)
	await process_frame
	await process_frame

	var world := home.get_node("World") as Node2D
	var legacy := world.get_node("StructuralBase/DEV_REFERENCE_ONLY") as Sprite2D
	var master := world.get_node("StructuralBase/DEV_VISUAL_MASTER") as Sprite2D
	var modular_base := world.get_node("StructuralBase/HomeBakedBaseSlot") as HomeAssetSlot
	if legacy.visible or master.visible or not modular_base.visible or modular_base.visual_node == null:
		_fail("Normal Home must render its modular architecture only, not a monolithic reference")
		return
	if master.texture.resource_path != MASTER_TEXTURE:
		_fail("F6 visual master must point at the exact available environment lock image")
		return
	print("[PASS] Modular architecture is default; the unchanged lock image is F6-only comparison art.")

	var counter_back := world.get_node("BackDecorLayer/CounterBackSlot") as HomeAssetSlot
	var counter_front := world.get_node("ForegroundOccluderLayer/CounterFrontSlot") as HomeAssetSlot
	var counter_plant := world.get_node("ForegroundOccluderLayer/CounterPlantSlot") as HomeAssetSlot
	var espresso := world.get_node("BackDecorLayer/EspressoStationSlot") as HomeAssetSlot
	var grinder := world.get_node("BackDecorLayer/GrinderSlot") as HomeAssetSlot
	var pos := world.get_node("BackDecorLayer/POSSlot") as HomeAssetSlot
	var pastry_case := world.get_node("BackDecorLayer/PastryDisplaySlot") as HomeAssetSlot
	if counter_back.get_parent() != world.get_node("BackDecorLayer") or \
		counter_front.get_parent() != world.get_node("ForegroundOccluderLayer") or \
		counter_plant.get_parent() != world.get_node("ForegroundOccluderLayer") or \
		counter_plant.get_index() <= counter_front.get_index() or \
		espresso.get_parent() != world.get_node("BackDecorLayer") or \
		grinder.get_parent() != world.get_node("BackDecorLayer") or \
		pos.get_parent() != world.get_node("BackDecorLayer") or \
		pastry_case.get_parent() != world.get_node("BackDecorLayer"):
		_fail("Counter pieces and replaceable stations must remain independently owned by their locked layers")
		return
	if espresso.get_parent() == counter_front or grinder.get_parent() == counter_front or \
		pos.get_parent() == counter_front or pastry_case.get_parent() == counter_front:
		_fail("Replaceable stations and case must not be baked into the counter-front owner")
		return
	var counter := home.get_node("CounterSystem") as HomeCounterSystem
	var worker_region := counter.get_node_or_null(counter.worker_region_path) as HomeWorkerRegion
	var anchors := counter.get_node_or_null(counter.counter_top_prop_anchors_path) as Node2D
	if counter == null or worker_region == null or anchors == null or \
		counter.get_node_or_null(counter.counter_back_path) != counter_back or \
		counter.get_node_or_null(counter.counter_front_path) != counter_front:
		_fail("Logical counter assembly must reference its cross-layer visuals, worker region and prop anchors")
		return
	var coffee_marker := home.get_node("GameplayNodes/CoffeeAction") as GameplayMarker
	var worker_marker := home.get_node("GameplayNodes/WorkerIdle") as GameplayMarker
	if espresso.global_position.distance_to(coffee_marker.global_position) > 0.01 or \
		anchors.get_node("EspressoAnchor").global_position.distance_to(coffee_marker.global_position) > 0.01 or \
		anchors.get_node("POSAnchor").global_position.distance_to((pos as Node2D).global_position) > 0.01 or \
		anchors.get_node("PastryCaseAnchor").global_position.distance_to(pastry_case.global_position) > 0.01 or \
		anchors.get_node("CounterPlantAnchor").global_position.distance_to(counter_plant.global_position) > 0.01 or \
		worker_region.global_position.y > worker_marker.global_position.y:
		_fail("CoffeeAction/station anchor or counter worker region drifted from the existing interaction layout")
		return
	counter.set_skin_color(Color("#53775c"))
	if not (counter_back.visual_node as HomeModularProp)._tint_enabled or \
		not (counter_front.visual_node as HomeModularProp)._tint_enabled:
		_fail("Counter skin tint must apply to both independently rendered pieces")
		return
	print("[PASS] Counter back/front are cross-layer components; stations are independent and CoffeeAction-aligned.")

	if pastry_case.get_child_count() != 4:
		_fail("Pastry case must contain three independent pastry content slots")
		return
	for pastry_name in ["PastrySlot01", "PastrySlot02", "PastrySlot03"]:
		var pastry_node := pastry_case.get_node_or_null(pastry_name) as HomeAssetSlot
		if pastry_node == null or pastry_node.asset_id != &"pastry_set_basic_01":
			_fail("Pastry contents must each use their own stable pastry asset slot")
			return
	print("[PASS] Pastry case and its three independently replaceable contents are separate.")

	var depth := world.get_node("DepthSortedLayer") as Node2D
	var table_one := depth.get_node("Table1Slot") as HomeAssetSlot
	var table_two := depth.get_node("Table2Slot") as HomeAssetSlot
	var chair_one := depth.get_node("ChairTable1LeftSlot") as HomeAssetSlot
	var door_left := depth.get_node("EntranceDoorLeftLeafSlot") as HomeAssetSlot
	var door_right := depth.get_node("EntranceDoorRightLeafSlot") as HomeAssetSlot
	var freestanding := depth.get_node("SignFreestandingSlot") as HomeAssetSlot
	if not depth.y_sort_enabled or table_one.get_parent() != depth or table_two.get_parent() != depth or \
		chair_one.get_parent() != depth or door_left.get_parent() != depth or door_right.get_parent() != depth or \
		freestanding.get_parent() != depth or table_one.definition == null or \
		not table_one.definition.floor_contact_pivot or not table_one.definition.y_sort_required:
		_fail("Furniture, entrance leaves and floor sign must retain floor-contact Y-sort ownership")
		return
	if (catalog.find_asset(&"entrance_door_01").future_animation_states as PackedStringArray).size() != 4:
		_fail("Door resource must reserve closed/opening/open/closing states without authoring animation")
		return
	if table_one.get_node_or_null("TableVaseSlot") == null:
		_fail("Table vase must stay attached to its owning furniture scene")
	print("[PASS] Tables, chairs, door leaves and freestanding sign preserve Y-sort/floor anchors and seat ownership.")

	var signs := home.get_node("DynamicSignage")
	if signs.get_child_count() != 4:
		_fail("Existing four dynamic sign controls must remain intact")
		return
	for sign_name in ["CafeNameSurface", "HangingSignSurface", "MenuSloganSurface", "FreestandingSignSurface"]:
		var sign := signs.get_node(sign_name) as DynamicSign
		if sign == null or not sign.get_text().is_empty():
			_fail("Dynamic sign %s must remain a blank runtime surface" % sign_name)
			return
	print("[PASS] Four runtime sign surfaces are preserved and blank; no text is baked into visual assets.")

	var mochi := depth.get_node("MochiScaleTestDEV") as MochiScaleTest
	if mochi.scale_mode != MochiScaleTest.ScaleMode.LARGE or absf(mochi.rendered_height_px() - 150.0) > 1.0:
		_fail("Home mock must begin with Mochi at the existing canonical 150 px test scale")
		return
	mochi.select_test_position(MochiScaleTest.TestPosition.COFFEE_ACTION)
	if not depth.y_sort_enabled or depth.z_index >= world.get_node("ForegroundOccluderLayer").z_index or \
		counter_front.z_index != 0 or not mochi.visible or mochi.get_node_or_null("SliceWorker") == null:
		_fail("CoffeeAction actors must use the normal depth layer and remain eligible for real counter occlusion")
		return
	if mochi.global_position.distance_to(coffee_marker.global_position) > 0.01:
		_fail("Mochi CoffeeAction selection must still resolve the existing semantic marker")
		return
	var alpha_bounds: Rect2i = mochi.sprite.texture.get_image().get_used_rect()
	var alpha_local_position: Vector2 = mochi.sprite.offset + Vector2(alpha_bounds.position)
	var character_rect := Rect2(
		mochi.to_global(alpha_local_position * mochi.sprite.scale),
		Vector2(alpha_bounds.size) * mochi.sprite.scale
	)
	var occlusion_regions: Array[Rect2] = (counter_front.visual_node as HomeModularProp).occlusion_regions_local()
	var overlaps_character: bool = false
	for local_region in occlusion_regions:
		var world_region := Rect2(counter_front.to_global(local_region.position), local_region.size)
		if world_region.intersects(character_rect):
			overlaps_character = true
	if not overlaps_character:
		_fail("Opaque counter-front geometry must overlap Mochi's alpha-bounded silhouette at CoffeeAction")
		return
	print("[PASS] CoffeeAction character remains in normal Y-sort; counter-front geometry spatially overlaps Mochi's silhouette at z=80. Mochi starts at 150 px.")

	home.toggle_dev_visual_master()
	if not master.visible or modular_base.visible or not mochi.visible:
		_fail("F6 must show the master alone while runtime characters remain visible")
		return
	home.toggle_dev_visual_master()
	if master.visible or not modular_base.visible:
		_fail("F6 off must restore the modular composition")
		return
	home.debug_overlay.toggle_dev_reference()
	if not legacy.visible or modular_base.visible:
		_fail("R legacy comparison must be exclusive from the modular view")
		return
	home.debug_overlay.toggle_dev_reference()
	if legacy.visible or not modular_base.visible:
		_fail("R off must restore the modular default")
		return
	print("[PASS] F6 master comparison and R legacy-reference toggle preserve a clean modular default.")

	home.queue_free()
	await process_frame
	print("--- ALL HOME MODULAR VISUAL MOCK V0 CHECKS PASSED ---")
	quit(0)


func _fail(message: String) -> void:
	printerr("[FAIL] " + message)
	quit(1)
