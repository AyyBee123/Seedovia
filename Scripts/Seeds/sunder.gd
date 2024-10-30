extends "res://Scripts/Seeds/seed_template.gd"

@onready var resource_preloader = $ResourcePreloader

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	if distance_travelled >= 1:
		total_distance += 1
		starting_position = global_position
	if total_distance >= _player_stats.get_stat("Weapon_Range") * range_multiplier:
		call_deferred("free")
	if total_distance % 10 == 0:
		explode()
		if total_distance % 20 == 0 and total_distance != 0:
			weapon_direction = Vector2.RIGHT.rotated(randf_range(0, 2 * PI))
			shoot_next_weapon()

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	call_deferred("free")

func explode():
	var explosion = resource_preloader.get_resource("Non-Weapon Effect Explosion").instantiate()
	for passive in $Passives.get_children():
		explosion.get_node("Passives").add_child(passive.duplicate())
	explosion.damage = _player_stats.get_stat("Weapon_Damage") * damage_multiplier
	explosion.damage_multiplier = damage_multiplier
	explosion.size = _player_stats.get_stat("Weapon_Blast_Radius") * blast_radius_multiplier
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.SADDLE_BROWN
	call_deferred("create_child", explosion)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = global_position
