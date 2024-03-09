extends "res://Scripts/Passives/Classes/passive_chance.gd"

@onready var resource_preloader := $ResourcePreloader

func _ready():
	chance = 0.3
	player.weapon_fired.connect(chance_to_trigger)
	super._ready()

func trigger(weapon = null):
	var effect_color = Color(1, 0.5, 0, 0.5)
	var effect_sprite = Sprite2D.new()
	var fire_effect = resource_preloader.get_resource("Burning Weapon").instantiate()
	effect_sprite.texture = weapon.texture
	effect_sprite.self_modulate = effect_color
	weapon.add_child(effect_sprite)
	fire_effect.damage = player._player_stats.get_stat("Weapon_Damage") / 4
	weapon.add_child(fire_effect)
	weapon.weapon_fired.connect(trigger)
