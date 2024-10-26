extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var resource_preloader = $ResourcePreloader
var bullet = preload("res://Scenes/Enemies/Weapons/Spore.tscn")

func _on_animated_sprite_2d_animation_looped():
	shoot_bullet()

func shoot_bullet():
	var bullet_instance = bullet.instantiate()
	bullet_instance.damage = _enemy_stats.weapon_damage
	bullet_instance.range = _enemy_stats.weapon_range
	bullet_instance.speed = _enemy_stats.weapon_speed
	while bullet_instance.direction == Vector2.ZERO:
		bullet_instance.direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = global_position + bullet_instance.direction * 10
