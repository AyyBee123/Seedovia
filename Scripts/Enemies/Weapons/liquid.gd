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
	original_size = scale.x


func _physics_process(delta):
	if lifetime.is_stopped():
		$Area2D/CollisionShape2D.disabled = true
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(modulate.r, modulate.g, modulate.b, 0), 0.5)
		if modulate.a == 0:
			tween.finished.connect(queue_free)
	
	if pop_rate.is_stopped():
		var pop = resource_preloader.get_resource("pop").instantiate()
		pop.scale = Vector2.ONE * randf_range(0.6, 1)
		add_child(pop)
		pop.position = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		pop_rate.start()
	
	if is_in_area and damage_buffer.is_stopped():
		player._player_stats.take_damage(self)
		damage_buffer.start()


func _on_area_2d_body_exited(body):
	if body.is_in_group("Players"):
		is_in_area = false


func _on_area_2d_body_entered(body):
	if body.is_in_group("Players"):
		player = body # just in case
		is_in_area = true
