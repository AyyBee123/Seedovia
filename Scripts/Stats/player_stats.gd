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
	"Invulnerability_Time": {
		"base": invulnerability_time,
		"+": 0,
		"x": 1
	},
	"Acceleration": {
		"base": acceleration,
		"+": 0,
		"x": 1
	},
	"Friction": {
		"base": friction,
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
	},
	"Weapon_Blast_Radius": {
		"base": weapon_blast_radius,
		"+": 0,
		"x": 1
	},
	"Luck": {
		# base luck is the base chance from an item or passive, not from the player (that's why it's not here)
		"+": 0,
		"x": 1
	},
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
	stats["Invulnerability_Time"]["base"] = invulnerability_time
	stats["Acceleration"]["base"] = acceleration
	stats["Friction"]["base"] = friction
	stats["Weapon_Speed"]["base"] = weapon_speed
	stats["Weapon_Range"]["base"] = weapon_range
	stats["Weapon_Size"]["base"] = weapon_size
	stats["Weapon_Damage"]["base"] = weapon_damage
	stats["Weapon_Blast_Radius"]["base"] = weapon_blast_radius
	
func get_health(was_equipped: bool):
	var previous_max_health = max_health
	max_health = get_stat("Max_Health")
	# heal current health by the increase in max health. ex: if max health increases by 1, heal by 1
	if not was_equipped:
		overcapped_health += max_health - previous_max_health
	var current_health = health
	current_health = min(overcapped_health, max_health)
	if current_health == 0:
		health = 1
	else:
		health = current_health

func get_stat(stat: String):
	return stats[stat]["x"] * (stats[stat]["base"] + stats[stat]["+"])
	
func update_stat(stat: String, was_equipped: bool, old_stat_value):
	if stat == "Max_Health":
		var previous_max_health = get_stat("Max_Health")
		# heal current health by the increase in max health. ex: if max health increases by 1, heal by 1
		if not was_equipped:
			overcapped_health += get_stat("Max_Health") - old_stat_value
		var current_health = health
		current_health = min(overcapped_health, get_stat("Max_Health"))
		if current_health == 0:
			health = 1
		else:
			health = current_health
	change_stat.emit()
