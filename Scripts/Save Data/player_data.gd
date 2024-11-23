class_name player_data extends Resource

# resource variables must have @export to be saved in a file
# data is loaded from the load_data function in the global script
@export var inventory: Dictionary = PlayerInventory.inventory
@export var talismans: Dictionary = PlayerInventory.talismans
@export var seeds: Dictionary = PlayerInventory.seeds
@export var starting_character: character_class
@export var starting_passives: Array
@export var passives: Array
@export var item_passives: Array
@export var character_scene_file_path: String
@export var coins: int
@export var stats: Dictionary
@export var current_health: int
@export var overcapped_health: int
@export var floor_number: int
@export var room_number: int
@export var current_room: String
@export var is_cleared: bool
@export var reward_given: bool
@export var doors: Dictionary
@export var items_on_ground: Dictionary
@export var passive_items_on_ground: Dictionary
@export var picked_up_passive: bool
@export var next_reward: item_pool
@export var passive_pool: Array
@export var current_seed: int

# these functions are called form the global script
func get_inventory():
	inventory = PlayerInventory.inventory
	talismans = PlayerInventory.talismans
	seeds = PlayerInventory.seeds

func set_inventory():
	PlayerInventory.inventory = inventory
	PlayerInventory.talismans = talismans
	PlayerInventory.seeds = seeds

func get_passives():
	starting_passives = PlayerPassives.starting_passives
	passives = PlayerPassives.get_passives()

func set_passives():
	PlayerPassives.starting_passives = starting_passives
	PlayerPassives.passives = passives

func get_item_passives():
	item_passives = PlayerPassives.get_item_passives()

func set_item_passives():
	PlayerPassives.item_passives = item_passives

func get_stats():
	stats = PlayerStatStorage.get_stats()
	current_health = PlayerStatStorage.current_health
	overcapped_health = PlayerStatStorage.overcapped_health

func set_stats():
	PlayerStatStorage.current_health = current_health
	PlayerStatStorage.overcapped_health = overcapped_health
	PlayerStatStorage.stats = stats

func get_character():
	character_scene_file_path = LevelList.character_scene_file_path
	starting_character = PlayerCharacter.starting_character

func set_character():
	LevelList.character_scene_file_path = character_scene_file_path
	PlayerCharacter.starting_character = starting_character

func get_coins():
	coins = PlayerCharacter.coins

func set_coins():
	PlayerCharacter.coins = coins

func get_current_room():
	floor_number = LevelList.floor_number
	room_number = LevelList.room_number
	current_room = LevelList.current_room
	is_cleared = LevelList.loaded_room_is_cleared
	reward_given = LevelList.current_reward_given
	doors = LevelList.doors
	items_on_ground = LevelList.items_on_ground
	passive_items_on_ground = LevelList.passive_items_on_ground
	picked_up_passive = LevelList.picked_up_passive
	current_seed = Global.RNG.seed
	next_reward = Global.next_reward

func set_current_room():
	Global.RNG = RandomNumberGenerator.new()
	Global.RNG.seed = current_seed
	LevelList.floor_number = floor_number
	LevelList.room_number = room_number
	LevelList.loaded_current_room = current_room
	LevelList.loaded_room_is_cleared = is_cleared
	LevelList.current_reward_given = reward_given
	LevelList.doors = doors
	LevelList.items_on_ground = items_on_ground
	LevelList.passive_items_on_ground = passive_items_on_ground
	LevelList.picked_up_passive = picked_up_passive
	Global.next_reward = next_reward

func get_pools():
	passive_pool = Pool.passive_pool.pool

func set_pools():
	Pool.passive_pool.pool = passive_pool
