extends TextureRect

var mouse_hovered = false
var event: InputEvent
@export var starting_character: character_class
@export var starting_stats: player_stats
var _player_stats: player_stats = preload("res://Resources/Characters/Stats/base_stats.tres")

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _physics_process(delta):
	if mouse_hovered == true:
	#TODO: [ph]
		modulate = Color.BLACK
	else:
		modulate = Color.WHITE

func _on_mouse_entered():
	mouse_hovered = true

func _on_mouse_exited():
	mouse_hovered = false

func select_character():
	Global.delete_data()
	PlayerCharacter._is_starting = true
	Global.RNG = RandomNumberGenerator.new()
	Global.rewards.clear()
	Global.next_reward = null
	LevelList.floor.rooms.clear()
	LevelList.floor_number = 0
	LevelList.room_number = 0
	LevelList.current_reward_given = true
	LevelList.doors.clear()
	LevelList.doors_spawned = false
	LevelList.passive_items_on_ground.clear()
	LevelList.items_on_ground.clear()
	PlayerCharacter.starting_character = starting_character
	PlayerInventory.inventory.clear()
	PlayerInventory.talismans.clear()
	PlayerInventory.seeds.clear()
	PlayerPassives.passives.clear()
	PlayerPassives.item_passives.clear()
	PlayerCharacter.set_inventory()
	PlayerCharacter.add_passives()
	PlayerCharacter.stat_resource = starting_stats
	Pool.start()
	_player_stats = starting_stats
	Global.save_room()
	get_tree().change_scene_to_file("res://Scenes/Levels/Special/Starting Room.tscn")

func set_base_stats():
	_player_stats.max_health = starting_stats.max_health
	_player_stats.health = starting_stats.max_health
	_player_stats.overcapped_health = starting_stats.max_health
	_player_stats.speed = starting_stats.speed
	_player_stats.dash_rate = starting_stats.dash_rate
	_player_stats.dash_distance = starting_stats.dash_distance
	_player_stats.dash_invulnerability = starting_stats.dash_invulnerability
	_player_stats.fire_rate = starting_stats.fire_rate
	_player_stats.contact_damage = starting_stats.contact_damage
	_player_stats.invulnerability_time = starting_stats.invulnerability_time
	_player_stats.acceleration = starting_stats.acceleration
	_player_stats.friction = starting_stats.friction
	_player_stats.luck = starting_stats.luck
	_player_stats.weapon_speed = starting_stats.weapon_speed
	_player_stats.weapon_range = starting_stats.weapon_range
	_player_stats.weapon_size = starting_stats.weapon_size
	_player_stats.weapon_damage = starting_stats.weapon_damage
	_player_stats.weapon_blast_radius = starting_stats.weapon_blast_radius
