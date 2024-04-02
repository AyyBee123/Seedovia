extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

var damage_multiplier: float = 0.3

@onready var resource_preloader = $ResourcePreloader

func _ready():
	super._ready()
	slot_number = 1

func trigger(weapon):
	if not weapon.is_in_group("Projectile"):
		return
	# spawns three orbs around the projectile
	for i in range(3):
		var dark_orbital = resource_preloader.get_resource("Dark Fire Orbital").instantiate()
		dark_orbital.weapon = weapon
		dark_orbital.damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier
		dark_orbital.index = i
		get_tree().current_scene.add_child(dark_orbital)
