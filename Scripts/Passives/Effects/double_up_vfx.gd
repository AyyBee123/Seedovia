extends Node

const SPLASH = preload("res://Scenes/Misc/Splash.tscn")

var damage_color = Color.GOLD
var damage_size_multi = 1.5
var source
var enemy

func _ready():
	source = get_parent().get_parent()
	source.has_collided.connect(set_damage_number)

func set_damage_number(body):
	if "damage_color" in body.get_parent():
		body.get_parent().damage_color = damage_color
		SfxDeconflicter.play(Game.audio_manager.crit)
		SfxDeconflicter.play(Game.audio_manager.ding_2)
		enemy = body.get_parent()
		explode()
	if "damage_size" in body.get_parent():
		body.get_parent().damage_size = damage_size_multi

func explode():
	var splash = SPLASH.instantiate()
	splash.size = 0.5
	splash.source = self
	splash.modulate = Color("ff1b1b")
	call_deferred("create_child", splash)

func create_child(child):
	get_tree().current_scene.add_child(child)
	if not "direction" in source:
		child.global_position = source.global_position
	else:
		var line_direction = source.direction.normalized()
		var enemy_direction = enemy.global_position - source.global_position
		var distance = line_direction.dot(enemy_direction)
		child.global_position = distance * line_direction + source.global_position
