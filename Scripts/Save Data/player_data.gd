class_name player_data extends Resource

# resource variables must have @export to be saved in a file
@export var inventory: Dictionary = PlayerInventory.inventory
@export var talismans: Dictionary = PlayerInventory.talismans
@export var seeds: Dictionary = PlayerInventory.seeds
@export var passives: Array
@export var item_passives: Array
@export var stats: Dictionary
@export var base_stats: Resource
@export var current_health: int
@export var overcapped_health: int
@export var character_sprite: Texture
@export var character_hand_sprite: Texture

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
	base_stats = PlayerStatStorage.base_stats

func set_stats():
	PlayerStatStorage.stats = stats
	PlayerStatStorage.current_health = current_health
	PlayerStatStorage.overcapped_health = overcapped_health
	PlayerStatStorage.base_stats = base_stats
	PlayerStatStorage.set_stats()

func get_sprite():
	character_sprite = PlayerCharacter.sprite
	character_hand_sprite = PlayerCharacter.hand_sprite

func set_sprite():
	PlayerCharacter.sprite = ImageTexture.create_from_image(character_sprite.get_image())
	PlayerCharacter.hand_sprite = ImageTexture.create_from_image(character_hand_sprite.get_image())
