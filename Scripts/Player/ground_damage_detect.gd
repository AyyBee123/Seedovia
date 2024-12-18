extends Area2D

@onready var damage_buffer = $"Damage Buffer"

const DAMAGE = 1
var _is_in_area: bool

@onready var player = get_parent()

func _physics_process(delta):
	if get_overlapping_areas().size() > 0 and damage_buffer.is_stopped():
		trigger()
		damage_buffer.start()

func trigger():
	player._player_stats.take_damage(DAMAGE)
