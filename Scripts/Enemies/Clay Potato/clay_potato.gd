extends "res://Scripts/Enemies/enemy.gd"

@onready var fire_rate = $"Fire Rate"
@onready var stomp_SFX = $Stomp
@onready var animated_sprite_2d = $AnimatedSprite2D

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const SPREAD = PI/12

var direction: Vector2

func _ready():
	super._ready()
	$Shadow.visible = false
	randomize()
	fire_rate.start(randf_range(2, 3))

func _physics_process(delta):
	super._physics_process(delta)
	direction = global_position.direction_to(player.global_position)
	
	if animated_sprite_2d.animation == "Jump":
		velocity = direction * _enemy_stats.speed
	else:
		velocity = Vector2.ZERO
		direction = global_position.direction_to(player.global_position)
	
	move_and_slide()

func _on_fire_rate_timeout():
	animated_sprite_2d.play("Jump")
	$Shadow.visible = true

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("Idle")
	$Shadow.visible = false
	var angle = 0
	while angle < TAU:
		var bullet = BULLET.instantiate()
		bullet.direction = Vector2.RIGHT.rotated(angle)
		bullet.speed = _enemy_stats.weapon_speed
		bullet.range = _enemy_stats.weapon_range
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		angle += SPREAD
	
	fire_rate.start()
	stomp_SFX.play()
	Targets.get_camera().add_trauma(0.25)
