extends "res://Scripts/Seeds/seed_template.gd"

var enemy
var distance_to_shoot: float
var distance = 500

func _ready():
	super._ready()
	if target_group == "Players":
		BASE_SPEED /= 4

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	distance_to_shoot += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		destroy()
	if get_next_weapon():
		if distance_to_shoot >= 500.0 / distance:
			shoot_next_weapon()
			distance_to_shoot = 0

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	SfxDeconflicter.play(Game.audio_manager.jetstream_hit)
	destroy()

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	var directions = [-PI/2, PI/2]
	for rotated_direction in directions:
		weapon_direction = direction.rotated(rotated_direction)
		set_weapon_properties(get_next_weapon().instantiate(), weapon_direction)

func initialize_location(weapon):
	super.initialize_location(weapon)
	distance = weapon.FIRE_RATE
