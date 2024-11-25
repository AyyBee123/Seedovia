extends "res://Scripts/Seeds/seed_template.gd"

@onready var resource_preloader = $ResourcePreloader
@onready var mild_explosion_SFX = $SunderExplosion

func travelled_distance():
	distance_travelled = starting_position.distance_squared_to(global_position)
	if distance_travelled >= 1:
		total_distance += 1
		starting_position = global_position
	if total_distance >= final_range:
		queue_free.call_deferred()
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
	queue_free.call_deferred()

func explode():
	var explosion = resource_preloader.get_resource("Non-Weapon Effect Explosion").instantiate()
	for passive in $Passives.get_children():
		explosion.get_node("Passives").add_child(passive.duplicate())
	explosion.damage = final_damage
	explosion.damage_multiplier = damage_multiplier
	explosion.size = final_blast_radius
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.SADDLE_BROWN
	SfxDeconflicter.play(mild_explosion_SFX)
	call_deferred("create_child", explosion)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = global_position
