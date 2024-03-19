extends Control

signal button_press(passive)

@onready var player := $"../Player"
@onready var buttons := $PassiveBackground/GridContainer.get_children()
var passives: Array

func _ready():
	get_tree().paused = true
	player.inventory.visible = false
	for button in buttons:
		var passive = get_passive()
		button.pressed.connect(on_press.bind(passive))
		button.get_node("Name").text = passive.passive_name
		button.get_node("Description").text = passive.description
		button.get_node("Sprite").texture = passive.sprite

func get_passive():
	var item = Pool.get_item(Pool.passive_pool)
	return item

func give_item(item: PackedScene):
	player.get_node("Passives").add_child(item.instantiate())

func on_press(passive_item):
	give_item(passive_item.passive_ability)
	# maybe play some animation here
	get_tree().paused = false
	call_deferred("free")
