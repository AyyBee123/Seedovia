extends "res://Scripts/Passives/Classes/passive_chance.gd"

var source
var source_passives
var third_seed

func _ready():
	source = get_parent().get_parent()
	chance = 0.5
	source.has_collided.connect(chance_to_trigger)
	source.weapon_fired.connect(transfer_passive)
	super._ready()

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null or weapon.is_in_group("Weapon Effect"):
		return
	# make a new clockwork passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(self.duplicate())
	source_passives = source.get_node("Passives").get_children()

func trigger(enemy = null):
	third_seed = null if PlayerInventory.seeds.get(2) == null else PlayerInventory.seeds.get(2).scene
	if third_seed == null or not enemy.is_in_group("Enemies"):
		return
	var seed_instance = third_seed.instantiate()
	seed_instance.previous_weapon = source
	seed_instance.ignore_first_collision = true
	seed_instance.hit_enemy = enemy
	if get_nearest_enemy(enemy) != null:
		seed_instance.desired_direction = source.global_position.direction_to(get_nearest_enemy(enemy).global_position)
	else:
		seed_instance.desired_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	get_tree().current_scene.add_child.call_deferred(seed_instance)
	source.weapon_fired.emit(seed_instance)
	seed_instance.global_position = enemy.get_parent().global_position

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
			nearest_distance = enemies[i].global_position.distance_squared_to(source.global_position)
		else:
			if nearest_distance > enemies[i].global_position.distance_squared_to(source.global_position):
				nearest_distance = enemies[i].global_position.distance_squared_to(source.global_position)
				nearest_enemy = enemies[i]
	return nearest_enemy
