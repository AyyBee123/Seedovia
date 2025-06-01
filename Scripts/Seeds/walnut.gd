extends "res://Scripts/Seeds/seed_template.gd"

@onready var fire_rate := $"Fire Rate"

@export var fire_rate_multiplier: float = 2

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

var rotation_rate

func _ready():
	super._ready()
	weapon_direction = Vector2(0,-1)
	rotation_rate = PI/4 * FIRE_RATE * fire_rate_multiplier

func _physics_process(delta):
	super._physics_process(delta)
	if not get_next_weapon():
		rotation_rate = PI/4 * FIRE_RATE * fire_rate_multiplier
	rotation += rotation_rate * delta
	if fire_rate.is_stopped():
		shoot_next_weapon()

func update_position(delta):
	current_velocity = direction * SPEED
	position += current_velocity * delta

func _collide(body):
	if ignore_first_collision:
		ignore_first_collision = false
		return
	has_collided.emit(body) # for on-hit effects (ex: burning an enemy on hit)
	if body.is_in_group("Enemies"):
		body.get_parent()._enemy_stats.take_damage(DAMAGE)
	elif body.is_in_group("Players"):
		body._player_stats.take_damage(1)
	SfxDeconflicter.play(Game.audio_manager.walnut_hit)
	explode()
	destroy()

func shoot_next_weapon():
	super.shoot_next_weapon()
	if get_next_weapon() == null:
		return
	change_direction()

func initialize_location(weapon):
	super.initialize_location(weapon)
	rotation_rate = PI/4 * fire_rate_multiplier * weapon.FIRE_RATE
	fire_rate.start(1.0 / (fire_rate_multiplier * weapon.FIRE_RATE))

func change_direction():
	match weapon_direction:
		Vector2(0,-1):
			weapon_direction = Vector2(1/sqrt(2),-1/sqrt(2))
		Vector2(1/sqrt(2),-1/sqrt(2)):
			weapon_direction = Vector2(1,0)
		Vector2(1,0):
			weapon_direction = Vector2(1/sqrt(2),1/sqrt(2))
		Vector2(1/sqrt(2),1/sqrt(2)):
			weapon_direction = Vector2(0,1)
		Vector2(0,1):
			weapon_direction = Vector2(-1/sqrt(2),1/sqrt(2))
		Vector2(-1/sqrt(2),1/sqrt(2)):
			weapon_direction = Vector2(-1,0)
		Vector2(-1,0):
			weapon_direction = Vector2(-1/sqrt(2),-1/sqrt(2))
		Vector2(-1/sqrt(2),-1/sqrt(2)):
			weapon_direction = Vector2(0,-1)

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.3
	splash.source = self
	splash.modulate = Color("aa7053")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
