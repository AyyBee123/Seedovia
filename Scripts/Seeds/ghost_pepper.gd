extends "res://Scripts/Seeds/seed_template.gd"

var radius: float = 60
var speed: float = 0.5
var angle: float = 0
static var number_of_ghosts

@onready var fire_rate = $"Fire Rate"
@onready var lifetime = $Lifetime

func _physics_process(delta):
	super._physics_process(delta)
	look()
	orbit(delta)
	if get_next_weapon() != null:
		if fire_rate.is_stopped() and get_nearest_enemy() != null:
			shoot_next_weapon()

func shoot_next_weapon():
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	var weapon_instance = get_next_weapon().instantiate()
	weapon_direction = global_position.direction_to(get_nearest_enemy().global_position)
	fire_rate.start(1.0/_player_stats.get_stat("Fire_Rate") / weapon_instance.fire_rate_multiplier)
	get_weapon_properties(weapon_instance, weapon_direction)

func update_position(delta):
	current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta

func look():
	if get_nearest_enemy() == null:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = false if get_nearest_enemy().global_position.x > global_position.x else true

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

func orbit(delta):
	angle += delta
	if slot_index == 0: # if shot by the player
		rotate_around(player.global_position)
	else: # if shot by a seed
		if previous_weapon == null: # if the previous weapon doesn't/no longer exists
			var nearest_enemy = get_nearest_enemy()
			if nearest_enemy == null: # if there are no enemies
				rotate_around(starting_position)
			else: # if there is an enemy
				rotate_around(nearest_enemy.global_position)
		else: # if the previous weapon exists
			rotate_around(previous_weapon.global_position)

func rotate_around(entity_position):
	global_position = Vector2(
		sin(angle * speed * deg_to_rad(360.0/1)) * radius,
		cos(angle * speed * deg_to_rad(360.0/1)) * radius
	) + entity_position

func travelled_distance():
	pass

func _collide(body):
	pass

func _on_lifetime_timeout():
	queue_free.call_deferred()
