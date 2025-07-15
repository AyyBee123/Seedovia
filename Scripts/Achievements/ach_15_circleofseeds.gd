class_name Ach15CircleOfSeeds extends Achievement

var circle_of_seeds = preload("res://Resources/Items/Passives/circle_of_seeds.tres")
var ach_image = preload("res://Sprites/Achievements/Circle of Seeds.png")

func _ready():
	name = "Ach15CircleOfSeeds"
	
	if not completed:
		progress = 1
		SignalBus.entered_new_floor.connect(_on_entered_new_floor)

func _on_entered_new_floor(number):
	if LevelList.floor_number == 5 and PlayerCharacter.starting_character.character_name == "Opium" \
			and get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(circle_of_seeds)
		SteamIntegration.set_ach("ACH_CIRCLEOFSEEDS")
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
		circle_of_seeds.unlocked = true
