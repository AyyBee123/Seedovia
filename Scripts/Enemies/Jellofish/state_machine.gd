extends state_machine

const COOLDOWN_TIME = 2

var timer = Timer.new()

func _ready():
	add_state("idle")
	add_state("charge")
	add_state("launch")
	add_state("stun")
	create_timer()
	set_state.call_deferred(states.idle)

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
			timer.start()
			parent.animated_sprite_2d.play("Idle")
		states.charge:
			parent.electric_SFX.play()
			parent.animated_sprite_2d.play("Charge Up")
		states.launch:
			parent.launch_SFX.play()
		states.stun:
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
