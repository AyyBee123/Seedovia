class_name Ach03Health extends Achievement

var berry = preload("res://Resources/Characters/berry.tres")
var ach_image = preload("res://Sprites/Achievements/Healthy.png")

func _ready():
	name = "Ach03Health"
	
	if not completed:
		SignalBus.max_health_changed.connect(_on_player_max_health_increase)

func _on_player_max_health_increase(amount):
	if amount >= 6:
		progress += 1
	if get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(berry)
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "Healthy"

func get_description() -> String:
	return "Have 6 max health."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 1

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		berry.unlocked = true
