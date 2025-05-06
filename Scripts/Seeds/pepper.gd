extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration := $Deceleration
@onready var resource_preloader := $ResourcePreloader
@onready var lifetime = $Lifetime

func _ready():
	super._ready()
	lifetime.start()
	deceleration.start()

func update_position(delta):
	current_velocity = direction * SPEED * deceleration.time_left
	position += current_velocity * delta

func _collide(body):
	if not ignore_first_collision:
		has_collided.emit(body)
		if body.is_in_group("Enemies"):
			body.get_parent()._enemy_stats.take_damage(DAMAGE / 2)
		elif body.is_in_group("Players"):
			body._player_stats.take_damage(1)
		explode()
	else:
		ignore_first_collision = false

func _on_lifetime_timeout():
	explode()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = DAMAGE
	explosion.size = BLAST_RADIUS
	explosion.collisions = collisions
	if shader:
		explosion.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		explosion.get_node("AnimatedSprite2D").material.shader = shader
	if source != player:
		explosion.get_node("Area2D").set_collision_layer(16)
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.ORANGE_RED
	SfxDeconflicter.play(Game.audio_manager.pepper_mild_explosion)
	call_deferred("create_explosion", explosion)
	spawn_child_peppers()
	queue_free.call_deferred()

func travelled_distance():
	pass

func spawn_child_peppers():
	# split the pepper into 4 smaller peppers with the indicated launch directions
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	for direction in directions:
		var pepper_child = resource_preloader.get_resource("Pepper Child").instantiate()
		weapon_direction = direction
		pepper_child.collisions = collisions
		pepper_child.desired_direction = direction
		pepper_child.slot_index = slot_index
		pepper_child.seed_slot_number = seed_slot_number
		pepper_child.source = source
		pepper_child.target_group = target_group
		pepper_child.parent = self
		pepper_child.transferred_speed_multiplier *= transferred_speed_multiplier
		pepper_child.transferred_range_multiplier *= transferred_range_multiplier
		pepper_child.transferred_size_multiplier *= transferred_size_multiplier
		pepper_child.transferred_damage_multiplier *= transferred_damage_multiplier
		pepper_child.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
		pepper_child.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
		pepper_child.modulate = modulate
		pepper_child.add_child(get_node("Passives").duplicate())
		call_deferred("create_child", pepper_child)

func create_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = self.global_position

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
