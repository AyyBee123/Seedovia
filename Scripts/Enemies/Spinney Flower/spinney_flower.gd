extends "res://Scripts/Enemies/enemy.gd"

@onready var fire_rate = $"Fire Rate"
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var pop_SFX = $Pop

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

var direction: Vector2

func _ready():
	randomize()
	super._ready()

func _physics_process(delta):
	super._physics_process(delta)
	direction = global_position.direction_to(player.global_position)

func idle():
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)

func spin():
	velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	
	if fire_rate.is_stopped():
		var bullet = BULLET.instantiate()
		bullet.damage = _enemy_stats.weapon_damage
		bullet.range = _enemy_stats.weapon_range
		bullet.speed = _enemy_stats.weapon_speed
		bullet.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + bullet.direction * 20
		pop_SFX.play()
		fire_rate.start()

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "Spin Beginning":
		$AnimatedSprite2D.play("Spin")
