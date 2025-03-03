extends "res://Scripts/Seeds/seed_template.gd"

const NUMBER_OF_ORBITALS = 4

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
var enemies_in_area: Array
var tick_timers: Array
var tick_rate := 0.1

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
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				if enemies_in_area[i] == player:
					enemies_in_area[i]._player_stats.take_damage(1)
					tick_timers[i].start(tick_rate / FIRE_RATE)
					return
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE)
				tick_timers[i].start(tick_rate / FIRE_RATE)
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
	if not is_shrinking:
		orbit(delta)
	else:
		shrink(delta)

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta

func _collide(body):
	if body.is_in_group("Enemies"):
		if is_instance_valid(body):
			enemies_in_area.append(body.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate / FIRE_RATE
			timer.one_shot = true
			tick_timers.append(timer)

func _on_hitbox_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func _on_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		if is_instance_valid(body):
			enemies_in_area.append(body)
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate / FIRE_RATE
			timer.one_shot = true
			tick_timers.append(timer)

func _on_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		if is_instance_valid(body):
			var index = enemies_in_area.find(body)
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func shoot_next_weapon():
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	for i in range(NUMBER_OF_ORBITALS):
		var weapon_instance = get_next_weapon().instantiate()
		orbitals.append(weapon_instance)
		orbital_directions.append(Vector2.ZERO)
		index = i
		set_weapon_properties(weapon_instance, Vector2.ZERO)

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon.global_position = Vector2(
		sin(index * deg_to_rad(360.0/NUMBER_OF_ORBITALS)) * radius,
		cos(index * deg_to_rad(360.0/NUMBER_OF_ORBITALS)) * radius
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
				sin(angle * speed + orbitals.find(orbital) * deg_to_rad(360.0/NUMBER_OF_ORBITALS)) * radius,
				cos(angle * speed + orbitals.find(orbital) * deg_to_rad(360.0/NUMBER_OF_ORBITALS)) * radius
			) + pos
			var op = global_position.direction_to(orbital.global_position)
			# get vector perpedicular to vector from the orbital to black hole
			orbital.direction = Vector2(op.y, -op.x)
			orbital.desired_direction = orbital.direction
			orbital_directions[orbitals.find(orbital)] = orbital.direction # stores the direction of the orbitals
			orbital.total_distance = 0 # to make the weapons not despawn mid-orbit

func travelled_distance():
	distance_travelled = starting_position.distance_squared_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
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
		noise_SFX.stop()
		queue_free.call_deferred()
