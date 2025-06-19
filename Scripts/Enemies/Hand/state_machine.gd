extends state_machine

var timer = Timer.new()
var random_attack: int
var attack_count: int = 0

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("slam")
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	parent.move_and_slide()
	
	if state == states.idle:
		parent.idle()
	if state == states.slam:
		parent.slam()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				return states.slam
		states.slam:
			pass
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			set_random_time()
			parent.animated_sprite_2d.play("Idle")
		states.slam:
			parent.slam_start()

func _exit_state(old_state, new_state):
	match old_state:
		states.idle:
			parent.t_idle = 0.0
		states.slam:
			parent.t_slam = 0.0

func set_random_time():
	timer.start(randf_range(2, 3))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	set_random_time()
