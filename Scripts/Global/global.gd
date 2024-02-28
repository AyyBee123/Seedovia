extends Node

#%APPDATA%\Roaming\Godot\app_userdata\Roguelike
var SAVE_PATH := "user://player_inventory.res"
var inventory_data = player_inventory_data.new()

func _ready():
	pass
	load_inventory()

func _physics_process(delta):
	if Input.is_action_just_pressed("save"):
		Global.save_inventory()

func save_inventory():
	inventory_data.get_inventory()
	ResourceSaver.save(inventory_data, SAVE_PATH)
	
func load_inventory():
	if ResourceLoader.exists(SAVE_PATH):
		inventory_data = ResourceLoader.load(SAVE_PATH)
		PlayerInventory.inventory = inventory_data.inventory
		PlayerInventory.equipment = inventory_data.equipment
		PlayerInventory.seeds = inventory_data.seeds
