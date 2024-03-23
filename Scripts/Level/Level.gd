extends Node2D

@onready var resource_preloader := $ResourcePreloader

var cleared := false
var was_cleared := false # checks if room initially has enemies on entering
var number_of_doors := 2
var doors_spawned := false
var reward_given := false

func _ready():
	Global.rewards.clear() # reset the reward item list
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
			spawn_doors()
		if not reward_given and not was_cleared:
			give_reward()

func pause():
	if Input.is_action_just_pressed("esc"):
		pass # spawn pause menu

func spawn_doors(): # -785 to 785 = 1570 (size of level in x-axis) # -400 is the y-position for the door
	doors_spawned = true
	if not was_cleared:
		await get_tree().create_timer(0.5).timeout
	var door_pos = [-1, 0, 1]
	for i in door_pos:
		if i == 0 and true: # true for now, this condition is for an item that adds an extra door choice
			continue
		var door = resource_preloader.get_resource("Door").instantiate()
		add_child(door)
		door.position = Vector2(1570.0 * i / 5, -400)

func give_reward():
	reward_given = true
	await get_tree().create_timer(0.5).timeout
	if Global.next_reward == null: # just in case
		return
	var item = resource_preloader.get_resource("Item").instantiate()
	item.set_item(Pool.get_item(Pool.pools[Pool.pools.find(Global.next_reward)]))
	add_child(item)
	item.global_position = $Camera2D.global_position
	Global.next_reward = null
