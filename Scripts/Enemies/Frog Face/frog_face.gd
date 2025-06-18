extends "res://Scripts/Enemies/enemy.gd"

@onready var animation_player = $AnimationPlayer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var splat = $Splat
@onready var splat_2 = $Splat2

const FLY_BULLET = preload("res://Scenes/Enemies/Weapons/Fly Bullet.tscn")

const NUMBER_OF_FLIES = 3

var direction: Vector2
var can_move: bool

func _ready():
	super._ready()
	$"Enemy Hitbox/CollisionPolygon2D".disabled = false
	$Shadow.visible = false

func idle():
	velocity = Vector2.ZERO
	if player:
		direction = global_position.direction_to(player.global_position)

func jump():
	if can_move:
		velocity = direction * _enemy_stats.speed
	else:
		velocity = Vector2.ZERO

func spawn_flies():
	for i in NUMBER_OF_FLIES:
		var bullet = FLY_BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.speed = _enemy_stats.weapon_speed
		bullet.range = _enemy_stats.weapon_range
		bullet.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		bullet.rotation_speed = 5
		bullet.home_time = 0.5
		bullet.home_delay = 0.25
		bullet.ignore_first_collision = true
		get_tree().current_scene.add_child.call_deferred(bullet)
		bullet.global_position = global_position

func set_move(_bool):
	can_move = _bool

func play_jump_sound():
	splat.play()

func play_land_sound():
	splat_2.play()
