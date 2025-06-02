class_name Ach05Pizza extends Achievement

var pizza_man = preload("res://Resources/Characters/pizza_man.tres")
var ach_image = preload("res://Sprites/Achievements/Pizza.png")

## the toppings
const TOMATO = preload("res://Scenes/Enemies/Tomato.tscn")
const MUSHROOM = preload("res://Scenes/Enemies/Mushroom.tscn")
const CHEESE = preload("res://Scenes/Enemies/Cheese.tscn")
const SAUSAGE = preload("res://Scenes/Enemies/Sausage.tscn")
const HERB = preload("res://Scenes/Enemies/Herb.tscn")

var failed: bool
var toppings: Array = []
var topping_locations: Array = []
var spawned: Array

func _ready():
	name = "Ach05Pizza"
	
	if not completed:
		failed = false
		SignalBus.topping_saved.connect(_on_topping_saved)
		SignalBus.topping_killed.connect(_on_topping_killed)
		SignalBus.entered_new_room.connect(_on_entered_new_room)
		SignalBus.entered_new_floor.connect(_on_entered_new_floor)

func _on_topping_saved():
	progress += 1
	Global.save_achievements()
	
	if get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(pizza_man)
		SteamIntegration.set_ach("ACH_PIZZA")

func _on_topping_killed():
	failed = true
	progress = 0
	Global.save_achievements()

func _on_entered_new_room(number):
	if not completed and not failed and topping_locations.has(number):
		var index = topping_locations.find(number)
		if spawned[index]: # check if that topping already spawned
			return
		var topping = toppings[index].instantiate()
		get_tree().current_scene.add_child(topping)
		topping.global_position = Vector2(randf_range(-736, 736), randf_range(-352, 352))
		spawned[index] = true
		Global.save_achievements()

func _on_entered_new_floor(number):
	toppings.clear()
	topping_locations.clear()
	spawned.clear()
	
	Global.RNG.randomize()
	if number == 2: # kitchen floor
		toppings.append(TOMATO)
		toppings.append(MUSHROOM)
		toppings.append(CHEESE)
		toppings.append(SAUSAGE)
		toppings.append(HERB)
		
		for i in toppings:
			while 1:
				var rand_num = randi_range(1, 13)
				if not topping_locations.has(rand_num):
					topping_locations.append(rand_num)
					break
		
		for i in toppings:
			spawned.append(false)
	
	failed = false
	progress = 0
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "Pizza"

func get_description() -> String:
	return "Complete the Pizza."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 5

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		pizza_man.unlocked = true
