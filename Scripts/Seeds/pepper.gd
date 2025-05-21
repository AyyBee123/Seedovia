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
		shoot_current_seed(resource_preloader.get_resource("Pepper Child").instantiate(), direction)

func shoot_current_seed(instantiated_weapon, _desired_direction = desired_direction, pos = global_position):
	instantiated_weapon.parent = self
	instantiated_weapon.add_child(get_node("Passives").duplicate())
	super.shoot_current_seed(instantiated_weapon, _desired_direction, pos)

func create_explosion(explosion):
	get_tree().current_scene.add_child(explosion)
	explosion.global_position = self.global_position
