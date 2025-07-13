extends "res://Scripts/Passives/Classes/passive_chance.gd"

var source
var toppings: Array = [CHEESE, HERB, MUSHROOM, SAUSAGE, TOMATO]

const CHEESE = preload("res://Scenes/Passives/Effects/Pizzaria Cheese.tscn")
const HERB = preload("res://Scenes/Passives/Effects/Pizzaria Herb.tscn")
const MUSHROOM = preload("res://Scenes/Passives/Effects/Pizzaria Mushroom.tscn")
const SAUSAGE = preload("res://Scenes/Passives/Effects/Pizzaria Sausage.tscn")
const TOMATO = preload("res://Scenes/Passives/Effects/Pizzaria Tomato.tscn")

func _ready():
	chance = 0.1
	source = get_parent().get_parent()
	super._ready()
	source.weapon_fired.connect(chance_to_trigger)

func trigger(weapon = null):
	# pizzaria toppings do not retrigger themselves
	if source.is_in_group("Pizzaria"):
		return
	# spawn one of the pizza toppings at random
	var topping = toppings.pick_random().instantiate()
	topping.add_child(player.get_node("Passives").duplicate())
	topping.add_child(player.get_node("Item Passives").duplicate())
	get_tree().current_scene.add_child(topping)
	topping.global_position = source.global_position
