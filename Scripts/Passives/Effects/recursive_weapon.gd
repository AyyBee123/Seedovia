extends Node

@onready var weapon := $".."
var scene = PackedScene.new()

func _ready():
	pass
	weapon.attempted_fire.connect(shoot_weapon)

func shoot_weapon():
	var new_weapon
	if not weapon.is_in_group("Child"):
		new_weapon = weapon.duplicate()
		new_weapon.slot_index = 3
		new_weapon.remove_child(new_weapon.get_node("RecursiveWeapon"))
		weapon.shoot_different_weapon(new_weapon)
		return
	new_weapon = weapon.parent_scene.instantiate()
	var node = new_weapon.get_node_or_null("RecursiveWeapon")
	if node != null:
		new_weapon.remove_child(new_weapon.get_node("RecursiveWeapon"))
	scene.pack(new_weapon)
	weapon.shoot_parent_recursion_passive(scene)
