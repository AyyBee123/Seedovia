extends Sprite2D

signal weapon_fired(weapon)

var position_initialized = false
var direction
var starting_position: Vector2 # gets the starting position from where the bullet is fired

var seed_slots
var slot_index
var seed_slot_number_index

var damage: float
var explosion_size: float

var speed: float

@onready var projectile_speed_timer := $"Projectile Deceleration"
@onready var life_time := $Lifetime
@onready var resource_preloader := $ResourcePreloader

func _physics_process(delta):
	initialize_position()
	update_position(delta)

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		position_initialized = true

func update_position(delta):
	var current_velocity: Vector2 = direction * speed * projectile_speed_timer.time_left
	position += current_velocity * delta
	look_at(global_position + current_velocity)

func _on_hitbox_area_entered(area):
	if area.is_in_group("Enemies"):
			area.get_parent()._enemy_stats.take_damage(damage / 2)
	explode()

func _on_hitbox_body_entered(body):
	explode()

func _on_lifetime_timeout():
	explode()

func explode():
	var explosion = resource_preloader.get_resource("Explosion").instantiate()
	explosion.damage = damage
	explosion.size = explosion_size
	explosion.get_node("AnimatedSprite2D").self_modulate = Color.ORANGE_RED
	call_deferred("create_child", explosion)
	for i in range(seed_slots.size()):
		var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
		if weapon != null:
			shoot_next_weapon(weapon)
		break
	queue_free()
	
func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func shoot_next_weapon(weapon):
	var directions = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]
	for direction in directions:
		var weapon_instance = weapon.instantiate()
		weapon_instance.initial_weapon = false
		weapon_instance.ignore_first_collision = true
		weapon_instance.slot_index = slot_index + 1
		weapon_instance.seed_slot_number = PlayerSeeds.seed_indices[seed_slot_number_index + 1]
		weapon_instance.seed_slot_number_index = seed_slot_number_index + 1
		weapon_fired.emit(weapon_instance)
		weapon_instance.desired_direction = direction
		call_deferred("spawn_child", weapon_instance)

func spawn_child(weapon_instance):
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = global_position
