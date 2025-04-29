extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var acceleration = $Acceleration
@onready var lifetime = $Lifetime

var has_stopped := false
var is_stopping := false
var is_decelerating := false
var previous_weapon_position: Vector2
var position_checked := false
var direction_changed := false
var _was_previous_weapon := false

func _ready():
	super._ready()
	lifetime.start()
	if previous_weapon != player:
		_was_previous_weapon = true
	if source.is_in_group("Enemy"):
		$"Detect Previous Seed".set_collision_mask(4)

func update_position(delta):
	if previous_weapon != null:
		position_checked = true
		previous_weapon_position = previous_weapon.global_position
	if not has_stopped:
		if not is_stopping:
			current_velocity = direction * SPEED
		else:
			current_velocity = direction * SPEED * deceleration.time_left
	else:
		if not _was_previous_weapon:
			direction = global_position.direction_to(player.global_position) # goes towards the player's position
		else:
			if not direction_changed:
				if position_checked:
					# goes towards the last known position of the previous weapon
					direction = global_position.direction_to(previous_weapon_position)
				else:
					direction = -direction
				if previous_weapon == null:
					direction_changed = true
		current_velocity = direction * SPEED \
				* (deceleration.wait_time - acceleration.time_left) / deceleration.wait_time
	position += current_velocity * delta
	rotation += deg_to_rad(-15)

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	if has_stopped:
		SfxDeconflicter.play(Game.audio_manager.hit)
		queue_free.call_deferred()
	else:
		has_stopped = true
	weapon_direction = -direction
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.bubble_pop_2)
	shoot_next_weapon()

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		if not is_stopping:
			is_decelerating = true
			is_stopping = true
			deceleration.start()
			weapon_direction = direction
			shoot_next_weapon()

func _on_deceleration_timeout():
	if has_stopped:
		return
	has_stopped = true
	acceleration.start(deceleration.wait_time)

func shoot_next_weapon():
	if get_next_weapon() == null:
		return
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction, true)

func _on_detect_previous_seed_body_entered(body): # detects the player
	if not has_stopped:
		return
	if body == source:
		queue_free()

func _on_detect_previous_seed_area_entered(area): # detects the previous weapon
	if not has_stopped:
		return
	if area.get_parent() == previous_weapon:
		queue_free()

func _on_lifetime_timeout():
	queue_free.call_deferred()
