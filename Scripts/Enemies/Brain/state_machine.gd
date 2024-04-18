extends "res://Scripts/State/state_machine.gd"

func _ready():
	add_state("down")
	add_state("forward")
	call_deferred("set_state", states.down)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.down:
		parent.move_down()
	if state == states.forward:
		parent.move_forward()

func _get_transition(delta):
	match state:
		states.down:
			if not parent.falling:
				return states.forward
	return null

func _enter_state(new_state, old_state):
	pass
	#match new_state:
		#states.idle:
			#parent.animation_player.play("idle")
		#states.jump:
			#parent.animation_player.play("jump")
		#states.shoot:
			#parent.animation_player.play("shoot")
			#parent.shoot()
