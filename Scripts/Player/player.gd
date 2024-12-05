extends CharacterBody2D

signal shoot(bullet, direction, location)
signal weapon_fired(weapon)
signal dashed
signal has_collided(object)

@export var _player_stats: player_stats

@onready var bullets_per_second := $"Bullets Per Second"
@onready var invulnerability_time := $"Invulnerability Time"
@onready var dash_cooldown := $"Dash Cooldown"
@onready var dash_invulnerability_time := $"Dash Invulnerability Time"
@onready var inventory := $"Inventory"
@onready var inventory_screen := $"Inventory/Inventory Screen"
@onready var initial_collision_layer := get_collision_layer()
@onready var player_passives := $Passives
@onready var hand := $"Rotation Point/Marker2D"
@onready var hand_sprite = $"Rotation Point/Marker2D/Hand"
@onready var inv_anim := $"Invulnerability Animation"
@onready var weapon_direction_marker = $"Rotation Point/Weapon Direction"
@onready var controller_cursor = $"Rotation Point/Weapon Direction/Cursor"
@onready var collision_buffer_time = $"Collision Buffer Time"

var current_weapon: PackedScene = null

var can_be_damaged := true
var mouse_in_inventory := false
var has_holding_item := false # this is set in the inventory script to true if the mouse cursor is holding an item
var damage_multiplier
var weapon_direction
var pickup_item = null
var item_in_area = false

# check if the input is from a keyboard or joystick
var _isMouse := true
var _isKeyboard := true

func _ready():
	if PlayerCharacter._is_starting: # when starting a new run
		PlayerCharacter._is_starting = false
		_player_stats.set_leaf_hearts(_player_stats.leaf_hearts)
		_player_stats.set_health(_player_stats.get_stat("Max_Health"))
		if PlayerPassives.starting_passives != null: # add starting passives to the player
			PlayerPassives.add_starting_passives()
		for stat in _player_stats.stats.keys():
			if stat == "Max_Health":
				_player_stats.stats[stat]["x"] = 1
				_player_stats.stats[stat]["+"] = 0
				continue
			_player_stats.stats[stat]["x"] = 1.0
			_player_stats.stats[stat]["+"] = 0.0
	else:
		PlayerPassives.set_passives()
		PlayerPassives.set_item_passives()
		PlayerStatStorage.set_stats()
		Global.load_data()
	_player_stats.set_health(PlayerStatStorage.current_health)
	controller_cursor.visible = false
	_player_stats.damaged.connect(took_damage)
	_player_stats.health_increased.connect(heal)
	_player_stats.change_coins.connect(update_coins)
	Global.save_data()

func _physics_process(delta):
	update_timers()
	PlayerStatStorage.set_stats()
	weapon_direction = hand.global_position.direction_to(weapon_direction_marker.global_position)
	# check if the mouse is in the inventory and if the inventory is visible to detect if the player can shoot
	mouse_in_inventory = inventory_screen.get_global_rect().has_point(inventory.get_global_mouse_position()) \
			and inventory.is_visible_in_tree()
	
	# aiming direction (right joystick by default)
	# TODO: change 0.15 to deadzone value from options menu
	var aim_direction = Input.get_vector("aim left", "aim right", "aim up", "aim down", 0.15)
	
	if Input.get_last_mouse_velocity() != Vector2.ZERO:
		# make player's hand look at mouse
		$"Rotation Point".look_at(get_global_mouse_position())
		# make mouse cursor visible
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		# hide the controller cusror
		controller_cursor.visible = false
	elif not _isMouse:
		# make the player's hand rotate with the right joystick (by default)
		$"Rotation Point".rotation = aim_direction.angle()
		# hide mouse cursor and place it in the middle of the screen
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		Input.warp_mouse(Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y / 2))
		# make the controller cursor visible
		controller_cursor.visible = true
		# offset the rotation of the curser against the hand rotation
		controller_cursor.rotation = -aim_direction.angle()
	
	# flip player sprite based on the hand's angle
	$"Player Sprite".flip_h = true if cos($"Rotation Point".rotation) < 0 else false
	
	# shoot bullet
	if Input.is_action_pressed("shoot") and bullets_per_second.is_stopped() and not mouse_in_inventory \
			and not has_holding_item:
		current_weapon = null if PlayerInventory.seeds.size() == 0 else PlayerSeeds.load_weapons()[0]
		if current_weapon != null:
			shoot.emit(current_weapon, hand.global_position)
			
	# pause game or close inventory, or close stat sheet
	if Input.is_action_just_pressed("esc"):
		if inventory.visible: # only inventory for now. Will add stat sheet when it's made
			inventory.visible = false
		else:
			pass # will add pause here, but it's not made yet
	
	if Input.is_action_just_pressed("pick up"):
		if item_in_area:
			pick_up(pickup_item)
	# invulnerability time when the player takes damage or dashes
	if invulnerability_time.is_stopped() and dash_invulnerability_time.is_stopped():
		can_be_damaged = true
	if not invulnerability_time.is_stopped():
		inv_anim.play("Invulnerable")
	else:
		inv_anim.stop()
		
	# die if health is 0 (or less)
	if _player_stats.health <= 0 and _player_stats.leaf_hearts <= 0:
		die()
	
	if can_be_damaged:
		set_collision_layer(initial_collision_layer)
	else:
		set_collision_layer(initial_collision_layer - 2) # 2 is the player's collision layer

func pick_up(item):
	if item.is_in_group("Shop Item"):
		if PlayerCharacter.coins < item.price:
			return
		_player_stats.set_coins(-item.price)
		if item.item.category == "PICKUP":
			item.item.on_pickup()
			item.queue_free.call_deferred()
			await get_tree().create_timer(0.5).timeout
			Global.save_data()
			Global.save_room()
			return
		item.add_to_group("Item")
		item.remove_from_group("Shop Item")
	PlayerInventory.add_item(item.item, self, inventory)
	item.queue_free.call_deferred()

func move():
	$"Player Sprite".play("Move")
	# TODO: add a deadzone value taken from the one in options menu (currently 0.15)
	var input_direction = Input.get_vector("left", "right", "up", "down", 0.15)
	if input_direction.length() > 0:
		velocity = velocity.lerp(input_direction * _player_stats.get_stat("Speed"), \
				_player_stats.get_stat("Acceleration"))

func stop():
	$"Player Sprite".play("Idle")
	velocity = velocity.lerp(Vector2.ZERO, _player_stats.get_stat("Friction"))

func die():
	hide() # temporary death effect
	process_mode = 4 # = Mode: Disabled
	Global.delete_data()
	# TODO: add death animation
	# TODO: pause game and add a menu with options to restart and go back to menu

func dash():
	$"Player Sprite".play("Dash")
	can_be_damaged = false
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = velocity.lerp((input_direction.normalized() if input_direction else Vector2(0,1)) \
			* _player_stats.get_stat("Dash_Distance"), 1)
	dashed.emit()
	dash_cooldown.start()
	dash_invulnerability_time.start()

func _on_shoot(weapon, location):
	var weapon_instance = weapon.instantiate()
	weapon_instance.initial_weapon = true
	weapon_instance.slot_index = 0
	weapon_instance.previous_weapon = self
	weapon_instance.seed_slot_number = PlayerSeeds.seed_indices[0]
	weapon_instance.desired_direction = location.direction_to(weapon_direction_marker.global_position)
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = location
	bullets_per_second.start()
	weapon_fired.emit(weapon_instance)

func update_timers():
	current_weapon = null if PlayerInventory.seeds.size() == 0 else PlayerSeeds.load_weapons()[0]
	if current_weapon != null:
		var weapon = current_weapon.instantiate()
		bullets_per_second.wait_time = 1.0/(_player_stats.get_stat("Fire_Rate") * weapon.fire_rate_multiplier)
		damage_multiplier = weapon.damage_multiplier
	else:
		bullets_per_second.wait_time = 1.0/_player_stats.get_stat("Fire_Rate")
	invulnerability_time.wait_time = _player_stats.get_stat("Invulnerability_Time")
	dash_cooldown.wait_time = _player_stats.get_stat("Dash_Rate")
	dash_invulnerability_time.wait_time = _player_stats.get_stat("Dash_Invulnerability")

func took_damage():
	$"Player Health".set_health()
	Global.save_data()
	can_be_damaged = false
	invulnerability_time.start()

func heal():
	Global.save_data()

func _should_move() -> bool:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	return input_direction.length() > 0

func _should_stop() -> bool:
	var input_direction = Input.get_vector("left", "right", "up", "down")
	return is_zero_approx(input_direction.length())

func _should_dash() -> bool:
	return Input.is_action_just_pressed("dash") and dash_cooldown.is_stopped()

func _input(event) -> void:
	# detect keyboard and controller buttons to determine if the input is from a keyboard or controller
	if event is InputEventJoypadButton:
		_isKeyboard = false
	elif event is InputEventKey:
		_isKeyboard = true
	# detect mouse and (right) joystick movement to determine if the input is from a mouse or controller
	if event is InputEventJoypadMotion:
		# TODO: add deadzone value from options menu
		if Input.get_vector("aim left", "aim right", "aim up", "aim down").length() > .15:
			# detect only the right joystick (2 = x_axis, 3 = y_axis)
			if event.get_axis() == 2 or event.get_axis() == 3:
				_isMouse = false
	elif event is InputEventMouseMotion:
		_isMouse = true

func _on_pickup_radius_area_entered(area):
	if area.get_parent().is_in_group("Item") or area.get_parent().is_in_group("Shop Item"):
		pickup_item = area.get_parent()
		item_in_area = true

func _on_pickup_radius_area_exited(area):
	if area.get_parent().is_in_group("Item") or area.get_parent().is_in_group("Shop Item"):
		item_in_area = false

## a little buffer to prevent immediate collision with other objects
func _on_collision_buffer_time_timeout():
	$Hitbox.disabled = false

func update_coins():
	$"Player Health".set_coins()
	await get_tree().process_frame
	ItemCheck.check_for_coins()
	await get_tree().create_timer(0.5).timeout
	Global.save_coins()
