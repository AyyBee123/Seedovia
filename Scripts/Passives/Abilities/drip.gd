extends Node

const DRIP_POOL = preload("res://Scenes/Passives/Effects/Drip Pool.tscn")

const RANGE = 50

var source

var distance_travelled = 0
var total_distance = 0
var starting_position

func _ready():
	source = get_parent().get_parent()
	starting_position = source.global_position

func _physics_process(delta):
	travelled_distance()

func travelled_distance():
	distance_travelled = starting_position.distance_to(source.global_position)
	total_distance += distance_travelled
	starting_position = source.global_position
	if total_distance >= RANGE:
		total_distance = 0
		var drip = DRIP_POOL.instantiate()
		get_tree().current_scene.add_child(drip)
		if source.get_node_or_null("Shadow"):
			drip.global_position = source.get_node("Shadow").global_position
		else:
			drip.global_position = source.global_position
