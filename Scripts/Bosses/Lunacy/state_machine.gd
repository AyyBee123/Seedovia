extends state_machine

var timer = Timer.new()
var random_attack: int

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("teeth")
	add_state("what")
	add_state("laser")
	add_state("what_idle")
	add_state("tahw")
	add_state("lunacy")
	add_state("frenzy")
	add_state("mouth")
	set_state.call_deferred(states.idle)
	# the random attacks are set up in the get_transition function
	random_attack = random_attack_value()

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
	if state == states.frenzy:
		parent.set_shader()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				if random_attack == 0:
					return states.teeth
				if random_attack == 1:
					return states.lunacy
				if random_attack == 2:
					return states.what
				if random_attack == 3:
					random_attack = random_attack_value()
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
			if timer.is_stopped():
				if random_attack == 0:
					return states.laser
				if random_attack == 1:
					return states.mouth
				if random_attack == 2:
					return states.frenzy
				if random_attack == 3:
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
			random_attack = random_attack_value()
			set_random_time()
		states.teeth:
			parent.animated_sprite_2d.play("Teeth")
		states.what:
			parent.animated_sprite_2d.play("WTF")
		states.laser:
			parent._on_fire_rate_timeout()
			parent.animated_sprite_2d.play("Laser Beginning")
		states.what_idle:
			parent.animated_sprite_2d.play("WTF Idle")
			random_attack = random_attack_value()
			set_random_time()
		states.tahw:
			parent.animated_sprite_2d.play("FTW")
		states.lunacy:
			parent.disappear_SFX.play()
		states.frenzy:
			parent.frenzy()
		states.mouth:
			parent.fire_rate_mouth.start()
			parent.animated_sprite_2d.play("Mouth Open")
			parent.toggle_mouth_hitbox(true)

func _exit_state(old_state, new_state):
	match old_state:
		states.tahw:
			parent.change_name("Lunacy")
		states.what:
			parent.change_name("Frenzy")
		states.laser:
			parent.laser_fire_rate.stop()
			parent.space_laser_noise_SFX.stop()
		states.mouth:
			parent.fire_rate_mouth.stop()
			parent.toggle_mouth_hitbox(false)

func random_attack_value():
	return randi_range(0, 3)

func set_random_time():
	timer.start(randf_range(1.5, 2.5))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(2, 3))
