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
	add_state("idle_to_transform")
	set_state.call_deferred(states.idle)
	# the random attacks are set up in the get_transition function
	random_attack = random_attack_value()

func _state_logic(delta):
	parent.move_and_slide()
	
	if state == states.idle or state == states.idle_to_transform:
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
					random_attack = random_attack_value()
				if random_attack == 2:
					return states.jump_to_transform
				if random_attack == 3:
					return states.shake
		states.idle_to_transform:
			if timer.is_stopped():
				return states.transform
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			random_attack = random_attack_value()
			parent.animated_sprite_2d.play("Idle")
		states.jump:
			parent.animated_sprite_2d.stop()
			parent.animation_player.play("Jump")
		states.jump_to_transform:
			if parent.global_position.x < 0:
				parent.dist = Vector2(-570, 0) - parent.global_position
			else:
				parent.dist = Vector2(570, 0) - parent.global_position
			parent.animated_sprite_2d.stop()
			parent.animation_player.play("Jump")
		states.short_jump:
			parent.animated_sprite_2d.play("Short Jump")
		states.shake:
			parent.animated_sprite_2d.play("Shake")
		states.transform:
			parent.disable_collisions()
			parent.animated_sprite_2d.play("Transform")
		states.transform_reverse:
			parent.animated_sprite_2d.play("Transform Reverse")
		states.wall:
			parent.stop_shooting = false
			parent.z_index += 1
			parent._enemy_stats.damage_taken_multiplier = 0.25
			parent.enable_wall_collisions()
			parent.global_position.y += 37
			Targets.get_camera().add_trauma(0.25)
			parent.stomp_2_SFX.play()
			parent.splat_SFX.play()
			parent.animated_sprite_2d.play("Wall")
		states.idle_to_transform:
			parent.animated_sprite_2d.play("Idle")

func _exit_state(old_state, new_state):
	match old_state:
		states.jump:
			timer.start(1.5)
		states.transform_reverse:
			parent.enable_collisions()
			set_random_time()
		states.short_jump:
			set_random_time()
		states.shake:
			set_random_time()
		states.jump_to_transform:
			timer.start(1)
		states.wall:
			parent.z_index -= 1
			parent._enemy_stats.damage_taken_multiplier = 1
			parent.disable_wall_collisions()
			parent.global_position.y -= 37

func random_attack_value():
	return randi_range(0, 0)

func set_random_time():
	timer.start(randf_range(2,3))

func create_timer():
	add_child(timer)
	timer.one_shot = true
	set_random_time()
