extends Node2D

@onready var damage_buffer := $"Damage Buffer"
@onready var animation_player := $AnimationPlayer
@onready var resource_preloader = $ResourcePreloader

@onready var fire_delay = $"Fire Delay"
@onready var shoot_right_delay = $"Shoot Right Delay"
@onready var fire_rate_left = $"Fire Rate Left"
@onready var fire_rate_right = $"Fire Rate Right"

# marker positions
@onready var top_left = $"Top Left"
@onready var bottom_left = $"Bottom Left"
@onready var top_right = $"Top Right"
@onready var bottom_right = $"Bottom Right"

var damage = 1
var range = 0
var speed = 0

var is_in_area := false
var right_was_delayed := false
var source
var player

func _physics_process(delta):
	if is_in_area and damage_buffer.is_stopped():
		player._player_stats.take_damage(self)
		damage_buffer.start()
	if fire_delay.is_stopped():
		shoot_left()
	if right_was_delayed and shoot_right_delay.is_stopped():
		shoot_right()
	if source == null:
		disappear()

func disappear():
	animation_player.play("Disappear")

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player = body
		is_in_area = true

func _on_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func _on_animation_player_animation_finished(anim_name):
	queue_free()

func shoot_left(): # shoot bullets in the left direction from the laser
	if fire_rate_left.is_stopped():
		var spread = deg_to_rad(randf_range(-10,10))
		var bullet = resource_preloader.get_resource("Bullet").instantiate()
		bullet.damage = damage
		bullet.range = range
		bullet.speed = speed
		bullet.direction = Vector2(-1, 0).rotated(spread)
		get_tree().current_scene.add_child(bullet)
		bullet.global_position.x = top_left.global_position.x
		bullet.global_position.y = randf_range(top_left.global_position.y, bottom_left.global_position.y)
		fire_rate_left.start()
		if not right_was_delayed:
			shoot_right_delay.start()
			right_was_delayed = true

func shoot_right(): # shoot bullets in the right direction from the laser
	if fire_rate_right.is_stopped():
		var spread = deg_to_rad(randf_range(-15,15))
		var bullet = resource_preloader.get_resource("Bullet").instantiate()
		bullet.damage = damage
		bullet.range = range
		bullet.speed = speed
		bullet.direction = Vector2(1, 0).rotated(spread)
		get_tree().current_scene.add_child(bullet)
		bullet.global_position.x = top_right.global_position.x
		bullet.global_position.y = randf_range(top_right.global_position.y, bottom_right.global_position.y)
		fire_rate_right.start()
