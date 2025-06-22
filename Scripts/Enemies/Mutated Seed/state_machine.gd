extends state_machine

const IDLE_TIME = 7

var timer = Timer.new()

func _ready():
	add_state("idle")
	add_state("chase")
	create_timer()
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.chase:
		parent.chase()
	if state == states.idle:
		parent.idle()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.chase

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start()
			parent.animated_sprite_2d.play("Idle")
		states.chase:
			parent.fire_rate.start()
			parent.animated_sprite_2d.play("Chase")

func _exit_state(old_state, new_state):
	match old_state:
		states.chase:
			parent.fire_rate.stop()
			parent.vacuum_SFX.stop()
			parent.chaseed_bullet_amount = 0
			parent.spawned_bullet_amount = 0

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = IDLE_TIME
