extends state_machine

func _ready():
	randomize()
	add_state("idle")
	add_state("die")
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.idle:
		parent.idle()

func _get_transition(delta):
	match state:
		states.die:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play(str(parent.NUMBER_OF_SCOOPS) + " Scoop")
		states.die:
			parent._enemy_stats.damage_taken_multiplier = 0

func _exit_state(old_state, new_state):
	match old_state:
		states.die:
			parent._enemy_stats.damage_taken_multiplier = 1
			parent.get_node("Health Bar").pos.y += 16
