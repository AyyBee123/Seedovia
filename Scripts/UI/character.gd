extends TextureButton

var mouse_hovered = false
var event: InputEvent
@export var starting_character: character_class
@export var character_scene: String

var _player_stats: player_stats = preload("res://Resources/Characters/Stats/base_stats.tres")

var menu

func _ready():
	menu = get_parent().get_parent()
	#if not starting_character.unlocked:
		#get_node("Lock").visible = true
		#self_modulate = Color.BLACK
		#mouse_default_cursor_shape = 0
		#disabled = true

func _physics_process(delta):
	starting_character.unlocked

func _on_pressed():
	menu.starting_character = starting_character
	menu.character_scene = character_scene
	menu._press(self)

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
	get_tree().change_scene_to_file("res://Scenes/Levels/Special/Starting Room 1.tscn")
