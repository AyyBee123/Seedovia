extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D

const ORBITAL_BULLET = preload("res://Scenes/Enemies/Weapons/Orbital Bullet.tscn")

const NUMBER_OF_BULLETS = 3

var direction: Vector2
var idle_radius = 50
var mad_radius = 250
var bullets: Array

func _ready():
	super._ready()
	for i in NUMBER_OF_BULLETS:
		var bullet = ORBITAL_BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		bullet.speed = _enemy_stats.weapon_speed
		bullet.starting_angle = TAU / NUMBER_OF_BULLETS * i
		bullet.radius = idle_radius
		bullet.source = self
		bullet.z_index = z_index
		get_tree().current_scene.add_child.call_deferred(bullet)
		bullet.global_position = global_position
		bullets.append(bullet)

func _physics_process(delta):
	super._physics_process(delta)
	direction = global_position.direction_to(player.global_position)

func idle():
	velocity = velocity.lerp(direction * _enemy_stats.speed, _enemy_stats.acceleration)

func mad():
	velocity = velocity.lerp(direction * _enemy_stats.speed / 2, _enemy_stats.acceleration)

func set_radius(_radius):
	for bullet in bullets:
		bullet.change_radius(_radius)
