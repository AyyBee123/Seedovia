class_name Ach09ShadeSlash extends Achievement

var shade_slash = preload("res://Resources/Items/Passives/shade_slash.tres")
var ach_image = preload("res://Sprites/Achievements/Shade Slash.png")

func _ready():
	name = "Ach09ShadeSlash"
	
	if not completed:
		progress = 1
		SignalBus.entered_new_floor.connect(_on_entered_new_floor)

func _on_entered_new_floor(number):
	if LevelList.floor_number == 4 and PlayerCharacter.starting_character.character_name == "Cercis" \
			and get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(shade_slash)
		SteamIntegration.set_ach("ACH_SHADESLASH")
	elif get_progress() < get_progress_goal() and not completed:
		progress = 1
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "Shade Slash"

func get_description() -> String:
	return "Complete floor 5 as Cercis."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 1

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		shade_slash.unlocked = true
