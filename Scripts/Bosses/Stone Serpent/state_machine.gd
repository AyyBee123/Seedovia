extends state_machine

var timer = Timer.new()
var random_attack: int

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("charge")
	add_state("jump")
	set_state.call_deferred(states.idle)
	# the random attacks are set up in the get_transition function
	random_attack = random_attack_value()

func _state_logic(delta):
	if state == states.idle:
		parent.idle()
	if state == states.jump:
		parent.jump()

func _get_transition(delta):
	match state:
		states.idle:
			pass
			if timer.is_stopped() and get_parent().player != null and parent.direction.y == 0:
				if random_attack == 0:
					return states.charge
				if random_attack == 1:
					return states.jump
		states.charge:
			pass
		states.jump:
			pass
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle Side")
		states.jump:
			parent.start_jump()
			parent.animated_sprite_2d.play("Jump")
		states.charge:
			parent.start_charge()

func _exit_state(old_state, new_state):
	match old_state:
		states.charge:
			random_attack = random_attack_value()
			set_random_time()
			parent.z_index = parent.Z_INDEX
		states.jump:
			random_attack = random_attack_value()
			set_random_time()

func random_attack_value():
	return randi_range(0, 1)

func set_random_time():
	timer.start(randf_range(7, 10))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(4, 6))
