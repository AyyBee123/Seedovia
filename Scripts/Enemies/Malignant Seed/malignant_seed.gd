extends "res://Scripts/Enemies/enemy.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var fire_rate = $"Fire Rate"
@onready var fart_SFX = $Fart

var collision
var direction: Vector2

const STATIONARY_BULLET = preload("res://Scenes/Enemies/Weapons/Stationary Bullet.tscn")

@export_range(-1, 1) var x_direction: int = 1
@export_range(-1, 1) var y_direction: int = 1

func _ready():
	super._ready()
	direction = Vector2(x_direction, y_direction).normalized()
	fire_rate.start()

func _physics_process(delta):
	super._physics_process(delta)
	velocity = velocity.lerp(Vector2.ZERO, _enemy_stats.friction)
	
	collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		direction = velocity.normalized()
	
	animated_sprite_2d.rotation = direction.angle() - PI/4

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("Idle")

func _on_fire_rate_timeout():
	animated_sprite_2d.play("Shoot")
	fart_SFX.play()
	
	var bullet = STATIONARY_BULLET.instantiate()
	bullet.damage = _enemy_stats.weapon_damage
	bullet.range = _enemy_stats.weapon_range
	bullet.speed = _enemy_stats.weapon_speed
	bullet.direction = Vector2.ZERO
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position
	
	velocity = _enemy_stats.speed * direction.normalized()
	fire_rate.start()
