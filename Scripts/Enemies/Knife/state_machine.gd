extends state_machine

var timer = Timer.new()

func _ready():
	randomize()
	create_timer()
	add_state("spin")
	add_state("dash")
	set_state.call_deferred(states.spin)

func _state_logic(delta):
	parent.move_and_slide()
	
	if state == states.spin:
		parent.spin()
	if state == states.dash:
		parent.dash()

func _get_transition(delta):
	match state:
		states.dash:
			if timer.is_stopped():
				return states.spin

func _enter_state(new_state, old_state):
	match new_state:
		states.spin:
			parent.animate_spin()
		states.dash:
			timer.start(1)
			parent.start_dash()

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(1)
