extends state_machine

var jump_count: int = 0
const COOLDOWN_TIME = 1

var timer = Timer.new()

func _ready():
	randomize()
	add_state("idle")
	add_state("jump")
	add_state("spin")
	add_state("spawn") # initial state when spawned by Jumbo
	create_timer()
	if parent.starting_state == null:
		set_state.call_deferred(states.idle)
	else:
		set_state.call_deferred(parent.starting_state)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.jump:
		parent.jump()
	if state == states.idle:
		parent.idle()
	if state == states.spin:
		parent.spin()
	if state == states.spawn:
		parent.spawn()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				if jump_count >= 2 and randf_range(0, 1) > 0.25:
					jump_count = 0
					return states.spin
				else:
					return states.jump
		states.jump:
			if not parent._jumping:
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start()
			parent.animated_sprite_2d.play("Idle")
			parent._jumping = true
		states.jump:
			jump_count += 1
			parent.animated_sprite_2d.stop()
			parent.animation_player.play("new_animation")
		states.spawn:
			parent.animated_sprite_2d.stop()
			parent.jumbo_spawn_animation.play("spawn")
		states.spin:
			parent.animated_sprite_2d.play("Spin Beginning")

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			pass
		states.jump:
			pass

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = COOLDOWN_TIME
