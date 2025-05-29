extends state_machine

func _ready():
	randomize()
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
			if parent.ready_to_scoop:
				parent.ready_to_scoop = false
				return states.scoop
		states.scoop:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
		states.scoop:
			parent.set_liquid()
			parent.animated_sprite_2d.play("Scoop")
