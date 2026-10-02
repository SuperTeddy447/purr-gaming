class_name WilliCatFocusSession
extends RefCounted
## Timer/reward authority independent of UI, frame rate, Godot world and transport.
const SCHEMA := 1
const MAX_DURATION_S := 10800
var data: Dictionary

func _init() -> void:
	data = {"schema":SCHEMA,"state":"ready","session_id":"","task":"","duration_s":1500,"remaining_ms":1500000,"deadline_ms":0,"last_seen_ms":0,"revision":0,"seeds":0,"completed_sessions":0,"focused_seconds":0,"receipts":[],"command_ids":[]}

func remaining(now_ms: int) -> int:
	if data.state == "running":
		return maxi(0, int(data.deadline_ms) - maxi(now_ms,int(data.last_seen_ms)))
	return int(data.remaining_ms)

func advance(now_ms: int) -> Array:
	var events: Array = []
	if data.state != "running": return events
	data.last_seen_ms = maxi(now_ms,int(data.last_seen_ms))
	if remaining(now_ms) > 0: return events
	data.remaining_ms = 0
	data.deadline_ms = 0
	data.state = "completed"
	# One receipt per session. Wallet and receipt are committed in the same snapshot.
	var exists := false
	for receipt in data.receipts:
		if receipt.session_id == data.session_id: exists = true
	if not exists:
		data.receipts.append({"session_id":data.session_id,"duration_s":data.duration_s,"task":data.task,"completed_ms":data.last_seen_ms,"seeds":1})
		data.seeds += 1
		data.completed_sessions += 1
		data.focused_seconds += data.duration_s
		data.revision += 1
		events.append({"type":"session_complete","session_id":data.session_id,"earned_seeds":1,"revision":data.revision})
	return events

func command(message: Dictionary, now_ms: int) -> Dictionary:
	var events := advance(now_ms)
	var ok := false
	var reason := "invalid_command"
	var id: Variant = message.get("request_id")
	if message.get("protocol_version") != 1 or not id is String or id.is_empty() or id.length()>96:
		return {"accepted":false,"reason":reason,"events":events}
	if data.command_ids.has(id): return {"accepted":true,"reason":"duplicate_ignored","events":events}
	var action := str(message.get("action",""))
	if action in ["pause","resume","cancel"] and message.get("session_id") != data.session_id:
		return {"accepted":false,"reason":"stale_session","events":events}
	match action:
		"start":
			var duration: Variant = message.get("duration_s")
			var task: Variant = message.get("task","")
			if data.state in ["running","paused"]: reason = "session_active"
			elif not (duration is int) or duration<1 or duration>MAX_DURATION_S: reason = "invalid_duration"
			elif not task is String or task.length()>80: reason = "invalid_task"
			else:
				data.state = "running"
				data.session_id = Crypto.new().generate_random_bytes(16).hex_encode()
				data.task = task.strip_edges()
				data.duration_s = duration
				data.remaining_ms = duration * 1000
				data.deadline_ms = now_ms + duration * 1000
				data.last_seen_ms = now_ms
				ok = true
		"pause":
			if data.state == "running":
				data.remaining_ms = remaining(now_ms)
				data.deadline_ms = 0
				data.state = "paused"
				ok = true
		"resume":
			if data.state == "paused":
				data.last_seen_ms = maxi(now_ms,int(data.last_seen_ms))
				data.deadline_ms = data.last_seen_ms + data.remaining_ms
				data.state = "running"
				ok = true
		"cancel":
			if data.state in ["running","paused"]:
				data.remaining_ms = remaining(now_ms)
				data.deadline_ms = 0
				data.state = "cancelled"
				ok = true
		"snapshot": ok = true
		_: reason = "unsupported_action"
	if ok:
		data.revision += 1
		data.command_ids.append(id)
		if data.command_ids.size()>128: data.command_ids.pop_front()
		if action != "snapshot": events.append({"type":{"start":"focus_started","pause":"focus_paused","resume":"focus_resumed","cancel":"focus_cancelled"}[action],"session_id":data.session_id,"revision":data.revision})
	return {"accepted":ok,"reason":"accepted" if ok else reason,"events":events}

func snapshot(now_ms: int) -> Dictionary:
	var result := data.duplicate(true)
	result.remaining_ms = remaining(now_ms)
	return result

static func valid(value: Variant) -> bool:
	if not value is Dictionary: return false
	var required := ["schema","state","session_id","task","duration_s","remaining_ms","deadline_ms","last_seen_ms","revision","seeds","completed_sessions","focused_seconds","receipts","command_ids"]
	if value.size()!=required.size(): return false
	for key in required:
		if not value.has(key): return false
	if value.schema!=SCHEMA or not value.state in ["ready","running","paused","completed","cancelled"]: return false
	for key in ["duration_s","remaining_ms","deadline_ms","last_seen_ms","revision","seeds","completed_sessions","focused_seconds"]:
		if not value[key] is int or value[key]<0: return false
	if value.duration_s<1 or value.duration_s>MAX_DURATION_S or value.remaining_ms>value.duration_s*1000: return false
	if not value.session_id is String or not value.task is String or value.task.length()>80: return false
	if value.state!="ready" and (value.session_id.length()!=32 or not value.session_id.is_valid_hex_number(false)): return false
	if value.state=="running" and value.deadline_ms<=0: return false
	if value.state!="running" and value.deadline_ms!=0: return false
	if value.state=="completed" and value.remaining_ms!=0: return false
	if not value.receipts is Array or not value.command_ids is Array or value.command_ids.size()>128: return false
	var ids: Array = []
	var seconds := 0
	for receipt in value.receipts:
		if not receipt is Dictionary or receipt.size()!=5: return false
		for key in ["session_id","duration_s","task","completed_ms","seeds"]:
			if not receipt.has(key): return false
		if not receipt.session_id is String or ids.has(receipt.session_id) or receipt.session_id.length()!=32: return false
		if not receipt.duration_s is int or receipt.duration_s<1 or receipt.duration_s>MAX_DURATION_S: return false
		if not receipt.completed_ms is int or receipt.completed_ms<0 or receipt.seeds!=1 or not receipt.task is String: return false
		ids.append(receipt.session_id); seconds += receipt.duration_s
	if value.seeds!=ids.size() or value.completed_sessions!=ids.size() or value.focused_seconds!=seconds: return false
	if value.state=="completed" and not ids.has(value.session_id): return false
	var commands: Array = []
	for id in value.command_ids:
		if not id is String or id.is_empty() or id.length()>96 or commands.has(id): return false
		commands.append(id)
	return true
