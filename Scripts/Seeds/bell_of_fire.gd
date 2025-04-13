extends "res://Scripts/Seeds/seed_template.gd"

const NON_WEAPON_EFFECT_EXPLOSION = preload("res://Scenes/Passives/Effects/Non-Weapon Effect Explosion.tscn")
const BELL_OF_FIRE_POOL = preload("res://Scenes/Seeds/Effects/Bell of Fire Pool.tscn")

func _physics_process(delta):
	super._physics_process(delta)
	$Sprite2D.rotation += PI * delta

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	explode()

func explode():
	var explosion = NON_WEAPON_EFFECT_EXPLOSION.instantiate()
	if get_node_or_null("Passives"):
		for passive in $Passives.get_children():
			explosion.get_node("Passives").add_child(passive.duplicate())
	explosion.BASE_DAMAGE = BASE_DAMAGE
	explosion.BASE_SIZE = BASE_BLAST_RADIUS
	explosion.collisions = collisions
	if shader:
		explosion.get_node("AnimatedSprite2D").material = ShaderMaterial.new()
		explosion.get_node("AnimatedSprite2D").material.shader = shader
	if source != player:
		explosion.get_node("Area2D").set_collision_layer(16)
	explosion.get_node("AnimatedSprite2D").self_modulate = Color("de4b13")
	SfxDeconflicter.play(Game.audio_manager.fire_explosion)
	call_deferred("create_child", explosion)
	if source == player: # spawn the fire pool only if shot by the player or a player seed
		var pool = BELL_OF_FIRE_POOL.instantiate()
		pool.scale *= BLAST_RADIUS
		pool.desired_direction = direction
		pool.slot_index = slot_index
		pool.seed_slot_number = seed_slot_number
		pool.source = source
		pool.target_group = target_group
		pool.transferred_speed_multiplier *= transferred_speed_multiplier
		pool.transferred_range_multiplier *= transferred_range_multiplier
		pool.transferred_size_multiplier *= transferred_size_multiplier
		pool.transferred_damage_multiplier *= transferred_damage_multiplier
		pool.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
		pool.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
		pool.add_child(get_node("Passives").duplicate())
		call_deferred("create_child", pool)
	queue_free.call_deferred()

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
