extends "res://Scripts/State/state_machine.gd"

@onready var timer := $Timer

func _ready():
	add_state("idle")
	add_state("jump")
	add_state("idle_from_jump")
	add_state("shoot")
	timer.one_shot = true
	timer.start(1)
	call_deferred("set_state", states.jump)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.jump:
		parent.jump()
	if state == states.idle:
		parent.idle()
	if state == states.shoot:
		parent.shoot()
	if state == states.idle_from_jump:
		parent.idle_from_jump()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				timer.start(1)
				return states.jump
		states.jump:
			if timer.is_stopped():
				timer.start(0.5)
				return states.idle_from_jump
		states.idle_from_jump:
			if timer.is_stopped():
				timer.start(1)
				return states.shoot
		states.shoot:
			if timer.is_stopped():
				timer.start(2)
				return states.idle
	return null

# this is mainly for animations. I don't have animations, so the function will do nothing for now
func _enter_state(new_state, old_state):
	pass

func _exit_state(old_state, new_state):
	pass
