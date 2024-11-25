extends "res://Scripts/Seeds/seed_template.gd"

@onready var orb_fire_rate := $"Fire Rate"

@export var orb_fire_rate_multiplier: float = 1

func _ready():
	super._ready()
	weapon_direction = Vector2(0,-1)
	orb_fire_rate.start(1.0/(player._player_stats.get_stat("Fire_Rate") * orb_fire_rate_multiplier))

func _physics_process(delta):
	if get_next_weapon():
		rotation_degrees += 45.0 * player._player_stats.get_stat("Fire_Rate") * orb_fire_rate_multiplier \
				* get_next_weapon().instantiate().fire_rate_multiplier * 2 * delta
	else:
		rotation_degrees += 45.0 * player._player_stats.get_stat("Fire_Rate") * orb_fire_rate_multiplier * delta
	super._physics_process(delta)
	if orb_fire_rate.is_stopped():
		shoot_next_weapon()

func update_position(delta):
	current_velocity = direction * player._player_stats.get_stat("Weapon_Speed") * speed_multiplier
	position += current_velocity * delta

func shoot_next_weapon():
	super.shoot_next_weapon()
	if get_next_weapon() == null:
		return
	orb_fire_rate.wait_time = 1.0/(player._player_stats.get_stat("Fire_Rate") * orb_fire_rate_multiplier \
			* get_next_weapon().instantiate().fire_rate_multiplier * 2)
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
