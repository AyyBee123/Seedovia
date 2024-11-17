extends "res://Scripts/State/state_machine.gd"

func _ready():
	add_state("down")
	add_state("forward")
	set_state.call_deferred(states.down)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.down:
		parent.move_down()
	if state == states.forward:
		parent.move_forward()

func _get_transition(delta):
	match state:
		states.down:
			if not parent.falling and get_parent().player != null:
				return states.forward
	return null
