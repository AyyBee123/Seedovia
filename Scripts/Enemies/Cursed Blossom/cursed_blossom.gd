extends "res://Scripts/Enemies/enemy.gd"

@onready var fire_rate = $"Fire Rate"
@onready var animated_sprite_2d = $AnimatedSprite2D

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

var direction: Vector2

func _ready():
	super._ready()
	randomize()
	fire_rate.start(randf_range(1.5, 2))

func _physics_process(delta):
	super._physics_process(delta)
	direction = global_position.direction_to(player.global_position)

func _on_animated_sprite_2d_animation_changed():
	if animated_sprite_2d.animation == "Shoot":
		var bullet = BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		bullet.speed = _enemy_stats.weapon_speed
		bullet.direction = direction
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + direction * 5
		fire_rate.start(1)

func _on_fire_rate_timeout():
	animated_sprite_2d.play("Shoot")

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("Idle")
