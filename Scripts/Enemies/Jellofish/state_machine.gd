extends state_machine

const COOLDOWN_TIME = 2

var timer = Timer.new()

func _ready():
	randomize()
	add_state("idle")
	add_state("charge")
	add_state("launch")
	add_state("stun")
	create_timer()
	if parent.starting_state == null:
		set_state.call_deferred(states.idle)
	else:
		set_state.call_deferred(parent.starting_state)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.idle:
		parent.idle()
	if state == states.charge:
		parent.charge()
	if state == states.launch:
		parent.launch()
	if state == states.stun:
		parent.stun()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.charge

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start(2)
			parent.animated_sprite_2d.play("Idle")
		states.charge:
			parent.electric_SFX.play()
			parent.animated_sprite_2d.play("Charge Up")
		states.launch:
			parent.launch_SFX.play()
		states.stun:
			Targets.get_camera().add_trauma(0.2)
			parent.impact_SFX.play()
			parent.animated_sprite_2d.play("Stun")

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			pass
		states.charge:
			parent.electric_SFX.stop()
		states.launch:
			pass
		states.stun:
			pass

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = randf_range(COOLDOWN_TIME - 0.5, COOLDOWN_TIME + 1)
