class_name Ach07Blueberry extends Achievement

var blueberry = preload("res://Resources/Items/Seeds/blueberry.tres")
var ach_image = preload("res://Sprites/Achievements/Blueberry.png")

func _ready():
	name = "Ach07Blueberry"
	
	if not completed:
		progress = 1
		SignalBus.entered_new_floor.connect(_on_entered_new_floor)

func _on_entered_new_floor(number):
	if LevelList.floor_number == 4 and PlayerCharacter.starting_character.character_name == "Berry" \
			and get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(blueberry)
		SteamIntegration.set_ach("ACH_BLUEBERRY")
	elif get_progress() < get_progress_goal() and not completed:
		progress = 1
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "Blueberry"

func get_description() -> String:
	return "Complete floor 5 as Berry."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 1

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		blueberry.unlocked = true
