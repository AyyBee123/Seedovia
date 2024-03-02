class_name enemy_stats extends Resource

signal health_changed(new_health) # send signal that current health changed
signal max_health_changed(new_max_health) # send signal that max health changed
signal health_depleted # send signal that health reached 0 (death)

@export_group("Enemy Stats")
@export var max_health: float # enemy's max health
@export var speed: float # movement speed
@export var fire_rate: float # fire rate (in shots/sec)
@export var damage: float # enemy damage to player
@export var acceleration: float # movement acceleration
@export var friction: float # movement friction/deceleration

@export_group("Weapon Stats")
@export var weapon_damage: float # the damage of the weapon used by the enemy (not every enemy has a weapon)
@export var weapon_range: float # the range of the weapon used by the enemy (not every enemy has a weapon)
@export var weapon_speed: float # the shot speed of the weapon used by the enemy (not every enemy has a weapon)

var health # enemy's current health

func initialize_stats(stats: enemy_stats):
	max_health = stats.max_health
	speed = stats.speed
	fire_rate = stats.fire_rate
	damage = stats.damage
	acceleration = stats.acceleration
	friction = stats.friction
	weapon_damage = stats.weapon_damage
	weapon_range = stats.weapon_range
	weapon_speed = stats.weapon_speed
	print_debug(stats.weapon_range)
	health = max_health

# as the game/run progresses, the enemies' health will go up by a little to counteract the player increasing in power
func _increase_max_health(amount):
	max_health += amount

func set_health(value):
	health = max(0, value)

func increase_max_health(amount):
	max_health += amount
	max_health_changed.emit(max_health)

func take_damage(damage):
	health -= damage
	health = max(0, health)
	health_changed.emit(health)
	if health <= 0:
		health_depleted.emit()

func heal(amount):
	health += amount
	health = min(health, max_health)
	health_changed.emit(health)
