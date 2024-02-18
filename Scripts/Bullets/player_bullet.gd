extends CharacterBody2D

@onready var player := $"../Player"
var _bullet_stats = bullet_stats.new()

var starting_position = 0 # gets the starting position from where the bullet is fired
var distance = 0 # gets the current range travelled by the bullet

var speed = _bullet_stats.speed
var range = _bullet_stats.range
var size = _bullet_stats.size 
var damage = _bullet_stats.damage

func _ready():
	starting_position = player.get_node("Rotation Point/Marker2D").get_global_position()

func _physics_process(delta):
	var _collision_detect = move_and_collide(velocity * delta * speed)
	distance = starting_position.distance_to($".".global_position)
	if distance >= range:
		queue_free()

func _on_bullet_hitbox_body_entered(body):
	_collide(body)
	
func _on_bullet_hitbox_area_entered(area):
	_collide(area)
	
func _collide(body):
	if body.is_in_group("Enemies"):
		body.get_parent().health -= damage # TODO: change to signal instead
	queue_free()
