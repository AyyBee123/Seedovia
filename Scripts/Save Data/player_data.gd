class_name player_data extends Resource

# resource variables must have @export to be saved in a file
@export var inventory: Dictionary = PlayerInventory.inventory
@export var equipment: Dictionary = PlayerInventory.equipment
@export var seeds: Dictionary = PlayerInventory.seeds
@export var passives: Array
@export var item_passives: Array
@export var stats: Dictionary
@export var current_health: int
@export var overcapped_health: int

# these functions are called form the global script
func get_inventory():
	inventory = PlayerInventory.inventory
	equipment = PlayerInventory.equipment
	seeds = PlayerInventory.seeds
	
func set_inventory():
	PlayerInventory.inventory = inventory
	PlayerInventory.equipment = equipment
	PlayerInventory.seeds = seeds

func get_passives():
	passives = PlayerPassives.get_passives()

func set_passives():
	PlayerPassives.passives = passives
	PlayerPassives.set_passives()

func get_item_passives():
	item_passives = PlayerPassives.get_item_passives()

func set_item_passives():
	PlayerPassives.item_passives = item_passives
	PlayerPassives.set_item_passives()

func get_stats():
	stats = PlayerStatStorage.get_stats()
	current_health = PlayerStatStorage.current_health
	overcapped_health = PlayerStatStorage.overcapped_health

func set_stats():
	PlayerStatStorage.stats = stats
	PlayerStatStorage.current_health = current_health
	PlayerStatStorage.overcapped_health = overcapped_health
	PlayerStatStorage.set_stats()
