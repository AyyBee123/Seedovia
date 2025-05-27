extends "res://Scripts/Seeds/seed_template.gd"

@onready var orb_fire_rate := $"Fire Rate"

@export var orb_fire_rate_multiplier: float = 2

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

func _ready():
	super._ready()
	weapon_direction = Vector2(0,-1)

func _physics_process(delta):
	super._physics_process(delta)
	if get_next_weapon():
		rotation += PI/4 * orb_fire_rate_multiplier * get_next_weapon().instantiate().FIRE_RATE * delta
	else:
		rotation += PI/4 * FIRE_RATE * orb_fire_rate_multiplier * delta
	if orb_fire_rate.is_stopped():
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
	orb_fire_rate.wait_time = 1.0 / (orb_fire_rate_multiplier * get_next_weapon().instantiate().FIRE_RATE)
	change_direction()
	orb_fire_rate.start()

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
