extends "res://Scripts/State/state_machine.gd"

func _ready():
	add_state("down")
	add_state("forward")
	call_deferred("set_state", states.down)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.down:
		parent.move_down()
	if state == states.forward:
		parent.move_forward()

func _get_transition(delta):
	match state:
		states.down:
			if not parent.falling:
				return states.forward
	return null
