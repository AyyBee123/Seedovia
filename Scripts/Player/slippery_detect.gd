extends Area2D

const FRICTION = 0.1
const ACCELERATION = 0.1
const DASH_DISTANCE = 0.5
var _is_slip: bool

@onready var player = get_parent()

func _physics_process(delta):
	if get_overlapping_areas().size() > 0:
		if not _is_slip:
			trigger()
	else:
		if _is_slip:
			untrigger()

func trigger():
	_is_slip = true
	player._player_stats.set_stat("Friction", "x", FRICTION)
	player._player_stats.set_stat("Acceleration", "x", ACCELERATION)
	player._player_stats.set_stat("Dash_Distance", "x", DASH_DISTANCE)

func untrigger():
	_is_slip = false
	player._player_stats.set_stat("Friction", "x", 1.0 / FRICTION)
	player._player_stats.set_stat("Acceleration", "x", 1.0 / ACCELERATION)
	player._player_stats.set_stat("Dash_Distance", "x", 1.0 / DASH_DISTANCE)
