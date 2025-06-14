extends "res://Scripts/Enemies/Weapons/bullet.gd"

const LIQUID = preload("res://Scenes/Enemies/Weapons/Liquid.tscn")
const ENEMY_EXPLOSION = preload("res://Scenes/Enemies/Weapons/Enemy Explosion.tscn")

var pos: Vector2
var tween

func _ready():
	super._ready()
	tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos, 1)

func break_pot():
	var liquid = LIQUID.instantiate()
	liquid.damage = damage
	liquid.scale *= 1.25
	get_tree().current_scene.add_child(liquid)
	liquid.global_position = global_position
	Game.audio_manager.play(Game.audio_manager.pome_mild_explosion_2)
	Game.audio_manager.play(Game.audio_manager.rock_3)
	var explosion = ENEMY_EXPLOSION.instantiate()
	explosion.damage = damage
	explosion.size = 0.7
	explosion.source = self
	explosion.modulate = "000000"
	call_deferred("create_child", explosion)
	queue_free()

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
