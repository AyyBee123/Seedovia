extends "res://Scripts/Seeds/seed_template.gd"

@onready var pointer = %Pointer
@onready var marker_2d = %Marker2D
@onready var fire_delay = $"Fire Delay"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")
var SPORE = load("res://Scenes/Seeds/Spore.tscn")

const SPORE_AMOUNT = 5
var spore_amount_spawned: int

var rotation_speed: float
var targeted_enemy
var _spawn_more_spores: bool = true
var origin_point
var first_collision_ignored: bool
var enemy

func _ready():
	super._ready()
	randomize()
	rotation_speed = randf_range(5, 6)
	pointer.rotation = desired_direction.angle() + randf_range(-PI/2, PI/2)
	first_collision_ignored = ignore_first_collision
	if _spawn_more_spores:
		fire_delay.start()
	await get_tree().physics_frame
	origin_point = global_position

func _physics_process(delta):
	super._physics_process(delta)
	if not ignore_first_collision:
		if $Hitbox.get_overlapping_areas().size() > 0:
			_collide($Hitbox.get_overlapping_areas()[0])

func update_position(delta):
	var current_velocity: Vector2
	
	if targeted_enemy == null:
		targeted_enemy = get_nearest_enemy(null)
	
	if targeted_enemy:
		direction = global_position.direction_to(targeted_enemy.global_position).normalized()
		pointer.rotation = lerp_angle(pointer.rotation, direction.angle(), rotation_speed * delta)
	
	current_velocity = global_position.direction_to(marker_2d.global_position) * SPEED
	position += current_velocity * delta
	rotation_speed += 2 * delta

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		SfxDeconflicter.play(Game.audio_manager.spore_pop)
		explode()
		queue_free.call_deferred()

func _on_hitbox_area_entered(area):
	pass

func _on_hitbox_body_entered(body):
	pass

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
		enemy = body.get_parent()
		shoot_next_weapon()
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.spore_pop)
	explode()
	queue_free.call_deferred()

func shoot_next_weapon():
	# for passives that require the weapon to not fire a seed (e.g the last seed slot fires itself again)
	attempted_fire.emit()
	if get_next_weapon() == null or enemy == null: # enemy == null, just in case
		return
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func get_nearest_enemy(object):
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

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.2 * SIZE
	splash.source = self
	splash.modulate = Color("c45930")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func _on_fire_delay_timeout():
	if not _spawn_more_spores:
		return
	var pos
	if is_instance_valid(previous_weapon):
		pos = previous_weapon.global_position
	else:
		pos = origin_point
	if spore_amount_spawned < SPORE_AMOUNT:
		var spore = SPORE.instantiate()
		spore._spawn_more_spores = false
		spore.desired_direction = desired_direction
		spore.seed_slots = seed_slots
		spore.slot_index = slot_index
		spore.seed_slot_number = seed_slot_number
		spore.ignore_first_collision = first_collision_ignored
		spore.transferred_speed_multiplier *= transferred_speed_multiplier
		spore.transferred_range_multiplier *= transferred_range_multiplier
		spore.transferred_size_multiplier *= transferred_size_multiplier
		spore.transferred_damage_multiplier *= transferred_damage_multiplier
		spore.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
		spore.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
		get_tree().current_scene.add_child.call_deferred(spore)
		spore.global_position = pos
		spore_amount_spawned += 1
		weapon_fired.emit(spore)
		fire_delay.start()
