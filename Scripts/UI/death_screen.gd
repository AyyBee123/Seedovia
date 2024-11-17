extends Control

var starting_character: character_class
var starting_stats: player_stats

func _ready():
	get_tree().paused = true

func _on_quick_restart_button_pressed():
	Global.RNG = RandomNumberGenerator.new()
	Global.rewards.clear()
	Global.next_reward = null
	LevelList.floor_number = 0
	LevelList.room_number = 0 # value doesn't reset unless the save_room function is called right after (no idea why)
	LevelList.floor.rooms.clear()
	LevelList.current_reward_given = true
	LevelList.loaded_room_is_cleared = true
	LevelList.doors.clear()
	LevelList.doors_spawned = false
	LevelList.passive_items_on_ground.clear()
	LevelList.items_on_ground.clear()
	get_tree().paused = false
	starting_character = PlayerCharacter.starting_character
	PlayerInventory.inventory.clear()
	PlayerInventory.talismans.clear()
	PlayerInventory.seeds.clear()
	PlayerPassives.passives.clear()
	PlayerPassives.item_passives.clear()
	PlayerCharacter.set_inventory()
	PlayerCharacter.add_passives()
	starting_stats = PlayerCharacter.stat_resource
	for stat in starting_stats.stats.keys():
		if stat == "Max_Health":
			starting_stats.stats[stat]["x"] = 1
			starting_stats.stats[stat]["+"] = 0
			continue
		starting_stats.stats[stat]["x"] = 1.0
		starting_stats.stats[stat]["+"] = 0.0
	Pool.start()
	Global.save_room()
	get_tree().change_scene_to_file("res://Scenes/Levels/Special/Starting Room.tscn")

func _on_quit_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/Main Menu.tscn")
