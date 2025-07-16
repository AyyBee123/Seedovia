extends Node

const ORBITING_SEED = preload("res://Scenes/Characters/Passives/Orbiting Seed.tscn")

var player

func _ready():
	player = get_parent().get_parent()
	var index = 0
	# if there are already children (from duplicating), delete them
	for child in get_children():
		remove_child(child)
		child.queue_free()
	for i in 3:
		var seed = ORBITING_SEED.instantiate()
		var angle = TAU / 3.0 * index
		seed.z_index = player.z_index
		seed.angle = angle
		add_child(seed)
		seed.global_position = player.global_position + Vector2.RIGHT.rotated(angle) * seed.RADIUS
		index += 1
