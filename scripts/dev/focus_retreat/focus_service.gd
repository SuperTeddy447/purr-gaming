class_name WilliCatFocusService
extends Node
## Durable single-writer transaction. UI/world events emit only after successful save.
signal updated(snapshot: Dictionary)
signal world_event(event: Dictionary)
signal storage_failed(reason: String)
const MODEL = preload("res://scripts/dev/focus_retreat/focus_session.gd")
var model = MODEL.new()
var save_path := "user://willicat_focus_retreat_dev_v1.save"
var clock: Callable
var last_error := ""
var _wall_anchor := 0
var _ticks_anchor := 0
var _display_bucket := -1
var _recovery_blocked := false

func _ready() -> void:
	_wall_anchor = int(Time.get_unix_time_from_system()*1000)
	_ticks_anchor = Time.get_ticks_msec()
	load_session()
	tick()

func now_ms() -> int:
	return int(clock.call()) if clock.is_valid() else _wall_anchor + Time.get_ticks_msec()-_ticks_anchor

func _process(_delta: float) -> void:
	tick()
	var bucket: int = int(model.remaining(now_ms())/1000)
	if bucket != _display_bucket:
		_display_bucket = bucket
		updated.emit(model.snapshot(now_ms()))

func receive_json(text: String) -> Dictionary:
	if text.length()>4096: return {"accepted":false,"reason":"message_too_large","events":[]}
	var message = JSON.parse_string(text)
	if not message is Dictionary: return {"accepted":false,"reason":"invalid_json_command","events":[]}
	if message.has("duration_s") and message.duration_s is float:
		if not is_finite(message.duration_s) or message.duration_s!=floor(message.duration_s):
			return {"accepted":false,"reason":"invalid_duration","events":[]}
		message.duration_s=int(message.duration_s)
	return receive(message)

func receive(message: Dictionary) -> Dictionary:
	var before: Dictionary = model.data.duplicate(true)
	var result: Dictionary = model.command(message,now_ms())
	if model.data!=before:
		if not _persist():
			model.data = before
			return {"accepted":false,"reason":"storage_unavailable","events":[]}
		for event in result.events: world_event.emit(event)
	updated.emit(model.snapshot(now_ms()))
	return result

func tick() -> void:
	if model.data.state!="running" or model.remaining(now_ms())>0: return
	var before: Dictionary = model.data.duplicate(true)
	var events: Array = model.advance(now_ms())
	if not _persist(): model.data = before; return
	for event in events: world_event.emit(event)
	updated.emit(model.snapshot(now_ms()))

func _digest(bytes: PackedByteArray) -> String:
	var context:=HashingContext.new()
	context.start(HashingContext.HASH_SHA256);context.update(bytes)
	return context.finish().hex_encode()

func _read(path: String) -> Variant:
	var f := FileAccess.open(path,FileAccess.READ)
	if f==null: return null
	if f.get_length()<85 or f.get_line()!="WILLICAT_FOCUS_1": f.close();return null
	var checksum:=f.get_line()
	if checksum.length()!=64 or f.get_position()+4>f.get_length(): f.close();return null
	var count:=f.get_32()
	if count<1 or count>16777216 or f.get_length()-f.get_position()!=count: f.close();return null
	var bytes:=f.get_buffer(count);f.close()
	if _digest(bytes)!=checksum: return null
	var payload = bytes_to_var(bytes)
	return payload if MODEL.valid(payload) else null

func load_session() -> bool:
	var loaded = _read(save_path)
	if loaded==null: loaded = _read(save_path+".bak")
	if loaded==null:
		if FileAccess.file_exists(save_path) or FileAccess.file_exists(save_path+".bak"):
			_recovery_blocked = true
			_fail("Saved notebook could not be read; original files retained")
		return false
	model.data = loaded
	updated.emit(model.snapshot(now_ms()))
	return true

func _persist() -> bool:
	if _recovery_blocked: _fail("Notebook recovery required; original files retained"); return false
	if not MODEL.valid(model.data): _fail("Session data rejected"); return false
	var temp := save_path+".tmp"
	var f := FileAccess.open(temp,FileAccess.WRITE)
	if f==null: _fail("Notebook cannot be written"); return false
	var bytes:=var_to_bytes(model.data)
	f.store_line("WILLICAT_FOCUS_1");f.store_line(_digest(bytes));f.store_32(bytes.size());f.store_buffer(bytes)
	f.flush(); f.close()
	if _read(temp)!=model.data: _fail("Notebook verification failed"); return false
	# Preserve a known-good previous snapshot; never replace backup with corrupt bytes.
	if _read(save_path)!=null:
		if DirAccess.copy_absolute(ProjectSettings.globalize_path(save_path),ProjectSettings.globalize_path(save_path+".bak"))!=OK:
			_fail("Notebook backup failed"); return false
	if DirAccess.rename_absolute(ProjectSettings.globalize_path(temp),ProjectSettings.globalize_path(save_path))!=OK:
		_fail("Notebook update failed"); return false
	last_error = ""
	return true

func _fail(reason: String) -> void:
	last_error = reason
	storage_failed.emit(reason)

func _notification(what: int) -> void:
	if what==NOTIFICATION_APPLICATION_FOCUS_IN and is_inside_tree():
		if not clock.is_valid():
			_wall_anchor = maxi(now_ms(),int(Time.get_unix_time_from_system()*1000))
			_ticks_anchor = Time.get_ticks_msec()
		tick()
