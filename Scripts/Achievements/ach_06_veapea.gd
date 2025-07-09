class_name Ach06VeaPea extends Achievement

var vea_pea = preload("res://Resources/Items/Seeds/vea_pea.tres")
var ach_image = preload("res://Sprites/Achievements/Swift.png")

func _ready():
	name = "Ach06VeaPea"
	
	if not completed:
		progress = 1
		SignalBus.entered_new_floor.connect(_on_entered_new_floor)

func _on_entered_new_floor(number):
	if LevelList.floor_number == 4 and PlayerCharacter.starting_character.character_name == "Sapling" \
			and get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(vea_pea)
		SteamIntegration.set_ach("ACH_VEAPEA")
	elif get_progress() < get_progress_goal() and not completed:
		progress = 1
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "Vea Pea"

func get_description() -> String:
	return "Complete floor 5 as Sapling."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 1

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		vea_pea.unlocked = true
