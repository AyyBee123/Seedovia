class_name enemy_stats

signal health_changed(new_health) # send signal that current health changed
signal max_health_changed(new_max_health) # send signal that max health changed
signal health_depleted # send signal that health reached 0 (death)

@export var max_health = 50 # enemy's max health
@export var speed = 30 # movement speed
@export var fire_rate = 1 # fire rate (in shots/sec)
@export var damage = 1 # enemy damage to player
@export var acceleration = 0.1 # movement acceleration
@export var friction = 0.25 # movement friction/deceleration

var health # enemy's current health

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
