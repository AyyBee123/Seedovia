extends state_machine

var timer = Timer.new()
var random_attack: int

func _ready():
	create_timer()
	add_state("idle")
	add_state("jump")
	add_state("short_jump")
	add_state("shake")
	add_state("wall")
	add_state("transform")
	add_state("transform_reverse")
	add_state("jump_to_transform")
	set_state.call_deferred(states.idle)
	# the random attacks are set up in the get_transition function
	random_attack = random_attack_value()

func _state_logic(delta):
	parent.move_and_slide()
	
	if state == states.idle:
		parent.idle()
	if state == states.jump:
		parent.jump()
	if state == states.shake:
		parent.shake()
	if state == states.jump_to_transform:
		parent.jump_to_transform()
	if state == states.wall:
		parent.wall()

func _get_transition(delta):
	match state:
		states.idle:
			if timer.is_stopped() and get_parent().player != null:
				if random_attack == 0:
					return states.jump
				if random_attack == 1 and parent.number_of_slimes < parent.MAX_SLIMES:
					return states.short_jump
				else:
					print("hi")
					random_attack = random_attack_value()
				#if random_attack == 2:
					#return states.jump_to_transform
				#if random_attack == 3:
					#return states.shake
		
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			random_attack = random_attack_value()
			parent.animated_sprite_2d.play("Idle")
		states.jump:
			parent.animated_sprite_2d.stop()
			parent.animation_player.play("Jump")
		states.short_jump:
			parent.animated_sprite_2d.play("Short Jump")
		states.shake:
			parent.animated_sprite_2d.play("Shake")
		states.transform:
			parent.animated_sprite_2d.play("Transform")
		states.transform_reverse:
			parent.animated_sprite_2d.play_backwards("Transform")
		states.wall:
			parent.animated_sprite_2d.play("Wall")

func _exit_state(old_state, new_state):
	match old_state:
		states.jump:
			timer.start(1.5)
		states.transform_reverse:
			set_random_time()
		states.short_jump:
			set_random_time()
		states.shake:
			set_random_time()

func random_attack_value():
	return randi_range(0, 1)

func set_random_time():
	timer.start(randf_range(2,3))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	set_random_time()
