extends Node

# %APPDATA%\Roaming\Godot\app_userdata\Roguelike
var SAVE_PATH := "user://player_inventory.res"
var data := player_data.new()

func _ready():
	load_inventory()
	LootPool.populate_pool(LootPool.equipment_pool, LootPool.equipment_path)
	LootPool.populate_pool(LootPool.consumables_pool, LootPool.consumables_path)
	LootPool.populate_pool(LootPool.passive_pool, LootPool.passives_path)
	LootPool.populate_pool(LootPool.seed_pool, LootPool.seeds_path)

func _physics_process(delta):
	if Input.is_action_just_pressed("save"):
		Global.save_inventory()

func save_inventory():
	data.get_inventory()
	ResourceSaver.save(data, SAVE_PATH)
	
func load_inventory():
	if not ResourceLoader.exists(SAVE_PATH):
		return
	data = ResourceLoader.load(SAVE_PATH)
	data.set_inventory()
