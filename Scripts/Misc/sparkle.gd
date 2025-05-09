extends Sprite2D

@onready var lifetime = $Lifetime

const POSITION_OFFSET = 20

var direction: Vector2
var speed: float
var pos_offset

func _ready():
	randomize()
	speed = randf_range(80, 100)
	scale = Vector2.ONE * randf_range(0.75, 1)

func _physics_process(delta):
	position += direction * speed * delta
	modulate.a -= delta * 5

func _on_lifetime_timeout():
	queue_free()
