extends "res://Scripts/State/state_machine.gd"

var timer = Timer.new()

func _ready():
	add_state("idle")
	add_state("forward")
	set_state.call_deferred(states.idle)
	create_timer()

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.idle:
		parent.idle()
	if state == states.forward:
		parent.move_forward()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				return states.forward
		states.forward:
			if parent.direction_changed:
				parent.direction_changed = false
				timer.start(1)
				return states.idle
	return null

func create_timer():
	add_child(timer)
	timer.start(1)
	timer.one_shot = true
