extends "res://Scripts/Enemies/Weapons/bullet.gd"

const BULLET = preload("res://Scenes/Enemies/Weapons/Bullet.tscn")

const SPREAD = PI/4

var start_pos: float
var end_pos: float
var angle := 0.0

func _ready():
	super._ready()
	speed = 0
	$Sprite2D.position.y = -(end_pos - start_pos)
	
	var tween = get_tree().create_tween()
	
	tween.tween_property($Sprite2D, "position:y", 0, 0.15)
	tween.parallel().tween_property($Shadow, "scale", Vector2(2, 3.631), 0.15)
	tween.tween_callback(launch)

func launch():
	$"Bullet Hitbox/CollisionShape2D".disabled = false
	while angle < TAU:
		var bullet = BULLET.instantiate()
		bullet.direction = Vector2.RIGHT.rotated(angle)
		bullet.speed = 500
		bullet.range = 500
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		angle += SPREAD
	Game.audio_manager.play(Game.audio_manager.stomp)
	queue_free.call_deferred()

func update_position(delta):
	pass

func travelled_distance():
	pass

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		player._player_stats.take_damage(damage)
