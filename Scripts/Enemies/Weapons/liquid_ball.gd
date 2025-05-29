extends "res://Scripts/Enemies/Weapons/bullet.gd"

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

var LIQUID

func _ready():
	super._ready()

func _physics_process(delta):
	initialize_position()
	update_position(delta)

func update_position(delta):
	var current_velocity: Vector2 = direction * speed
	position += current_velocity * delta

func _collide(body):
	pop()

func pop():
	var splash = SPLASH.instantiate()
	splash.size = 0.4
	splash.source = self
	splash.modulate = modulate
	Game.audio_manager.play(Game.audio_manager.chocolate_splat)
	call_deferred("create_child", splash)
	
	if LIQUID:
		var liquid = LIQUID.instantiate()
		liquid.add_to_group("Used Liquid")
		liquid.scale *= 0.75
		liquid.modulate.a = 1
		get_tree().current_scene.add_child.call_deferred(liquid)
		liquid.global_position = global_position
	
	queue_free()

func create_child(child):
	get_tree().current_scene.add_child(child)
	child.global_position = self.global_position
