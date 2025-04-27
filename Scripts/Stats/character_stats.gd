class_name character_stats extends Resource

signal health_changed(new_health) # send signal that current health changed
signal max_health_changed(new_max_health) # send signal that max health changed
signal health_increased # send signal that current health increased
signal health_depleted # send signal that health reached 0 (death)
signal damaged(amount)

# player values
@export_group("Player Stats")
@export var max_health: int # max health
@export var leaf_hearts: int # number of leaf hearts
@export var speed: float # movement speed
@export var dash_rate: float # dash rate (in dashes/sec)
@export var dash_distance: float # distance the player dashes from their original position
@export var dash_invulnerability: float # invulnerability time in seconds after dashing
@export var fire_rate: float # fire rate (in shots/sec)
@export var contact_damage: float # this is mainly for the enemy
@export var invulnerability_time: float # time before player can take damage after taking damage (in seconds)
@export var acceleration: float # movement acceleration
@export var friction: float # movement friction/deceleration
@export var luck: float # affects chances, like proc chances and maybe drops

# weapon values
@export_group("Weapon Stats")
@export var weapon_speed: float # shot speed of the weapon
@export var weapon_range: float # range of the weapon before it gets destroyed
@export var weapon_size: float # size of the weapon
@export var weapon_damage: float # damage of the weapon
@export var weapon_blast_radius: float # blast/splash radius of the weapon

var health: int # the player's current health

## overcapped health is used to determine the amount of "health" in the background after taking equipment into account
## this is to prevent abusing the healing getting increased max health gives when wearing equipment that do so
## ex: wearing an armour-piece that gives +1 max health will also heal the player's current health for 1 health
## the purpose of overcapped health is to prevent constantly healing when unequipping and re-equipping the armour
## this stat is only for the player, but it's added in this class to make initializing it easier
var overcapped_health: int
	
func set_health(value):
	health = max(0, value)
	overcapped_health = max(0, value)

func set_leaf_hearts(value):
	leaf_hearts = max(0, value)

func increase_max_health(amount):
	max_health += amount
	max_health_changed.emit(max_health)
	
func take_damage(damage):
	damaged.emit(damage)
	health_changed.emit(health)
	SignalBus.player_damaged.emit()
