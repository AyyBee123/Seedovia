extends "res://Scripts/Enemies/Weapons/bullet.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

var LIQUID

func _ready():
	super._ready()
	$AnimationPlayer.speed_scale = randf_range(0.8, 1.1)

func _physics_process(delta):
	initialize_position()
	update_position(delta)

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta

func _collide(body):
	if ignore_first_collision:
		return
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
	
	pop()

func pop():
	var splash = SPLASH.instantiate()
	splash.size = 0.25
	splash.source = self
	splash.modulate = "241111"
	Game.audio_manager.play(Game.audio_manager.chocolate_splat)
	call_deferred("create_child", splash)
	queue_free()

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
