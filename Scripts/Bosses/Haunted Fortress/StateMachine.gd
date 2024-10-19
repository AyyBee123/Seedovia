extends "res://Scripts/State/state_machine.gd"

var timer = Timer.new()
var random_attack: int

func _ready():
	create_timer()
	add_state("idle")
	add_state("laser")
	add_state("ghosts")
	add_state("suck")
	set_state.call_deferred(states.idle)
	random_attack = randi_range(0, states.size() - 2) # -2 because it ignores the idle state

func _state_logic(delta):
	if state == states.idle:
		parent.idle()
	if state == states.laser:
		parent.laser()
	if state == states.ghosts:
		parent.ghosts()
	if state == states.suck:
		parent.suck()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				if random_attack == 0:
					return states.laser
				if random_attack == 1:
					return states.ghosts
				if random_attack == 2:
					return states.suck
		states.laser:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle
		states.ghosts:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle
		states.suck:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
		states.laser:
			parent.animated_sprite_2d.play("Laser")
		states.ghosts:
			parent.animated_sprite_2d.play("Ghosts")
		states.suck:
			parent.animated_sprite_2d.play("Suck")

func _exit_state(old_state, new_state):
	match old_state:
		states.laser:
			random_attack = randi_range(0, states.size() - 2)
			timer.start(randf_range(3,6))
		states.ghosts:
			random_attack = randi_range(0, states.size() - 2)
			timer.start(randf_range(3,6))
		states.suck:
			random_attack = randi_range(0, states.size() - 2)
			timer.start(randf_range(3,6))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(3,6))

func animation_finished():
	random_attack = randi_range(0, states.size() - 2)
	timer.start(randf_range(3,6))
