extends state_machine

var jump_timer = Timer.new()
var jump_delay_timer = Timer.new()

var jump_count: int = 0

func _ready():
	randomize()
	create_timer()
	add_state("idle")
	add_state("jump")
	add_state("charge")
	add_state("float")
	add_state("return")
	set_state.call_deferred(states.idle)

func _state_logic(delta):
	if state == states.idle:
		parent.idle()
	if state == states.jump:
		parent.jump()
	if state == states.charge:
		parent.charge()
	if state == states.float:
		parent.shoot()
	if state == states.return:
		parent.uncharge()

func _get_transition(delta):
	match state:
		states.idle:
			if jump_count >= 1 and jump_delay_timer.is_stopped():
				jump_count = 0
				return states.charge
			elif jump_timer.is_stopped():
				return states.jump
		states.jump:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle
		states.charge:
			if not parent.animated_sprite_2d.is_playing():
				return states.float
		states.float:
			if parent.projectile_count >= parent.NUMBER_OF_PROJECTILES:
				parent.projectile_count = 0
				return states.return
		states.return:
			if not parent.animated_sprite_2d.is_playing():
				return states.idle

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			parent.animated_sprite_2d.play("Idle")
		states.jump:
			jump_count += 1
			parent.animated_sprite_2d.play("Jump")
		states.charge:
			parent.animated_sprite_2d.play("Charge")
		states.float:
			parent.shoot_pancakes()
			parent.animated_sprite_2d.play("Float")
		states.return:
			parent.animated_sprite_2d.play("Return")

func _exit_state(old_state, new_state):
	match old_state:
		states.return:
			jump_timer.start(0.75)
		states.jump:
			parent.plate_SFX.play()
			jump_delay_timer.start(0.25)
			jump_timer.start(0.75)
		states.float:
			parent.projectile_count = 0

func create_timer():
	add_child(jump_timer)
	jump_timer.one_shot = true
	jump_timer.start(0.5)
	
	add_child(jump_delay_timer)
	jump_delay_timer.one_shot = true
