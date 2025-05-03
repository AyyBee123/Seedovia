extends Control

@onready var player = Targets.get_player()
@onready var buttons := $PassiveBackground/GridContainer.get_children()
var passives: Array
var green_dice_amount: int
var current_die = null
var current_slot = null

func _ready():
	get_tree().paused = true
	player.inventory.visible = false
	player.stat_sheet.visible = false
	for button in buttons:
		var passive = get_passive()
		button.pressed.connect(on_press.bind(passive))
		button.get_node("Name").text = passive.passive_name
		button.get_node("Description").text = passive.description
		button.get_node("Sprite").texture = passive.sprite
	
	check_for_green_dice()
	%Reroll.visible = current_slot != null

func get_passive():
	var item = Pool.get_item(Pool.passive_pool)
	return item

func give_item(item):
	player.get_node("Passives").add_child(item.passive_ability.instantiate())
	PlayerPassives.passive_list.append(item)
	Global.save_run_data()
	Global.save_run_room()

func on_press(passive_item):
	give_item(passive_item)
	# maybe play some animation here
	get_tree().paused = false
	queue_free.call_deferred()

func _on_reroll_button_pressed():
	for button in buttons:
		var passive = get_passive()
		button.pressed.disconnect(on_press)
		button.pressed.connect(on_press.bind(passive))
		button.get_node("Name").text = passive.passive_name
		button.get_node("Description").text = passive.description
		button.get_node("Sprite").texture = passive.sprite
	PlayerInventory.remove_item(current_slot) # remove the item from the player inventory dictionary
	current_slot.item.queue_free.call_deferred() # then delete the item
	current_slot = null
	check_for_green_dice()
	%Reroll.visible = current_slot != null

func check_for_green_dice():
	green_dice_amount = 0
	for item in PlayerInventory.inventory.values():
		if item.item_name == "Green D6":
			green_dice_amount += 1
			current_die = item
			current_slot = player.inventory.inventory_slots[PlayerInventory.inventory.find_key(item)]
	%Amount.text = "[center]x" + str(green_dice_amount)
