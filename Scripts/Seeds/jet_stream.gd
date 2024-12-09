extends "res://Scripts/Seeds/seed_template.gd"

var enemy

func travelled_distance():
	distance_travelled = starting_position.distance_squared_to(global_position)
	if distance_travelled >= 1:
		total_distance += 1
		starting_position = global_position
	if total_distance >= player._player_stats.get_stat("Weapon_Range") * range_multiplier:
		queue_free.call_deferred()
	if get_next_weapon() != null:
		if total_distance > 0 and total_distance % max(int(15/(player._player_stats.get_stat("Fire_Rate") \
				* get_next_weapon().instantiate().fire_rate_multiplier)), 1) == 0:
			shoot_next_weapon()

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(player._player_stats.get_stat("Weapon_Damage") * damage_multiplier)
	SfxDeconflicter.play(Game.audio_manager.jetstream_hit)
	queue_free()

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	var directions = [-PI/2, PI/2]
	for rotated_direction in directions:
		attempted_fire.emit()
		weapon_direction = direction.rotated(rotated_direction)
		set_weapon_properties(get_next_weapon().instantiate(), weapon_direction)
