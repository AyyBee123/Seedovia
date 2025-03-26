extends state_machine

var timer = Timer.new()
var random_attack: int

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("laser")
	add_state("ghosts")
	add_state("suck")
	set_state.call_deferred(states.idle)
	# the random attacks are set up in the get_transition function
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
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
		states.laser:
			parent.animated_sprite_2d.play("Laser Beginning")
		states.ghosts:
			parent.animated_sprite_2d.play("Ghosts Beginning")
		states.suck:
			parent.animated_sprite_2d.play("Suck Beginning")

func _exit_state(old_state, new_state):
	match old_state:
		states.laser:
			random_attack = randi_range(0, states.size() - 2)
			set_random_time()
		states.ghosts:
			random_attack = randi_range(0, states.size() - 2)
			set_random_time()
		states.suck:
			random_attack = randi_range(0, states.size() - 2)
			set_random_time()

func create_timer():
	add_child(timer)
	timer.one_shot = true
	set_random_time()

func animation_finished():
	random_attack = randi_range(0, states.size() - 2)
	set_random_time()

func set_random_time():
	timer.start(randf_range(3,6))
