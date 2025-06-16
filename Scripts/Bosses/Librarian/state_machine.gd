extends state_machine

var timer = Timer.new()
var random_attack: int

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("charge")
	add_state("eye")
	add_state("broom")
	random_attack = random_attack_value()
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()
	
	if state == states.idle:
		parent.idle()
	if state == states.charge:
		parent.charge()
	if state == states.eye:
		parent.eye()
	if state == states.broom:
		parent.idle()

func random_attack_value():
	return randi_range(0, 2)

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				if random_attack == 0:
					return states.charge
				if random_attack == 1:
					return states.eye
				if random_attack == 2:
					return states.broom

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
			random_attack = random_attack_value()
			timer.start(randf_range(2, 3))
		states.eye:
			parent.animated_sprite_2d.play("Eye Open")
			parent.eye_time.start()
		states.charge:
			parent.set_direction()
		states.broom:
			parent.broom_attack()
			parent.broom_fire_rate.start()

func _exit_state(old_state, new_state):
	match old_state:
		states.broom:
			parent.broom_fire_rate.stop()

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(2, 3))
