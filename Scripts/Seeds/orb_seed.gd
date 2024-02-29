extends "res://Scripts/Seeds/seed_template.gd"

@onready var orb_fire_rate := $"Fire Rate"

var shot_direction := Vector2(0,-1)
@export var orb_fire_rate_multiplier: float = 1

func _ready():
	orb_fire_rate.wait_time = 1.0/(player._player_stats.get_stat("Fire_Rate") * orb_fire_rate_multiplier)
	orb_fire_rate.start(orb_fire_rate.wait_time)

func _process(delta):
	for i in range(seed_slots.size()):
		var weapon = null if PlayerSeeds.seeds.size() <= 1 + slot_index or slot_index >= 2 else PlayerSeeds.seeds[slot_index + 1]
		if weapon != null:
			if orb_fire_rate.is_stopped():
				shoot_next_weapon(weapon)
			break
	
func shoot_next_weapon(weapon):
	var weapon_instance = weapon.instantiate()
	weapon_instance.initial_weapon = false
	weapon_instance.ignore_first_collision = true
	weapon_instance.slot_index = slot_index + 1
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = global_position
	weapon_instance.velocity = shot_direction.normalized()
	weapon_instance.rotation = weapon_instance.velocity.angle()
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
