extends Sprite2D

@onready var lifetime = $Lifetime
@onready var pop_rate = $"Pop Rate"
@onready var resource_preloader = $ResourcePreloader
@onready var damage_buffer := $"Damage Buffer" # prevents an accidental extra damage call if sitting in enemy hitbox

var original_size: float
var is_in_area: bool
var player = null
var damage: int = 1

func _ready():
	lifetime.start()
	original_size = scale.x

func _physics_process(delta):
	if lifetime.is_stopped():
		$Area2D/CollisionShape2D.disabled = true
		var tween = get_tree().create_tween()
		tween.tween_callback(func(): remove_from_group("Liquid"))
		tween.tween_property(self, "modulate", Color(modulate.r, modulate.g, modulate.b, 0), 0.5)
		tween.tween_callback(queue_free)
	
	if pop_rate.is_stopped():
		var pop = resource_preloader.get_resource("pop").instantiate()
		pop.scale = Vector2.ONE * randf_range(0.6, 1)
		add_child(pop)
		pop.position = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		pop_rate.start()
