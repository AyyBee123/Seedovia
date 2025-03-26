extends state_machine

var timer = Timer.new()
var random_attack: int

func _ready():
	randomize()
	create_timer()
	add_state("walk")
	add_state("tongue_begin")
	add_state("launch")
	add_state("crash")
	set_state.call_deferred(states.walk)

func _state_logic(delta):
	if state == states.walk:
		parent.walk()
	if state == states.launch:
		parent.launch()

func _get_transition(delta):
	match state:
		states.walk:
			if timer.is_stopped():
				return states.tongue_begin

func _enter_state(new_state, old_state):
	match new_state:
		states.walk:
			parent.animated_sprite_2d.play("Walk")
		states.tongue_begin:
			parent.animated_sprite_2d.play("Tongue")
		states.launch:
			parent.animated_sprite_2d.play("Tongue Launch")
		states.crash:
			Game.audio_manager.play(Game.audio_manager.impact_high_pitch)
			parent.animated_sprite_2d.play("Tongue Crash")

func _exit_state(old_state, new_state):
	match old_state:
		states.crash:
			set_random_time()

func set_random_time():
	timer.start(randf_range(3, 4))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	set_random_time()
