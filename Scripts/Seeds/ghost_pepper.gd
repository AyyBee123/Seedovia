extends "res://Scripts/Seeds/seed_template.gd"

var radius: float = 60
var speed: float = 0.5
var angle: float = 0
static var number_of_ghosts
var current_radius: float = 5
var _is_dying := false

@onready var fire_rate = $"Fire Rate"
@onready var lifetime = $Lifetime

func _ready():
	super._ready()
	lifetime.start()
	transferred_damage_multiplier *= damage_multiplier

func _physics_process(delta):
	super._physics_process(delta)
	look()
	orbit(delta)
	if get_next_weapon() != null:
		if fire_rate.is_stopped() and get_nearest_enemy() != null:
			shoot_next_weapon()

func shoot_next_weapon():
	if _is_dying:
		return
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	var weapon_instance = get_next_weapon().instantiate()
	weapon_direction = global_position.direction_to(get_nearest_enemy().global_position)
	fire_rate.start(1.0 / player._player_stats.get_stat("Fire_Rate") * fire_rate_multiplier)
	set_weapon_properties(weapon_instance, weapon_direction)

func update_position(delta):
	current_velocity = direction * player._player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta

func look():
	if get_nearest_enemy() == null:
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = false if get_nearest_enemy().global_position.x > global_position.x else true

func get_nearest_enemy(object = null):
	var enemies = Targets.get_enemy_hitboxes()
	if object != null and object.is_in_group("Enemies"):
		# removes the hit enemy from the array so that the projectile does not target it when "bouncing"
		for i in range(enemies.size()):
			if enemies[i] == object:
				enemies.remove_at(i)
				break # break out of the loop because only one enemy is hit anyway, so it's reduntent to continue
	var nearest_enemy = null
	var nearest_distance = null
	for i in enemies.size():
		if nearest_enemy == null:
			if is_instance_valid(enemies[i]): # prevents game from crashing if enemy dies to quickly
				nearest_enemy = enemies[i]
				nearest_distance = enemies[i].global_position.distance_squared_to(global_position)
		else:
			if is_instance_valid(enemies[i]):
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
			die()
		else: # if the previous weapon exists
			rotate_around(previous_weapon.global_position)

func rotate_around(entity_position):
	current_radius = min(current_radius + 1, radius)
	global_position = Vector2(
		sin(angle * speed * deg_to_rad(360.0/1)) * current_radius,
		cos(angle * speed * deg_to_rad(360.0/1)) * current_radius
	) + entity_position

func travelled_distance():
	pass

func _collide(body):
	pass

func die():
	_is_dying = true
	scale -= Vector2.ONE * 0.05
	if scale <= Vector2.ZERO:
		queue_free.call_deferred()

func _on_lifetime_timeout():
	die()
