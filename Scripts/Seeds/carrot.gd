extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

const SPREAD = PI/6
const NUMBER_OF_SHOTS = 2

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	explode()
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.hit_3)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	if body.is_in_group("Enemies") or body.is_in_group("Obstacle"):
		for i in NUMBER_OF_SHOTS:
			weapon_direction = direction.rotated(-SPREAD/2 + i * SPREAD)
			shoot_next_weapon()
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	else: # hitting a wall will destroy the carrot
		destroy()

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.35 * SIZE
	splash.source = self
	splash.modulate = Color("d55c20")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
