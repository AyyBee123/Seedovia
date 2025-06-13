extends state_machine

var timer = Timer.new()
var fire_time = Timer.new()
var random_attack: int

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("charge")
	add_state("fire")
	add_state("dash")
	random_attack = random_attack_value()
	set_state.call_deferred(states.idle)

func random_attack_value():
	return randi_range(0, 2)

func _state_logic(delta):
	parent.move_and_slide()
	
	if state == states.idle:
		parent.idle()
	if state == states.fire:
		parent.fire()
	if state == states.charge:
		parent.shoot()
	if state == states.dash:
		parent.dashing()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				if random_attack == 0:
					return states.charge
				if random_attack == 1:
					return states.fire
				if random_attack == 2:
					return states.dash
		states.fire:
			if fire_time.is_stopped():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			random_attack = random_attack_value()
			timer.start(randf_range(2, 3))
		states.charge:
			parent.charge()
		states.dash:
			parent.animated_sprite_2d.play("Dash")
			parent.dash()
		states.fire:
			parent.fire_rate.start()
			fire_time.start()

func _exit_state(old_state, new_state):
	match old_state:
		states.dash:
			parent.animated_sprite_2d.play("Reverse Dash")

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(3, 4))
	
	add_child(fire_time)
	fire_time.one_shot = true
	fire_time.wait_time = 5
