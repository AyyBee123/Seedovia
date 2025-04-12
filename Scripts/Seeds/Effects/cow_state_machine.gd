extends state_machine

func _ready():
	add_state("move")
	add_state("stop")
	set_state.call_deferred(states.move)

func _state_logic(delta):
	if state == states.move:
		parent.move()
	if state == states.stop:
		parent.stop()

func _get_transition(delta):
	match state:
		states.move:
			if parent.move_time.is_stopped():
				return states.stop
		states.stop:
			if parent.move_delay.is_stopped():
				return states.move
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.move:
			parent.set_direction()
			parent.move_time.start()
			parent.animated_sprite_2d.play("Move")
		states.stop:
			parent.move_delay.start()
			parent.animated_sprite_2d.play("Stop")
