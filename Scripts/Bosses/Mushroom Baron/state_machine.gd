extends "res://Scripts/State/state_machine.gd"

var timer = Timer.new()
var jump_to_spit_delay = Timer.new()
var spit_to_spin_delay = Timer.new()
var random_attack: int
var has_jumped := false
var has_spit := false

func _ready():
	create_timer()
	add_state("idle")
	add_state("spit")
	add_state("jump")
	add_state("spin")
	set_state.call_deferred(states.idle)
	# the random attacks are set up in the get_transition function
	random_attack = randi_range(0, states.size() - 3) # -3 because it ignores the idle and spit states

func _state_logic(delta):
	if state == states.idle:
		parent.idle()
	if state == states.spin:
		parent.spin()
	if state == states.jump:
		parent.jump()
	if state == states.spit:
		parent.spit()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and not (has_jumped or has_spit) and get_parent().player != null:
				if random_attack == 0:
					return states.spin
				if random_attack == 1:
					return states.jump
			if spit_to_spin_delay.is_stopped() and has_spit:
				has_spit = false
				return states.spin
			if jump_to_spit_delay.is_stopped() and has_jumped:
				has_jumped = false
				return states.spit
		states.spin:
			if parent.spin_finished:
				parent.spin_finished = false
				return states.idle
		states.jump:
			if parent.jump_finished:
				parent.jump_finished = false
				return states.idle
		states.spit:
			if parent.spit_finished:
				parent.spit_finished = false
				return states.idle
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
		states.spin:
			parent.animated_sprite_2d.play("Spin Beginning")
		states.jump:
			parent.animated_sprite_2d.play("Jump")
		states.spit:
			parent.animated_sprite_2d.play("Spit Beginning")

func _exit_state(old_state, new_state):
	match old_state:
		states.spin:
			random_attack = randi_range(0, states.size() - 3)
			timer.start(randf_range(2,3))
		states.jump:
			jump_to_spit_delay.start(1)
			has_jumped = true
		states.spit:
			spit_to_spin_delay.start(1)
			has_spit = true

func create_timer():
	add_child(timer)
	add_child(jump_to_spit_delay)
	add_child(spit_to_spin_delay)
	timer.one_shot = true
	timer.start(randf_range(2,3))
	jump_to_spit_delay.one_shot = true
	spit_to_spin_delay.one_shot = true
