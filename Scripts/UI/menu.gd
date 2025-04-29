extends Control

const SETTINGS = preload("res://Scenes/UI/Settings.tscn")
const MENU_SEED = preload("res://Scenes/UI/Menu Seed.tscn")

@onready var camera = $"Menu Camera"
@onready var save_file_select = $"Save File Select"
@onready var starting_menu = $"Starting Menu"

@onready var save_pos = save_file_select.position
@onready var start_pos = starting_menu.position

var tween
var current_pos: int = 0
var settings
var delete_popup
var seed_list: Array

func _ready():
	seed_list = get_all_file_paths("res://Resources/Items/Seeds/")

func _physics_process(delta):
	pass

func _on_play_button_pressed():
	$"Save File Select".find_child("Save1").grab_focus()
	current_pos = 1 # save file select position
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(camera, "position", Vector2(0, 1080), 0.5) \
			.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_back_button_pressed():
	%"Play Button".grab_focus()
	current_pos = 0 # starting menu position
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
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if is_instance_valid(settings):
			return
		if is_instance_valid(delete_popup):
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
	get_tree().current_scene.add_child(menu_seed)
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
	$"Seed Spawn Rate".start()
