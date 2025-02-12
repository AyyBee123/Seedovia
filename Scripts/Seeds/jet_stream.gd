extends "res://Scripts/Seeds/seed_template.gd"

var enemy
var distance_to_shoot: float

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	distance_to_shoot += distance_travelled
	starting_position = global_position
	if total_distance >= player._player_stats.get_stat("Weapon_Range") * range_multiplier:
		queue_free.call_deferred()
	if get_next_weapon() != null:
		if total_distance > 0 and distance_to_shoot >= 70.0 / get_next_weapon().instantiate().fire_rate_multiplier:
			shoot_next_weapon()
			distance_to_shoot = 0

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(player._player_stats.get_stat("Weapon_Damage") * damage_multiplier)
	SfxDeconflicter.play(Game.audio_manager.jetstream_hit)
	SfxDeconflicter.play(Game.audio_manager.bubble_pop_2)
	queue_free()

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	var directions = [-PI/2, PI/2]
	for rotated_direction in directions:
		attempted_fire.emit()
		weapon_direction = direction.rotated(rotated_direction)
		set_weapon_properties(get_next_weapon().instantiate(), weapon_direction)
