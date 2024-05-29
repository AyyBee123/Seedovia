extends "res://Scripts/Seeds/seed_template.gd"

var enemy

func _physics_process(delta):
	initialize_position()
	travelled_distance()
	distance_after_collision()
	update_position(delta)

func _collide(body):
	if not ignore_first_collision:
		has_collided.emit(body)
		attempted_fire.emit()
		if body.is_in_group("Enemies"):
			enemy = body
			body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
		var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2\
		else PlayerSeeds.seeds[slot_index + 1]
		if weapon != null:
			shoot_next_weapon(weapon)
		call_deferred("free")
	else:
		ignore_first_collision = false
		
func initialize_position():
	if not position_initialized:
		starting_position = global_position
		if slot_index == 0:
			direction = global_position.direction_to(get_global_mouse_position())
		else:
			var nearest_enemy = get_nearest_enemy(hit_enemy)
			direction = desired_direction
		position_initialized = true
	
func shoot_next_weapon(weapon):
	if get_nearest_enemy(enemy) != null:
		weapon_direction = global_position.direction_to(get_nearest_enemy(enemy).global_position)
	else:
		weapon_direction = global_position.direction_to(player.global_position)
	var weapon_instance = weapon.instantiate()
	get_weapon_properties(weapon_instance, weapon_direction, true, enemy)
	weapon_fired.emit()

func initialize_location(weapon_instance):
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = global_position
	weapon_fired.emit(weapon_instance)
	
func travelled_distance():
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= _player_stats.get_stat("Weapon_Range") * range_multiplier:
		attempted_fire.emit()
		for i in range(seed_slots.size()):
			var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2\
			else PlayerSeeds.seeds[slot_index + 1]
			if weapon != null:
				shoot_next_weapon(weapon)
			break
		call_deferred("free")
		
func get_nearest_enemy(enemy):
	var enemies = get_tree().get_nodes_in_group("Enemies")
	if enemy != null:
		# removes the hit enemy from the array so that the projectile does not target it when "bouncing"
		for i in range(enemies.size()): 
			if enemies[i] == enemy:
				enemies.remove_at(i)
				break # break out of the loop because only one enemy is hit anyway, so it's reduntent to continue
	var nearest_enemy = null
	var nearest_distance = null
	for i in enemies.size():
		if nearest_enemy == null:
			nearest_enemy = enemies[i]
			nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
		else:
			if nearest_distance > enemies[i].global_position.distance_squared_to(global_position):
				nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
				nearest_enemy = enemies[i]
	return nearest_enemy
