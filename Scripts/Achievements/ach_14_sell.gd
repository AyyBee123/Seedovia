class_name Ach14Sell extends Achievement

var opium = preload("res://Resources/Characters/opium.tres")
var shrub_bush = preload("res://Resources/Items/Seeds/shrub_bush.tres")
var ach_image = preload("res://Sprites/Achievements/Sell.png")

func _ready():
	name = "Ach14Sell"
	
	if not completed:
		SignalBus.item_sold.connect(_on_item_sold)

func _on_item_sold(amount):
	progress += 1
	
	# update steam progress
	SteamIntegration.set_progress("STAT_SELL", progress)
	
	if get_progress() >= get_progress_goal() and not completed:
		completed = true
		SignalBus.achievement.emit(self)
		SignalBus.unlock.emit(opium)
	Global.save_achievements()
	Global.load_achievements()

func get_title() -> String:
	return "$$$"

func get_description() -> String:
	return "Sell 30 items."

func get_image() -> Texture:
	return ach_image

func get_progress() -> float:
	return progress

func get_progress_goal() -> float:
	return 30

func set_progress(_progress) -> void:
	super.set_progress(_progress)
	if completed:
		opium.unlocked = true
		shrub_bush.unlocked = true
		SteamIntegration.set_progress("STAT_SELL", get_progress_goal())
		SteamIntegration.set_ach("ACH_SELL")
