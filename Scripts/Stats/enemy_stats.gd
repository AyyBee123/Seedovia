class_name enemy_stats

var max_health = 50 # enemy's max health
var speed = 30 # movement speed
var fire_rate = 1 # fire rate (in shots/sec)
var damage = 1 # enemy damage to player

const acceleration = 0.1 # movement acceleration
const friction = 0.25 # movement friction/deceleration

# as the game/run progresses, the enemies' health will go up by a little to counteract the player increasing in power
func _increase_max_health(amount):
	max_health += amount
