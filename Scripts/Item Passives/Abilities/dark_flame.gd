extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

var damage_multiplier: float = 0.3
var number_of_orbitals = 2
var source

@onready var resource_preloader = $ResourcePreloader

func _ready():
	super._ready()
	slot_number = 1
	source = get_parent().get_parent()
	source.weapon_fired.connect(get_slot_number)

func trigger(weapon):
	# spawns three orbs around the projectile
	for i in range(number_of_orbitals):
		var dark_orbital = resource_preloader.get_resource("Dark Fire Orbital").instantiate()
		dark_orbital.weapon = weapon
		dark_orbital.DAMAGE = weapon.DAMAGE
		dark_orbital.index = i
		dark_orbital.number_of_orbitals = number_of_orbitals
		# spawn the oribital outside the screen to prevent 1 frame of it spawning at the center
		get_tree().current_scene.add_child(dark_orbital)
