extends CharacterBody2D

signal shoot(bullet, direction, location)

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet
var ignore_first_collision := false

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
	if not ignore_first_collision:
		if body.is_in_group("Enemies"):
			body.get_parent()._enemy_stats.take_damage(_player_stats.get_stat("Weapon_Damage"))
			shoot_next_weapon()
		queue_free()
	ignore_first_collision = false
	
func shoot_next_weapon():
	pass
