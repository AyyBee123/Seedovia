extends CharacterBody2D

signal shoot(bullet, direction, location)
signal weapon_fired(weapon)
signal dashed
signal has_collided(object)
signal seed_fired(seed) # for immediately fired seeds (for the mirage passive)
signal contact_damage_dealt(enemy)

var POPUP = load("res://Scenes/UI/Item Popup.tscn") # retarded-ass engine breaks when putting preload here
const PLAYER_HAND = preload("res://Scenes/Seeds/Player Hand.tscn")
const DASH_TRAIL = preload("res://Scenes/Player/Dash Trail.tscn")
const STAT_INCREASE = preload("res://Scenes/UI/Stat Increase.tscn")
const SPARKLE = preload("res://Scenes/Misc/Sparkle.tscn")

var _player_stats: player_stats = preload("res://Resources/Characters/Stats/base_stats.tres")

@onready var _state_machine = $StateMachine
@onready var player_sprite = $"Player Sprite"
@onready var stats = get_node("Stats")
@onready var fire_rate := $"Bullets Per Second"
@onready var invulnerability_time := $"Invulnerability Time"
@onready var dash_cooldown := $"Dash Cooldown"
@onready var dash_invulnerability_time := $"Dash Invulnerability Time"
@onready var dash_trail_time = $"Dash Trail Time"
@onready var inventory := $"Inventory Canvas/Inventory"
@onready var stat_sheet = $"Stat Sheet"
@onready var inventory_screen := $"Inventory Canvas/Inventory/Inventory Screen"
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
var items_in_area: Array
var popup = null
var highlight_color = Color("ffff6e")
var is_dead: bool
var starting_dash_pos: Vector2
var total_dash_distance: float
var dash_distance_travelled: float
var direction

# check if the input is from a keyboard or joystick
var _isMouse := true
var _isKeyboard := true

# stats mainly for passives
var DAMAGE = 10
var SPEED = 500
var RANGE = 250
var FIRE_RATE = 10
var BLAST_RADIUS = 1
var SIZE = 1

var input_direction = Input.get_vector("left", "right", "up", "down", 0.5) # placeholder value

func _ready():
	if PlayerCharacter._is_starting: # when starting a new run
		for stat in _player_stats.stats.keys():
			if stat == "Max_Health":
				_player_stats.stats[stat]["x"] = 1
				_player_stats.stats[stat]["+"] = 0
				continue
			_player_stats.stats[stat]["x"] = 1.0
			_player_stats.stats[stat]["+"] = 0.0
		stats.set_stats()
		_player_stats.set_leaf_hearts(_player_stats.leaf_hearts)
		_player_stats.set_health(_player_stats.get_stat("Max_Health"))
		if PlayerPassives.starting_passives != null: # add starting passives to the player
			PlayerPassives.add_starting_passives()
		for p in PlayerPassives.starting_passives:
			if p.passive_name == "Add Talisman Passives":
				continue
			PlayerPassives.passive_list.append(p)
		PlayerCharacter._is_starting = false
	else:
		PlayerPassives.set_passives()
		PlayerPassives.set_item_passives()
		PlayerStatStorage.set_stats()
		Global.load_run_data()
	_player_stats.reset_temp_stats()
	_player_stats.set_health(PlayerStatStorage.current_health)
	controller_cursor.visible = false
	_player_stats.damaged.connect(took_damage)
	_player_stats.health_increased.connect(heal)
	_player_stats.change_coins.connect(update_coins)
	_player_stats.health_depleted.connect(die)
	SignalBus.pickup_item_recieved.connect(_on_pickup)
	DAMAGE = _player_stats.get_seed_stat("Weapon_Damage")
	FIRE_RATE = _player_stats.get_seed_stat("Fire_Rate")
	SPEED = _player_stats.get_seed_stat("Weapon_Speed")
	RANGE = _player_stats.get_seed_stat("Weapon_Range")
	BLAST_RADIUS = _player_stats.get_seed_stat("Weapon_Blast_Radius")
	SIZE = _player_stats.get_seed_stat("Weapon_Size")
	Global.save_run_data()

func _physics_process(delta):
	if is_dead:
		return
	
	direction = Vector2.RIGHT.rotated($"Rotation Point".rotation)
	
	# set up the left stick deadzone
	var left_deadzone = Global.settings.left_deadzone
	InputMap.action_set_deadzone("left", left_deadzone)
	InputMap.action_set_deadzone("right", left_deadzone)
	InputMap.action_set_deadzone("up", left_deadzone)
	InputMap.action_set_deadzone("down", left_deadzone)
	
	input_direction = Vector2(Input.get_axis("left", "right"), Input.get_axis("up", "down")).normalized()
	update_timers()
	PlayerStatStorage.set_stats()
	weapon_direction = hand.global_position.direction_to(weapon_direction_marker.global_position)
	# check if the mouse is in the inventory and if the inventory is visible to detect if the player can shoot
	mouse_in_inventory = (inventory_screen.get_global_rect()) \
			.has_point(inventory.get_global_mouse_position()) and inventory.is_visible_in_tree()
	
	if items_in_area.size() > 0:
		add_popup(get_nearest_item())
	elif items_in_area.size() == 0 and popup:
		popup.queue_free()
	
	# aiming direction (right joystick by default)
	var right_deadzone = Global.settings.left_deadzone
	InputMap.action_set_deadzone("aim_left", right_deadzone)
	InputMap.action_set_deadzone("aim_right", right_deadzone)
	InputMap.action_set_deadzone("aim_up", right_deadzone)
	InputMap.action_set_deadzone("aim_down", right_deadzone)
	var aim_direction = Vector2(Input.get_axis("aim_left", "aim_right"), \
			Input.get_axis("aim_up", "aim_down")).normalized()
	
	if _isMouse:
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
	if Input.is_action_pressed("shoot") and fire_rate.is_stopped() and not mouse_in_inventory \
			and not has_holding_item:
		current_weapon = null if PlayerInventory.seeds.size() == 0 else PlayerSeeds.load_weapons()[0]
		if current_weapon != null:
			shoot.emit(current_weapon, hand.global_position)
		else:
			shoot.emit(PLAYER_HAND, hand.global_position)
			
	# pause game or close inventory, or close stat sheet
	if Input.is_action_just_pressed("esc"):
		if inventory.visible: # only inventory for now. Will add stat sheet when it's made
			inventory.visible = false
		else:
			pass # will add pause here, but it's not made yet
	
	# pick up the nearest item from the player
	if Input.is_action_just_pressed("pick_up"):
		if items_in_area.size() > 0:
			var item = get_nearest_item()
			pick_up(item)
	
	# invulnerability time when the player takes damage or dashes
	if invulnerability_time.is_stopped() and dash_invulnerability_time.is_stopped():
		can_be_damaged = true
	if not invulnerability_time.is_stopped():
		inv_anim.play("Invulnerable")
	else:
		inv_anim.stop()
	
	if $"Player Sprite".animation == "Dash":
		dash_trail_time.start()
		starting_dash_pos = global_position
	
	if not dash_trail_time.is_stopped():
		dash_distance_travelled = starting_dash_pos.distance_to(global_position)
		total_dash_distance += dash_distance_travelled
		starting_dash_pos = global_position
		if total_dash_distance >= 40:
			var trail = DASH_TRAIL.instantiate()
			
			# get the current texture in the animation
			var frame_index: int = $"Player Sprite".get_frame()
			var animation_name: String = $"Player Sprite".animation
			var sprite_frames: SpriteFrames = $"Player Sprite".get_sprite_frames()
			var current_texture: Texture2D = sprite_frames.get_frame_texture(animation_name, frame_index)
			trail.texture = current_texture
			
			trail.flip_h = $"Player Sprite".flip_h
			trail.scale = scale
			get_tree().current_scene.add_child(trail)
			trail.global_position = global_position + $"Player Sprite".position
			total_dash_distance = 0

func pick_up(item):
	if item.is_in_group("Shop Item"):
		if PlayerCharacter.coins < item.price:
			return
		_player_stats.set_coins(-item.price)
		if item.item.category == "PICKUP":
			item.item.on_pickup()
			item.queue_free.call_deferred()
			await get_tree().create_timer(0.5).timeout
			Global.save_run_data()
			Global.save_run_room()
			return
		item.add_to_group("Item")
		item.remove_from_group("Shop Item")
	PlayerInventory.equip_item(item.item, self, inventory)
	item.queue_free.call_deferred()

func get_nearest_item():
	var nearest_item = null
	var nearest_distance = null
	for item in items_in_area:
		# remove highlight from all items to only add it to the nearest item at the end
		item.nearest_item = false
		if nearest_item == null:
			nearest_item = item
			nearest_distance = item.global_position.distance_squared_to(global_position)
			# add highlight to the nearest item
			nearest_item.nearest_item = true
		else:
			if nearest_distance > item.global_position.distance_squared_to(global_position):
				# remove highlight from the old nearest item and add it to the new one
				nearest_item.nearest_item = false
				nearest_item = item
				nearest_distance = item.global_position.distance_squared_to(global_position)
				nearest_item.nearest_item = true
				
	return nearest_item

func move():
	$"Player Sprite".play("Move")
	if input_direction.length() > 0:
		velocity = velocity.lerp(input_direction * _player_stats.get_stat("Speed"), \
				_player_stats.get_stat("Acceleration"))

func stop():
	$"Player Sprite".play("Idle")
	velocity = velocity.lerp(Vector2.ZERO, _player_stats.get_stat("Friction"))

func die():
	if is_dead:
		return
	is_dead = true
	_state_machine.set_state(_state_machine.states.die)

func dash():
	if is_dead:
		return
	$"Player Sprite".play("Dash")
	can_be_damaged = false
	velocity = velocity.lerp((input_direction.normalized() if input_direction else Vector2(0,1)) \
			* _player_stats.get_stat("Dash_Distance"), 1)
	Game.audio_manager.play(Game.audio_manager.dash)
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
	weapon_instance.source = self
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = location
	fire_rate.start(1.0 / (weapon_instance.BASE_FIRE_RATE * (1 + _player_stats.stats["Fire_Rate"]["+"]) \
			* _player_stats.stats["Fire_Rate"]["x"]))
	weapon_fired.emit(weapon_instance)
	seed_fired.emit(weapon_instance)

func update_timers():
	current_weapon = null if PlayerInventory.seeds.size() == 0 else PlayerSeeds.load_weapons()[0]
	invulnerability_time.wait_time = _player_stats.get_stat("Invulnerability_Time")
	dash_cooldown.wait_time = _player_stats.get_stat("Dash_Rate")
	dash_invulnerability_time.wait_time = _player_stats.get_stat("Dash_Invulnerability")

func took_damage(amount):
	if amount == 0 or not can_be_damaged:
		return
	if _player_stats.leaf_hearts > 0:
		_player_stats.leaf_hearts -= amount
	else:
		_player_stats.health -= amount
		_player_stats.overcapped_health -= amount
		_player_stats.health = max(0, _player_stats.health)
		_player_stats.overcapped_health = max(0, _player_stats.health)
	change_color()
	$"Player Health".set_health()
	Game.audio_manager.play(Game.audio_manager.player_hit)
	Global.save_run_data()
	can_be_damaged = false
	invulnerability_time.start()

func change_color():
	material.set("shader_parameter/tint_factor", 1.0)
	await get_tree().create_timer(0.1, false).timeout
	material.set("shader_parameter/tint_factor", 0.0)

func heal():
	Global.save_run_data()

func _should_move() -> bool:
	return input_direction.length() > 0

func _should_stop() -> bool:
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
		var right_deadzone = Global.settings.right_deadzone
		if Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down").length() > right_deadzone:
			# detect only the right joystick (2 = x_axis, 3 = y_axis)
			if event.get_axis() == 2 or event.get_axis() == 3:
				_isMouse = false
	elif event is InputEventMouseMotion and not event.relative.is_zero_approx():
		_isMouse = true

func _on_pickup_radius_area_entered(area):
	if area.get_parent().is_in_group("Item") or area.get_parent().is_in_group("Shop Item"):
		pickup_item = area.get_parent()
		items_in_area.append(pickup_item)

func _on_pickup_radius_area_exited(area):
	if area.get_parent().is_in_group("Item") or area.get_parent().is_in_group("Shop Item"):
		pickup_item = area.get_parent()
		pickup_item.nearest_item = false
		var index = items_in_area.find(pickup_item)
		items_in_area.remove_at(index)

func add_popup(item):
	if is_instance_valid(popup):
		popup.queue_free() # remove the old item popup, if one exists
	# create a new item popup
	popup = POPUP.instantiate()
	if item.item.category == "SEED":
		popup.item = item.item.scene.instantiate()
	popup.item_name = item.item.item_name
	popup.type = item.item.category
	popup.description = item.item.description
	popup.rarity = item.item.rarity
	popup.inventory = inventory
	popup.player = self
	add_child.call_deferred(popup)

func _on_pickup(_item):
	_item.queue_free()
	await get_tree().process_frame
	ItemCheck.check_for_pickup_items()
	await get_tree().create_timer(0.5).timeout
	Global.save_run_data()
	Global.save_run_room()

func spawn_stat_increase(amount, type):
	var stat = STAT_INCREASE.instantiate()
	get_tree().current_scene.add_child(stat)
	stat.global_position = global_position
	stat.set_and_animate_stat(amount, type)
	
	for i in 8:
		spawn_sparkle(Color("73fb85"))

func spawn_sparkle(color: Color):
	var sparkle = SPARKLE.instantiate()
	sparkle.modulate = color
	sparkle.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	add_child(sparkle)
	sparkle.global_position = global_position + sparkle.direction * 20

## a little buffer to prevent immediate collision with other objects
func _on_collision_buffer_time_timeout():
	$Hitbox.disabled = false

func update_coins():
	$"Player Health".set_coins()

func _on_player_sprite_animation_finished():
	if $"Player Sprite".animation == "Die":
		hide()
		await get_tree().create_timer(0.5).timeout
		SignalBus.player_die.emit()

func _on_contact_area_area_entered(area):
	if area.is_in_group("Enemies"):
		if _player_stats.contact_damage <= 0:
			return
		area.get_parent()._enemy_stats.take_damage(_player_stats.contact_damage)
		contact_damage_dealt.emit(area.get_parent())
