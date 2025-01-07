extends state_machine

var timer = Timer.new()
var random_attack: int
var attack_count: int = 0

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("mad")
	add_state("handpocalypse")
	add_state("hats")
	set_state.call_deferred(states.idle)
	# the random attacks are set up in the get_transition function
	random_attack = random_attack_value()

func _state_logic(delta):
	parent.move_and_slide()
	
	if state == states.idle:
		parent.idle()
	if state == states.mad:
		parent.mad()
	if state == states.handpocalypse:
		parent.handpocalypse()
	if state == states.hats:
		parent.hats()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				if random_attack == 0:
					return states.mad
				if random_attack == 1 and attack_count >= 3:
					return states.handpocalypse
				else:
					random_attack = random_attack_value()
				if random_attack == 2:
					return states.hats
		states.handpocalypse:
			if timer.is_stopped():
				return states.idle
		states.hats:
			pass
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			set_random_time()
			random_attack = random_attack_value()
			parent.animated_sprite_2d.play("Idle")
		states.mad:
			parent.mad_fps_cap = parent.MAD_FPS_CAP
			parent.animated_sprite_2d.play("Mad")
			parent.animated_sprite_2d.stop()
			parent.move_eratically()
		states.handpocalypse:
			timer.start(8)
		states.hats:
			parent._enemy_stats.damage = 1

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			attack_count += 1
		states.mad:
			pass
		states.handpocalypse:
			attack_count = 0
		states.hats:
			parent._enemy_stats.damage = 0

func random_attack_value():
	return randi_range(0, 0)

func set_random_time():
	timer.start(randf_range(2,3))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	set_random_time()
