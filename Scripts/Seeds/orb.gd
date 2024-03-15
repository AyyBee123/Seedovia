extends "res://Scripts/Seeds/seed_template.gd"

@onready var orb_fire_rate := $"Fire Rate"

var shot_direction := Vector2(0,-1)
@export var orb_fire_rate_multiplier: float = 1

func _ready():
	super._ready()
	orb_fire_rate.wait_time = 1.0/(player._player_stats.get_stat("Fire_Rate") * orb_fire_rate_multiplier)
	orb_fire_rate.start(orb_fire_rate.wait_time)

func _physics_process(delta):
	super._physics_process(delta)
	var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
	if orb_fire_rate.is_stopped():
		attempted_fire.emit()
		if weapon != null:
			shoot_next_weapon(weapon)

func shoot_next_weapon(weapon):
	var weapon_instance = weapon.instantiate()
	get_weapon_properties(weapon_instance, shot_direction.normalized())
	orb_fire_rate.wait_time = 1.0/(player._player_stats.get_stat("Fire_Rate") * orb_fire_rate_multiplier * weapon_instance.fire_rate_multiplier * 2)
	change_direction()
	orb_fire_rate.start()

func shoot_different_weapon(weapon):
	weapon.initial_weapon = false
	weapon.ignore_first_collision = false
	weapon.desired_direction = shot_direction.normalized()
	weapon.previous_weapon = self
	get_tree().current_scene.add_child(weapon)
	weapon_fired.emit(weapon)
	orb_fire_rate.wait_time = 1.0/(player._player_stats.get_stat("Fire_Rate") * orb_fire_rate_multiplier * weapon.fire_rate_multiplier * 2)
	weapon.global_position = global_position
	change_direction()
	orb_fire_rate.start()

func change_direction():
	match shot_direction:
		Vector2(0,-1):
			shot_direction = Vector2(1,-1)
		Vector2(1,-1):
			shot_direction = Vector2(1,0)
		Vector2(1,0):
			shot_direction = Vector2(1,1)
		Vector2(1,1):
			shot_direction = Vector2(0,1)
		Vector2(0,1):
			shot_direction = Vector2(-1,1)
		Vector2(-1,1):
			shot_direction = Vector2(-1,0)
		Vector2(-1,0):
			shot_direction = Vector2(-1,-1)
		Vector2(-1,-1):
			shot_direction = Vector2(0,-1)
