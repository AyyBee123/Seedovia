extends state_machine

var timer = Timer.new()
var pot_time = Timer.new()
var random_attack: int

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("jump")
	add_state("spit")
	add_state("pots")
	random_attack = random_attack_value()
	set_state.call_deferred(states.idle)

func random_attack_value():
	return randi_range(0, 2)

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				if random_attack == 0:
					return states.jump
				if random_attack == 1:
					return states.spit
				if random_attack == 2:
					return states.pots
		states.pots:
			if parent.animated_sprite_2d.animation == "Reverse Pots" and not parent.animated_sprite_2d.is_playing():
				return states.idle
		states.jump:
			if parent.jumps >= parent.JUMP_AMOUNT:
				parent.jumps = 0
				return states.idle
		states.spit:
			if parent.spits >= parent.SPIT_AMOUNT:
				parent.spits = 0
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
			random_attack = random_attack_value()
			timer.start(randf_range(2, 3))
		states.jump:
			parent.animated_sprite_2d.play("Jump")
		states.spit:
			parent.animated_sprite_2d.play("Spit")
		states.pots:
			parent.animated_sprite_2d.play("Pots")
			parent.fire_rate.start()
			pot_time.start()

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(3, 4))
	
	add_child(pot_time)
	pot_time.one_shot = true
	pot_time.wait_time = 4
	pot_time.timeout.connect(_on_pot_time_timeout)

func _on_pot_time_timeout():
	parent.animated_sprite_2d.play("Reverse Pots")
