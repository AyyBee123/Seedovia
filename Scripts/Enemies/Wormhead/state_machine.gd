extends state_machine

var timer = Timer.new()

func _ready():
	randomize()
	add_state("idle")
	add_state("shoot")
	create_timer()
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.shoot:
		parent.shoot()
	if state == states.idle:
		parent.idle()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.shoot
		states.shoot:
			if parent.spawned_bullet_amount >= parent.NUMBER_OF_BULLETS:
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			start_random_time()
			parent.set_random_direction()
		states.shoot:
			parent.animated_sprite_2d.play("Shoot")

func _exit_state(old_state, new_state):
	match old_state:
		states.shoot:
			parent.spawned_bullet_amount = 0

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = randf_range(2.5, 4)

func start_random_time():
	timer.start(randf_range(2.5, 4))
