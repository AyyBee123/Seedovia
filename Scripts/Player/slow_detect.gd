extends Area2D

const SLOW_MULTIPLIER = 0.5
var _is_slowed: bool

@onready var player = get_parent()

func _physics_process(delta):
	if get_overlapping_areas().size() > 0:
		if not _is_slowed:
			trigger()
	else:
		if _is_slowed:
			untrigger()

func trigger():
	_is_slowed = true
	player._player_stats.set_temp_stat("Speed", "x", SLOW_MULTIPLIER)

func untrigger():
	_is_slowed = false
	player._player_stats.set_temp_stat("Speed", "x", 1.0 / SLOW_MULTIPLIER)
