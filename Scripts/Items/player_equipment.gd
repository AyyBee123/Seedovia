extends Node
# set increases in value as +n, +n%, or nx amount for stats

var is_percent = false

func add_stats(item, player, was_equipped): # add stats when slotting an equipment item to an equipment slot in the inventory
	setup_property(item, player, 1, was_equipped)

func remove_stats(item, player, was_equipped): # remove stats when slotting an item out of an equipment slot in the inventory
	setup_property(item, player, -1, was_equipped)

func setup_property(item, player, sign, was_equipped):
	var properties = item.item.properties
	for i in range(properties.size()):
		# split the key words. ex: split "+10% Fire_Rate" to ["+10%, "Fire_Rate"]
		var key_words = properties[i].split(" ")
		# get the property name and modify it in the player_stats class
		var property = key_words[1]
		var operation = null
		# get the first character of the first split string to get the operation. ex: first character of "+10%" = "+"
		if key_words[0].left(1) == "+":
			operation = key_words[0].left(1)
			# get the value after declaring the operation. ex: "+10%" -> "10%"
			key_words[0] = key_words[0].right(-1)
		elif key_words[0].left(1) == "-":
			operation = key_words[0].left(1)
			# get the value after declaring the operation. ex: "+10%" -> "10%"
			key_words[0] = key_words[0].right(-1)
		# check if the value has a percent to change it to a decimal value. ex: "10%" -> 10% * fire_rate
		# checks the last charcter of the string to see if it's a "%"
		if key_words[0].right(1) == "%":
			key_words[0] = key_words[0].left(-1)
			is_percent = true
		elif key_words[0].right(1) == "x":
			operation = key_words[0].right(1)
			key_words[0] = key_words[0].left(-1)
			is_percent = false
		else:
			is_percent = false
		# turn the string to a float type now that the string is just the number. ex: "10" -> 10
		var amount = float(key_words[0]) * sign
		# basically make it add a negative number
		if operation == "-":
			amount *= -1
			operation = "+"
		if is_percent:
			# convert the amount to a decimal value
			amount = player._player_stats.stats[property]["base"] * amount / 100
		var old_stat_value = player._player_stats.get_stat(property)
		if operation == "+" or operation == "-":
			player._player_stats.stats[property][operation] += amount
		elif operation == "x":
			if sign > 0:
				player._player_stats.stats[property][operation] *= amount
			else:
				player._player_stats.stats[property][operation] /= -amount
		player._player_stats.update_stat(property, was_equipped, old_stat_value)

func add_passive(player, passive):
	player.get_node("Item Passives").add_child(passive)

func remove_passive(player, passive_name):
	for passive in player.get_node("Item Passives").get_children():
		if passive.name == passive_name:
			player.get_node("Item Passives").remove_child(passive)
			passive.queue_free()
