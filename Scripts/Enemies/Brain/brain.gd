extends "res://Scripts/Enemies/enemy.gd"

@onready var downward_direction_point = %"Downward Direction Point"
@onready var forward_direction_point = %"Forward Direction Point"
@onready var fire_time = $"Fire Time"

var bullet = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

var downward_direction
var forward_direction
var initial_downward_velocity
var direction = 1
var rot

func _ready():
	randomize()
	super._ready()
	downward_direction = global_position.direction_to(downward_direction_point.global_position)
	fire_time.wait_time = randf_range(1, 1.2)
	
	rot = rotation
	rotation = 0
	$AnimatedSprite2D.rotation = rot
	$"Enemy Hitbox/CollisionPolygon2D".rotation = rot
	$CollisionPolygon2D.rotation = rot
	$"Wall Detect".rotation = rot
	$Node2D.rotation = rot

func _physics_process(delta):
	super._physics_process(delta)
	if player:
		$"Rotation Point".look_at(player.global_position)
	velocity = velocity.lerp(downward_direction * _enemy_stats.speed, _enemy_stats.acceleration)
	move_forward()
	
	move_and_slide()

func move_forward():
	forward_direction = global_position.direction_to(forward_direction_point.global_position)
	velocity = velocity.lerp(forward_direction * _enemy_stats.speed * direction, _enemy_stats.acceleration)
	shoot()

func _on_wall_detect_body_entered(body):
	direction *= -1

func shoot():
	if fire_time.is_stopped():
		shoot_bullet()
		fire_time.start(1)

func shoot_bullet():
	var bullet_instance = bullet.instantiate()
	bullet_instance.damage = _enemy_stats.weapon_damage
	bullet_instance.range = _enemy_stats.weapon_range
	bullet_instance.speed = _enemy_stats.weapon_speed
	bullet_instance.direction = global_position.direction_to(player.global_position)
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = $"Rotation Point/Marker2D".global_position
