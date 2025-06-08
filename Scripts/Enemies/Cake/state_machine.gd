extends state_machine

var timer = Timer.new()

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("charge")
	add_state("fire")
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	if state == states.idle:
		parent.idle()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				return states.charge
		states.charge:
			if not parent.animated_sprite_2d.is_playing():
				return states.fire
		states.fire:
			if parent.number_of_slices >= 8:
				parent.number_of_slices = 0
				parent.animated_sprite_2d.play("Return")
			if not parent.animated_sprite_2d.is_playing():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
		states.charge:
			parent.heal_1.play()
			parent.sound_delay.start()
			parent.animated_sprite_2d.play("Charge")
		states.fire:
			parent.animated_sprite_2d.play("Fire")
			parent.fire()

func _exit_state(old_state, new_state):
	match old_state:
		states.charge:
			parent.cake_hitbox.disabled = true
			parent.cake_collision_shape.disabled = true
		states.fire:
			timer.start(1.5)
			parent.cake_hitbox.disabled = false
			parent.cake_collision_shape.disabled = false

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(1, 2))
