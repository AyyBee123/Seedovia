extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var laser_whoosh = $LaserWhoosh

const WAVE = preload("res://Scenes/Enemies/Weapons/Wave.tscn")

const OFFSET = 8.5
const SPEED_BURST_MULTIPLIER = 8
const SPREAD = PI/6

var direction: Vector2 = Vector2(1, 0)
var starting_dash_pos: Vector2
var total_dash_distance: float
var dash_distance_travelled: float

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	animated_sprite_2d.flip_h = direction.x < 0
	animated_sprite_2d.offset.x = sign(direction.x) * OFFSET

func idle():
	if player:
		direction = global_position.direction_to(player.global_position)
	velocity = velocity.lerp(direction * _enemy_stats.speed, _enemy_stats.friction)

func slash():
	velocity = velocity.lerp(direction * _enemy_stats.speed * SPEED_BURST_MULTIPLIER, _enemy_stats.acceleration)

func spawn_wave(_spread):
	var bullet = WAVE.instantiate()
	bullet.damage = _enemy_stats.weapon_damage
	bullet.range = _enemy_stats.weapon_range
	bullet.speed = _enemy_stats.weapon_speed
	bullet.direction = direction.rotated(_spread)
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + direction * 20
