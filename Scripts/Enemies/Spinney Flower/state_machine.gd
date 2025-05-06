extends state_machine

const COOLDOWN_TIME = 2
const SPIN_TIME = 4

var timer = Timer.new()
var spin_time = Timer.new()

func _ready():
	randomize()
	add_state("idle")
	add_state("spin")
	create_timer()
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.idle:
		parent.idle()
	if state == states.spin:
		parent.spin()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.spin
		states.spin:
			if spin_time.is_stopped():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start()
			parent.animated_sprite_2d.play("Idle")
		states.spin:
			spin_time.start()
			parent.animated_sprite_2d.play("Spin Beginning")

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			pass
		states.spin:
			pass

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = COOLDOWN_TIME
	add_child(spin_time)
	spin_time.one_shot = true
	spin_time.wait_time = SPIN_TIME
