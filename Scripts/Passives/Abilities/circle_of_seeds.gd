extends Node

const CIRCLE_OF_SEEDS_ORBITAL = preload("res://Scenes/Passives/Effects/Circle of Seeds Orbital.tscn")

const RADIUS = 65

var player
var current_seeds

func _ready():
	player = get_parent().get_parent()
	set_items()
	SignalBus.inventory_item_moved.connect(set_items)

func set_items():
	# remove all children
	for child in get_children():
		child.queue_free()
	
	current_seeds = PlayerInventory.seeds
	var index = 0
	for i in current_seeds.keys():
		var seed = current_seeds[i]
		var angle = TAU / current_seeds.size() * index
		var orbital = CIRCLE_OF_SEEDS_ORBITAL.instantiate()
		orbital.scene = seed.scene
		orbital.texture = seed.texture
		orbital.z_index = player.z_index
		orbital.player = player
		orbital.radius = RADIUS
		orbital.angle = angle
		orbital.seed_slot = i
		add_child(orbital)
		orbital.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * RADIUS
		index += 1
