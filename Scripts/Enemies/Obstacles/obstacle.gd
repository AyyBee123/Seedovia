extends CharacterBody2D

@onready var damage_buffer := $"Damage Buffer" # prevents an accidental extra damage call if sitting in enemy hitbox
@export var _enemy_stats: enemy_stats

var stats
var player
var is_in_area := false

func _ready():
	_enemy_stats = _enemy_stats.duplicate()
	_enemy_stats.initialize_stats(_enemy_stats)
	_enemy_stats.set_health(1)

func _physics_process(delta):
	if is_in_area and damage_buffer.is_stopped() and _enemy_stats.damage > 0:
		player._player_stats.take_damage(_enemy_stats)
		damage_buffer.start()
	# once all the enemies in the current room are defeated, destroy the obstacle
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		await get_tree().create_timer(0.5, false).timeout
		die()

func _on_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player = body
		is_in_area = true

func die():
	process_mode = 4 # = Mode: Disabled
	# TODO: add death animation
	call_deferred("free")
