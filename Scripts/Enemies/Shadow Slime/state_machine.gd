extends state_machine

const COOLDOWN_TIME = 1.5
const SHADOW_TIME = 1.5

var timer = Timer.new()
var shadow_time = Timer.new()

func _ready():
	add_state("idle")
	add_state("jump")
	add_state("dive")
	create_timer()
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.jump:
		parent.jump()
	if state == states.idle:
		parent.idle()
	if state == states.dive:
		parent.dive()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.dive
		states.jump:
			if not parent._jumping:
				return states.idle
		states.dive:
			if shadow_time.is_stopped():
				return states.jump

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start()
			parent.animated_sprite_2d.play("Idle")
			parent._jumping = true
		states.jump:
			parent.animated_sprite_2d.stop()
			parent.animation_player.play("new_animation")
		states.dive:
			shadow_time.start()
			parent.animated_sprite_2d.play("Dive")

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = COOLDOWN_TIME
	
	add_child(shadow_time)
	shadow_time.one_shot = true
	shadow_time.wait_time = SHADOW_TIME
