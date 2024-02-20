extends Node

enum properties {
	max_health,
	speed,
	dash_rate,
	dash_distance,
	dash_invulnerability,
	fire_rate,
	contact_damage,
	acceleration,
	friction,
	weapon_speed,
	weapon_range,
	weapon_size,
	weapon_damage
}
var is_percent = false

func add_stats(item, player): # add stats when slotting an equipment item to an equipment slot in the inventory
	var properties = item.item.properties
	for i in range(properties.size()):
		# split the key words. ex: split "+10% Fire_Rate" to ["+10%, "Fire_Rate"]
		var key_words = properties[i].split(" ")
		# get the first character of the first split string to get the operation. ex: first character of "+10%" = "+"
		var operation = key_words[0].left(1)
		# get the value after declaring the operation. ex: "+10%" -> "10%"
		key_words[0] = key_words[0].right(-1)
		# check if the value has a percent to change it to a decimal value. ex: "10%" -> 10% * fire_rate
		# checks the last charcter of the string to see if it's a "%"
		if key_words[0].right(1) == "%":
			key_words[0] = key_words[0].left(-1)
			is_percent = true
		else:
			is_percent = true
		# turn the string to a float type now that the string is just the number. ex: "10" -> 10
		var amount = float(key_words[0])
		
		if operation == "+": # check if the first character is a "+"
			pass
	
func remove_stats(item, player): # remove stats when slotting an equipment item out of an equipment slot in the inventory
	pass
	
func check_property(word: String, item, player):
	match word:
		"Max_Health":
			return player.player_stats.max_health
		"Fire_rate":
			return player.player_stats.fire_rate
	

