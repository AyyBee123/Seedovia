extends Node

var AppID = "3636730"
var id
var steam_name
var steam_ready: bool = false

func _init():
	OS.set_environment("SteamAppID", AppID)
	OS.set_environment("SteamGameID", AppID)

func _ready():
	steam_ready = Steam.steamInit()
	
	#id = Steam.getSteamID()
	#steam_name = Steam.getFriendPersonaName(id)

func set_ach(ach: String):
	if not steam_ready:
		print("Steam not initialized!")
		return
	
	var status = Steam.getAchievement(ach)
	
	if status.has("achieved") and status["achieved"]:
		return # already unlocked

	if Steam.setAchievement(ach):
		print("Achievement", ach, "unlocked")
	else:
		print("Failed to unlock achievement", ach)

	if Steam.storeStats():
		print("Stats stored successfully")
	else:
		print("Failed to store stats")

func set_progress(ach: String, value):
	if not steam_ready:
		print("Steam not initialized!")
		return
	
	if typeof(value) == TYPE_INT:
		if Steam.setStatInt(ach, value):
			print("Set int stat", ach, "to", value)
	elif typeof(value) == TYPE_FLOAT:
		if Steam.setStatFloat(ach, value):
			print("Set float stat", ach, "to", value)
	if Steam.storeStats():
		print("Stats stored to Steam")
	else:
		print("Failed to store stats")
