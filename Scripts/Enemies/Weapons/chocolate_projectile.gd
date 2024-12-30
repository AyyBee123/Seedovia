extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D

func _ready():
	super._ready()
	$Shadow.visible = false

func _physics_process(delta):
	initialize_position()
	update_position(delta)

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		player._player_stats.take_damage(damage)
		queue_free()

func play_splat():
	Game.audio_manager.play(Game.audio_manager.chocolate_splat)

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Start":
		speed = randf_range(200, 500)
		$AnimationPlayer.play("new_animation")
	if animated_sprite_2d.animation == "Pop":
		queue_free()

func pop():
	set_physics_process(false)
	$Shadow.visible = false
	$AnimatedSprite2D/Area2D/CollisionShape2D.disabled = true
	animated_sprite_2d.play("Pop")
