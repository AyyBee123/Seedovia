extends "res://Scripts/Seeds/seed_template.gd"

@onready var orb_fire_rate := $"Fire Rate"

@export var orb_fire_rate_multiplier: float = 1

func _ready():
	super._ready()
	weapon_direction = Vector2(0,-1)
	orb_fire_rate.wait_time = 1.0/(player._player_stats.get_stat("Fire_Rate") * orb_fire_rate_multiplier)
	orb_fire_rate.start(orb_fire_rate.wait_time)

func _physics_process(delta):
	super._physics_process(delta)
	var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or\
	slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
	if orb_fire_rate.is_stopped():
		shoot_next_weapon()

func shoot_next_weapon():
	super.shoot_next_weapon()
	orb_fire_rate.wait_time = 1.0/(player._player_stats.get_stat("Fire_Rate") * orb_fire_rate_multiplier\
	* get_next_weapon().instantiate().fire_rate_multiplier * 2)
	change_direction()
	orb_fire_rate.start()

func change_direction():
	match weapon_direction:
		Vector2(0,-1):
			weapon_direction = Vector2(1,-1)
		Vector2(1,-1):
			weapon_direction = Vector2(1,0)
		Vector2(1,0):
			weapon_direction = Vector2(1,1)
		Vector2(1,1):
			weapon_direction = Vector2(0,1)
		Vector2(0,1):
			weapon_direction = Vector2(-1,1)
		Vector2(-1,1):
			weapon_direction = Vector2(-1,0)
		Vector2(-1,0):
			weapon_direction = Vector2(-1,-1)
		Vector2(-1,-1):
			weapon_direction = Vector2(0,-1)
