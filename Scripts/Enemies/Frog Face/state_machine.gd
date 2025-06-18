extends state_machine

const COOLDOWN_TIME = 2

var timer = Timer.new()

func _ready():
	add_state("idle")
	add_state("jump")
	create_timer()
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.jump:
		parent.jump()
	if state == states.idle:
		parent.idle()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.jump
		states.jump:
			if not parent.animation_player.is_playing():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start()
			parent.animated_sprite_2d.play("Idle")
		states.jump:
			parent.animated_sprite_2d.stop()
			parent.animation_player.play("Jump")

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			pass
		states.jump:
			parent.spawn_flies()

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = COOLDOWN_TIME
