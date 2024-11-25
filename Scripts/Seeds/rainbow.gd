extends "res://Scripts/Seeds/seed_template.gd"

@onready var rainbow_effect = $"Rainbow Effect"
@onready var resource_preloader = $ResourcePreloader
@onready var humming_SFX = $Humming
@onready var hit_SFX = $Hit

var hue = 0.0
var color
var shooting_direction = 1
var MAX_DISTANCE_BEFORE_SHOOTING: int = 10

func _ready():
	super._ready()
	SfxDeconflicter.play(humming_SFX)

func _physics_process(delta):
	super._physics_process(delta)
	var trail = resource_preloader.get_resource("Trail").instantiate()
	color = Color.from_hsv(hue, 1.0, 1.0, 1.0)
	if hue < 1.0:
		hue += 0.002
	else:
		hue = 0.0
	rainbow_effect.modulate = color
	trail.modulate = color
	trail.modulate.s = 0.75
	trail.modulate.v = 0.75
	trail.scale = scale
	trail.rotation = rotation
	get_tree().current_scene.add_child(trail)
	trail.global_position = global_position

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage") * damage_multiplier)
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
	if total_distance >= _player_stats.get_stat("Weapon_Range") * range_multiplier:
		queue_free.call_deferred()

func shoot_next_weapon():
	# for passives that require the weapon to not fire a seed (e.g the last seed slot fires itself again)
	attempted_fire.emit()
	if get_next_weapon() == null:
		return
	weapon_direction = direction.rotated(PI/2 * shooting_direction)
	shooting_direction = -shooting_direction
	get_weapon_properties(get_next_weapon().instantiate(), weapon_direction)
