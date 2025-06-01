extends Control

var DELETE_SAVE_POPUP = preload("res://Scenes/UI/Delete Save Popup.tscn")

@onready var saves = $GridContainer.get_children()

func _ready():
	for save in saves:
		var save_num = saves.find(save) + 1
		var delete = save.get_node("Delete Button")
		if not Global.load_data_exists("user://save_data%s.res" % save_num):
			save.get_node("Control").visible = false
			save.get_node("Empty Text").visible = true
			delete.disabled = true
			delete.visible = false
		else:
			Global.load_data("user://save_data%s.res" % save_num)
			save.find_child("Last Played Info").text = SelectionSaveData.last_played
			save.find_child("Runs Played Info").text = str(SelectionSaveData.number_of_runs)
			var time_played
			if SelectionSaveData.time_played < 3600:
				time_played = "%2dm %02ds" % [SelectionSaveData.time_played as int / 60 \
						, SelectionSaveData.time_played as int % 60]
			else:
				time_played = "%dh %2dm %02ds" % [SelectionSaveData.time_played as int / 3600 \
						, (SelectionSaveData.time_played as int / 60) % 60 \
						, SelectionSaveData.time_played as int % 60]
			save.find_child("Time Played Info").text = time_played
		save.pressed.connect(_save_button_pressed.bind(save_num))
		delete.pressed.connect(_delete_button_pressed.bind(save_num))

func _save_button_pressed(num):
	Game.audio_manager.play(Game.audio_manager.ui_button)
	Global.SAVE_PATH = "user://save_data%s.res" % num
	Global.RUN_SAVE_PATH = "user://current_run%s.res" % num
	if not Global.load_data_exists(Global.SAVE_PATH):
		var res = overall_data.new()
		res.resource_path = Global.SAVE_PATH
		var error = ResourceSaver.save(res, res.resource_path)
	
	Global.load_data()
	Global.load_achievements()
	var d = Time.get_datetime_dict_from_system()
	SelectionSaveData.last_played = "%04d-%02d-%02d" % [d.year, d.month, d.day]
	Global.save_save_selection()
	get_tree().change_scene_to_file("res://Scenes/UI/Main Menu.tscn")

func _delete_button_pressed(num):
	var delete_popup = DELETE_SAVE_POPUP.instantiate()
	delete_popup.SAVE_PATH = "user://save_data%s.res" % num
	delete_popup.RUN_SAVE_PATH = "user://current_run%s.res" % num
	delete_popup.save = saves[num - 1]
	delete_popup.num = num
	delete_popup.delete_button = saves[num - 1].get_node("Delete Button")
	get_parent().delete_popup = delete_popup
	get_tree().current_scene.add_child(delete_popup)
	delete_popup.global_position = Vector2(960, 1620)
