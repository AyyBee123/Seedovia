extends "res://Scripts/State/state_machine.gd"

var timer = Timer.new()
var random_attack: int

func _ready():
	create_timer()
	add_state("idle")
	add_state("teeth")
	add_state("what")
	add_state("laser")
	add_state("what_idle")
	add_state("tahw")
	add_state("lunacy")
	set_state.call_deferred(states.idle)
	# the random attacks are set up in the get_transition function
	random_attack = randi_range(0, 2)

func _state_logic(delta):
	if state == states.idle:
		parent.idle()
	if state == states.teeth:
		parent.teeth()
	if state == states.what:
		parent.what()
	if state == states.laser:
		parent.laser()
	if state == states.idle:
		parent.what_idle()
	if state == states.tahw:
		parent.tahw()
	if state == states.lunacy:
		parent.lunacy()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				if random_attack == 0:
					return states.teeth
				if random_attack == 1:
					return states.what
				if random_attack == 2:
					return states.lunacy
		states.teeth:
			if parent.teeth_finished:
				parent.teeth_finished = false
				return states.idle
		states.what:
			if parent.what_finished:
				parent.what_finished = false
				return states.what_idle
		states.laser:
			if parent.laser_finished:
				return states.what_idle
		states.what_idle:
			if timer.is_stopped() and not parent.laser_finished:
				return states.laser
			if timer.is_stopped() and parent.laser_finished:
				parent.laser_finished = false
				return states.tahw
		states.tahw:
			if parent.tahw_finished:
				parent.tahw_finished = false
				return states.idle
		states.lunacy:
			if parent.lunacy_finished:
				parent.lunacy_finished = false
				return states.idle
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
		states.teeth:
			parent.animated_sprite_2d.play("Teeth")
		states.what:
			parent.animated_sprite_2d.play("WTF")
		states.laser:
			parent.animated_sprite_2d.play("Laser Beginning")
		states.what_idle:
			parent.animated_sprite_2d.play("WTF Idle")
		states.tahw:
			parent.animated_sprite_2d.play("FTW")

func _exit_state(old_state, new_state):
	match old_state:
		states.teeth:
			random_attack = randi_range(0, 2)
			timer.start(randf_range(1,2.5))
		states.lunacy:
			random_attack = randi_range(0, 2)
			timer.start(randf_range(1,2.5))
		states.tahw:
			random_attack = randi_range(0, 2)
			timer.start(randf_range(1,2.5))
		states.what:
			timer.start(randf_range(1,2.5))
		states.laser:
			timer.start(1)

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(2,3))
