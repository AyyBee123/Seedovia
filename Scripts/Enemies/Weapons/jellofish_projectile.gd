extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var trail_rate = $"Trail Rate"

const JELLOFISH_PROJECTILE_TRAIL = preload("res://Scenes/Enemies/Effects/Jellofish Projectile Trail.tscn")

func _ready():
	super._ready()
	speed = 750

func _physics_process(delta):
	initialize_position()
	update_position(delta)
	
	if trail_rate.is_stopped():
		trail_rate.start()
		var trail = JELLOFISH_PROJECTILE_TRAIL.instantiate()
		get_tree().current_scene.add_child(trail)
		trail.rotation = $Sprite2D.rotation
		trail.global_position = $Sprite2D.global_position

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		player._player_stats.take_damage(damage)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
