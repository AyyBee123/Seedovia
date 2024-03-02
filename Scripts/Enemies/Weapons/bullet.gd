extends CharacterBody2D

@onready var player := $"../Player"

var damage: int = 0
var range: float = 0
var speed: float = 0

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet
var position_initialized := false

func _ready():
	starting_position = global_position

func _physics_process(delta):
	initialize_position()
	collision_detect(delta)
	travelled_distance()

func _collide(body):
	if body.is_in_group("Players"):
		player._player_stats.take_damage(self)
	queue_free()
	
func collision_detect(delta):
	var collision_detect = move_and_collide(velocity * delta * speed)
	
func travelled_distance():
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= range:
		queue_free()
		
func _on_bullet_hitbox_body_entered(body):
	_collide(body)
	
func _on_bullet_hitbox_area_entered(area):
	_collide(area)
	
func initialize_position():
	if not position_initialized:
		starting_position = global_position
		position_initialized = true
