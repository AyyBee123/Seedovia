extends Control

@onready var key = $Key
@onready var icon = $Icon

const ControllerIconMapping = preload("res://Scripts/UI/controller_icon_mapping.gd")

@onready var controller_mapping = ControllerIconMapping.new()

var player
var inventory

func _ready():
	player = Targets.get_player()
	inventory = player.inventory
	
	key.visible = false
	icon.visible = false

func _physics_process(delta):
	match Global.settings.input_icons:
		0:
			key.visible = inventory._isMandK
			icon.visible = not key.visible
		1:
			key.visible = true
		2:
			icon.visible = true
