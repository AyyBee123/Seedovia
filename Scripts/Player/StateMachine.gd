extends state_machine

func _ready():
	add_state("idle")
	add_state("move")
	add_state("dash")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	parent.move_and_slide()
	
	if state == states.move:
		parent.move()
	if state == states.idle:
		parent.stop()
	if state != states.dash and parent._should_dash():
		parent.dash()
	
func _get_transition(delta):
	match state:
		states.idle:
			if parent._should_move():
				return states.move
			if parent._should_dash():
				return states.dash
		states.move:
			if parent._should_stop():
				return states.idle
			if parent._should_dash():
				return states.dash
		states.dash:
			if parent._should_stop():
				return states.idle
	return null

# this is mainly for animations. I don't have animations, so it will do nothing for now
func _enter_state(new_state, old_state):
	pass

func _exit_state(old_state, new_state):
	pass
