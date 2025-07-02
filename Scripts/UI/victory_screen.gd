extends Control

@onready var label = %"Victory?"
@onready var background = %Background
@onready var run_timer = %"Run Timer"
@onready var menu_button = %"Menu Button"

var tween
var final_elapsed_time: float

var time_minutes: int: 
	get:
		return LevelList.elapsed_time as int / 60
var time_seconds: int:
	get:
		return LevelList.elapsed_time as int % 60
var time_milli_seconds: int:
	get:
		return LevelList.elapsed_time * 100 as int % 100

func _ready():
	Global.delete_run_data()
	run_timer.text = "%02d:%02d:%02d" % [time_minutes, time_seconds, time_milli_seconds]
	label.modulate.a = 0
	background.modulate.a = 0
	run_timer.modulate.a = 0
	menu_button.visible = false
	tween = get_tree().create_tween()
	tween.tween_interval(0.5)
	tween.tween_property(label, "modulate:a", 1, 1)
	tween.tween_interval(0.5)
	tween.tween_property(background, "modulate:a", 1, 1)
	tween.parallel().tween_property(run_timer, "modulate:a", 1, 1)
	tween.tween_callback(func(): 
		menu_button.visible = true
		menu_button.grab_focus()
	)

func _on_menu_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	get_tree().change_scene_to_file("res://Scenes/UI/Menu.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel") and event.is_pressed():
		Game.audio_manager.play(Game.audio_manager.popup_close_2)
		get_tree().change_scene_to_file("res://Scenes/UI/Menu.tscn")
