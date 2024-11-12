extends "res://Scripts/Seeds/seed_template.gd"

@onready var noise_SFX = $Noise

var _was_previous_weapon := false # check if the branch was fired by a non-player (seed, passive effect, etc.)

@onready var bottom = $Bottom
@onready var middle = $Middle
@onready var top = $Top
@onready var tick_rate = $"Tick Rate"
@onready var collision_shape_2d = $Hitbox/CollisionShape2D
@onready var lifetime = $Lifetime
@onready var fire_rate = $"Fire Rate"
@onready var detect_ruptures = $"Detect Ruptures"
@onready var bottom_left = $"Bottom Left"
@onready var bottom_right = $"Bottom Right"
@onready var top_left = $"Top Left"
@onready var top_right = $"Top Right"

var enemy = null
var mouse_left_down := true
var x_pos: float
var lifetime_started := false
var is_shrinking := false

var enemies_in_area: Array
var tick_timers: Array

func _ready():
	if previous_weapon: # if fired by a non-player
		_was_previous_weapon = true
	super._ready()
	visible = false
	middle.scale.y = max(0, _player_stats.get_stat("Weapon_Range") \
			* range_multiplier) # extends the beam length based on player range
	top.position.y -= middle.scale.y - 1 # places the top portion of the beam above the middle portion
	collision_shape_2d.shape.extents.y = 20 + middle.scale.y * 0.5
	collision_shape_2d.position.y = -16 - middle.scale.y * 0.5
	collision_shape_2d.disabled = true
	top_left.position.y = -32 - middle.scale.y
	top_right.position.y = top_left.position.y
	x_pos = 1

func _physics_process(delta):
	super._physics_process(delta)
	if slot_index > 0:
		noise_SFX.volume_db = max(noise_SFX.volume_db - delta * 7.5, -30)
	# damage multiple enemies at a time
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") \
						* damage_multiplier)
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
				tick_timers[i].start(0.1 / _player_stats.get_stat("Fire_Rate") * 10 / fire_rate_multiplier)
	if not _was_previous_weapon: # if fired from the player
		if not mouse_left_down:
			is_shrinking = true
	if is_shrinking:
		shrink(65)

func rupture(): # this is just to find other ruptures that exist using the has_method function (a.k.a duck typing)
	pass

func initialize_position():
	if not position_initialized:
		starting_position = global_position
		direction = desired_direction.normalized()
		position_initialized = true
		if not _was_previous_weapon:
			rotation = global_position.angle_to_point(player.weapon_direction_marker.global_position) + deg_to_rad(90)
		else:
			rotation = desired_direction.angle() + deg_to_rad(90)
		# if the seed is the first seed (shot directly by the player character)
		if not _was_previous_weapon:
			# only the first instance of a node has its original name
			# other instances will just be Node<Object Type>
			# this removes all rupture nodes after the first, until the original is destroyed, then the cycle repeats
			if not name == "Rupture":
				queue_free()
		else:
			var areas = detect_ruptures.get_overlapping_areas()
			for area in areas:
				if abs(area.get_parent().rotation - rotation) <= deg_to_rad(5) \
							and area.get_parent().global_position.distance_to(global_position) <= 1:
					queue_free()
					return
		visible = true
		collision_shape_2d.disabled = false
		SfxDeconflicter.play(noise_SFX)

func travelled_distance():
	pass

func _collide(body):
	if body.is_in_group("Enemies"):
		if is_instance_valid(body):
			enemies_in_area.append(body.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = 0.1 / _player_stats.get_stat("Fire_Rate") * 20 / fire_rate_multiplier
			timer.one_shot = true
			tick_timers.append(timer)

func _on_hitbox_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)

func shoot_next_weapon():
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	x_pos = -x_pos # alternate direction of the next weapon
	weapon_direction = Vector2.RIGHT.rotated(rotation + randf_range(deg_to_rad(-5), deg_to_rad(5))) * sign(x_pos)
	get_weapon_properties(get_next_weapon().instantiate(), weapon_direction)

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	if x_pos < 0:
		weapon.global_position = Vector2(randf_range(bottom_left.global_position.x,top_left.global_position.x), \
				randf_range(bottom_left.global_position.y,top_left.global_position.y))
	else:
		weapon.global_position = Vector2(randf_range(bottom_right.global_position.x,top_right.global_position.x), \
				randf_range(bottom_right.global_position.y,top_right.global_position.y))
	weapon_fired.emit(weapon)

func update_position(delta):
	if not _was_previous_weapon:
		global_position = player.hand.global_position
		rotation = global_position.angle_to_point(player.weapon_direction_marker.global_position) + deg_to_rad(90)
	else:
		if previous_weapon != null:
			global_position = previous_weapon.global_position
			rotation = desired_direction.angle() + deg_to_rad(90)
		else:
			if not lifetime_started:
				lifetime.start()
				lifetime_started = true

func _input(event):
	if Input.is_action_just_pressed("shoot") and event.is_pressed():
			mouse_left_down = true
	elif Input.is_action_just_released("shoot") and not event.is_pressed():
			mouse_left_down = false

func shrink(shrink_speed_mult):
	bottom.scale.x -= get_process_delta_time() * shrink_speed_mult
	middle.scale.x -= get_process_delta_time() * shrink_speed_mult
	top.scale.x -= get_process_delta_time() * shrink_speed_mult
	noise_SFX.volume_db -= get_process_delta_time() * shrink_speed_mult * 10
	if middle.scale.x <= 0:
		queue_free.call_deferred()

func _on_lifetime_timeout():
	is_shrinking = true

func _on_fire_rate_timeout():
	shoot_next_weapon()
	fire_rate.start()
