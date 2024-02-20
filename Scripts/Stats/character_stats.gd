class_name character_stats extends Node

signal health_changed(new_health) # send signal that current health changed
signal max_health_changed(new_max_health) # send signal that max health changed
signal health_depleted() # send signal that health reached 0 (death)

var modifiers = {}

# base values
@export var max_health: int # max health
@export var speed: float # movement speed
@export var dash_rate: float # dash rate (in dashes/sec)
@export var dash_distance: float # distance the player dashes from their original position
@export var dash_invunerability: float # invulnerability time in seconds after dashing
@export var fire_rate: float # fire rate (in shots/sec)
@export var contact_damage: float # this is mainly for the enemy
@export var acceleration: float # movement acceleration
@export var friction: float # movement friction/deceleration
var health: int

func initialize(stats: character_stats):
	max_health = stats.max_health
	speed = stats.speed
	dash_rate = stats.dash_rate
	dash_distance = stats.dash_distance
	dash_invunerability = stats.dash_invunerability
	fire_rate = stats.fire_rate
	contact_damage = stats.contact_damage
	acceleration = stats.acceleration
	friction = stats.friction
	health = max_health
	
func set_max_health(value):
	health = max(0, value)
	
func increase_max_health(amount):
	max_health += amount
	max_health_changed.emit(max_health)
	
func take_damage(hit_source):
	health -= hit_source.damage
	health = max(0, health)
	health_changed.emit(health)
	if health <= 0:
		health_depleted.emit()
		
func heal(amount):
	health += amount
	health = min(health, max_health)
	health_changed.emit(health)
	
func _increase_max_health(amount):
	max_health += amount
	
func add_modifier(id, modifier):
	modifiers[id] = modifier
	
func remove_modifier(id):
	modifiers.erase(id)
