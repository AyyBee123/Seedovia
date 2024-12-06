extends Control

var scene_to_load_path
var loading = false
var progress = []
var thread: Thread

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
	thread = Thread.new()
	thread.start(Global.load_run_room)
	Global.load_run_data()
	LevelList.load_char()
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

func _exit_tree():
	thread.wait_to_finish()
