extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var lifetime = $Lifetime
@onready var pointer = $Pointer
@onready var marker_2d = $Pointer/Marker2D

const LIQUID_ICE = preload("res://Scenes/Misc/Liquid Ice.tscn")
const RANGE = 75

var direction: Vector2
var rotation_speed: float
var distance_travelled = 0
var total_distance = 0
var starting_position
var original_size

func _ready():
	super._ready()
	rotation_speed = 3
	starting_position = global_position
	original_size = animated_sprite_2d.scale
	
	# look at the player's spawn point at the start to avoid turning when entering a new room
	pointer.rotation = global_position.direction_to(Vector2(0, 330)).angle()

func _physics_process(delta):
	super._physics_process(delta)
	if player:
		direction = global_position.direction_to(player.global_position)
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), rotation_speed * delta)
		velocity = velocity.lerp(global_position.direction_to(marker_2d.global_position) * _enemy_stats.speed, \
				_enemy_stats.acceleration)
	move_and_slide()
	# dies within 8 seconds by default, if not damaged by the player
	_enemy_stats.health_decay(0.125 * _enemy_stats.max_health * delta)
	animated_sprite_2d.scale = (original_size - Vector2.ONE * 0.5) * _enemy_stats.health/_enemy_stats.max_health\
			 + Vector2.ONE * 0.5
	$CollisionPolygon2D.scale = animated_sprite_2d.scale
	$"Enemy Hitbox/CollisionPolygon2D".scale = animated_sprite_2d.scale
	travelled_distance()

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		total_distance = 0
		var ice = LIQUID_ICE.instantiate()
		get_tree().current_scene.add_child(ice)
		ice.global_position = global_position
