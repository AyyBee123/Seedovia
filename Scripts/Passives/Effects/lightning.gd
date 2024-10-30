extends Sprite2D

signal weapon_fired(weapon) # signal for firing the next seed
signal has_collided(object) # signal for colliding with an enemy or wall
signal attempted_fire # signal for attempting to fire the next seed (even if the next seed is null)

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats
@onready var flip_timer = $"Flip Timer"
@onready var lifetime = $Lifetime

var nearest_enemy = null
var pos
var damage_multiplier: float = 1
var damage: float

func _ready():
	if nearest_enemy != null:
		nearest_enemy.get_parent()._enemy_stats.take_damage(damage)

func _on_flip_timer_timeout():
	flip_v = not flip_v
	flip_timer.start()

func _on_lifetime_timeout():
	if nearest_enemy != null:
		has_collided.emit(nearest_enemy)
	queue_free()

func chain_lightning():
	pass
