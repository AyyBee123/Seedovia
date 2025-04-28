class_name Ach04Swift extends Achievement

var salvia = preload("res://Resources/Characters/salvia.tres")
var ach_image = preload("res://Sprites/Achievements/Swift.png")

func _ready():
	name = "Ach04Swift"
	
	if not completed:
		progress = 1
		SignalBus.player_damaged.connect(_on_player_damaged)
		SignalBus.entered_new_floor.connect(_on_entered_new_floor)

func _on_entered_new_floor():
	if not LevelList.floor_number == 0 and get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(salvia)
	elif get_progress() < get_progress_goal() and not completed:
		progress = 1
	Global.save_achievements()
	Global.load_achievements()

func _on_player_damaged(amount):
	progress = 0
	Global.save_achievements()

func get_title() -> String:
	return "Swift"

func get_description() -> String:
	return "Complete a floor without taking damage."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 1

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		salvia.unlocked = true
		
