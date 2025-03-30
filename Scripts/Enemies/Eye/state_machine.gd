extends state_machine

var timer = Timer.new()

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("begin_shoot")
	add_state("shoot")
	add_state("end_shoot")
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	if state == states.idle:
		parent.idle()
	if state == states.shoot:
		parent.shoot()
	if state == states.end_shoot:
		parent.end_shoot()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped():
				return states.begin_shoot
		states.begin_shoot:
			if not parent.animated_sprite_2d.is_playing():
				return states.shoot
		states.shoot:
			if parent.shoot_time.is_stopped():
				return states.end_shoot
		states.end_shoot:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.begin_shoot:
			parent.animated_sprite_2d.play("Transform")
		states.shoot:
			parent.animated_sprite_2d.play("Shoot")
			parent.shoot_time.start()
		states.end_shoot:
			parent.animated_sprite_2d.play_backwards("Transform")

func _exit_state(old_state, new_state):
	match old_state:
		states.end_shoot:
			set_random_time()

func set_random_time():
	timer.start(randf_range(1, 1.5))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.start(randf_range(1.5, 2))
