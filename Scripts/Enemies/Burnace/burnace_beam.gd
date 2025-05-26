extends Node2D

@onready var base = $Base
@onready var beam = $Beam

var parent
var tween
var destroyed: bool

func _ready():
	pass

func _physics_process(delta):
	if not is_instance_valid(parent) and not destroyed:
		destroyed = true
		destroy()

func _on_base_frame_changed():
	beam.frame = base.frame

func destroy():
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale:x", 0, 0.2)
	tween.tween_callback(queue_free)
