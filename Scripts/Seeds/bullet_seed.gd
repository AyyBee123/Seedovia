extends "res://Scripts/Seeds/seed_template.gd"

func _collide(body):
	if not ignore_first_collision:
		if body.is_in_group("Enemies"):
			body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
		for i in range(seed_slots.size()):
			var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
			if weapon != null:
				shoot_next_weapon(weapon, body)
			break
		queue_free()
	else:
		ignore_first_collision = false
	
func shoot_next_weapon(weapon, enemy = null):
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
	
	var weapon_instance = weapon.instantiate()
	weapon_instance.initial_weapon = false
	weapon_instance.ignore_first_collision = true
	weapon_instance.slot_index = slot_index + 1
	call_deferred("initialize_location", weapon_instance, nearest_enemy)
	
func initialize_location(weapon_instance, nearest_enemy):
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = global_position
	weapon_instance.velocity = -velocity if nearest_enemy == null else (nearest_enemy.global_position - global_position).normalized()
	weapon_instance.rotation = weapon_instance.velocity.angle()
	
func travelled_distance():
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= _player_stats.get_stat("Weapon_Range") * range_multiplier:
		for i in range(seed_slots.size()):
			var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
			if weapon != null:
				shoot_next_weapon(weapon)
			break
		queue_free()
