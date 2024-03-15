extends "res://Scripts/Passives/Classes/passive_slot_specific.gd"

@onready var resource_preloader := $ResourcePreloader

var first_weapon = null

func _ready():
	super._ready()
	slot_number = 2


func get_slot_number(weapon = null):
	super.get_slot_number(weapon)
	if weapon.is_in_group("Weapon"):
		if weapon.seed_slot_number == 0:
			first_weapon = PackedScene.new()
			first_weapon.pack(weapon)


func trigger(weapon = null):
	weapon.add_child(resource_preloader.get_resource("Recursive Weapon").instantiate())
