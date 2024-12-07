extends Control

var starting_character: character_class
var starting_stats: player_stats

func _ready():
	get_tree().paused = true

func _on_quick_restart_button_pressed():
	LevelList.elapsed_time = 0
	Global.RNG = RandomNumberGenerator.new()
	PlayerCharacter._is_starting = true
	Global.rewards.clear()
	Global.next_reward = null
	LevelList.floor_number = 0
	LevelList.room_number = 0 # value doesn't reset unless the save_run_room function is called right after (no idea why)
	LevelList.floor.rooms.clear()
	LevelList.current_reward_given = true
	LevelList.loaded_room_is_cleared = true
	LevelList.doors.clear()
	LevelList.doors_spawned = false
	LevelList.pickup_items_on_ground.clear()
	LevelList.items_on_ground.clear()
	LevelList.shop_items_on_ground.clear()
	LevelList.coins_on_ground.clear()
	LevelList.shop_items_spawned = false
	get_tree().paused = false
	starting_character = PlayerCharacter.starting_character
	PlayerCharacter.coins = starting_character.starting_coins
	PlayerInventory.inventory.clear()
	PlayerInventory.talismans.clear()
	PlayerInventory.seeds.clear()
	PlayerPassives.passives.clear()
	PlayerPassives.item_passives.clear()
	PlayerCharacter.set_inventory()
	PlayerCharacter.add_passives()
	starting_stats = PlayerCharacter.stat_resource
	Pool.start()
	Global.save_run_room()
	get_tree().change_scene_to_file("res://Scenes/Levels/Special/Starting Room 1.tscn")

func _on_quit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/Main Menu.tscn")
