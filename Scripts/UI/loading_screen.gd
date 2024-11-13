extends Control

var scene_to_load_path
var loading = false
var progress = []

func _ready():
	ResourceLoader.load_threaded_request(LevelList.loaded_current_room)

func load_scene(path):
	if ResourceLoader.has_cached(path):
		ResourceLoader.load_threaded_get(path)
	else:
		ResourceLoader.load_threaded_request(path)
	
	loading = true
	scene_to_load_path = path

func load_save():
	Global.load_room()
	Global.load_data()
	Pool.continue_run()

func _process(delta):
	if not loading:
		return
	
	var status = ResourceLoader.load_threaded_get_status(scene_to_load_path, progress)
	
	if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		$ProgressBar.value = progress[0] * 100
		$ProgressNumber.text = str(progress[0] * 100) + "%"
	elif status == ResourceLoader.THREAD_LOAD_LOADED:
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scene_to_load_path))
		queue_free()
		loading = false
	else:
		print("Error loading...")
