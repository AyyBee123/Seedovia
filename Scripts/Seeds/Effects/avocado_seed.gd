extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(player._player_stats.get_stat("Weapon_Damage") * damage_multiplier)
	explode()
	SfxDeconflicter.play(Game.audio_manager.walnut_hit)
	queue_free.call_deferred()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.175
	splash.source = self
	splash.modulate = Color("51351a")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func shoot_next_weapon():
	pass
