extends state_machine

var timer = Timer.new()

func _ready():
	add_state("idle")
	add_state("forward")
	set_state.call_deferred(states.idle)
	create_timer()

func _state_logic(delta):
	if state == states.idle:
		parent.idle()
	if state == states.forward:
		parent.move_forward()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				return states.forward
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start(0.5)

func create_timer():
	add_child(timer)
	timer.start(0.5)
	timer.one_shot = true
