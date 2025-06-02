extends "res://Scripts/Seeds/seed_template.gd"

@onready var fire_rate = $"Fire Rate"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

const SPREAD = PI/6

var fire_rate_multiplier: float = 0.6

func _ready():
	randomize()
	super._ready()
	fire_rate.start()

func _physics_process(delta):
	super._physics_process(delta)
	
	if fire_rate.is_stopped():
		weapon_direction = direction.rotated(randf_range(-SPREAD, SPREAD))
		shoot_next_weapon()

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.crunch_2)
	
	explode()
	destroy()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.22 * SIZE
	splash.source = self
	splash.modulate = Color("5a882b")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func initialize_location(weapon):
	if not get_tree():
		return
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	weapon.global_position = global_position + direction * 12
	fire_rate.start(1.0 / (fire_rate_multiplier * weapon.FIRE_RATE))
