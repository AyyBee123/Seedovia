extends state_machine

func _ready():
	add_state("move")
	add_state("bite")
	add_state("shoot")
	set_state.call_deferred(states.move)

func _state_logic(delta):
	if state == states.move:
		parent.move()
	if state == states.bite:
		parent.bite()
	if state == states.shoot:
		parent.shoot()

func _get_transition(delta):
	match state:
		states.move:
			if parent._can_bite:
				return states.bite
			if parent._can_shoot:
				return states.shoot
		states.bite:
			if not parent._can_bite:
				return states.move
		states.shoot:
			if not parent._can_shoot:
				return states.move
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.move:
			parent.animated_sprite_2d.play("Idle")
		states.shoot:
			parent.animated_sprite_2d.play("Shoot")
			parent.instance_next_seed()
		states.bite:
			parent.animated_sprite_2d.play("Bite")
