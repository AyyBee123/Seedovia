extends "res://Scripts/Enemies/enemy.gd"

@onready var marker_2d = $"Rotation Point"
@onready var hand = $"Rotation Point/Hand"
@onready var fire_rate = $"Fire Rate"
@onready var laser_shot = $LaserShot

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

var direction: Vector2
var weapon_direction: Vector2

func _ready():
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	
	if player:
		direction = global_position.direction_to(player.global_position).normalized()
		weapon_direction = direction
		marker_2d.look_at(player.global_position)
		approach(delta)
	else:
		marker_2d.rotation = direction.angle()
		stop()
	
	if direction.x > 0:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true

func approach(delta):
	if global_position.distance_to(player.global_position) > _enemy_stats.weapon_range * 0.75:
		velocity = velocity.lerp(direction * _enemy_stats.speed, _enemy_stats.acceleration)
		$AnimatedSprite2D.play("Move")
	elif global_position.distance_to(player.global_position) < _enemy_stats.weapon_range * 0.75:
		velocity = velocity.lerp(-direction * _enemy_stats.speed, _enemy_stats.acceleration)
		$AnimatedSprite2D.play("Move")
	else:
		velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
		$AnimatedSprite2D.play("Idle")
	
	if global_position.distance_to(player.global_position) <= _enemy_stats.weapon_range:
		if fire_rate.is_stopped():
			var bullet = BULLET.instantiate()
			bullet.direction = direction
			bullet.speed = _enemy_stats.weapon_speed
			bullet.range = _enemy_stats.weapon_range
			bullet.damage = _enemy_stats.weapon_damage
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = hand.global_position
			laser_shot.play()
			fire_rate.start()
	
	move_and_slide()

func stop():
	direction = global_position.direction_to(player.global_position)
	weapon_direction = direction
	
	if global_position.distance_to(player.global_position) > 100:
		velocity = velocity.lerp(direction * _enemy_stats.speed, _enemy_stats.acceleration)
		$AnimatedSprite2D.play("Move")
	else:
		velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction * 5)
		$AnimatedSprite2D.play("Idle")
	
	move_and_slide()
