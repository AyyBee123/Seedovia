extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var fire_rate = $"Fire Rate"
var shoot_direction: Vector2
var bullet = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var bullet_spawn_point = $"Bullet Spawn Point"

func _ready():
	super._ready()
	fire_rate.start(1.0/_enemy_stats.fire_rate)
	shoot_direction = Vector2(0,-1)

func _physics_process(delta):
	super._physics_process(delta)
	if fire_rate.is_stopped():
		animated_sprite_2d.play("default")

func shoot():
	shoot_bullet()
	change_direction()
	fire_rate.start(1.0/_enemy_stats.fire_rate)

func shoot_bullet():
	var bullet_instance = bullet.instantiate()
	bullet_instance.damage = _enemy_stats.weapon_damage
	bullet_instance.range = _enemy_stats.weapon_range
	bullet_instance.speed = _enemy_stats.weapon_speed
	bullet_instance.direction = shoot_direction.normalized()
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = bullet_spawn_point.global_position + shoot_direction.normalized() * 10

func change_direction():
	match shoot_direction:
		Vector2(0,-1):
			shoot_direction = Vector2(1,-1)
		Vector2(1,-1):
			shoot_direction = Vector2(1,0)
		Vector2(1,0):
			shoot_direction = Vector2(1,1)
		Vector2(1,1):
			shoot_direction = Vector2(0,1)
		Vector2(0,1):
			shoot_direction = Vector2(-1,1)
		Vector2(-1,1):
			shoot_direction = Vector2(-1,0)
		Vector2(-1,0):
			shoot_direction = Vector2(-1,-1)
		Vector2(-1,-1):
			shoot_direction = Vector2(0,-1)

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.stop()

func _on_animated_sprite_2d_frame_changed():
	# frame 3 is the "shoot" sprite frame
	if animated_sprite_2d.frame == 3:
		shoot()

