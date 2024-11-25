extends "res://Scripts/Seeds/seed_template.gd"

@onready var rainbow_effect = $"Rainbow Effect"
@onready var humming_SFX = $Humming
@onready var hit_SFX = $Hit
@onready var rainbow_particle = $"Rainbow Particle"

var hue = 0.0
var color
var shooting_direction = 1
var MAX_DISTANCE_BEFORE_SHOOTING: int = 8
var trail_delta = 0.0

func _ready():
	super._ready()
	SfxDeconflicter.play(humming_SFX)

func _physics_process(delta):
	super._physics_process(delta)
	color = Color.from_hsv(hue, 1.0, 1.0, 1.0)
	if hue < 1.0:
		hue += 0.0025
	else:
		hue = 0.0
	rainbow_effect.modulate = color
	rainbow_particle.modulate = color
	rainbow_particle.rotation = rotation

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(final_damage)
	SfxDeconflicter.play(hit_SFX)
	if hit_SFX.playing:
		await hit_SFX.finished
	queue_free.call_deferred()

func travelled_distance():
	distance_travelled = starting_position.distance_squared_to(global_position)
	if distance_travelled >= 1:
		total_distance += 1
		starting_position = global_position
	if total_distance > 0 and total_distance % MAX_DISTANCE_BEFORE_SHOOTING == 0:
		shoot_next_weapon()
	if total_distance >= final_range:
		queue_free.call_deferred()

func shoot_next_weapon():
	# for passives that require the weapon to not fire a seed (e.g the last seed slot fires itself again)
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	weapon_direction = direction.rotated(PI/2 * shooting_direction)
	shooting_direction = -shooting_direction
	get_weapon_properties(get_next_weapon().instantiate(), weapon_direction)
