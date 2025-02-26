extends CharacterBody2D

@export var _enemy_stats: enemy_stats
@onready var damage_buffer := $"Damage Buffer" # prevents an accidental extra damage call if sitting in enemy hitbox

const DAMAGE_COLOR = Color(0.5, 0, 0)
var original_color

var stats
var player
var health_bar
var is_in_area := false
var _damaged_color_changed := false

var damage_number = preload("res://Scenes/UI/damage_number.tscn")

func _ready():
	original_color = modulate
	health_bar = $"Health Bar"
	_enemy_stats = _enemy_stats.duplicate()
	_enemy_stats.initialize_stats(_enemy_stats)
	_enemy_stats.set_health(_enemy_stats.max_health)
	health_bar.init_health(_enemy_stats.max_health)
	_enemy_stats.health_changed.connect(update_health)
	_enemy_stats.health_depleted.connect(die)
	_enemy_stats.spawn_damage_number.connect(spawn_damage_number)
	_enemy_stats.change_color.connect(change_color)

func _physics_process(delta):
	if player == null: # keep looking for the player until they are found
		player = Targets.get_player()
	if is_in_area and damage_buffer.is_stopped() and _enemy_stats.damage > 0:
		player._player_stats.take_damage(_enemy_stats.damage)
		damage_buffer.start()

func _on_enemy_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player = body # just in case
		is_in_area = true

func die():
	process_mode = 4 # = Mode: Disabled
	# TODO: add death animation
	queue_free.call_deferred()
	
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

## set the enemy color to red for a brief time whne taking damage
func change_color():
	$AnimatedSprite2D.material.set("shader_parameter/tint_factor", 0.8)
	await get_tree().create_timer(0.05, false).timeout
	$AnimatedSprite2D.material.set("shader_parameter/tint_factor", 0.0)
