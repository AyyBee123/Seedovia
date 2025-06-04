extends Control

const SETTINGS = preload("res://Scenes/UI/Settings.tscn")
const MENU_SEED = preload("res://Scenes/UI/Menu Seed.tscn")
const LICENCE_POPUP = preload("res://Scenes/UI/Licence Popup.tscn")
const GRAPES = preload("res://Resources/Items/Seeds/grapes.tres")
const loading_screen_scene = preload("res://Scenes/UI/Loading Screen.tscn")
const character_select_scene = preload("res://Scenes/UI/Character Select.tscn")

@onready var camera = %"Menu Camera"
@onready var save_file_select = %"Save File Select"
@onready var starting_menu = %"Starting Menu"
@onready var continue_button = %"Continue Button"

@onready var save_pos = save_file_select.position
@onready var start_pos = starting_menu.position

var loading_screen_scene_instance
var tween
var thread
var current_pos: int = 0
var settings
var delete_popup
var licence_popup
var seed_list: Array

func _ready():
	if OS.has_feature("demo"):
		get_tree().change_scene_to_file.call_deferred("res://Scenes/UI/Demo Menu.tscn")
	Game.music_manager.play(Game.music_manager.MENU_THEME)
	seed_list = get_all_file_paths("res://Resources/Items/Seeds/")
	
	if FileAccess.file_exists(Global.RUN_SAVE_PATH):
		continue_button.disabled = false
		continue_button.get_node("Text").modulate = Color("e7cca0")
	else:
		continue_button.disabled = true
		continue_button.get_node("Text").modulate = Color("d2bdaa")
	
	thread = Thread.new()
	
	await get_tree().create_timer(0.5).timeout
	Global.load_data()
	Global.load_achievements()
	

func _on_play_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	get_tree().change_scene_to_packed(character_select_scene)

func _on_continue_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	loading_screen_scene_instance = loading_screen_scene.instantiate()
	get_tree().current_scene.add_child.call_deferred(loading_screen_scene_instance)
	thread.start(continue_run)

func continue_run():
	Global.load_run_data()
	Global.load_run_room()
	LevelList.load_char()
	Pool.continue_run()
	change_scene.call_deferred()

func change_scene():
	thread.wait_to_finish()
	get_tree().change_scene_to_file(LevelList.loaded_current_room)

func _on_back_button_pressed():
	%"Play Button".grab_focus()
	current_pos = 0 # starting menu position
	Game.audio_manager.play(Game.audio_manager.ui_button)
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(camera, "position", start_pos, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_settings_button_pressed():
	if get_tree().current_scene.find_child("Settings"): # if a settings scene already exists
		return
	settings = SETTINGS.instantiate()
	settings.default_focus = %"Settings Button"
	get_tree().current_scene.add_child(settings)

func _on_quit_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(settings):
			return
		if is_instance_valid(delete_popup):
			return
		if is_instance_valid(licence_popup):
			return
		if current_pos == 0:
			get_tree().quit()
		elif current_pos == 1:
			_on_back_button_pressed()

func spawn_seed():
	var seed = seed_list.pick_random()
	if not ResourceLoader.load(seed).unlocked:
		spawn_seed()
		return
	var menu_seed = MENU_SEED.instantiate()
	menu_seed.texture = ResourceLoader.load(seed).texture
	$CanvasLayer.add_child(menu_seed)
	menu_seed.position = Vector2(randf_range(0, 1920), -100)

func get_all_file_paths(path: String) -> Array[String]:
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		var file_path = path + "/" + file_name
		if file_name.ends_with(".remap"):
			file_name = file_name.replace(".remap", "")
		if dir.current_is_dir():
			file_paths += get_all_file_paths(file_path)
		else:
			file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths

func _on_seed_spawn_rate_timeout():
	spawn_seed()
	%"Seed Spawn Rate".start()

func _on_licence_button_pressed():
	Game.audio_manager.play(Game.audio_manager.ui_button)
	if get_tree().current_scene.find_child("Licence Popup"): # if a settings scene already exists
		return
	licence_popup = LICENCE_POPUP.instantiate()
	licence_popup.default_focus = %"Licence Button"
	get_tree().current_scene.add_child(licence_popup)

func _on_wishlist_button_pressed():
	OS.shell_open("steam://store/3636730")
