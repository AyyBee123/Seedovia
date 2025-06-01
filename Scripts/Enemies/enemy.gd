extends CharacterBody2D

@export var _enemy_stats: enemy_stats
@onready var damage_buffer := $"Damage Buffer" # prevents an accidental extra damage call if sitting in enemy hitbox
@onready var accumulated_damage_text = $"Health Bar/Accumulated Damage"
@onready var accumulated_timer_delay = $"Health Bar/Accumulated Timer Delay"

const DAMAGE_COLOR = Color(0.5, 0, 0)
const IMMUNITY_TIME = 0.016667

var original_color
var accumulated_damage = 0
var immunity_frame_time: float = 0

var stats
var player
var health_bar
var is_in_area := false
var damage_color = Color.WHITE
var damage_size = 1

var damage_number = preload("res://Scenes/UI/damage_number.tscn")

func _ready():
	accumulated_damage_text.visible = false
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
	
	if accumulated_timer_delay.is_stopped():
		accumulated_damage_text.visible = false
		accumulated_damage = 0
	else:
		accumulated_damage_text.visible = true

func _on_enemy_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player = body # just in case
		is_in_area = true

func die():
	process_mode = 4 # = Mode: Disabled
	queue_free.call_deferred()
	
func update_health(new_health):
	health_bar.health = new_health

func spawn_damage_number(damage: float):
	accumulated_damage += damage
	accumulated_damage_text.text = str(int(round(accumulated_damage)))
	accumulated_timer_delay.start()

## set the enemy color to red for a brief time whne taking damage
func change_color():
	$AnimatedSprite2D.material.set("shader_parameter/tint_factor", 0.8)
	await get_tree().create_timer(0.05, false).timeout
	$AnimatedSprite2D.material.set("shader_parameter/tint_factor", 0.0)

func instance_seed(_seed: Node, _direction: Vector2, _pos: Vector2 = global_position, _timer = null, \
		_shader = null, _time: float = 1):
	var seed = _seed
	seed.desired_direction = _direction
	seed.previous_weapon = self
	seed.source = self
	seed.slot_index = 3
	seed.seed_slot_number = 3
	seed.collisions |= 2 # add the player collision
	seed.collisions &= 3 # player & wall (if the seed had a wall collision)
	seed.target_group = "Players"
	seed.shader = _shader
	seed.remove_from_group("Seed")
	seed.remove_from_group("Weapon to be Destroyed")
	seed.remove_from_group("Weapon")
	seed.add_to_group("Enemy Weapon")
	if seed.get_node_or_null("Passives"):
		for n in seed.get_node("Passives").get_children():
			n.queue_free()
	get_tree().current_scene.add_child.call_deferred(seed)
	seed.global_position = _pos
	if _timer:
		_timer.start(1.0 / seed.FIRE_RATE * _time)
