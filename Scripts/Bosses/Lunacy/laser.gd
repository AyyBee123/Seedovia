extends AnimatedSprite2D

@onready var damage_buffer = $"Damage Buffer"

var damage = 1
var is_in_area := false
var source
var player

func _physics_process(delta):
	if is_in_area and damage_buffer.is_stopped():
		player._player_stats.take_damage(damage)
		damage_buffer.start()

func _on_area_2d_body_entered(body):
	if body.is_in_group("Players"):
		player = body
		is_in_area = true

func _on_area_2d_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false
