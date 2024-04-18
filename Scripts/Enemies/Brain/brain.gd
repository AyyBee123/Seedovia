extends "res://Scripts/Enemies/enemy.gd"

@onready var downward_direction_point = $"Downward Direction Point"
@onready var forward_direction_point = $"Forward Direction Point"
@onready var fire_time = $"Fire Time"

var bullet = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

var downward_direction
var forward_direction
var initial_downward_velocity
var falling = true
var direction = 1

func _ready():
	super._ready()
	downward_direction = global_position.direction_to(downward_direction_point.global_position).normalized()

func _physics_process(delta):
	super._physics_process(delta)
	$"Rotation Point".look_at(player.global_position)

func move_down():
	velocity = velocity.lerp(downward_direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)

func move_forward():
	forward_direction = global_position.direction_to(forward_direction_point.global_position).normalized()
	velocity = velocity.lerp(forward_direction.normalized() * _enemy_stats.speed * direction, _enemy_stats.acceleration)
	shoot()

func _on_floor_detect_body_entered(body):
	falling = false

func _on_wall_detect_body_entered(body):
	direction *= -1

func shoot():
	var can_fire = false
	if fire_time.is_stopped():
		can_fire = true
		fire_time.start()
	if can_fire:
		shoot_bullet()

func shoot_bullet():
	var bullet_instance = bullet.instantiate()
	bullet_instance.damage = _enemy_stats.weapon_damage
	bullet_instance.range = _enemy_stats.weapon_range
	bullet_instance.speed = _enemy_stats.weapon_speed
	bullet_instance.direction = global_position.direction_to(player.global_position).normalized()
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = $"Rotation Point/Marker2D".global_position
