extends Node

@onready var player := $"../Player"
@onready var _player_stats = player._player_stats
@onready var seed_slots := $"../Player/Inventory/NinePatchRect/Seed Slots".get_children()

var starting_position: Vector2 # gets the starting position from where the bullet is fired
var distance_travelled: float # gets the current range travelled by the bullet

# this value is set because the weapon's position is not updated until after the ready function.
# That's why it's called in the physics process function instead of the ready function
var position_initialized := false

var initial_weapon := true
var ignore_first_collision := false # this is to let the projectiles spawn without instantly colliding with an object
var short_distance_travelled: float # this lets the projectile move a little before enabling collisions again

var slot_index: int


