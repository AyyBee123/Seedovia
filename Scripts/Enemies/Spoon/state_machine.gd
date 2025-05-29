extends state_machine

var timer = Timer.new()

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("scoop")
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()
	
	if state == states.idle:
		parent.idle()
	if state == states.scoop:
		parent.scoop()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and parent.ready_to_scoop:
				parent.ready_to_scoop = false
				return states.scoop
		states.scoop:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
			timer.start(1)
		states.scoop:
			parent.set_liquid()
			parent.animated_sprite_2d.play("Scoop")

func _exit_state(old_state, new_state):
	match old_state:
		states.scoop:
			pass

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(1)
