extends state_machine

var timer = Timer.new()

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("charge")
	add_state("fire")
	add_state("return")
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	if state == states.fire:
		parent.fire()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				return states.charge
		states.charge:
			if not parent.animated_sprite_2d.is_playing():
				return states.fire
		states.return:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
		states.charge:
			parent.rumble_SFX.play()
			parent.animated_sprite_2d.play("Charge")
		states.fire:
			parent.rumble_SFX.stop()
			parent.animated_sprite_2d.play("Fire")
			parent.fire_time.start()
			parent.create_beam()
		states.return:
			parent.animated_sprite_2d.play("To Idle")
			parent.destroy_beam()

func _exit_state(old_state, new_state):
	match old_state:
		states.return:
			timer.start(3)
		states.fire:
			parent.destroy_beam()

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(3, 4))
