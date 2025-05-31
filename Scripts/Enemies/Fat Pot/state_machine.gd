extends state_machine

const COOLDOWN_TIME = 1.5

func _ready():
	randomize()
	add_state("idle")
	add_state("charge")
	add_state("shoot")
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	if state == states.idle:
		parent.idle()

func _get_transition(delta):
	match state:
		states.idle:
			if parent.area_detect.size() > 0:
				return states.charge
		states.charge:
			if not parent.animated_sprite_2d.is_playing():
				return states.shoot
		states.shoot:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.charge:
			parent.charge()
		states.shoot:
			parent.shoot()
