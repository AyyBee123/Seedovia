extends CharacterBody2D

signal shoot(bullet, direction, location)

@export var _player_stats: player_stats

@onready var bullets_per_second := $"Bullets Per Second"
@onready var dash_cooldown := $"Dash Cooldown"
@onready var dash_invulnerability_time := $"Dash Invulnerability Time"
@onready var inventory := $"Inventory"
@onready var inventory_screen := $"Inventory/NinePatchRect"

var bullet = preload('res:///Scenes/Player/Player Bullets/Player Bullet.tscn')

var can_be_damaged := true
var mouse_in_inventory := false

func _ready():
	_player_stats.initialize_base_stats()
	_player_stats.set_health(_player_stats.max_health)
	bullets_per_second.wait_time = 1.0/_player_stats.fire_rate
	bullets_per_second.start()
	dash_cooldown.wait_time = _player_stats.dash_rate
	dash_cooldown.start()
	dash_invulnerability_time.wait_time = _player_stats.dash_invulnerability

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
		shoot.emit(bullet, get_global_mouse_position().angle(), $"Rotation Point/Marker2D".get_global_position())
		
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
		velocity = velocity.lerp(input_direction.normalized() * _player_stats.speed, _player_stats.acceleration)
	else:
		velocity = velocity.lerp(Vector2.ZERO, _player_stats.friction)
	move_and_slide()
	
func die():
	hide() # temporary death effect
	set_physics_process(false)
	# TODO: add death animation
	# TODO: pause game and add options to restart and go back to menu
	
func dash():
	can_be_damaged = false
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = velocity.lerp((input_direction.normalized() if input_direction else Vector2(0,1)) * _player_stats.dash_distance, 1)
	dash_cooldown.start()
	dash_invulnerability_time.start()

func _on_shoot(bullet, direction, location):
	var bullet_instance = bullet.instantiate()
	get_tree().current_scene.add_child(bullet_instance)
	bullet_instance.global_position = location
	bullet_instance.velocity = (get_global_mouse_position() - bullet_instance.global_position).normalized()
	bullet_instance.rotation = bullet_instance.velocity.angle()
	bullets_per_second.start()
