extends "res://Scripts/Seeds/seed_template.gd"

var parent

@onready var deceleration := $Deceleration
@onready var lifetime := $Lifetime
@onready var resource_preloader := $ResourcePreloader

func _ready():
	super._ready()
	deceleration.start()
	lifetime.start()

func _physics_process(delta):
	update_position(delta)

func update_position(delta):
	var current_velocity: Vector2 = direction * SPEED * deceleration.time_left
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func _on_hitbox_area_entered(area):
	has_collided.emit(area)
	if area.is_in_group("Enemies"):
		area.get_parent()._enemy_stats.take_damage(DAMAGE / 2)
	explode()

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	has_collided.emit(body)
	explode()

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
	SfxDeconflicter.play(Game.audio_manager.pepper_child_mild_explosion)
	call_deferred("create_child", explosion)
	for i in range(seed_slots.size()):
		var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or \
				slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
		shoot_next_weapon()
		break
	# call defer twice to allow passives that trigger off of weapon fire to work
	# Otherwise, the weapon is destroyed before it has a chance to trigger the passives
	destroy.call_deferred()

func shoot_next_weapon():
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	for direction in directions:
		weapon_direction = direction
		super.shoot_next_weapon()

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = global_position

func destroy():
	queue_free.call_deferred()
