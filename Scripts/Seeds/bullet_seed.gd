extends CharacterBody2D

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet

# this value is set because the weapon's position is not updated until after the ready fuction. 
# That's why it's called in the physics process function instead of the ready function
var position_initialized := false

func _physics_process(delta):
	if not position_initialized:
		starting_position = global_position
		position_initialized = true
	var _collision_detect = move_and_collide(velocity * delta * _player_stats.get_stat("Weapon_Speed"))
	distance_travelled = starting_position.distance_to(self.global_position)
	if distance_travelled >= _player_stats.get_stat("Weapon_Range"):
		queue_free()

func _on_bullet_hitbox_body_entered(body):
	_collide(body)
	
func _on_bullet_hitbox_area_entered(area):
	_collide(area)
	
func _collide(body):
	if body.is_in_group("Enemies"):
		body.get_parent().health -= _player_stats.get_stat("Weapon_Damage") # TODO: change to signal instead
	queue_free()
