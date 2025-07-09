class_name Ach01Die extends Achievement

var cercis = preload("res://Resources/Characters/cercis.tres")
var grapes = preload("res://Resources/Items/Seeds/grapes.tres")
var shadow_summons = preload("res://Resources/Items/Passives/shadow_summons.tres")
var ach_image = preload("res://Sprites/Achievements/Die.png")
func _ready():
	name = "Ach01Die"
	
	if not completed:
		SignalBus.player_die.connect(_on_player_death)

func _on_player_death():
	progress += 1
	if get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(cercis)
		SteamIntegration.set_ach("ACH_DIE")
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "Death"

func get_description() -> String:
	return "Die."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 1

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		cercis.unlocked = true
		shadow_summons.unlocked = true
		grapes.unlocked = true
