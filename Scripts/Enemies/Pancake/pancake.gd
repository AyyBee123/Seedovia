extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var marker = $Marker2D

const PANCAKE_PROJECTILE = preload("res://Scenes/Enemies/Weapons/Pancake Projectile.tscn")

const NUMBER_OF_PROJECTILES = 2
const SPREAD = PI/4

var player_direction: Vector2
var projectile_count: int = 0

func _physics_process(delta):
	super._physics_process(delta)
	player_direction = global_position.direction_to(player.global_position)

func idle():
	velocity = Vector2.ZERO

func jump():
	velocity = player_direction * _enemy_stats.speed
	move_and_slide()

func charge():
	pass

func shoot():
	if projectile_count == 1:
		var current_frame = animated_sprite_2d.get_frame()
		var current_progress = animated_sprite_2d.get_frame_progress()
		animated_sprite_2d.play("Float 1 Pancake")
		animated_sprite_2d.set_frame_and_progress(current_frame, current_progress)

func shoot_pancakes():
	for i in NUMBER_OF_PROJECTILES:
		var proj = PANCAKE_PROJECTILE.instantiate()
		proj.direction = player_direction.rotated(-SPREAD / 2 + SPREAD * i)
		proj.range = _enemy_stats.weapon_range
		proj.damage = _enemy_stats.weapon_damage
		proj.speed = _enemy_stats.weapon_speed
		proj.source = self
		get_tree().current_scene.add_child(proj)
		proj.global_position = marker.global_position

func uncharge():
	pass
