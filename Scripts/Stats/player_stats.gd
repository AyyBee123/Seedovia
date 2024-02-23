class_name player_stats extends "res://Scripts/Stats/character_stats.gd"

signal change_stat

var stats := {
	"Max_Health": {
		"base": max_health,
		"+": 0,
		"x": 1
	},
	"Speed": {
		"base": speed,
		"+": 0,
		"x": 1
	},
	"Dash_Rate": {
		"base": dash_rate,
		"+": 0,
		"x": 1
	},
	"Dash_Distance": {
		"base": dash_distance,
		"+": 0,
		"x": 1
	},
	"Dash_Invulnerability": {
		"base": dash_invulnerability,
		"+": 0,
		"x": 1
	},
	"Fire_Rate": {
		"base": fire_rate,
		"+": 0,
		"x": 1
	},
	"Contact_Damage": {
		"base": contact_damage,
		"+": 0,
		"x": 1
	},
	"Weapon_Speed": {
		"base": weapon_speed,
		"+": 0,
		"x": 1
	},
	"Weapon_Range": {
		"base": weapon_range,
		"+": 0,
		"x": 1
	},
	"Weapon_Size": {
		"base": weapon_size,
		"+": 0,
		"x": 1
	},
	"Weapon_Damage": {
		"base": weapon_damage,
		"+": 0,
		"x": 1
	}
}

# initialize the base stats in the player script because exports don't get assigned until _ready() is called
func initialize_base_stats():
	stats["Max_Health"]["base"] = max_health
	stats["Speed"]["base"] = speed
	stats["Dash_Rate"]["base"] = dash_rate
	stats["Dash_Distance"]["base"] = dash_distance
	stats["Dash_Invulnerability"]["base"] = dash_invulnerability
	stats["Fire_Rate"]["base"] = fire_rate
	stats["Contact_Damage"]["base"] = contact_damage
	stats["Weapon_Speed"]["base"] = weapon_speed
	stats["Weapon_Range"]["base"] = weapon_range
	stats["Weapon_Size"]["base"] = weapon_size
	stats["Weapon_Damage"]["base"] = weapon_damage

func get_stat(stat: String):
	return stats[stat]["x"] * (stats[stat]["base"] + stats[stat]["+"])
	
func update_stat(stat: String, was_equipped: bool):
	match stat:
		"Max_Health":
			var previous_max_health = max_health
			max_health = get_stat(stat)
			# heal current health by the increase in max health. ex: if max health increases by 1, heal by 1
			if not was_equipped:
				overcapped_health += max_health - previous_max_health
			var current_health = health
			current_health = min(overcapped_health, max_health)
			if current_health == 0:
				health = 1
			else:
				health = current_health
		"Speed":
			speed = get_stat(stat)
		"Dash_Rate":
			dash_rate = get_stat(stat)
		"Dash_Distance":
			dash_distance = get_stat(stat)
		"Dash_Invulnerability":
			dash_invulnerability = get_stat(stat)
		"Fire_Rate":
			fire_rate = get_stat(stat)
		"Contact_Damage":
			contact_damage = get_stat(stat)
		"Weapon_Speed":
			weapon_speed = get_stat(stat)
		"Weapon_Range":
			weapon_range = get_stat(stat)
		"Weapon_Size":
			weapon_size = get_stat(stat)
		"Weapon_Damage":
			weapon_size = get_stat(stat)
	change_stat.emit()
