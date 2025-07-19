class_name Ach13WhiteChaos extends Achievement

var white_chaos = preload("res://Resources/Characters/white_chaos.tres")
var ach_image = preload("res://Sprites/Achievements/White Chaos.png")

func _ready():
	name = "Ach13WhiteChaos"
	
	if not completed:
		progress = 1
		SignalBus.entered_new_floor.connect(_on_entered_new_floor)

func _on_entered_new_floor(number):
	if LevelList.floor_number == 5 and get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(white_chaos)
	elif get_progress() < get_progress_goal() and not completed:
		progress = 1
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "?"

func get_description() -> String:
	return "Complete floor 5."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 1

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		white_chaos.unlocked = true
		SteamIntegration.set_ach("ACH_WHITECHAOS")
