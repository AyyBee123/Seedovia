extends CharacterBody2D

@onready var player := $"../Player"
@export var _enemy_stats: enemy_stats

var damage_number = preload("res://Scenes/UI/damage_number.tscn")

func _ready():
	_enemy_stats.initialize_stats(_enemy_stats)
	_enemy_stats.set_health(_enemy_stats.max_health)
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.health_depleted.connect(die)
	_enemy_stats.spawn_damage_number.connect(spawn_damage_number)

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player._player_stats.take_damage(_enemy_stats)
		
func die():
	process_mode = 4 # = Mode: Disabled
	# TODO: add death animation
	self.queue_free()
	
func update_health(new_health):
	_enemy_stats.health = new_health
	
func spawn_damage_number(damage: float):
	var value = str(round(damage))
	var pos = global_position
	var height = 20
	var spread = 75
	var damage_text = damage_number.instantiate()
	get_tree().current_scene.add_child(damage_text, true)
	damage_text.global_position = global_position
	damage_text.set_and_animate_damage(damage, pos, height, spread)
