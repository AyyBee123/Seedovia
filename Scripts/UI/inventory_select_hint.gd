extends Control

@onready var key = $Key
@onready var icon = $Icon

const ControllerIconMapping = preload("res://Scripts/UI/controller_icon_mapping.gd")

@onready var controller_mapping = ControllerIconMapping.new()

var player

func _ready():
	player = Targets.get_player()
	
	key.visible = player._isMouse
	icon.visible = not key.visible
