extends Control
## Native playable UI for validating the focus/world loop before selecting a mobile host.
const SERVICE = preload("res://scripts/dev/focus_retreat/focus_service.gd")
const COMPANION = preload("res://scripts/dev/focus_retreat/focus_companion.gd")
const HOME = preload("res://scenes/dev/first_party_style_proof/home_first_party_style_proof_001.tscn")
const INK := Color("#352c28")
const MUTED := Color("#746d5b")
const PAPER := Color("#faf1df")
const SAGE := Color("#637b58")
var service: WilliCatFocusService
var world: HomeContinuousWorld
var companion
var world_ready := false
var duration_s := 1500
var selected_preset := 0
var outer: MarginContainer
var column: VBoxContainer
var body: BoxContainer
var timer_card: PanelContainer
var world_card: PanelContainer
var viewport: SubViewport
var viewport_container: SubViewportContainer
var timer_label: Label
var state_label: Label
var note_label: Label
var wallet_label: Label
var notebook_label: Label
var progress: ProgressBar
var primary: Button
var stop_button: Button
var task_edit: LineEdit
var presets: Array[Button] = []
var portrait := false
var toast: Label
var cancel_dialog: ConfirmationDialog
var request_sequence := 0
var _selected_duration := 1500
var timer_intro: Label
var task_prompt: Label
var timer_stack: VBoxContainer

func box(bg: Color, radius: int=20, border: Color=Color.TRANSPARENT) -> StyleBoxFlat:
	var result := StyleBoxFlat.new()
	result.bg_color=bg;result.set_corner_radius_all(radius)
	result.set_border_width_all(1);result.border_color=border
	result.content_margin_left=22;result.content_margin_right=22;result.content_margin_top=18;result.content_margin_bottom=18
	return result

func label(text: String, font_size: int=18, color: Color=INK) -> Label:
	var result := Label.new();result.text=text
	result.add_theme_font_size_override("font_size",font_size);result.add_theme_color_override("font_color",color)
	return result

func button(text: String, action: Callable, filled: bool=false) -> Button:
	var b := Button.new();b.text=text;b.custom_minimum_size.y=48;b.mouse_default_cursor_shape=Control.CURSOR_POINTING_HAND
	b.add_theme_font_size_override("font_size",16)
	b.add_theme_stylebox_override("normal",box(SAGE if filled else Color("#ede6d5"),14))
	b.add_theme_stylebox_override("hover",box(SAGE.lightened(.10) if filled else Color("#e4dac4"),14))
	b.add_theme_stylebox_override("pressed",box(SAGE.darkened(.09) if filled else Color("#d7ccb6"),14))
	b.add_theme_stylebox_override("disabled",box(Color("#e7e3d7"),14))
	b.add_theme_color_override("font_color",PAPER if filled else INK)
	b.add_theme_color_override("font_hover_color",PAPER if filled else INK)
	b.add_theme_color_override("font_pressed_color",PAPER if filled else INK)
	b.add_theme_color_override("font_disabled_color",MUTED)
	b.pressed.connect(action);return b

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var bg := ColorRect.new();bg.color=Color("#e9e2d3");bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(bg)
	outer=MarginContainer.new();outer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);add_child(outer)
	var scroll := ScrollContainer.new();scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED;outer.add_child(scroll)
	column=VBoxContainer.new();column.size_flags_horizontal=Control.SIZE_EXPAND_FILL;column.add_theme_constant_override("separation",16);scroll.add_child(column)
	var header := HBoxContainer.new();header.add_theme_constant_override("separation",12);column.add_child(header)
	var title := label("WilliCat",32);header.add_child(title)
	var spacer := Control.new();spacer.size_flags_horizontal=Control.SIZE_EXPAND_FILL;header.add_child(spacer)
	wallet_label=label("0 seeds",17,SAGE);header.add_child(wallet_label)
	var preview := label("PLAYABLE PREVIEW",11,MUTED);header.add_child(preview)
	body=HBoxContainer.new();body.add_theme_constant_override("separation",24);body.size_flags_vertical=Control.SIZE_EXPAND_FILL;column.add_child(body)
	_build_timer();_build_world()
	toast=label("",14,Color("#9b5846"));toast.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;column.add_child(toast)
	var footer := label("A little focus. A little company. A day that adds up.",14,MUTED);footer.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;column.add_child(footer)
	cancel_dialog=ConfirmationDialog.new();cancel_dialog.title="End this session?";cancel_dialog.dialog_text="Your earlier progress stays in your notebook.\nYou can begin again whenever you are ready.";cancel_dialog.ok_button_text="End session";cancel_dialog.confirmed.connect(func():send("cancel"));add_child(cancel_dialog)
	service=SERVICE.new();service.name="FocusSessionAuthority";service.updated.connect(render);service.world_event.connect(_on_world_event);service.storage_failed.connect(func(reason:String):toast.text=reason);add_child(service)
	get_viewport().size_changed.connect(_responsive);_responsive();render(service.model.snapshot(service.now_ms()))
	_install_world.call_deferred()

func _build_timer() -> void:
	timer_card=PanelContainer.new();timer_card.add_theme_stylebox_override("panel",box(PAPER,26,Color("#ded4bf")));timer_card.size_flags_horizontal=Control.SIZE_EXPAND_FILL;body.add_child(timer_card)
	var stack := VBoxContainer.new();stack.add_theme_constant_override("separation",10);timer_card.add_child(stack);timer_stack=stack
	stack.add_child(label("YOUR RIVERSIDE RITUAL",12,SAGE))
	stack.add_child(label("One thing at a time.",29))
	timer_intro=label("Settle in. Willi will keep you company.",15,MUTED);stack.add_child(timer_intro)
	task_prompt=label("What would you like to finish?",14,MUTED);stack.add_child(task_prompt)
	task_edit=LineEdit.new();task_edit.placeholder_text="One meaningful thing...";task_edit.max_length=80;task_edit.custom_minimum_size.y=44;task_edit.add_theme_font_size_override("font_size",16);task_edit.add_theme_stylebox_override("normal",box(Color("#fff8eb"),12,Color("#ded4bf")));task_edit.add_theme_stylebox_override("read_only",box(Color("#f3eddc"),12,Color("#ded4bf")));task_edit.add_theme_color_override("font_color",INK);task_edit.add_theme_color_override("font_placeholder_color",MUTED);task_edit.add_theme_color_override("caret_color",INK);task_edit.add_theme_color_override("font_uneditable_color",INK);task_edit.add_theme_stylebox_override("focus",box(Color("#fff8eb"),12,SAGE));stack.add_child(task_edit)
	var options := HBoxContainer.new();options.add_theme_constant_override("separation",8);stack.add_child(options)
	for i in 3:
		var b := button(["25 min","45 min","Demo 30s"][i],_preset.bind(i));b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.add_theme_font_size_override("font_size",14);options.add_child(b);presets.append(b)
	timer_label=label("25:00",88);timer_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;stack.add_child(timer_label)
	state_label=label("Ready when you are",15,SAGE);state_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;stack.add_child(state_label)
	progress=ProgressBar.new();progress.show_percentage=false;progress.custom_minimum_size.y=7;var bg_style:=box(Color("#e3dccb"),4);var fill_style:=box(SAGE,4)
	for st in [bg_style,fill_style]:
		st.content_margin_top=0;st.content_margin_bottom=0;st.content_margin_left=0;st.content_margin_right=0
	progress.add_theme_stylebox_override("background",bg_style);progress.add_theme_stylebox_override("fill",fill_style);stack.add_child(progress)
	primary=button("Start focus",_primary_pressed,true);primary.custom_minimum_size.y=56;stack.add_child(primary)
	stop_button=button("End this session",func():cancel_dialog.popup_centered());stop_button.visible=false;stop_button.custom_minimum_size.y=26
	for state in ["normal","hover","pressed"]:stop_button.add_theme_stylebox_override(state,StyleBoxEmpty.new())
	stop_button.add_theme_font_size_override("font_size",13);stack.add_child(stop_button)
	var divider := HSeparator.new();stack.add_child(divider)
	notebook_label=label("Your little notebook\n0 sessions  ·  0 focus minutes",14,MUTED);stack.add_child(notebook_label)

func _build_world() -> void:
	world_card=PanelContainer.new();world_card.size_flags_horizontal=Control.SIZE_EXPAND_FILL;world_card.size_flags_stretch_ratio=1.7;world_card.add_theme_stylebox_override("panel",box(PAPER,26,Color("#ded4bf")));body.add_child(world_card)
	var stack := VBoxContainer.new();stack.add_theme_constant_override("separation",10);world_card.add_child(stack)
	var row := HBoxContainer.new();stack.add_child(row);row.add_child(label("Riverside, with Willi",23));var spacer := Control.new();spacer.size_flags_horizontal=Control.SIZE_EXPAND_FILL;row.add_child(spacer);row.add_child(label("HOME",11,SAGE))
	viewport_container=SubViewportContainer.new();viewport_container.stretch=true;viewport_container.size_flags_vertical=Control.SIZE_EXPAND_FILL;viewport_container.custom_minimum_size=Vector2(280,420);viewport_container.mouse_filter=Control.MOUSE_FILTER_IGNORE;stack.add_child(viewport_container)
	viewport=SubViewport.new();viewport.size=Vector2i(960,640);viewport.render_target_update_mode=SubViewport.UPDATE_ALWAYS;viewport_container.add_child(viewport)
	note_label=label("A quiet place to make a little progress.",15,MUTED);note_label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;stack.add_child(note_label)
	stack.add_child(label("Collect small memories, one completed session at a time.",13,MUTED))

func _install_world() -> void:
	world=HOME.instantiate();world.autoplay_route=false;viewport.add_child(world)
	for i in 12: await get_tree().process_frame
	companion=COMPANION.new();add_child(companion);companion.bind(world,service)
	world_ready=true;_frame_camera();render(service.model.snapshot(service.now_ms()))

func _responsive() -> void:
	var narrow := get_viewport_rect().size.x<900
	for side in ["left","right","top","bottom"]:outer.add_theme_constant_override("margin_"+side,14 if narrow else 28)
	if narrow!=portrait:
		portrait=narrow
		var next: BoxContainer = VBoxContainer.new() if narrow else HBoxContainer.new()
		next.add_theme_constant_override("separation",18 if narrow else 24);next.size_flags_vertical=Control.SIZE_EXPAND_FILL
		column.add_child(next);column.move_child(next,1)
		timer_card.reparent(next);world_card.reparent(next)
		if narrow: next.move_child(world_card,0)
		body.queue_free();body=next
	timer_card.custom_minimum_size=Vector2(0 if narrow else 360,0)
	viewport_container.custom_minimum_size.y=190 if narrow else 420
	timer_intro.visible=not narrow;task_prompt.visible=not narrow
	timer_stack.add_theme_constant_override("separation",8 if narrow else 10)
	timer_label.add_theme_font_size_override("font_size",64 if narrow else 80)
	if world_ready: _frame_camera()

func _frame_camera() -> void:
	var tree = world.find_object(&"river_depth_tree")
	var camera: Camera2D=world.get_node("Camera")
	camera.global_position=tree.global_position+Vector2(-110,-75 if portrait else -50)
	# Viewport framing changes only; canonical camera/world layout files remain untouched.
	var view_size: Vector2=viewport_container.size
	var zoom: float=clampf(view_size.y/340.0,0.7,1.6)
	camera.zoom=Vector2.ONE*zoom

func _preset(index: int) -> void:
	if service.model.data.state in ["running","paused"]: return
	selected_preset=index;duration_s=[1500,2700,30][index];_selected_duration=duration_s
	render(service.model.snapshot(service.now_ms()))

func send(action: String) -> Dictionary:
	request_sequence+=1
	var request := {"protocol_version":1,"request_id":"ui-"+Crypto.new().generate_random_bytes(12).hex_encode(),"action":action,"session_id":service.model.data.session_id}
	if action=="start":request.duration_s=duration_s;request.task=task_edit.text
	var result: Dictionary=service.receive(request)
	if not result.accepted:toast.text="Could not update the session: "+str(result.reason)
	else:toast.text=""
	return result

func _primary_pressed() -> void:
	match str(service.model.data.state):
		"running":send("pause")
		"paused":send("resume")
		_:send("start")

func render(snapshot: Dictionary) -> void:
	if timer_label==null: return
	var state := str(snapshot.state)
	var active := state in ["running","paused"]
	var ms: int=int(snapshot.remaining_ms) if state in ["running","paused","completed"] else duration_s*1000
	var seconds := int(ceil(ms/1000.0))
	timer_label.text="%02d:%02d" % [int(seconds/60),seconds%60]
	wallet_label.text="%d %s" % [snapshot.seeds,"seed" if snapshot.seeds==1 else "seeds"]
	state_label.text={"ready":"Ready when you are","running":"A little progress, right now","paused":"Taking a breath","completed":"You showed up. That counts.","cancelled":"A fresh start is always here"}[state]
	primary.text={"ready":"Start focus","running":"Pause session","paused":"Continue focusing","completed":"Start another session","cancelled":"Start again"}[state]
	primary.disabled=not world_ready
	stop_button.visible=active
	task_edit.editable=not active
	if active and task_edit.text!=snapshot.task: task_edit.text=snapshot.task
	for i in presets.size():
		presets[i].disabled=active
		presets[i].add_theme_stylebox_override("normal",box(Color("#dbe4cf") if i==selected_preset else Color("#ede6d5"),12))
	progress.value=100.0*(1.0-float(ms)/(snapshot.duration_s*1000)) if state in ["running","paused","completed"] else 0
	var sessions: int=int(snapshot.completed_sessions)
	var memory := "First riverside memory" if sessions>=1 else "Your first memory is waiting"
	if sessions>=3:memory="A familiar little ritual"
	if sessions>=6:memory="Willi's favorite company"
	var focus_time := "%d focus seconds" % snapshot.focused_seconds if snapshot.focused_seconds<60 else "%d min %02d sec focused" % [int(snapshot.focused_seconds/60),int(snapshot.focused_seconds)%60]
	notebook_label.text="YOUR LITTLE NOTEBOOK\n%d %s  ·  %s\n%s" % [sessions,"session" if sessions==1 else "sessions",focus_time,memory]
	if note_label!=null:note_label.text={"ready":"Willi is ready to keep you company.","running":"A little riverside walk while you focus.","paused":"Willi rests here. Your remaining time stays yours.","completed":"A new memory, and +1 seed in your notebook.","cancelled":"Nothing lost. Your earlier memories are still here."}[state]

func _on_world_event(_event: Dictionary) -> void:
	if world_ready: _frame_camera()

func _process(_delta: float) -> void:
	if world_ready: _frame_camera()
