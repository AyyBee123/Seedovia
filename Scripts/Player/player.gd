extends CharacterBody2D

signal shoot(bullet, direction, location)

@export var _player_stats: player_stats

@onready var bullets_per_second := $"Bullets Per Second"
@onready var dash_cooldown := $"Dash Cooldown"
@onready var dash_invulnerability_time := $"Dash Invulnerability Time"
@onready var inventory := $"Inventory"
@onready var inventory_screen := $"Inventory/NinePatchRect"
@onready var player_stats_ui := $"../Player Stats"

var current_weapon: PackedScene = null

var can_be_damaged := true
var mouse_in_inventory := false

func _ready():
	_player_stats.initialize_base_stats()
	_player_stats.change_stat.connect(update_timers)
	_player_stats.health_changed.connect(update_health)
	update_timers()
	_player_stats.set_health(_player_stats.get_stat("Max_Health"))

func _physics_process(delta):
	# check if the mouse is in the inventory and if the inventory is visible to detect if the player can shoot
	mouse_in_inventory = inventory.get_global_rect().has_point(inventory.get_global_mouse_position()) and inventory.is_visible_in_tree()
	
	# movement
	move()
	
	# make player's hand look at mouse
	$"Rotation Point".look_at(get_global_mouse_position())
	
	# flip player sprite based of mouse position
	$"Player Sprite".flip_h = false if get_global_mouse_position().x > global_position.x else true
	
	# shoot bullet
	if Input.is_action_pressed("shoot") and bullets_per_second.is_stopped() and not mouse_in_inventory:
		current_weapon = null if PlayerSeeds.seeds.size() == 0 else PlayerSeeds.load_weapons()[0]
		if current_weapon != null:
			shoot.emit(current_weapon, $"Rotation Point/Marker2D".get_global_position())

	# dash
	if Input.is_action_just_pressed("dash") and dash_cooldown.is_stopped():
		dash()
	if dash_invulnerability_time.is_stopped():
		can_be_damaged = true
		
	# die if health is 0 (or less)
	if _player_stats.health <= 0:
		die()
		
	if can_be_damaged:
		$Hitbox.disabled = false
	else:
		$Hitbox.disabled = true
		
func move():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if input_direction.length() > 0:
		velocity = velocity.lerp(input_direction.normalized() * _player_stats.get_stat("Speed"), _player_stats.get_stat("Acceleration"))
	else:
		velocity = velocity.lerp(Vector2.ZERO, _player_stats.get_stat("Friction"))
	move_and_slide()
	
func die():
	hide() # temporary death effect
	process_mode = 4 # = Mode: Disabled
	# TODO: add death animation
	# TODO: pause game and add a menu with options to restart and go back to menu
	
func dash():
	can_be_damaged = false
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = velocity.lerp((input_direction.normalized() if input_direction else Vector2(0,1)) * _player_stats.get_stat("Dash_Distance"), 1)
	dash_cooldown.start()
	dash_invulnerability_time.start()

func _on_shoot(weapon, location):
	var weapon_instance = weapon.instantiate()
	weapon_instance.slot_index = 0
	get_tree().current_scene.add_child(weapon_instance)
	weapon_instance.global_position = location
	weapon_instance.velocity = (get_global_mouse_position() - weapon_instance.global_position).normalized()
	weapon_instance.rotation = weapon_instance.velocity.angle()
	bullets_per_second.start()
	
func update_timers():
	bullets_per_second.wait_time = 1.0/_player_stats.get_stat("Fire_Rate")
	dash_cooldown.wait_time = _player_stats.get_stat("Dash_Rate")
	dash_invulnerability_time.wait_time = _player_stats.get_stat("Dash_Invulnerability")
	bullets_per_second.start()
	dash_cooldown.start()
	
func update_health(new_health):
	player_stats_ui.set_health()
