extends CharacterBody2D

@onready var player := $"../Player"
var _seed_stats = seed_class.new()
@onready var _player_stats = player._player_stats

var starting_position = 0 # gets the starting position from where the bullet is fired
var distance = 0 # gets the current range travelled by the bullet

func _ready():
	starting_position = player.get_node("Rotation Point/Marker2D").get_global_position()

func _physics_process(delta):
	var _collision_detect = move_and_collide(velocity * delta * _player_stats.get_stat("Weapon_Speed"))
	distance = starting_position.distance_to($".".global_position)
	if distance >= _player_stats.get_stat("Weapon_Range"):
		queue_free()

func _on_bullet_hitbox_body_entered(body):
	_collide(body)
	
func _on_bullet_hitbox_area_entered(area):
	_collide(area)
	
func _collide(body):
	if body.is_in_group("Enemies"):
		body.get_parent().health -= _player_stats.get_stat("Weapon_Damage") # TODO: change to signal instead
	queue_free()
