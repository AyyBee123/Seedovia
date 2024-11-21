extends Node

var AppID = "480"
var id
var steam_name

func _init():
	OS.set_environment("SteamAppID", AppID)
	OS.set_environment("SteamGameID", AppID)

func _ready():
	Steam.steamInit()
	
	id = Steam.getSteamID()
	steam_name = Steam.getFriendPersonaName(id)
