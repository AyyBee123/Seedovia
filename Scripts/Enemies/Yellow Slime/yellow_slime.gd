extends "res://Scripts/Enemies/enemy.gd"

@onready var hitbox := $"Enemy Hitbox"
@onready var initial_collision_layer: int = $"Enemy Hitbox".get_collision_layer()
@onready var fire_time := $"Fire Time"
var number_of_shots := 3

var timer = Timer.new()

func _ready():
	super._ready()

func jump():
	var direction = player.global_position - self.global_position
	velocity = velocity.lerp(direction.normalized() * _enemy_stats.speed, _enemy_stats.acceleration)
	hitbox.set_collision_layer(0)

func idle():
	velocity = Vector2.ZERO

func idle_from_jump():
	hitbox.set_collision_layer(initial_collision_layer)
	velocity = Vector2.ZERO

func shoot():
	var shots_left := number_of_shots
	if fire_time.time_left == 0:
		#print("shoot")
		shots_left -= 1
