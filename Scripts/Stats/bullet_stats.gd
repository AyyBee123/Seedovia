class_name bullet_stats

@export var base_speed = 500 # bullet speed
@export var base_range = 500 # max range before the bullet is destroyed
@export var base_size = 10 # bullet size
@export var base_radius = 10 # splash/explosion radius of the bullet after it's destroyed
@export var base_damage = 10 # bullet damage

# total values
var speed = base_speed
var range = base_range
var size = base_size
var radius = base_radius
var damage = base_damage
	
# calculate the new total value
func _calculate_total(base_stat, increase, multiple) -> float:
	return multiple * (base_stat + increase)
