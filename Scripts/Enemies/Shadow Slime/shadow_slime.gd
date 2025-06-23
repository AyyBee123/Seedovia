extends "res://Scripts/Enemies/enemy.gd"

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var _state_machine = $state_machine
@onready var pointer = $Pointer
@onready var marker_2d = $Pointer/Marker2D

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")
const SPREAD = PI/4

var _can_move: bool = false
var direction: Vector2
var _jumping: bool
var rotation_speed: float = 2.5

func _ready():
	super._ready()
	$Shadow.visible = false

func _physics_process(delta):
	visible = true
	super._physics_process(delta)

func jump():
	if _can_move:
		velocity = direction.normalized() * _enemy_stats.speed
	else:
		velocity = Vector2.ZERO

func idle():
	velocity = Vector2.ZERO
	if player:
		direction = global_position.direction_to(player.global_position)
		pointer.rotation = direction.angle()

func dive():
	if player:
		direction = global_position.direction_to(player.global_position)
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), rotation_speed \
				* get_physics_process_delta_time())
	
	if _can_move:
		velocity = velocity.lerp(global_position.direction_to(marker_2d.global_position) * _enemy_stats.speed * 2, \
				_enemy_stats.acceleration)

func shoot():
	_can_move = false
	
	var directions = [-SPREAD, 0, SPREAD]
	for i in directions:
		var bullet = BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		bullet.speed = _enemy_stats.weapon_speed
		bullet.direction = global_position.direction_to(player.global_position).rotated(i)
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + bullet.direction * 20

func jump_finished():
	_jumping = false

func set_spawn_state():
	_state_machine.set_state(_state_machine.states.spawn)

func play_sound(_node: NodePath):
	get_node(_node).play()

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Dive":
		_can_move = true
		$"Enemy Hitbox/CollisionPolygon2D".disabled = true
