extends Node

var AppID = "480" # temparary until the game has its own steam page
var id
var steam_name

func _init():
	OS.set_environment("SteamAppID", AppID)
	OS.set_environment("SteamGameID", AppID)

func _ready():
	Steam.steamInit()
	
	id = Steam.getSteamID()
	steam_name = Steam.getFriendPersonaName(id)
