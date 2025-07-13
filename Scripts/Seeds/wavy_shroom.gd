extends "res://Scripts/Seeds/seed_template.gd"

const WAVY_SHROOM = preload("res://Scenes/Seeds/Wavy-shroom.tscn")

const FREQUENCY = 3
const AMPLITUDE = 150
const NUMBER_OF_SHROOMS = 3

var shroom_number: int = 1
var t: float
var pos: Vector2
var amp_sign: int = -1
var first_collision_ignored: bool

func _ready():
	super._ready()
	first_collision_ignored = ignore_first_collision
	BASE_RANGE *= 2
	await get_tree().physics_frame
	pos = global_position

func _physics_process(delta):
	super._physics_process(delta)
	if amp_sign != sign(sin(t * FREQUENCY)): # when the shroom almost reaches peak amplitude, shoot the next seed
		amp_sign = -amp_sign
		weapon_direction = direction.rotated(PI/2) * amp_sign
		shoot_next_weapon()

func update_position(delta):
	super.update_position(delta)
	
	t += delta
	var forward_offset = current_velocity * t
	var perpendicular = direction.rotated(PI/2)
	var wave_offset = perpendicular * sin(t * FREQUENCY * SPEED / 100) * AMPLITUDE # wave pattern
	
	position = pos + forward_offset + wave_offset

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	SfxDeconflicter.play(Game.audio_manager.hit)
	match shroom_number:
		1:
			SfxDeconflicter.play(Game.audio_manager.crunch_wavy)
		2:
			SfxDeconflicter.play(Game.audio_manager.crunch_wavy_2)
		3:
			SfxDeconflicter.play(Game.audio_manager.crunch_wavy_3)
	destroy()

func _on_spawn_delay_timeout():
	if shroom_number < NUMBER_OF_SHROOMS:
		shoot_current_seed(WAVY_SHROOM.instantiate(), desired_direction, pos)

func shoot_current_seed(instantiated_weapon, _desired_direction = desired_direction, pos = global_position):
	weapon_direction = _desired_direction
	instantiated_weapon.shroom_number = shroom_number + 1
	instantiated_weapon.shader = shader
	instantiated_weapon.collisions = collisions
	instantiated_weapon.source = source
	instantiated_weapon.previous_weapon = previous_weapon
	instantiated_weapon.target_group = target_group
	instantiated_weapon.desired_direction = _desired_direction
	instantiated_weapon.slot_index = slot_index
	instantiated_weapon.seed_slot_number = seed_slot_number
	instantiated_weapon.set_next_seed_slot_number = set_next_seed_slot_number
	instantiated_weapon.set_next_seed_slot_index = set_next_seed_slot_index
	instantiated_weapon.ignore_first_collision = first_collision_ignored
	instantiated_weapon.transferred_speed_multiplier *= transferred_speed_multiplier
	instantiated_weapon.transferred_range_multiplier *= transferred_range_multiplier
	instantiated_weapon.transferred_size_multiplier *= transferred_size_multiplier
	instantiated_weapon.transferred_damage_multiplier *= transferred_damage_multiplier / 2
	instantiated_weapon.transferred_blast_radius_multiplier *= transferred_blast_radius_multiplier
	instantiated_weapon.transferred_fire_rate_multiplier *= transferred_fire_rate_multiplier
	instantiated_weapon.modulate = modulate
	get_tree().current_scene.add_child.call_deferred(instantiated_weapon)
	instantiated_weapon.modulate.a = modulate.a / 2
	instantiated_weapon.global_position = pos
	weapon_fired.emit(instantiated_weapon)
