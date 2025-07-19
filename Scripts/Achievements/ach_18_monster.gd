class_name Ach18Monster extends Achievement

var alp = preload("res://Resources/Characters/alp.tres")
var blood_burst = preload("res://Resources/Items/Seeds/blood_burst.tres")
var devils_step = preload("res://Resources/Items/Passives/devils_step.tres")
var ach_image = preload("res://Sprites/Achievements/Monster Slayer.png")

func _ready():
	name = "Ach18Monster"
	
	if not completed:
		SignalBus.enemy_defeated.connect(_on_enemy_defeat)

func _on_enemy_defeat(enemy):
	progress += 1
	
	# update steam progress
	SteamIntegration.set_progress("STAT_MONSTER", progress)
	
	if get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(alp)
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "Monster Slayer"

func get_description() -> String:
	return "Defeat 500 Enemies."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 500

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		alp.unlocked = true
		blood_burst.unlocked = true
		devils_step.unlocked = true
		SteamIntegration.set_progress("STAT_MONSTER", get_progress_goal())
		SteamIntegration.set_ach("ACH_MONSTER")
