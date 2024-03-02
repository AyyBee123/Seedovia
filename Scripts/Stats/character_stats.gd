class_name character_stats extends Resource

signal health_changed(new_health) # send signal that current health changed
signal max_health_changed(new_max_health) # send signal that max health changed
signal health_depleted # send signal that health reached 0 (death)

# player values
@export_group("Player Stats")
@export var max_health: int # max health
@export var speed: float # movement speed
@export var dash_rate: float # dash rate (in dashes/sec)
@export var dash_distance: float # distance the player dashes from their original position
@export var dash_invulnerability: float # invulnerability time in seconds after dashing
@export var fire_rate: float # fire rate (in shots/sec)
@export var contact_damage: float # this is mainly for the enemy
@export var invulnerability_time: float # time before player can take damage after taking damage (in seconds)
@export var acceleration: float # movement acceleration
@export var friction: float # movement friction/deceleration

# weapon values
@export_group("Weapon Stats")
@export var weapon_speed: float # shot speed of the weapon
@export var weapon_range: float # range of the weapon before it gets destroyed
@export var weapon_size: float # size of the weapon
@export var weapon_damage: float # damage of the weapon
@export var weapon_blast_radius: float # blast/splash radius of the weapon

# the player's current health
var health: int

# overcapped health is used to determine the amount of "health" in the background after taking equipment into account
# this is to prevent abusing the healing getting increased max health gives when wearing equipment that do so
# ex: wearing an armour-piece that gives +1 max health will also heal the player's current health for 1 health
# the purpose of overcapped health is to prevent constantly healing when unequipping and re-equipping the armour
# this stat is only for the player, but it's added in this class to make initializing it easier
var overcapped_health: int
	
func set_health(value):
	health = max(0, value)
	overcapped_health = max(0, value)
	
func increase_max_health(amount):
	max_health += amount
	max_health_changed.emit(max_health)
	
func take_damage(source):
	health -= source.damage
	overcapped_health -= source.damage
	health = max(0, health)
	overcapped_health = max(0, health)
	health_changed.emit(health)
	if health <= 0:
		health_depleted.emit()
		
func heal(amount):
	health += amount
	health = min(health, max_health)
	health_changed.emit(health)
