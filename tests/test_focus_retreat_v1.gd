extends SceneTree
const MODEL = preload("res://scripts/dev/focus_retreat/focus_session.gd")
const SERVICE = preload("res://scripts/dev/focus_retreat/focus_service.gd")
var cases: Array = []
var failed := false
var now := 100000
var emitted: Array = []

func _initialize() -> void: call_deferred("run")
func check(condition: bool, name: String) -> void:
	cases.append({"test":name,"passed":condition})
	if not condition: failed=true;push_error(name)
func message(action: String, id: String, session: String="", duration: int=10) -> Dictionary:
	return {"protocol_version":1,"request_id":id,"action":action,"session_id":session,"duration_s":duration,"task":"Finish this chapter"}
func run() -> void:
	await process_frame
	var m = MODEL.new()
	check(MODEL.valid(m.data),"empty notebook is valid")
	check(m.command(message("start","a"),now).accepted,"start accepted")
	var sid: String=m.data.session_id
	check(m.remaining(now+2500)==7500,"deadline independent of frame count")
	check(m.command(message("start","a"),now+1000).reason=="duplicate_ignored" and m.data.session_id==sid,"duplicate command is idempotent")
	check(not m.command(message("start","b"),now+1000).accepted,"cannot start overlapping session")
	check(not m.command(message("pause","wrong","other"),now+1000).accepted,"stale session cannot pause active session")
	check(m.command(message("pause","pause",sid),now+3000).accepted,"pause accepted")
	check(m.remaining(now+90000)==7000,"paused timer remains frozen across long absence")
	var p = MODEL.new();p.data=m.data.duplicate(true)
	check(MODEL.valid(p.data) and p.remaining(now+200000)==7000,"paused snapshot restores remaining duration")
	check(m.command(message("resume","resume",sid),now+10000).accepted,"resume accepted")
	check(m.remaining(now+12000)==5000,"resume starts deadline from remaining duration")
	check(m.advance(now+17000).size()==1 and m.data.seeds==1,"completion grants one durable receipt")
	check(m.advance(now+999999).is_empty() and m.data.seeds==1,"duplicate completion does not grant twice")
	check(MODEL.valid(m.data),"completed notebook validates")
	check(not m.command(message("earned_seeds","fake",sid),now+999999).accepted and m.data.seeds==1,"external reward injection rejected")
	var cancelled = MODEL.new();cancelled.command(message("start","c"),now);cancelled.command(message("cancel","stop",cancelled.data.session_id),now+1000)
	check(cancelled.advance(now+90000).is_empty() and cancelled.data.seeds==0,"cancelled session earns no reward")
	var wrong = MODEL.new();check(not wrong.command(message("start","bad","",0),now).accepted,"zero duration rejected")
	check(not wrong.command(message("start","long","",10801),now).accepted,"out-of-domain duration rejected")
	var forged = m.data.duplicate(true);forged.seeds+=1
	check(not MODEL.valid(forged),"wallet inconsistent with receipts rejected")
	forged=m.data.duplicate(true);forged.receipts.append(forged.receipts[0].duplicate(true))
	check(not MODEL.valid(forged),"duplicate reward receipts rejected")
	var expires = MODEL.new();expires.command(message("start","e"),now);expires.command(message("pause","too_late",expires.data.session_id),now+10001)
	check(expires.data.state=="completed" and expires.data.seeds==1,"pause at expired deadline settles completion")
	# Real persistence and transactional failure behavior, isolated from player notebook.
	var s=SERVICE.new();s.save_path="/private/tmp/willicat_focus_test_"+Crypto.new().generate_random_bytes(8).hex_encode()+".save";s.clock=func():return now
	s.world_event.connect(func(event: Dictionary):emitted.append(event));root.add_child(s)
	check(s.receive_json('{"protocol_version":1,"request_id":"json-start","action":"start","duration_s":10,"task":"Read"}').accepted,"JSON transport accepts integral duration")
	check(not s.receive_json('{"protocol_version":1,"request_id":"bad-json","action":"start","duration_s":0.5}').accepted,"fractional JSON duration rejected")
	check(not s.receive_json('[]').accepted,"non-object JSON rejected")
	now+=4000
	s.receive(message("pause","savedpause",s.model.data.session_id))
	var restored=SERVICE.new();restored.save_path=s.save_path
	restored.clock=func():return now
	root.add_child(restored);await process_frame
	check(restored.model.data.state=="paused" and restored.model.remaining(now)==6000,"real paused notebook reload")
	check(restored.receive(message("resume","restartresume",restored.model.data.session_id)).accepted,"restored session resumes")
	now+=6001;restored.tick()
	check(restored.model.data.seeds==1 and restored.model.data.receipts.size()==1,"real persisted completion")
	var reloaded=SERVICE.new();reloaded.save_path=s.save_path
	reloaded.clock=func():return now
	root.add_child(reloaded);await process_frame;reloaded.tick()
	check(reloaded.model.data.seeds==1 and reloaded.model.data.receipts.size()==1,"restart after completion keeps single reward")
	var denied=SERVICE.new();denied.save_path="/private/tmp/nonexistent_focus_parent_"+Crypto.new().generate_random_bytes(8).hex_encode()+"/session.save"
	denied.clock=func():return now
	root.add_child(denied);await process_frame
	var before_events: int=emitted.size();denied.world_event.connect(func(event:Dictionary):emitted.append(event))
	check(not denied.receive(message("start","nosave")).accepted and denied.model.data.state=="ready" and emitted.size()==before_events,"failed write rolls back and emits no world event")
	# Completion must also roll back if the storage boundary fails.
	var pending=SERVICE.new();pending.save_path=s.save_path+".pending"
	pending.clock=func():return now
	root.add_child(pending);await process_frame;pending.receive(message("start","pending","",1));pending.save_path=denied.save_path;now+=1001;pending.tick()
	check(pending.model.data.state=="running" and pending.model.data.seeds==0,"failed completion persistence does not mint reward")
	# Backup recovery uses actual checksummed files; corrupt originals retained if neither copy is valid.
	var good_path: String=s.save_path
	var f:=FileAccess.open(good_path,FileAccess.WRITE);f.store_string("corrupt primary");f.close()
	var backup=SERVICE.new();backup.save_path=good_path
	backup.clock=func():return now
	root.add_child(backup);await process_frame
	check(backup.model.data.session_id!="" and backup.last_error=="","valid previous snapshot recovers corrupt primary")
	var badpath: String=good_path+".bad";f=FileAccess.open(badpath,FileAccess.WRITE);f.store_string("broken original");f.close()
	var bad=SERVICE.new();bad.save_path=badpath
	bad.clock=func():return now
	root.add_child(bad);await process_frame
	check(not bad.receive(message("start","overwrite-bad")).accepted and FileAccess.get_file_as_string(badpath)=="broken original","unrecoverable notebook is not silently overwritten")
	var active=SERVICE.new();active.save_path=good_path+".active"
	active.clock=func():return now
	root.add_child(active);active.receive(message("start","active-new","",2));now+=3000
	var catchup=SERVICE.new();catchup.save_path=active.save_path
	catchup.clock=func():return now
	root.add_child(catchup);await process_frame
	check(catchup.model.data.state=="completed" and catchup.model.data.seeds==1,"restart after deadline catches up once")
	# Ephemeral test notebook cleanup only.
	for path in [good_path,badpath,good_path+".pending",good_path+".active"]:
		for suffix in ["",".bak",".tmp"]:
			if FileAccess.file_exists(path+suffix):DirAccess.remove_absolute(path+suffix)
	var out:=OS.get_cmdline_user_args()[0] if not OS.get_cmdline_user_args().is_empty() else "/private/tmp/willicat_focus_test_results.json"
	var file:=FileAccess.open(out,FileAccess.WRITE);file.store_string(JSON.stringify({"cases":cases,"count":cases.size(),"passed":not failed},"\t"));file.close()
	print("FOCUS RETREAT TESTS ",cases.size()," / ","PASS" if not failed else "FAIL")
	for child in root.get_children():child.queue_free()
	await process_frame
	quit(1 if failed else 0)
