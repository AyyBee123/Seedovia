class_name Ach02Coins extends Achievement

var midas = preload("res://Resources/Characters/midas.tres")
var fools_gold = preload("res://Resources/Items/Seeds/fools_gold.tres")
var ach_image = preload("res://Sprites/Achievements/Rich.png")

func _ready():
	name = "Ach02Coins"
	
	if not completed:
		SignalBus.coin_pickup.connect(_on_coin_pickup)

func _on_coin_pickup(amount):
	if amount >= 100:
		progress += 1
	if get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(midas)
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "I'm Rich!"

func get_description() -> String:
	return "Accumulate 100 coins at once."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 1

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		midas.unlocked = true
		fools_gold.unlocked = true
		SteamIntegration.set_ach("ACH_RICH")
