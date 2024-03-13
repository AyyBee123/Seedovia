extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader := $ResourcePreloader

var damage_multiplier := 0.25

func _ready():
	chance = 0.3
	player.weapon_fired.connect(chance_to_trigger)
	super._ready()

func trigger(weapon = null):
	var fire_effect = resource_preloader.get_resource("Burning Weapon").instantiate()
	if weapon.is_in_group("Weapon"):
		if weapon.modulate == Color.WHITE:
			weapon.modulate *= Color.DARK_ORANGE
		else:
			weapon.modulate += Color.DARK_ORANGE
		weapon.weapon_fired.connect(trigger)
	fire_effect.damage = player._player_stats.get_stat("Weapon_Damage") * damage_multiplier
	weapon.add_child(fire_effect)
