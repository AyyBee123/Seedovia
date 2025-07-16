extends Node

const MAX_OFFSET = 25

var orbital
var weapon_instance
var player
var offset: Vector2

func _ready():
	randomize()
	weapon_instance = get_parent()
	if orbital.weapon_instance:
		offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * MAX_OFFSET
	
	SignalBus.inventory_item_moved.connect(weapon_instance.destroy)

func _physics_process(delta):
	if not weapon_instance.is_in_group("Seed"):
		return
	# give the seed infinite range and lifetime
	weapon_instance.total_distance = 0
	if "lifetime" in weapon_instance:
		weapon_instance.lifetime.start()
	weapon_instance.global_position = orbital.global_position + offset
	weapon_instance.direction = player.global_position.direction_to(orbital.global_position)

func _exit_tree():
	if orbital:
		orbital.list.erase(weapon_instance)
