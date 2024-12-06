extends Control

@onready var saves = $GridContainer.get_children()

func _ready():
	for save in saves:
		save.pressed.connect(_save_button_pressed.bind(saves.find(save) + 1))
		var delete = save.get_node("Delete Button")
		delete.pressed.connect(_delete_button_pressed.bind(saves.find(save) + 1))

func _save_button_pressed(num):
	Global.SAVE_PATH = "user://save_data" + str(num) + ".res"
	Global.RUN_SAVE_PATH = "user://current_run" + str(num) + ".res"
	get_tree().change_scene_to_file("res://Scenes/UI/Main Menu.tscn")

func _delete_button_pressed(num):
	var save_name = "Save" + str(num)
	# add confirmation popup
