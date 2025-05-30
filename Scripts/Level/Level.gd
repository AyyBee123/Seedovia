extends Node2D

@onready var resource_preloader := $ResourcePreloader
@onready var circle_transition = %"Circle Transition"

const DEATH_SCREEN = preload("res://Scenes/UI/Death Screen.tscn")

var thread

func _input(event):
	if event.is_action_pressed("pause") and event.is_pressed():
		if player.get_node("Inventory").visible or player.get_node("Stat Sheet").visible:
			player.get_node("Inventory").visible = false
			player.get_node("Stat Sheet").visible = false
		else:
			if get_node_or_null("PauseMenu"):
				return
			var pause_menu = resource_preloader.get_resource("Pause Menu").instantiate()
			add_child(pause_menu)

var player
var player_pos = Vector2(0, 330)

var cleared := false
var was_cleared := false # checks if room initially has enemies on entering
var number_of_doors := 2
var doors_spawned := false
var reward_given := false

var time_minutes: int: 
	get:
		return LevelList.elapsed_time as int / 60
var time_seconds: int:
	get:
		return LevelList.elapsed_time as int % 60
var time_milli_seconds: int:
	get:
		return LevelList.elapsed_time * 100 as int % 100

func _ready():
	thread = Thread.new()
	SeedManager.seeds_on_screen.clear()
	SignalBus.player_die.connect(spawn_death_screen)
	%"Circle Transition".visible = true # disable it from the editor because it blocks the whole room
	# very start of the run
	if LevelList.room_number == 0 and LevelList.floor_number == 0 and PlayerCharacter._is_starting:
		SelectionSaveData.number_of_runs += 1
		Global.save_save_selection()
	
	# transition when entering new floor
	if LevelList._entered_new_floor:
		circle_transition.material.set("shader_parameter/circle_position_y", 0.695)
		circle_transition.get_node("AnimationPlayer").play("Open")
		LevelList._entered_new_floor = false
	else:
		# prevent black screen when entering a new room
		circle_transition.material.set("shader_parameter/circle_size", 1)
	
	# play floor theme music
	match LevelList.floor_number:
		0:
			play_music(Game.music_manager.GARDEN_THEME)
		1:
			play_music(Game.music_manager.HALL_THEME)
		2:
			play_music(Game.music_manager.KITCHEN_THEME)
		3:
			play_music(Game.music_manager.LIBRARY_THEME)
		4:
			play_music(Game.music_manager.BASEMENT_THEME)
	Global.RNG.randomize()
	if LevelList.loaded_room_is_cleared:
		for enemy in get_tree().get_nodes_in_group("Enemy"):
			enemy.visible = false
			enemy.queue_free()
			was_cleared = true
	# spawn the player character
	player = LevelList.player.instantiate()
	add_child(player)
	player.global_position = player_pos
	Global.load_run_data()
	Global.load_run_room()
	Global.load_data()
	reward_given = LevelList.current_reward_given
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
	for i in LevelList.pickup_items_on_ground:
		var item_instance = resource_preloader.get_resource("Pickup Item").instantiate()
		item_instance.set_item(LevelList.pickup_items_on_ground[i]["item"])
		add_child(item_instance)
		item_instance.global_position = LevelList.pickup_items_on_ground[i]["position"]
	for i in LevelList.shop_items_on_ground:
		var item_instance = resource_preloader.get_resource("Shop Item").instantiate()
		item_instance.set_item(LevelList.shop_items_on_ground[i]["item"])
		add_child(item_instance)
		item_instance.global_position = LevelList.shop_items_on_ground[i]["position"]
	for i in LevelList.coins_on_ground:
		var item_instance = resource_preloader.get_resource("Coin").instantiate()
		add_child(item_instance)
		item_instance.global_position = LevelList.coins_on_ground[i]["position"]
	await get_tree().physics_frame
	LevelList.entered_room = true
	Global.save_run_room()

func _physics_process(delta):
	$"Run Timer".visible = Global.settings.show_timer
	player = Targets.get_player()
	count_up(delta)
	check_for_enemies()

func check_for_enemies():
	if get_tree().get_nodes_in_group("Enemy").size() == 0:
		cleared = true
		SignalBus.room_cleared.emit()
		if not doors_spawned:
			spawn_doors()
			LevelList.doors_spawned = true
		if not reward_given and not was_cleared:
			if get_tree().current_scene.name == "Boss Room":
				Game.music_manager.play(Game.music_manager.BOSS_THEME_END)
			thread.start(give_reward)
			LevelList.current_reward_given = true
			LevelList.loaded_room_is_cleared = cleared
			await get_tree().create_timer(0.5).timeout # buffer to allow the item to register in the level
			ItemCheck.check_for_items()
			ItemCheck.check_for_coins()
			ItemCheck.check_for_pickup_items()
			Global.save_run_data()
			Global.save_run_room()
			Global.save_data()

func spawn_doors(): # -785 to 785 = 1570 (size of level in x-axis) # -400 is the y-position for the door(s)
	Global.load_run_room()
	doors_spawned = true
	if not was_cleared:
		await get_tree().create_timer(0.5, false).timeout
		Game.audio_manager.play(Game.audio_manager.bounce)
		Game.audio_manager.play(Game.audio_manager.ping)
	if LevelList.doors.size() > 0:
		for loaded_reward in LevelList.doors:
			var door = resource_preloader.get_resource("Door").instantiate()
			door.position = LevelList.doors[loaded_reward]
			door.set_reward(loaded_reward)
			add_child(door)
		return
	# room before the passive room, boss room, and the next floor (so it only spawns one door)
	if LevelList.room_number == 5 or LevelList.room_number == 11 or LevelList.room_number == 12:
		var door = resource_preloader.get_resource("Door").instantiate()
		add_child(door)
		if LevelList.room_number == 5:
			door.set_reward("Passive", ResourceLoader.load("res://Sprites/Reward Images/Passive.png"))
		elif LevelList.room_number == 11:
			door.set_reward("Boss", ResourceLoader.load("res://Sprites/Reward Images/Boss.png"))
		elif LevelList.room_number == 12:
			door.set_reward("Next Floor", ResourceLoader.load("res://Sprites/Reward Images/Next Floor.png"))
		door.position = Vector2(0, -384)
		return
	var door_pos = [-1, 0, 1]
	for i in door_pos:
		if i == 0 and true: # true for now, this condition is for an item that adds an extra door choice
			continue
		var door = resource_preloader.get_resource("Door").instantiate()
		if i == 1 and LevelList.room_number == 10:
			door.set_reward("Shop", ResourceLoader.load("res://Sprites/Reward Images/Shop.png"))
		else:
			door.set_reward()
		add_child(door)
		door.position = Vector2(1570.0 * i / 5, -384)
		LevelList.doors[door.text] = door.global_position
	Global.save_run_room()

func give_reward():
	reward_given = true
	await get_tree().create_timer(0.5, false).timeout
	if Global.next_reward == null: # just in case
		return
	if Global.next_reward.pool_name == "Talisman" or Global.next_reward.pool_name == "Die" \
			or Global.next_reward.pool_name == "Seed":
		var item = resource_preloader.get_resource("Item").instantiate()
		item.set_item(Pool.get_item(Pool.pools[Pool.pools.find(Global.next_reward)]))
		check_for_possesions(item)
		add_child(item)
		# spawn item in the middle of the screen
		item.global_position = $Camera2D.global_position
	else:
		if Global.next_reward.pool_name == "Coins":
			var roll: float = Global.RNG.randf_range(0.0, 1.0) # probability roll
			var acc_chance = 0.0 # accumulated chance
			var amount_of_coins: int
			var weighted_drops = { # <amount>: <weighted drop chance>
				1: 0.01,
				5: 0.80,
				10: 0.15,
				15: 0.04
			}
			for i in weighted_drops.keys():
				acc_chance += weighted_drops[i]
				if roll <= acc_chance:
					amount_of_coins = i
					break
			for i in amount_of_coins:
				var coin = resource_preloader.get_resource("Coin").instantiate()
				add_child(coin)
				coin.global_position = Vector2(randf_range(-25, 25), randf_range(-25, 25))
		elif Global.next_reward.pool_name == "Stat Up":
			var item = resource_preloader.get_resource("Pickup Item").instantiate()
			item.set_item(Pool.get_item(Pool.pools[Pool.pools.find(Global.next_reward)]))
			add_child(item)
			# spawn item in the middle of the screen
			item.global_position = $Camera2D.global_position
		elif Global.next_reward.pool_name == "Health Up":
			var item = resource_preloader.get_resource("Pickup Item").instantiate()
			item.set_item(Pool.get_item(Pool.pools[Pool.pools.find(Global.next_reward)]))
			add_child(item)
			# spawn item in the middle of the screen
			item.global_position = $Camera2D.global_position
		elif Global.next_reward.pool_name == "Leaf Heart":
			var item = resource_preloader.get_resource("Pickup Item").instantiate()
			item.set_item(Pool.get_item(Pool.pools[Pool.pools.find(Global.next_reward)]))
			add_child(item)
			# spawn item in the middle of the screen
			item.global_position = $Camera2D.global_position
		elif Global.next_reward.pool_name == "Heal":
			var item = resource_preloader.get_resource("Item").instantiate()
			item.set_item(Pool.get_item(Pool.pools[Pool.pools.find(Global.next_reward)]))
			add_child(item)
			# spawn item in the middle of the screen
			item.global_position = $Camera2D.global_position
	Global.next_reward = null
	finish.call_deferred()

func finish():
	thread.wait_to_finish()

func play_music(soundtrack):
	if get_tree().current_scene.name == "Boss Room":
		if not LevelList.loaded_room_is_cleared:
			Game.music_manager.play(Game.music_manager.BOSS_THEME)
		else:
			Game.music_manager.stop()
	elif get_tree().current_scene.name == "Shop":
		Game.music_manager.play(Game.music_manager.SHOP_THEME)
	else:
		Game.music_manager.play(soundtrack)
	Game.music_manager

func check_for_possesions(reward_item):
	# don't care if there are duplicate consumables
	if reward_item.item.category == "CONSUMABLE":
		return
	var possesions = []
	# get all items the player has in their inventory and put them in an array
	for item in PlayerInventory.inventory.values():
		possesions.append(item)
	for item in PlayerInventory.seeds.values():
		possesions.append(item)
	for item in PlayerInventory.talismans.values():
		possesions.append(item)
	
	for possesion in possesions:
		if reward_item.item.item_name == possesion.item_name:
			reward_item.set_item(Pool.get_item(Pool.pools[Pool.pools.find(Global.next_reward)]))
			check_for_possesions(reward_item)

func spawn_death_screen():
	var death_screen = DEATH_SCREEN.instantiate()
	get_tree().current_scene.add_child(death_screen)

func _notification(what: int):
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if get_node_or_null("PauseMenu"):
			return
		if player.get_node("Inventory").visible: # or stat sheet is visible (when I add the stat sheet)
			player.get_node("Inventory").visible = false
		var pause_menu = resource_preloader.get_resource("Pause Menu").instantiate()
		add_child.call_deferred(pause_menu)

func count_up(delta):
	LevelList.elapsed_time += delta
	SelectionSaveData.time_played += delta
	$"Run Timer".text = "%02d:%02d:%02d" % [time_minutes, time_seconds, time_milli_seconds]
