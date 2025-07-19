class_name Ach08GoldBasket extends Achievement

var pot_of_gold = preload("res://Resources/Items/Passives/pot_of_gold.tres")
var ach_image = preload("res://Sprites/Achievements/Pot of Gold.png")

func _ready():
	name = "Ach08GoldBasket"
	
	if not completed:
		progress = 1
		SignalBus.entered_new_floor.connect(_on_entered_new_floor)

func _on_entered_new_floor(number):
	if LevelList.floor_number == 5 and PlayerCharacter.starting_character.character_name == "Midas" \
			and get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(pot_of_gold)
	elif get_progress() < get_progress_goal() and not completed:
		progress = 1
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "Pot of Gold"

func get_description() -> String:
	return "Complete floor 5 as Midas."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 1

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		pot_of_gold.unlocked = true
		SteamIntegration.set_ach("ACH_GOLDBASKET")
