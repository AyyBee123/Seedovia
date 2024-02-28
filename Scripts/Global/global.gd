extends Node

#%APPDATA%\Roaming\Godot\app_userdata\Roguelike
var SAVE_PATH := "user://player_inventory.res"
var data = player_data.new()

func _ready():
	load_inventory()

func _physics_process(delta):
	if Input.is_action_just_pressed("save"):
		Global.save_inventory()

func save_inventory():
	data.get_inventory()
	ResourceSaver.save(data, SAVE_PATH)
	
func load_inventory():
	if ResourceLoader.exists(SAVE_PATH):
		data = ResourceLoader.load(SAVE_PATH)
		PlayerInventory.inventory = data.inventory
		PlayerInventory.equipment = data.equipment
		PlayerInventory.seeds = data.seeds
