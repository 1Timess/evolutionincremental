extends Control

var population := 1.0
var habitat_fraction := 0.05
var convergence := 0.0
var time := 0.0

func _process(delta: float) -> void:
	time += delta
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var max_radius := minf(size.x, size.y) * 0.47
	var habitat_radius := max_radius * sqrt(habitat_fraction)
	var visible_cells := clampi(int(ceil(log(maxf(population, 1.0)) / log(1.32))) + 1, 1, 80)

	draw_circle(center, habitat_radius, Color(0.16, 0.85, 0.72, 0.025))
	draw_arc(center, habitat_radius, 0.0, TAU, 96, Color(0.65, 0.96, 0.88, 0.13), 2.0)

	for i in range(visible_cells):
		var angle := float(i) * 2.399963 + sin(time * 0.18 + i) * 0.035
		var radial_seed := sqrt(fmod(float(i * 37 + 11), 101.0) / 101.0)
		var radius_from_center := habitat_radius * radial_seed * (1.0 - convergence)
		var drift := Vector2(sin(time * 0.42 + i * 1.7), cos(time * 0.35 + i * 1.3)) * 4.0 * (1.0 - convergence)
		var position := center + Vector2(cos(angle), sin(angle)) * radius_from_center + drift
		_draw_cell(position, 14.0 + fmod(float(i * 7), 5.0), float(i))

func _draw_cell(position: Vector2, radius: float, seed: float) -> void:
	var pulse := 1.0 + sin(time * 1.5 + seed) * 0.035
	var r := radius * pulse
	draw_circle(position, r + 3.0, Color(0.12, 0.65, 0.55, 0.22))
	draw_circle(position, r, Color(0.36, 0.83, 0.69, 0.78))
	draw_circle(position, r * 0.72, Color(0.55, 0.94, 0.79, 0.20))
	draw_circle(position + Vector2(-r * 0.20, -r * 0.12), r * 0.27, Color(0.08, 0.31, 0.29, 0.62))
	draw_arc(position, r * 0.88, 0.2, 2.6, 18, Color(0.78, 1.0, 0.90, 0.48), 2.0)
