extends state_machine

var timer = Timer.new()

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("spin")
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	if state == states.idle:
		parent.idle()
	if state == states.spin:
		parent.spin()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				return states.spin
		states.spin:
			if parent.spin_time.is_stopped():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.shrink()
		states.spin:
			parent.spin_time.start()
			parent.stretch()

func _exit_state(old_state, new_state):
	match old_state:
		states.spin:
			timer.start(3)
			parent.deceleration.start()
		states.idle:
			parent.acceleration.start()

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(2, 3))
