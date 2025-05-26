extends Node2D

@onready var delay = $Delay

const ENEMY_EXPLOSION = preload("res://Scenes/Enemies/Weapons/Enemy Explosion.tscn")
const LAVA = preload("res://Scenes/Enemies/Weapons/Lava.tscn")

var DELAY := 1.0

func _ready():
	delay.start(DELAY)
	visible = false

func destroy():
	var explosion = ENEMY_EXPLOSION.instantiate()
	var lava = LAVA.instantiate()
	explosion.is_vanity = true
	explosion.modulate = "272727"
	explosion.size = 0.5
	explosion.z_index = z_index
	get_tree().current_scene.add_child(explosion)
	get_tree().current_scene.add_child(lava)
	lava.global_position = global_position
	explosion.global_position = global_position
	Game.audio_manager.play(Game.audio_manager.chocolate_splat)
	Game.audio_manager.play(Game.audio_manager.pome_mild_explosion_2)
	queue_free()

func _on_delay_timeout():
	$AnimationPlayer.play("Fall")
