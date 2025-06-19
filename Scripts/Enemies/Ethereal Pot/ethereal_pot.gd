extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@export var enemy_number: int = 0
@export_range(0, 360) var starting_angle: float = 0

@onready var enemy_list: Array = Targets.get_enemies()
@onready var fire_rate = $"Fire Rate"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var whiff_SFX = $Whiff

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

var target
var radius: float = 65
var speed: float
var angle = 0

func _ready():
	super._ready()
	speed = _enemy_stats.speed
	fire_rate.start(randf_range(1.5, 3))
	enemy_number = min(enemy_number, enemy_list.size() - 1)
	target = enemy_list[enemy_number]
	z_index = target.z_index

func _physics_process(delta):
	super._physics_process(delta)
	
	if not is_instance_valid(target):
		queue_free()
	
	if is_instance_valid(target):
		angle += delta
		global_position = Vector2(
			sin(angle * speed + deg_to_rad(starting_angle)) * radius,
			cos(angle * speed + deg_to_rad(starting_angle)) * radius
		) + target.global_position

func _on_fire_rate_timeout():
	animated_sprite_2d.play("Shoot")

func _on_animated_sprite_2d_frame_changed():
	if animated_sprite_2d.animation == "Shoot":
		if animated_sprite_2d.frame == 3:
			var bullet = BULLET.instantiate()
			bullet.damage = _enemy_stats.weapon_damage
			bullet.range = _enemy_stats.weapon_range
			bullet.speed = _enemy_stats.weapon_speed
			bullet.scale = Vector2.ONE
			bullet.direction = global_position.direction_to(player.global_position)
			get_tree().current_scene.add_child(bullet)
			bullet.global_position = global_position
			whiff_SFX.play()

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Shoot":
		animated_sprite_2d.play("Idle")
		fire_rate.start(1.0/_enemy_stats.fire_rate)
