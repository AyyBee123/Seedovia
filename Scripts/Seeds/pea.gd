extends "res://Scripts/Seeds/seed_template.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

var enemy

func _ready():
	super._ready()
	if slot_index != 0:
		var nearest_enemy = get_nearest_enemy(hit_enemy)

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		enemy = body
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	shoot_next_weapon()
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.bubble_pop_2)
	explode()
	destroy()

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	if get_nearest_enemy(enemy) != null:
		weapon_direction = global_position.direction_to(get_nearest_enemy(enemy).global_position)
	else:
		weapon_direction = global_position.direction_to(player.global_position)
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true, enemy)

func initialize_location(weapon_instance):
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = global_position
	weapon_fired.emit(weapon_instance)
	
func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		destroy()

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

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.2 * SIZE
	splash.source = self
	splash.modulate = Color("4ba329")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
