extends Sprite2D

@onready var lifetime = $Lifetime

var original_size: float
var is_in_area: bool
var player = null
var damage: int = 1
var is_shrinking: bool

func _ready():
	SignalBus.room_cleared.connect(shrink)
	$Area2D/CollisionShape2D.disabled = false
	lifetime.start()
	original_size = scale.x

func _physics_process(delta):
	if lifetime.is_stopped():
		shrink()

func shrink():
	if is_shrinking:
		return
	$Area2D/CollisionShape2D.disabled = true
	var tween = get_tree().create_tween()
	tween.tween_callback(func(): remove_from_group("Liquid"))
	tween.tween_property(self, "modulate", Color(modulate.r, modulate.g, modulate.b, 0), 1)
	tween.parallel().tween_property(self, "scale", Vector2.ONE * 0.5, 1)
	tween.tween_callback(queue_free)
