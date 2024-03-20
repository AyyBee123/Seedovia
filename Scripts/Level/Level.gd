extends Node2D

@onready var resource_preloader := $ResourcePreloader

var cleared := false
var was_cleared := false # checks if room initially has enemies on entering
var number_of_doors := 2
var doors_spawned := false

func _ready():
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		was_cleared = true
	Global.load_data()

func _physics_process(delta):
	pause()
	check_for_enemies()

func check_for_enemies():
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		cleared = true
		if not doors_spawned:
			if not was_cleared:
				await get_tree().create_timer(0.5).timeout
			spawn_doors()

func pause():
	if Input.is_action_just_pressed("esc"):
		get_tree().paused = !get_tree().paused

func spawn_doors(): # -785 to 785 = 1570 (size of level in x-axis) # -400 is the y-position for the door
	var door_pos = [-1, 0, 1]
	for i in door_pos:
		if i == 0 and true: # true for now, this condition is for an item that adds an extra door choice
			continue
		var door = resource_preloader.get_resource("Door").instantiate()
		add_child(door)
		door.position = Vector2(1570.0 * i / 5, -400)
	doors_spawned = true
