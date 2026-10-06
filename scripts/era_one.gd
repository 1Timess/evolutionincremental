extends Control

const METABOLISM_MAX := 20
const REPLICATION_MAX := 20
const ADAPTATION_MAX := 19
const STARTING_HABITAT := 0.05
const HABITAT_STEP := 0.05

var energy := 0.0
var metabolism_level := 0
var replication_level := 0
var adaptation_level := 0
var population := 1.0
var era_complete := false

@onready var energy_label: Label = %EnergyLabel
@onready var energy_rate_label: Label = %EnergyRateLabel
@onready var population_label: Label = %PopulationLabel
@onready var habitat_label: Label = %HabitatLabel
@onready var habitat_fill: ColorRect = %HabitatFill
@onready var cell_field: Control = %CellField
@onready var metabolism_button: Button = %MetabolismButton
@onready var replication_button: Button = %ReplicationButton
@onready var adaptation_button: Button = %AdaptationButton
@onready var cooperation_button: Button = %CooperationButton
@onready var status_label: Label = %StatusLabel

func _ready() -> void:
	metabolism_button.pressed.connect(_buy_metabolism)
	replication_button.pressed.connect(_buy_replication)
	adaptation_button.pressed.connect(_buy_adaptation)
	cooperation_button.pressed.connect(_buy_cooperation)
	_refresh_ui()

func _process(delta: float) -> void:
	if era_complete:
		return

	energy += energy_per_second() * delta

	if replication_level > 0:
		var growth := population * replication_growth_rate() * delta
		population = minf(population + growth, habitat_capacity())

	_refresh_ui()

func energy_per_second() -> float:
	return population * (1.0 + metabolism_level * 0.25)

func replication_growth_rate() -> float:
	return 0.0125 * replication_level

func habitat_fraction() -> float:
	return minf(1.0, STARTING_HABITAT + adaptation_level * HABITAT_STEP)

func habitat_capacity() -> float:
	return habitat_fraction() * 2000.0

func metabolism_cap() -> int:
	if adaptation_level >= ADAPTATION_MAX:
		return METABOLISM_MAX
	return 10 + int(floor(float(adaptation_level) * 10.0 / float(ADAPTATION_MAX)))

func replication_cap() -> int:
	if metabolism_level < 10:
		return 0
	return min(REPLICATION_MAX, 1 + adaptation_level)

func metabolism_cost() -> float:
	return 10.0 * pow(1.55, metabolism_level)

func replication_cost() -> float:
	return 500.0 * pow(1.38, replication_level)

func adaptation_cost() -> float:
	return 1800.0 * pow(1.32, adaptation_level)

func _buy_metabolism() -> void:
	var cost := metabolism_cost()
	if energy >= cost and metabolism_level < metabolism_cap():
		energy -= cost
		metabolism_level += 1

func _buy_replication() -> void:
	var cost := replication_cost()
	if energy >= cost and replication_level < replication_cap():
		energy -= cost
		replication_level += 1

func _buy_adaptation() -> void:
	var cost := adaptation_cost()
	if energy >= cost and adaptation_level < ADAPTATION_MAX and metabolism_level >= metabolism_cap():
		energy -= cost
		adaptation_level += 1

func _buy_cooperation() -> void:
	if not _can_cooperate():
		return
	era_complete = true
	_refresh_ui()

func _can_cooperate() -> bool:
	return metabolism_level >= METABOLISM_MAX and replication_level >= REPLICATION_MAX and adaptation_level >= ADAPTATION_MAX

func _refresh_ui() -> void:
	energy_label.text = _format_number(energy) + " Energy"
	energy_rate_label.text = "+" + _format_number(energy_per_second()) + " / sec"
	population_label.text = "Population  " + _format_number(population)
	habitat_label.text = "Habitat Access  %d%%" % int(round(habitat_fraction() * 100.0))
	habitat_fill.size.x = habitat_fill.get_parent().size.x * habitat_fraction()
	cell_field.set("population", population)
	cell_field.set("habitat_fraction", habitat_fraction())
	cell_field.queue_redraw()

	var metabolism_locked := metabolism_level >= metabolism_cap() and metabolism_level < METABOLISM_MAX
	var metabolism_detail := "MAXIMUM" if metabolism_level >= METABOLISM_MAX else ("Not enough energy in habitat space" if metabolism_locked else _format_number(metabolism_cost()) + " Energy")
	metabolism_button.text = "METABOLISM  %d/%d\n%s" % [metabolism_level, METABOLISM_MAX, metabolism_detail]
	metabolism_button.disabled = era_complete or metabolism_level >= METABOLISM_MAX or metabolism_locked or energy < metabolism_cost()

	var replication_requirement := metabolism_level < 10
	var replication_locked := replication_level >= replication_cap() and replication_level < REPLICATION_MAX
	var replication_detail := "MAXIMUM" if replication_level >= REPLICATION_MAX else ("Requires Metabolism 10" if replication_requirement else ("Habitat capacity reached" if replication_locked else _format_number(replication_cost()) + " Energy"))
	replication_button.text = "REPLICATION  %d/%d\n%s" % [replication_level, REPLICATION_MAX, replication_detail]
	replication_button.disabled = era_complete or replication_level >= REPLICATION_MAX or replication_requirement or replication_locked or energy < replication_cost()

	var can_expand := metabolism_level >= metabolism_cap()
	var adaptation_detail := "100% Habitat Access" if adaptation_level >= ADAPTATION_MAX else (_format_number(adaptation_cost()) + " Energy" if can_expand else "Current habitat still supports growth")
	adaptation_button.text = "ADAPTATION  %d/%d\n%s" % [adaptation_level, ADAPTATION_MAX, adaptation_detail]
	adaptation_button.disabled = era_complete or adaptation_level >= ADAPTATION_MAX or not can_expand or energy < adaptation_cost()

	cooperation_button.text = "CELLULAR COOPERATION\n" + ("ERA I COMPLETE" if era_complete else ("Begin Era II" if _can_cooperate() else "Requires Metabolism, Replication & Adaptation MAX"))
	cooperation_button.disabled = era_complete or not _can_cooperate()

	if era_complete:
		status_label.text = "ERA I COMPLETE — Individual cells begin cooperating."
	elif metabolism_level < 10:
		status_label.text = "Improve metabolism until life can sustain replication."
	elif metabolism_locked and adaptation_level < ADAPTATION_MAX:
		status_label.text = "Available habitat is exhausted. Adapt to expand."
	elif adaptation_level >= ADAPTATION_MAX and not _can_cooperate():
		status_label.text = "The entire habitat is accessible. Complete the remaining adaptations."
	else:
		status_label.text = "Life is spreading through the accessible habitat."

func _format_number(value: float) -> String:
	if value >= 1000000.0:
		return "%.2fM" % (value / 1000000.0)
	if value >= 1000.0:
		return "%.2fK" % (value / 1000.0)
	return "%.1f" % value
