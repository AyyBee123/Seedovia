extends "res://Scripts/Seeds/seed_template.gd"

@onready var projectile_speed_timer := $"Projectile Deceleration"
@onready var resource_preloader := $ResourcePreloader
@onready var mild_explosion_SFX = $MildExplosion

func update_position(delta):
	current_velocity = direction * player._player_stats.get_stat("Weapon_Speed") * speed_multiplier * projectile_speed_timer.time_left
	position += current_velocity * delta

func _collide(body):
	if not ignore_first_collision:
		has_collided.emit(body)
		if body.is_in_group("Enemies"):
			body.get_parent()._enemy_stats.take_damage(player._player_stats.get_stat("Weapon_Damage") * damage_multiplier / 2)
		explode()
	else:
		ignore_first_collision = false

func _on_lifetime_timeout():
	explode()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier
	explosion.size = player._player_stats.get_stat("Weapon_Blast_Radius") * blast_radius_multiplier
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.ORANGE_RED
	SfxDeconflicter.play(mild_explosion_SFX)
	visible = false
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	call_deferred("create_explosion", explosion)
	spawn_child_peppers()
	if mild_explosion_SFX.playing:
		await mild_explosion_SFX.finished
	queue_free.call_deferred()

func travelled_distance():
	pass

func spawn_child_peppers():
	# split the pepper into 4 smaller peppers with the indicated launch directions
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	for direction in directions:
		var pepper_child = resource_preloader.get_resource("Pepper Child").instantiate()
		weapon_direction = direction
		pepper_child.desired_direction = direction
		pepper_child.seed_slots = seed_slots
		pepper_child.slot_index = slot_index
		pepper_child.seed_slot_number = seed_slot_number
		pepper_child.parent = self
		pepper_child.add_child(get_node("Passives").duplicate())
		call_deferred("create_child", pepper_child)
		weapon_fired.emit(pepper_child)

func create_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = self.global_position

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
