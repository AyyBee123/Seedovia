extends "res://Scripts/Seeds/seed_template.gd"

@onready var projectile_speed_timer := $"Projectile Deceleration"
@onready var resource_preloader := $ResourcePreloader

func update_position(delta):
	var current_velocity: Vector2 = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier * projectile_speed_timer.time_left
	position += current_velocity * delta

func _collide(body):
	if not ignore_first_collision:
		has_collided.emit(body)
		if body.is_in_group("Enemies"):
			body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier / 2)
		explode()
	else:
		ignore_first_collision = false

func _on_lifetime_timeout():
	explode()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = _player_stats.get_stat("Weapon_Damage") * damage_multiplier
	explosion.size = _player_stats.get_stat("Weapon_Blast_Radius") * blast_radius_multiplier
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.ORANGE_RED
	call_deferred("create_child", explosion)
	spawn_child_peppers()
	call_deferred("free")

func spawn_child_peppers():
	# split the pepper into 4 smaller peppers with the indicated launch directions
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	for direction in directions:
		var pepper_child = resource_preloader.get_resource("Pepper Child").instantiate()
		pepper_child.damage = _player_stats.get_stat("Weapon_Damage") * damage_multiplier * 0.3
		pepper_child.speed = _player_stats.get_stat("Weapon_Speed") * speed_multiplier
		pepper_child.explosion_size = _player_stats.get_stat("Weapon_Blast_Radius") * blast_radius_multiplier * 0.55
		pepper_child.direction = direction
		pepper_child.seed_slots = seed_slots
		pepper_child.slot_index = slot_index
		pepper_child.seed_slot_number_index = seed_slot_number_index
		call_deferred("create_child", pepper_child)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
