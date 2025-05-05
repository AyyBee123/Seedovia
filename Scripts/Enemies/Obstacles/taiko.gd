extends "res://Scripts/Enemies/Obstacles/obstacle.gd"

@onready var knockback_buffer = $"Knockback Buffer"
@onready var drum_SFX = $Drum
@onready var hit_SFX = $Hit2

const PLAYER_KNOCKBACK = preload("res://Scenes/Misc/Player Knockback.tscn")
const KNOCKBACK = preload("res://Scenes/Seeds/Effects/Knockback.tscn")

@export var direction: Vector2

var collision

func _physics_process(delta):
	super._physics_process(delta)
	
	velocity = direction * _enemy_stats.speed
	collision = move_and_collide(velocity * delta)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		direction = velocity.normalized()
	
	if is_in_area and knockback_buffer.is_stopped():
		knockback_player(player)

func knockback_player(body):
	$AnimatedSprite2D.play("Beat")
	drum_SFX.play()
	hit_SFX.play()
	if not body.is_in_group("Players"):
		return
	player = body # just in case player was null before
	if not knockback_buffer.is_stopped(): # prevent multiple knockbacks at once
		return
	# knock the player back if they are hit
	var knockback = PLAYER_KNOCKBACK.instantiate()
	var knockback_direction = global_position.direction_to(player.global_position).angle()
	knockback.knockback_direction = Vector2.RIGHT.rotated(knockback_direction).normalized()
	knockback.knockback_speed = 1500
	# add node to the player that gives velocity/position change
	body.add_child(knockback)
	knockback_buffer.start()

func _on_animated_sprite_2d_animation_finished():
	$AnimatedSprite2D.play("Idle")

func _on_enemy_hitbox_2_area_entered(area):
	if not area.is_in_group("Enemies"):
		return
	# knock the enemy back if they are hit
	$AnimatedSprite2D.play("Beat")
	drum_SFX.play()
	hit_SFX.play()
	var knockback = KNOCKBACK.instantiate()
	var knockback_direction = global_position.direction_to(area.get_parent().global_position).angle()
	knockback.knockback_direction = Vector2.RIGHT.rotated(knockback_direction).normalized()
	knockback.knockback_speed = 1000
	knockback.damage = 10
	# add node to the player that gives velocity/position change
	area.get_parent().add_child(knockback)
