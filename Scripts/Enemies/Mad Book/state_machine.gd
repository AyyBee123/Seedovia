extends state_machine

const COOLDOWN_TIME = 3
const MAD_TIME = 4

var timer = Timer.new()
var mad_time = Timer.new()

func _ready():
	add_state("idle")
	add_state("mad")
	create_timer()
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.mad:
		parent.mad()
	if state == states.idle:
		parent.idle()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.mad
		states.mad:
			if mad_time.is_stopped():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start()
			parent.animated_sprite_2d.play("Idle")
			parent.set_radius(parent.idle_radius)
		states.mad:
			mad_time.start()
			parent.animated_sprite_2d.play("Mad")
			parent.set_radius(parent.mad_radius)

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = COOLDOWN_TIME
	
	add_child(mad_time)
	mad_time.one_shot = true
	mad_time.wait_time = MAD_TIME
