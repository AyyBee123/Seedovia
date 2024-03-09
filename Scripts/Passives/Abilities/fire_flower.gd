extends "res://Scripts/Passives/Classes/passive_chance.gd"

func _ready():
	chance = 0.3
	player.weapon_fired.connect(chance_to_trigger)
	super._ready()

func trigger(weapon = null):
	var effect_color = Color(1, 0.5, 0, 0.5)
	var effect_sprite = Sprite2D.new()
	effect_sprite.texture = weapon.texture
	effect_sprite.self_modulate = effect_color
	weapon.add_child(effect_sprite)
	weapon.weapon_fired.connect(chance_to_trigger)
