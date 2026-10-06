extends Control

var population := 1.0
var habitat_fraction := 0.05

func _draw() -> void:
	var visible_cells := clampi(int(ceil(log(maxf(population, 1.0)) / log(1.35))) + 1, 1, 72)
	var usable_width := maxf(size.x * habitat_fraction - 24.0, 12.0)
	var usable_height := maxf(size.y - 24.0, 12.0)

	for i in range(visible_cells):
		var x_seed := fmod(float(i * 73 + 19), 101.0) / 101.0
		var y_seed := fmod(float(i * 47 + 11), 97.0) / 97.0
		var radius := 4.0 + fmod(float(i * 13), 5.0)
		var position := Vector2(12.0 + x_seed * usable_width, 12.0 + y_seed * usable_height)
		draw_circle(position, radius + 2.0, Color(0.25, 0.78, 0.67, 0.16))
		draw_circle(position, radius, Color(0.47, 0.93, 0.76, 0.88))
		draw_circle(position + Vector2(-radius * 0.2, -radius * 0.2), maxf(1.5, radius * 0.28), Color(0.85, 1.0, 0.92, 0.9))
