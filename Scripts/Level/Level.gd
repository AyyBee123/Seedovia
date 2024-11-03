extends Node2D

@onready var resource_preloader := $ResourcePreloader
@onready var player := $Player

var cleared := false
var was_cleared := false # checks if room initially has enemies on entering
var number_of_doors := 2
var doors_spawned := false
var reward_given := false
var is_paused := false
var packed_scene = PackedScene.new()

func _ready():
	Global.RNG.randomize()
	if LevelList.loaded_room_is_cleared:
		for enemy in get_tree().get_nodes_in_group("Enemy"):
			enemy.visible = false
			enemy.queue_free()
			was_cleared = true
	Global.load_room()
	Global.load_data()
	reward_given = LevelList.current_reward_given
	Targets.get_entities()
	LevelList.current_room = get_tree().current_scene.scene_file_path
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		was_cleared = true
	if not LevelList.doors_spawned and not LevelList.current_reward_given:
		Global.rewards.clear() # reset the reward item list
		check_for_enemies() # initially check for enemies to see if the room is cleared
	# get the current scene's filepath and then save it to the current run file
	for i in LevelList.items_on_ground:
		var item_instance = resource_preloader.get_resource("Item").instantiate()
		item_instance.set_item(LevelList.items_on_ground[i]["item"])
		add_child(item_instance)
		item_instance.global_position = LevelList.items_on_ground[i]["position"]
	for i in LevelList.passive_items_on_ground:
		var item_instance = resource_preloader.get_resource("Item").instantiate()
		item_instance.set_item(LevelList.passive_items_on_ground[i]["item"])
		add_child(item_instance)
		item_instance.global_position = LevelList.passive_items_on_ground[i]["position"]
	Global.save_room()
	Global.save_data()

func _physics_process(delta):
	pause()
	check_for_enemies()
	check_for_items()

func check_for_enemies():
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		cleared = true
		if not doors_spawned:
			spawn_doors()
			LevelList.doors_spawned = true
		if not reward_given:
			give_reward()
			LevelList.current_reward_given = true
			LevelList.loaded_room_is_cleared = cleared
			Global.save_data()
			Global.save_room()

func check_for_items():
	LevelList.items_on_ground.clear()
	var i = 0
	# check all direct children of the scene (i.e. all nodes on the ground)
	for item in get_children():
		# get the item and its current position, stored as a dictionary
		if item.is_in_group("Item"):
			LevelList.items_on_ground[i] = {
				"item": item.item, 
				"position": item.global_position
			}
			i += 1

func check_for_passive_items():
	LevelList.passive_items_on_ground.clear()
	var i = 0
	# check all direct children of the scene (i.e. all nodes on the ground)
	for item in get_children():
		# get the item and its current position, stored as a dictionary
		if item.is_in_group("Passive Item"):
			LevelList.passive_items_on_ground[i] = {
				"item": item.item, 
				"position": item.global_position
			}
			i += 1

func pause():
	if Input.is_action_just_pressed("esc"):
		if player.get_node("Inventory").visible: # or stat sheet is visible (when I add the stat sheet)
			player.get_node("Inventory").visible = false
		else:
			var pause_menu = resource_preloader.get_resource("Pause Menu").instantiate()
			add_child(pause_menu)

func spawn_doors(): # -785 to 785 = 1570 (size of level in x-axis) # -400 is the y-position for the door(s)
	Global.load_room()
	doors_spawned = true
	if not was_cleared:
		await get_tree().create_timer(0.5).timeout
	# room before the passive room, boss room, and the next floor (so it only spawns one door)
	if LevelList.doors.size() > 0:
		for loaded_reward in LevelList.doors:
			var door = resource_preloader.get_resource("Door").instantiate()
			door.position = LevelList.doors[loaded_reward]
			door.set_reward(loaded_reward)
			add_child(door)
		return
	if LevelList.room_number == 4 or LevelList.room_number == 9 or LevelList.room_number == 10:
		var door = resource_preloader.get_resource("Door").instantiate()
		add_child(door)
		if LevelList.room_number == 4:
			door.set_reward("Passive")
		elif LevelList.room_number == 9:
			door.set_reward("Boss")
		elif LevelList.room_number == 10:
			door.set_reward("Next Floor")
		door.position = Vector2(0, -384)
		return
	var door_pos = [-1, 0, 1]
	for i in door_pos:
		if i == 0 and true: # true for now, this condition is for an item that adds an extra door choice
			continue
		var door = resource_preloader.get_resource("Door").instantiate()
		door.set_reward()
		add_child(door)
		door.position = Vector2(1570.0 * i / 5, -384)
		LevelList.doors[door.text] = door.global_position
	Global.save_room()

func give_reward():
	reward_given = true
	await get_tree().create_timer(0.5).timeout
	if Global.next_reward == null: # just in case
		return
	var item = resource_preloader.get_resource("Item").instantiate()
	item.set_item(Pool.get_item(Pool.pools[Pool.pools.find(Global.next_reward)]))
	add_child(item)
	# spawn item in the middle of the screen
	item.global_position = $Camera2D.global_position
	Global.next_reward = null
