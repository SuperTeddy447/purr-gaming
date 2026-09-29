extends AtmosphereLamp
## Hide only the lab's vector fixture once a real lamp texture is slotted.


func _draw() -> void:
	var fixture := get_node_or_null("LampSample") as RealArtProofSlot
	if fixture == null or fixture.candidate_texture == null:
		super._draw()
