extends "res://Scripts/Seeds/seed_template.gd"

@onready var deceleration = $Deceleration
@onready var lifetime = $Lifetime
@onready var fire_rate = $"Fire Rate"
@onready var rotation_speed = $"Rotation Speed"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

const FIRE_RATE_MULTIPLIER = 1.5

func _ready():
	randomize()
	super._ready()
	deceleration.start()
	rotation_speed.start()

func _physics_process(delta):
	super._physics_process(delta)
	if fire_rate.is_stopped() and deceleration.is_stopped():
		weapon_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		shoot_next_weapon()

func update_position(delta):
	current_velocity = direction * SPEED * deceleration.time_left
	position += current_velocity * delta
	rotation += 2 * TAU * delta * (1 - rotation_speed.time_left)

func initialize_location(weapon):
	super.initialize_location(weapon)
	fire_rate.start(1.0 / (FIRE_RATE_MULTIPLIER * weapon.FIRE_RATE))

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	SfxDeconflicter.play(Game.audio_manager.hit)
	SfxDeconflicter.play(Game.audio_manager.blueberry_mild_explosion)
	explode()
	destroy()

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.5 * SIZE
	splash.source = self
	splash.modulate = Color("884b2b")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position

func _on_deceleration_timeout():
	lifetime.start()

func _on_lifetime_timeout():
	destroy()
