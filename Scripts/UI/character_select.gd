extends Control

var MAIN_MENU = load("res://Scenes/UI/Main Menu.tscn")
const character = preload("res://Scripts/UI/character.gd")
@onready var characters = %Characters.get_children()
@onready var starting_items = %"Starting Items".get_children()
@onready var loading_screen_scene = preload("res://Scenes/UI/Loading Screen.tscn")
@onready var buffer = $Buffer
var loading_screen_scene_instance
var char
var thread

@export var starting_character: character_class
@export var character_scene: String

func _ready():
	characters[0].grab_focus()
	thread = Thread.new()
	for button in characters:
		button.connect("gui_input", on_input)
	char = $"Characters/Character 1"
	display_info()

func _press(char_select: character):
	Game.audio_manager.play(Game.audio_manager.ui_button)
	char = char_select
	display_info()

func _on_back_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	get_tree().change_scene_to_packed(MAIN_MENU)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_packed(MAIN_MENU)

func on_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		if event.double_click and char.starting_character.unlocked:
			_on_play_button_pressed()

func _on_play_button_pressed():
	if not buffer.is_stopped(): # prevent accidentally starting immediately if the previous menu was double clicked
		return
	if starting_character == null or character_scene == null:
		return
	Game.audio_manager.play(Game.audio_manager.ui_button)
	loading_screen_scene_instance = loading_screen_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(loading_screen_scene_instance)
	thread.start(select_character)

func display_info():
	%"Character Sprite".texture = starting_character.character_sprite
	%"Character Name".text = starting_character.character_name
	
	%"Starting Items".visible = char.starting_character.unlocked
	
	if not char.starting_character.unlocked:
		%"Character Sprite".modulate = Color.BLACK
		%"Character Name".text = "Locked"
		$"Play Button/Text".modulate = Color("c8bca0")
	else:
		$"Play Button/Text".modulate = Color("e7cca0")
		%"Character Sprite".modulate = Color.WHITE
	%"Unlock Text".visible = not char.starting_character.unlocked
	%"Unlock Info".visible = not char.starting_character.unlocked
	%"Play Button".disabled = not char.starting_character.unlocked
	%"Unlock Info".text = char.unlock_method
	
	# default values
	for starting_item in starting_items:
		starting_item.get_node("Info").text = "None"
	
	# starting seed
	var starting_seeds = starting_character.starting_seeds.filter(func(value): return value != null)
	if starting_character.character_name == "?":
		starting_items[0].get_node("Info").text = "?"
	else:
		if starting_seeds.size() > 0:
			starting_items[0].get_node("Info").text = starting_seeds[0].item_name
		if starting_seeds.size() > 1:
			for i in starting_seeds.size() - 1: # exclude the first element in the array
				starting_items[0].get_node("Info").text += ", " + starting_seeds[i+1].item_name
	
	# starting talisman
	var starting_talisman = starting_character.starting_talismans.filter(func(value): return value != null)
	if starting_character.character_name == "?":
		starting_items[1].get_node("Info").text = "?"
	else:
		if starting_talisman.size() > 0:
			starting_items[1].get_node("Info").text = starting_talisman[0].item_name
		if starting_talisman.size() > 1:
			for i in starting_talisman.size() - 1: # exclude the first element in the array
				starting_items[1].get_node("Info").text += ", " + starting_talisman[i+1].item_name
	
	# starting passives
	var starting_passives = starting_character.starting_passives.filter(func(value): return value != null)
	if starting_passives.size() > 0:
		starting_items[2].get_node("Info").text = starting_passives[0].passive_name
	if starting_passives.size() > 1:
		for i in starting_passives.size() - 1: # exclude the first element in the array
			starting_items[2].get_node("Info").text += ", " + starting_passives[i+1].instantiate().passive_name
	
	# starting inventory
	var starting_inventory = starting_character.starting_inventory.filter(func(value): return value != null)
	if starting_inventory.size() > 0:
		starting_items[3].get_node("Info").text = starting_inventory[0].item_name
	if starting_inventory.size() > 1:
		for i in starting_inventory.size() - 1: # exclude the first element in the array
			starting_items[3].get_node("Info").text += ", " + starting_inventory[i+1].item_name

func select_character():
	Global.delete_run_data()
	LevelList.elapsed_time = 0
	PlayerCharacter._is_starting = true
	PlayerCharacter.coins = starting_character.starting_coins
	LevelList.character_scene_file_path = character_scene
	LevelList.load_char()
	Global.RNG = RandomNumberGenerator.new()
	Global.rewards.clear()
	Global.next_reward = null
	LevelList.floor.rooms.clear()
	LevelList.floor_number = 0
	LevelList.room_number = 0
	LevelList.current_reward_given = true
	LevelList.doors.clear()
	LevelList.doors_spawned = false
	LevelList.pickup_items_on_ground.clear()
	LevelList.items_on_ground.clear()
	LevelList.shop_items_on_ground.clear()
	LevelList.coins_on_ground.clear()
	LevelList.shop_items_spawned = false
	PlayerCharacter.starting_character = starting_character
	PlayerInventory.inventory.clear()
	PlayerInventory.talismans.clear()
	PlayerInventory.seeds.clear()
	PlayerPassives.passives.clear()
	PlayerPassives.item_passives.clear()
	PlayerCharacter.set_inventory()
	PlayerCharacter.add_passives()
	Pool.start()
	Global.save_run_room()
	change_scene.call_deferred()

func change_scene():
	thread.wait_to_finish()
	SignalBus.entered_new_floor.emit()
	get_tree().change_scene_to_file("res://Scenes/Levels/Special/Starting Room 1.tscn")
