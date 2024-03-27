extends Node2D

@onready var damage_buffer := $"Damage Buffer"
@onready var animation_player := $AnimationPlayer
@onready var player := $"../Player"

var damage := 0

var is_in_area := false

func _physics_process(delta):
	if is_in_area and damage_buffer.is_stopped():
		player._player_stats.take_damage(self)
		damage_buffer.start()

func disappear():
	animation_player.play("Disappear")

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		is_in_area = true

func _on_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false

func _on_animation_player_animation_finished(anim_name):
	queue_free()
