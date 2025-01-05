extends state_machine

var timer = Timer.new()
var random_attack: int
var attack_count: int = 0

func _ready():
	create_timer()
	add_state("idle")
	add_state("slam")
	add_state("handpocalypse")
	add_state("charge")
	set_state.call_deferred(states.idle)
	# the random attacks are set up in the get_transition function
	random_attack = random_attack_value()

func _state_logic(delta):
	parent.move_and_slide()
	
	if state == states.idle:
		parent.idle()
	if state == states.slam:
		parent.slam()
	if state == states.handpocalypse:
		parent.handpocalypse()
	if state == states.charge:
		parent.charge()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				if random_attack == 0:
					return states.slam
				if random_attack == 1 and attack_count >= 3:
					return states.handpocalypse
				else:
					random_attack = random_attack_value()
				if random_attack == 2:
					return states.charge
		states.slam:
			if timer.is_stopped():
				return states.idle
		states.handpocalypse:
			if timer.is_stopped():
				return states.idle
		states.charge:
			pass
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			random_attack = random_attack_value()
			parent.animated_sprite_2d.play("Idle")
		states.slam:
			timer.start(5)
		states.handpocalypse:
			timer.start(8)
		states.charge:
			parent._enemy_stats.damage = 1

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			attack_count += 1
		states.slam:
			pass
		states.handpocalypse:
			attack_count = 0
		states.charge:
			parent._enemy_stats.damage = 0

func random_attack_value():
	return randi_range(0, 2)

func set_random_time():
	timer.start(randf_range(2,3))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	set_random_time()
