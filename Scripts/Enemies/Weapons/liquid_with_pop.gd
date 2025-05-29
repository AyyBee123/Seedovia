extends "res://Scripts/Enemies/Weapons/liquid.gd"

@onready var pop_rate = $"Pop Rate"
@onready var resource_preloader = $ResourcePreloader

func _physics_process(delta):
	super._physics_process(delta)
	
	if pop_rate.is_stopped():
		var pop = resource_preloader.get_resource("pop").instantiate()
		pop.scale = Vector2.ONE * randf_range(0.6, 1)
		add_child(pop)
		pop.position = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		pop_rate.start()
