extends "res://Scripts/State/state_machine.gd"

var timer = Timer.new()

func _ready():
	add_state("idle")
	add_state("ready_up")
	add_state("punch")
	set_state.call_deferred(states.idle)
	create_timer()

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.idle:
		parent.idle()
	if state == states.ready_up:
		parent.ready_up()
	if state == states.punch:
		parent.punch()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.ready_up
		states.ready_up:
			if parent._is_ready:
				parent._is_ready = false
				return states.punch
		states.punch:
			if parent._punched:
				parent._punched = false
				timer.start(1)
				return states.idle
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
		states.ready_up:
			parent.animated_sprite_2d.play("Ready Beginning")
		states.punch:
			parent.animated_sprite_2d.play("Punch")

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(1)
