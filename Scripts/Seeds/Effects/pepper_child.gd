extends "res://Scripts/Seeds/seed_template.gd"

var parent

@onready var projectile_speed_timer := $"Projectile Deceleration"
@onready var life_time := $Lifetime
@onready var resource_preloader := $ResourcePreloader
@onready var mild_explosion_SFX = $MildExplosion

func _ready():
	projectile_speed_timer.start()
	life_time.start()

func _physics_process(delta):
	initialize_position()
	update_position(delta)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		direction = desired_direction
		position_initialized = true

func update_position(delta):
	var current_velocity: Vector2 = direction * _player_stats.get_stat("Weapon_Speed") * \
			speed_multiplier * projectile_speed_timer.time_left
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func _on_hitbox_area_entered(area):
	has_collided.emit(area)
	if area.is_in_group("Enemies"):
			area.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * \
					damage_multiplier / 2)
	explode()

func _on_hitbox_body_entered(body):
	has_collided.emit(body)
	explode()

func _on_lifetime_timeout():
	explode()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = _player_stats.get_stat("Weapon_Damage") * damage_multiplier
	explosion.size = _player_stats.get_stat("Weapon_Blast_Radius") * blast_radius_multiplier
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.ORANGE_RED
	SfxDeconflicter.play(mild_explosion_SFX)
	visible = false
	call_deferred("create_child", explosion)
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	for i in range(seed_slots.size()):
		var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or \
				slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
		shoot_next_weapon()
		break
	# call defer twice to allow passives that trigger off of weapon fire to work
	# Otherwise, the weapon is destroyed before it has a chance to trigger the passives
	if mild_explosion_SFX.playing:
		await mild_explosion_SFX.finished
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
