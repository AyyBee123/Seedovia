extends state_machine

var timer = Timer.new()

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("charge")
	add_state("shoot")
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	if state == states.idle:
		parent.idle()
	if state == states.shoot:
		parent.shoot()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.shoot
		states.shoot:
			pass

func _exit_state(old_state, new_state):
	match old_state:
		states.shoot:
			set_random_time()
		

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			pass
		states.shoot:
			parent.current_frame = 0
			parent.current_progress = 0

func set_random_time():
	timer.start(randf_range(4, 8))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(2,3))
