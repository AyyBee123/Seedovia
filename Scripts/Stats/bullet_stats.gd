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

# increases in the base values (in %)
var increased_speed = 0.0
var increased_range = 0.0
var increased_size = 0.0
var increased_radius = 0.0
var increased_damage = 0.0

# multiplying the base values (in decimal)
var multiply_speed = 0.0
var multiply_range = 0.0
var multiply_size = 0.0
var multiply_radius = 0.0
var multiply_damage = 0.0

# adding the increase in stats
func _increase_speed(amount):
	increased_speed += amount
	speed = _calculate_total(base_speed, increased_speed, multiply_speed)

func _increase_range(amount):
	increased_range += amount
	range = _calculate_total(base_range, increased_range, multiply_range)
	
func _increase_damage(amount):
	increased_damage += amount
	damage = _calculate_total(base_damage, increased_damage, multiply_damage)

func _increase_size(amount):
	increased_size += amount
	size = _calculate_total(base_size, increased_size, multiply_size)
	
func _increase_radius(amount):
	increased_radius += amount
	radius = _calculate_total(base_radius, increased_radius, multiply_radius)
	
# adding the multiplier in stats
func _multiply_speed(amount):
	multiply_speed += amount
	speed = _calculate_total(base_speed, increased_speed, multiply_speed)

func _multiply_range(amount):
	multiply_range += amount
	range = _calculate_total(base_range, increased_range, multiply_range)
	
func _multiply_damage(amount):
	multiply_damage += amount
	damage = _calculate_total(base_damage, increased_damage, multiply_damage)

func _multiply_size(amount):
	multiply_size += amount
	size = _calculate_total(base_size, increased_size, multiply_size)
	
func _multiply_radius(amount):
	multiply_radius += amount
	radius = _calculate_total(base_radius, increased_radius, multiply_radius)
	
# calculate the new total value
func _calculate_total(base_stat, increase, multiple) -> float:
	return multiple * (base_stat + increase)
