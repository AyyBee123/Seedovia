extends "res://Scripts/State/state_machine.gd"

var timer = Timer.new()

func _ready():
	add_state("idle")
	add_state("jump")
	add_state("idle_from_jump")
	add_state("shoot")
	call_deferred("set_state", states.jump)
	create_timer()

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.jump:
		parent.jump()
	if state == states.idle:
		parent.idle()
	if state == states.shoot:
		parent.shoot()
	if state == states.idle_from_jump:
		parent.idle()

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

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(1)
