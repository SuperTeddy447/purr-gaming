extends WindowLightingController
## Window-only exterior card inside the approved frame; no whole-room art swap.


func _draw() -> void:
	# The silhouette stays inside the transparent aperture after the scene's
	# uniform .32 display scale. Frame art renders later, on top of this card.
	var aperture := PackedVector2Array([
		Vector2(-19, 78), Vector2(-19, -42), Vector2(-16, -57),
		Vector2(-9, -72), Vector2(0, -78), Vector2(9, -72),
		Vector2(16, -57), Vector2(19, -42), Vector2(19, 78)])
	draw_colored_polygon(aperture, Color(current_exterior.r,
		current_exterior.g, current_exterior.b, 1.0))
	if current_haze > 0.05:
		draw_colored_polygon(aperture, Color(0.91, 0.93, 0.92,
			current_haze * 0.18))
	if current_foliage > 0.01:
		for i in 3:
			draw_circle(Vector2(-12 + i * 12, 58 - (i % 2) * 8),
				3.0 + current_foliage * 4.0,
				Color(0.29, 0.48, 0.39, current_foliage * 0.38))
	if current_rain > 0.0:
		for i in 5:
			var x := -13.0 + float(i) * 6.0
			draw_line(Vector2(x, -30 + (i % 2) * 24),
				Vector2(x - 4, -13 + (i % 2) * 24),
				Color(0.93, 0.97, 1.0, current_rain * 0.9), 1.5)
