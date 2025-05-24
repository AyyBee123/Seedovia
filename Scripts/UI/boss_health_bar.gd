extends "res://Scripts/UI/health_bar.gd"

func _ready():
	pass

func _process(delta):
	show_bar()

func show_bar():
	visible = Global.settings.show_damage_numbers_2 # toggle visibility based on the health bar setting
