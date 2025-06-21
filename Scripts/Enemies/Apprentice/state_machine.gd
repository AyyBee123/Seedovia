extends state_machine

const COOLDOWN_TIME = 2

var timer = Timer.new()

func _ready():
	add_state("idle")
	add_state("slash")
	create_timer()
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.slash:
		parent.slash()
	if state == states.idle:
		parent.idle()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.slash
		states.slash:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start()
			parent.animated_sprite_2d.play("Idle")
		states.slash:
			parent.laser_whoosh.play()
			parent.animated_sprite_2d.play("Slash")
			
			parent.spawn_wave(parent.SPREAD)
			parent.spawn_wave(0)
			parent.spawn_wave(-parent.SPREAD)

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = COOLDOWN_TIME
