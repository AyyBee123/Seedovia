extends "res://Scripts/Enemies/Weapons/bullet.gd"

@onready var fire_rate = $"Fire Rate"

const LIQUID = preload("res://Scenes/Enemies/Weapons/Liquid.tscn")
const ENEMY_EXPLOSION = preload("res://Scenes/Enemies/Weapons/Enemy Explosion.tscn")

func _physics_process(delta):
	super._physics_process(delta)
	if fire_rate.is_stopped():
		var liquid = LIQUID.instantiate()
		liquid.damage = damage
		get_tree().current_scene.add_child(liquid)
		liquid.global_position = global_position
		fire_rate.start()

func update_position(delta):
	super.update_position(delta)
	look_at(global_position + direction)

func _collide(body):
	if ignore_first_collision:
		return
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
	
	var liquid = LIQUID.instantiate()
	liquid.scale *= 2.5
	liquid.damage = damage
	get_tree().current_scene.add_child.call_deferred(liquid)
	liquid.global_position = global_position
	
	Game.audio_manager.play(Game.audio_manager.strawberry_mild_explosion)
	Game.audio_manager.play(Game.audio_manager.rock_4)
	
	var explosion = ENEMY_EXPLOSION.instantiate()
	explosion.damage = damage
	explosion.size = 1.5
	explosion.source = self
	explosion.modulate = "000000"
	call_deferred("create_child", explosion)
	queue_free()

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
