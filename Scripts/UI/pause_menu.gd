extends Control

func _ready():
	get_tree().paused = true

func _physics_process(delta):
	if Input.is_action_just_pressed("esc"):
		get_tree().paused = false
		queue_free()

func _on_resume_button_pressed():
	get_tree().paused = false
	queue_free()
