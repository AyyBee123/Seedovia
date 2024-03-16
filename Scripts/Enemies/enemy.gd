extends CharacterBody2D

@onready var player := $"../Player"
@onready var health_bar := $"Health Bar"
@onready var damage_buffer := $"Damage Buffer" # prevents an accidental extra damage call if sitting in enemy hitbox
@export var _enemy_stats: enemy_stats

var is_in_area := false

var damage_number = preload("res://Scenes/UI/damage_number.tscn")

func _ready():
	_enemy_stats.initialize_stats(_enemy_stats)
	_enemy_stats.set_health(_enemy_stats.max_health)
	health_bar.init_health(_enemy_stats.max_health)
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.health_depleted.connect(die)
	_enemy_stats.spawn_damage_number.connect(spawn_damage_number)

func _physics_process(delta):
	if is_in_area and damage_buffer.is_stopped():
		player._player_stats.take_damage(_enemy_stats)
		damage_buffer.start()

func _on_enemy_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		is_in_area = true

func die():
	process_mode = 4 # = Mode: Disabled
	# TODO: add death animation
	call_deferred("free")
	
func update_health(new_health):
	health_bar.health = new_health
	
func spawn_damage_number(damage: float):
	var value = str(round(damage))
	var pos = global_position
	var height = 20
	var spread = 75
	var damage_text = damage_number.instantiate()
	get_tree().current_scene.add_child(damage_text, true)
	damage_text.global_position = global_position
	damage_text.set_and_animate_damage(damage, pos, height, spread)
