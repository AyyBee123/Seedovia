extends state_machine

const COOLDOWN_TIME = 1

var timer = Timer.new()

func _ready():
	add_state("idle")
	add_state("jump")
	add_state("spawn") # initial state when spawned by Jumbo
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
			if not parent._jumping:
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start()
			parent.animated_sprite_2d.play("Idle")
			parent._jumping = true
		states.jump:
			parent.animated_sprite_2d.stop()
			parent.animation_player.play("Jumbo")
		states.spawn:
			parent.animated_sprite_2d.stop()
			parent.jumbo_spawn_animation.play("spawn")

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = COOLDOWN_TIME
