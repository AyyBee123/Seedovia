extends "res://Scripts/Enemies/Weapons/bullet.gd"

var temp_speed
var start_pos: float
var end_pos: float

func _ready():
	super._ready()
	speed = 0
	$Sprite2D.position.y = -(end_pos - start_pos)
	
	var tween = get_tree().create_tween()
	
	tween.tween_property($Sprite2D, "position:y", 0, 1)
	tween.parallel().tween_property($Shadow, "scale", Vector2(0.688, 1.25), 1)
	tween.tween_callback(launch)

func launch():
	$"Bullet Hitbox/CollisionShape2D".disabled = false
	$Shadow.visible = false
	speed = temp_speed

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		player._player_stats.take_damage(damage)

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
