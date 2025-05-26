extends "res://Scripts/Enemies/enemy.gd"

const BURNACE_BEAM = preload("res://Scenes/Enemies/Effects/Burnace Beam.tscn")
const FALLING_COAL = preload("res://Scenes/Enemies/Weapons/Falling Coal.tscn")

@onready var fire_time = $"Fire Time"
@onready var _state_machine = $state_machine
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var fire_rate = $"Fire Rate"
@onready var bfg_SFX = $Bfg
@onready var rumble_SFX = $Rumble

const AMOUNT_OF_COAL: int = 12 # number of falling coals per attack

var beam = null

func _ready():
	randomize()
	super._ready()
	fire_rate.wait_time = fire_time.wait_time / (AMOUNT_OF_COAL + 1) # add one to actually add the final coal

func create_beam():
	bfg_SFX.play()
	beam = BURNACE_BEAM.instantiate()
	beam.parent = self
	get_tree().current_scene.add_child(beam)
	beam.global_position = $Marker2D.global_position

func destroy_beam():
	if beam:
		beam.destroy()
		beam = null

func fire():
	if fire_rate.is_stopped():
		var coal = FALLING_COAL.instantiate()
		coal.DELAY = fire_time.wait_time
		get_tree().current_scene.add_child(coal)
		coal.global_position = Vector2(randf_range(-764, 764), randf_range(-380, 380))
		fire_rate.start()

func _on_fire_time_timeout():
	_state_machine.set_state(_state_machine.states.return)
