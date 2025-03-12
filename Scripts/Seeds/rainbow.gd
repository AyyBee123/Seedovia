extends "res://Scripts/Seeds/seed_template.gd"

@onready var fire_rate = $"Fire Rate"

const RAINBOW_BOMB = preload("res://Scenes/Seeds/Effects/Rainbow Bomb.tscn")
const RAINBOW_TRAIL = preload("res://Scenes/Seeds/Effects/Rainbow Trail.tscn")

var fire_rate_multiplier: float = 1.25
var radius := 0.0
var angle := 0.0
var starting_angle: float

var tween

func _ready():
	super._ready()
	var original_size = scale
	SfxDeconflicter.play(Game.audio_manager.sparkle)
	
	scale.x = 0
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale:x", original_size.x, 0.1)

func _physics_process(delta):
	super._physics_process(delta)
	
	if fire_rate.is_stopped():
		weapon_direction = direction
		shoot_next_weapon()
	
	var trail = RAINBOW_TRAIL.instantiate()
	if shader:
		trail.material = ShaderMaterial.new()
		trail.material.shader = shader
	trail.scale = scale
	trail.rotation = rotation
	trail.z_index = z_index
	get_tree().current_scene.add_child(trail)
	trail.global_position = global_position

func travelled_distance():
	distance_travelled = starting_position.distance_to(global_position)
	total_distance += distance_travelled
	starting_position = global_position
	if total_distance >= RANGE:
		if tween:
			tween.kill()
		queue_free.call_deferred()

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		SfxDeconflicter.play(Game.audio_manager.hit)
		SfxDeconflicter.play(Game.audio_manager.sparkle_higher_pitch)
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		SfxDeconflicter.play(Game.audio_manager.hit)
		SfxDeconflicter.play(Game.audio_manager.sparkle_higher_pitch)
		body._player_stats.take_damage(1)

func set_weapon_properties(weapon, _desired_direction, _ignore_first_collision = false, _enemy = null):
	var bomb = RAINBOW_BOMB.instantiate()
	bomb.DAMAGE = DAMAGE / 2
	weapon.BASE_SPEED = 0
	super.set_weapon_properties(weapon, _desired_direction)
	bomb.seed_slot = weapon.seed_slot_number
	weapon.get_node("Passives").add_child(bomb)
	fire_rate.start(1.0 / (weapon.FIRE_RATE * fire_rate_multiplier))


func _on_visible_on_screen_notifier_2d_screen_exited():
	if tween:
		tween.kill()
	queue_free.call_deferred()
