extends "res://Scripts/Seeds/seed_template.gd"

@onready var resource_preloader = $ResourcePreloader

func travelled_distance():
	distance_travelled = starting_position.distance_squared_to(global_position)
	if distance_travelled >= 1:
		total_distance += 1
		starting_position = global_position
	if total_distance >= player._player_stats.get_stat("Weapon_Range") * range_multiplier:
		queue_free.call_deferred()
	if total_distance % 2 == 0:
		splat()

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	queue_free.call_deferred()

func splat():
	var syrup = resource_preloader.get_resource("Syrup").instantiate()
	for passive in $Passives.get_children():
		syrup.get_node("Passives").add_child(passive.duplicate())
	syrup.damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier
	syrup.size = player._player_stats.get_stat("Weapon_Blast_Radius") * blast_radius_multiplier
	syrup.source = self
	syrup.next_weapon = get_next_weapon()	
	call_deferred("create_child", syrup)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = global_position
