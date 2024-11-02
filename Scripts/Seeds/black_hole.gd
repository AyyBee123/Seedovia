extends "res://Scripts/Seeds/seed_template.gd"

var is_in_area := false
var enemy = null
var orbitals: Array
var index: int
var radius: float = 25
var speed: float = 5
var angle: float = 0
var pos
var is_shrinking := false
var orbital_direction
var orbital_directions: Array
var is_shrunk := false

@onready var tick_rate = $"Tick Rate"
@onready var noise_SFX = $Noise

func _ready():
	SfxDeconflicter.play(noise_SFX)
	super._ready()
	var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or \
			slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
	shoot_next_weapon()

func _physics_process(delta):
	super._physics_process(delta)
	noise_SFX.volume_db = max(noise_SFX.volume_db - delta * 5, linear_to_db(0))
	if is_in_area:
		if tick_rate.is_stopped():
			if is_instance_valid(enemy):
				enemy._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
				has_collided.emit(enemy.get_node("Enemy Hitbox"))
				tick_rate.start(0.1 / _player_stats.get_stat("Fire_Rate") * 10)
	if not is_shrinking:
		orbit(delta)
	else:
		shrink(delta)

func update_position(delta):
	current_velocity = direction * _player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta

func _collide(body):
	if body.is_in_group("Enemies"):
		enemy = body.get_parent()
		is_in_area = true

func _on_hitbox_area_exited(area):
	if area.is_in_group("Enemies"):
		is_in_area = false

func shoot_next_weapon():
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	for i in range(2):
		var weapon_instance = get_next_weapon().instantiate()
		orbitals.append(weapon_instance)
		orbital_directions.append(Vector2.ZERO)
		index = i
		get_weapon_properties(weapon_instance, Vector2.ZERO)

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon.global_position = Vector2(
		sin(index * deg_to_rad(360.0/2)) * radius,
		cos(index * deg_to_rad(360.0/2)) * radius
	) + global_position
	weapon_fired.emit(weapon)

func orbit(delta):
	angle += delta
	for orbital in orbitals:
		if self != null:
			pos = global_position
		if orbital != null:
			# reset starting position of next weapon to make it not disappear while orbiting
			orbital.starting_position = orbital.global_position
			orbital.global_position = Vector2(
				sin(angle * speed + orbitals.find(orbital) * deg_to_rad(360.0/orbitals.size())) * radius,
				cos(angle * speed + orbitals.find(orbital) * deg_to_rad(360.0/orbitals.size())) * radius
			) + pos
			var op = global_position.direction_to(orbital.global_position)
			orbital.direction = Vector2(op.y, -op.x) # get vector perpedicular to vector from the orbital to black hole
			orbital.desired_direction = orbital.direction
			orbital_directions[orbitals.find(orbital)] = orbital.direction # stores the direction of the orbitals
			orbital.total_distance = 0 # to make the weapons not despawn mid-orbit

func travelled_distance():
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= _player_stats.get_stat("Weapon_Range") * range_multiplier:
		is_shrinking = true

func shrink(delta):
	for orbital in orbitals:
		if orbital != null:
			if not is_shrunk:
				orbital.desired_direction = orbital_directions[orbitals.find(orbital)]
				orbital.direction = orbital.desired_direction.normalized()
	is_shrunk = true
	scale -= Vector2(delta, delta)
	if scale <= Vector2.ZERO:
		call_deferred("free")
