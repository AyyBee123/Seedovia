extends "res://Scripts/Seeds/seed_template.gd"

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var fire_rate = $"Fire Rate"
@onready var laser_marker = %"Laser Marker"
@onready var laser_area = $"Laser Area/CollisionShape2D"
@onready var seed_marker = %"Seed Marker"
@onready var resource_preloader = $ResourcePreloader
@onready var area = $"Laser Area"
@onready var space_laser_noise_SFX = $SpaceLaserNoise

const BASE_LASER_RADIUS = 50
const LASER_RADIUS_MULTIPLIER = 0.5
const FRENZY_FIRE_RATE_MULTIPLIER = 2

var enemies_in_area := []
var tick_timers := []
var lasers := []
var tick_rate := 0.075
var _beginning_played: bool
var _end_played: bool = true

func _ready():
	super._ready()
	$"Laser Area".set_collision_mask(collisions - 1)

func _physics_process(delta):
	super._physics_process(delta)
	if area.get_overlapping_areas().size() > 0:
		fire_laser()
	else:
		stop_laser()
	laser_area.shape.radius = RANGE * LASER_RADIUS_MULTIPLIER / 2 + BASE_LASER_RADIUS
	for i in enemies_in_area.size():
		if tick_timers[i].is_stopped():
			if is_instance_valid(enemies_in_area[i]):
				enemies_in_area[i]._enemy_stats.take_damage(DAMAGE * 0.1)
				has_collided.emit(enemies_in_area[i].get_node("Enemy Hitbox"))
				tick_timers[i].start(tick_rate * FIRE_RATE)

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta

func _on_laser_area_area_entered(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			enemies_in_area.append(area.get_parent())
			var timer = Timer.new()
			add_child(timer)
			timer.wait_time = tick_rate * FIRE_RATE
			timer.one_shot = true
			tick_timers.append(timer)
			var laser = resource_preloader.get_resource("Frenzy's Rage Laser").instantiate()
			laser.source = self
			laser.target = area.get_parent()
			get_tree().current_scene.add_child.call_deferred(laser)
			lasers.append(laser)

func _on_laser_area_area_exited(area):
	if area.is_in_group("Enemies"):
		if is_instance_valid(area):
			var index = enemies_in_area.find(area.get_parent())
			enemies_in_area.remove_at(index)
			tick_timers.remove_at(index)
			lasers[index].queue_free()
			lasers.remove_at(index)

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "Laser Beginning":
		animated_sprite_2d.play("Laser")
	if animated_sprite_2d.animation == "Laser End":
		animated_sprite_2d.play("Idle")

func fire_laser():
	if not _beginning_played:
		if not space_laser_noise_SFX.playing:
			SfxDeconflicter.play(space_laser_noise_SFX)
		animated_sprite_2d.play("Laser Beginning")
		_beginning_played = true
		_end_played = false
	if fire_rate.is_stopped():
		shoot_next_weapon()

func shoot_next_weapon():
	# for passives that require the weapon to not fire a seed (e.g the last seed slot fires itself again)
	if get_next_weapon() == null:
		return
	weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	set_weapon_properties(get_next_weapon().instantiate(), weapon_direction)
	fire_rate.start(1.0 / (FRENZY_FIRE_RATE_MULTIPLIER * get_next_weapon().instantiate().FIRE_RATE))

func initialize_location(weapon):
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	weapon.global_position = seed_marker.global_position

func stop_laser():
	if not _end_played:
		space_laser_noise_SFX.stop()
		animated_sprite_2d.play("Laser End")
		_end_played = true
		_beginning_played = false

func get_next_weapon_pos():
	return seed_marker.global_position
