extends "res://Scripts/Level/Level.gd"

var CONSOLE = preload("res://Scenes/Utils/Console.tscn")

var _player_stats: player_stats = preload("res://Resources/Characters/Stats/base_stats.tres")

@export var starting_character: character_class
var starting_stats: player_stats = preload("res://Resources/Characters/Stats/base_stats.tres")
@export var character_scene: String

func _ready():
	Global.RNG = RandomNumberGenerator.new()
	select_character()
	# spawn the player character
	player = LevelList.player.instantiate()
	add_child(player)
	player.global_position = player_pos
	circle_transition.get_node("AnimationPlayer").play("Instant Open")

func _physics_process(delta):
	player = Targets.get_player()
	count_up(delta)
	
	print("Node count: ", get_tree().get_node_count())
	print(RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TEXTURE_MEM_USED))

func _input(event):
	if event is InputEventKey:
		# 96 is the ` key
		if event.keycode == 96 and event.pressed:
			if get_node_or_null("Console"):
				get_node("Console").queue_free()
				return
			var console = CONSOLE.instantiate()
			add_child(console)
	
	if Input.is_action_just_pressed("esc"):
		if player.get_node("Inventory").visible or player.get_node("Stat Sheet").visible:
			player.get_node("Inventory").visible = false
			player.get_node("Stat Sheet").visible = false
		elif get_node_or_null("Console"):
			get_node("Console").queue_free()
		else:
			if get_node_or_null("PauseMenu"):
				return
			var pause_menu = resource_preloader.get_resource("Pause Menu").instantiate()
			add_child(pause_menu)

func select_character():
	LevelList.elapsed_time = 0
	PlayerCharacter._is_starting = true
	PlayerCharacter.coins = starting_character.starting_coins
	LevelList.character_scene_file_path = character_scene
	LevelList.load_char()
	PlayerCharacter.starting_character = starting_character
	PlayerInventory.inventory.clear()
	PlayerInventory.talismans.clear()
	PlayerInventory.seeds.clear()
	PlayerPassives.passives.clear()
	PlayerPassives.item_passives.clear()
	PlayerCharacter.set_inventory()
	PlayerCharacter.add_passives()
	_player_stats = starting_stats
