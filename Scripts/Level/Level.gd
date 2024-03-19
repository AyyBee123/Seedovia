extends Node2D

func _ready():
	Global.load_data()

func pause():
	if Input.is_action_just_pressed("esc"):
		get_tree().paused = !get_tree().paused
