extends Node

var AppID = "3636730"
var id
var steam_name

func _init():
	OS.set_environment("SteamAppID", AppID)
	OS.set_environment("SteamGameID", AppID)

func _ready():
	Steam.steamInit()
	
	#id = Steam.getSteamID()
	#steam_name = Steam.getFriendPersonaName(id)

func set_ach(ach):
	var status = Steam.getAchievement(ach)
	if status['achieved']:
		return
	Steam.setAchievement(ach)
