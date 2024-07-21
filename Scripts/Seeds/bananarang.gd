extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var acceleration = $Acceleration

var has_stopped := false
var is_stopping := false
var is_decelerating := false
var previous_weapon_position: Vector2
var position_checked := false
var direction_changed := false

func update_position(delta):
	if previous_weapon != null:
		position_checked = true
		previous_weapon_position = previous_weapon.global_position
	if not has_stopped:
		if not is_stopping:
			current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier
		else:
			current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier\
			* deceleration.time_left
	else:
		if initial_weapon:
			direction = global_position.direction_to(player.global_position) # goes towards the player's position
		else:
			if not direction_changed:
				if position_checked:
					# goes towards the last known position of the previous weapon
					direction = global_position.direction_to(previous_weapon_position)
				else:
					direction = -direction
				if previous_weapon == null:
					direction_changed = true
		current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier\
		* (deceleration.wait_time - acceleration.time_left) / deceleration.wait_time
	position += current_velocity * delta
	rotation += deg_to_rad(-10)

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
	if has_stopped:
		call_deferred("free")
	else:
		has_stopped = true
	weapon_direction = -direction
	shoot_next_weapon()

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	if distance_travelled >= 1:
		total_distance += 1
		starting_position = global_position
	if total_distance >= _player_stats.get_stat("Weapon_Range") * range_multiplier:
		if not is_stopping:
			is_decelerating = true
			is_stopping = true
			deceleration.start()
			weapon_direction = direction
			shoot_next_weapon()

func _on_deceleration_timeout():
	if has_stopped:
		return
	has_stopped = true
	acceleration.start(deceleration.wait_time)

func shoot_next_weapon():
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	get_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func _on_detect_previous_seed_body_entered(body): # detects the player
	if not has_stopped:
		return
	if initial_weapon:
		if body.is_in_group("Players"):
			queue_free()

func _on_detect_previous_seed_area_entered(area): # detects the previous weapon
	if not has_stopped:
		return
	if area.get_parent() == previous_weapon:
		queue_free()
