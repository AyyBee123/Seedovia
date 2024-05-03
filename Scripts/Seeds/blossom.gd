extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var lifetime = $Lifetime
@onready var fire_rate = $"Fire Rate"
@onready var animated_sprite_2d = $AnimatedSprite2D

var time_to_live: float = 5
var blossom_fire_rate_multiplier: float = 0.5

func _physics_process(delta):
	super._physics_process(delta)
	var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2\
		else PlayerSeeds.seeds[slot_index + 1]
	if weapon != null:
		if fire_rate.is_stopped() and get_nearest_enemy() != null and deceleration.is_stopped():
			attempted_fire.emit()
			shoot_next_weapon(weapon)

func update_position(delta):
	current_velocity = direction * _player_stats.get_stat("Weapon_Speed")\
	* speed_multiplier * deceleration.time_left
	position += current_velocity * delta

func travelled_distance():
	pass

func shoot_next_weapon(weapon):
	play_animation()
	var weapon_instance = weapon.instantiate()
	weapon_direction = global_position.direction_to(get_nearest_enemy().global_position)
	get_weapon_properties(weapon_instance, weapon_direction)
	fire_rate.start(1.0/_player_stats.get_stat("Fire_Rate") / weapon_instance.fire_rate_multiplier\
	/ blossom_fire_rate_multiplier)

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var nearest_enemy = null
	var nearest_distance = null
	for i in enemies.size():
		if nearest_enemy == null:
			nearest_enemy = enemies[i]
			nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
		else:
			if nearest_distance > enemies[i].global_position.distance_squared_to(global_position):
				nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
				nearest_enemy = enemies[i]
	return nearest_enemy

func _on_lifetime_timeout():
	queue_free.call_deferred()

func play_animation():
	animated_sprite_2d.play("Shoot")

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("Idle")

func _on_deceleration_timeout():
	lifetime.start(time_to_live)
