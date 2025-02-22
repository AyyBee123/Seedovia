extends Node

const FIRE_RATE_MULTIPLIER = 2

@onready var resource_preloader = $ResourcePreloader
@onready var fire_rate = $"Fire Rate"

var source
var player

func _ready():
	player = Targets.get_player()
	source = get_parent().get_parent()

func _physics_process(delta):
	if fire_rate.is_stopped():
		var proj = resource_preloader.get_resource("Lunacy's Delight Projectile").instantiate()
		proj.DAMAGE = player._player_stats.get_seed_stat("Weapon_Damage")
		proj.RANGE = player._player_stats.get_seed_stat("Weapon_Range")
		proj.SPEED = player._player_stats.get_seed_stat("Weapon_Speed")
		proj.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
		proj.previous_weapon = source
		get_tree().current_scene.add_child(proj)
		proj.global_position = source.global_position
		fire_rate.start(1.0 / source.FIRE_RATE)
