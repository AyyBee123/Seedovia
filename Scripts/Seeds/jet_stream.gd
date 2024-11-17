extends "res://Scripts/Seeds/seed_template.gd"

var enemy
@onready var hit_SFX = $Hit

func _ready():
	ignore_first_collision_timer = Timer.new()
	ignore_first_collision_timer.one_shot = true
	ignore_first_collision_timer.connect("timeout", set_ignore_first_collision)
	ignore_first_collision_timer.wait_time = 0.05
	ignore_first_collision_timer.autostart = true
	speed_multiplier *= transferred_speed_multiplier
	range_multiplier *= transferred_range_multiplier
	size_multiplier *= transferred_size_multiplier
	damage_multiplier *= transferred_damage_multiplier
	blast_radius_multiplier *= transferred_blast_radius_multiplier
	fire_rate_multiplier *= transferred_fire_rate_multiplier
	scale = scale * player._player_stats.get_stat("Weapon_Size") * size_multiplier

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
	shoot_next_weapon()
	SfxDeconflicter.play(hit_SFX)
	if hit_SFX.playing:
		await hit_SFX.finished
	queue_free()

func shoot_next_weapon():
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	if get_nearest_enemy(enemy) != null:
		weapon_direction = global_position.direction_to(get_nearest_enemy(enemy).global_position)
	else:
		weapon_direction = global_position.direction_to(player.global_position)
	get_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true, enemy)

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
