class_name Ach16Jelly extends Achievement

var jelly = preload("res://Resources/Characters/jelly.tres")
var duplex = preload("res://Resources/Items/Seeds/duplex.tres")
var mitosis = preload("res://Resources/Items/Passives/mitosis.tres")
var ach_image = preload("res://Sprites/Achievements/Jelly.png")

func _ready():
	name = "Ach16Jelly"
	
	if not completed:
		SignalBus.enemy_defeated.connect(_on_enemy_defeat)

func _on_enemy_defeat(enemy):
	if not enemy.name.contains("Jumbo") or not enemy.is_in_group("Boss"):
		return
	progress += 1
	
	# update steam progress
	SteamIntegration.set_progress("STAT_PROGRESS", progress)
	
	if get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(jelly)
		SteamIntegration.set_ach("ACH_JELLY")
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "Jelly!"

func get_description() -> String:
	return "Defeat Jumbo 5 times."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 5

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		jelly.unlocked = true
		duplex.unlocked = true
		mitosis.unlocked = true
