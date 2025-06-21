extends state_machine

const COOLDOWN_TIME = 5

var timer = Timer.new()

func _ready():
	add_state("idle")
	add_state("suck")
	create_timer()
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()

	if state == states.suck:
		parent.suck()
	if state == states.idle:
		parent.idle()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.suck
		states.suck:
			if parent.sucked_bullet_amount >= parent.NUMBER_OF_BULLETS:
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			timer.start()
		states.suck:
			parent.fire_rate.start()
			parent.vacuum_SFX.play()
			if sin(parent.pointer.rotation) > 0:
				parent.animated_sprite_2d.play("Suck")
			else:
				parent.animated_sprite_2d.play("Suck Back")

func _exit_state(old_state, new_state):
	match old_state:
		states.suck:
			parent.fire_rate.stop()
			parent.vacuum_SFX.stop()
			parent.sucked_bullet_amount = 0
			parent.spawned_bullet_amount = 0

func create_timer():
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = COOLDOWN_TIME
