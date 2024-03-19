extends Node

@onready var weapon := $".."
var scene = PackedScene.new()

func _ready():
	weapon.attempted_fire.connect(shoot_weapon)

func shoot_weapon():
	var new_weapon
	new_weapon = weapon
	var node = new_weapon.get_node_or_null("RecursiveWeapon")
	if node != null:
		new_weapon.remove_child(new_weapon.get_node("RecursiveWeapon"))
	scene.pack(new_weapon)
	if weapon.has_method("shoot_next_weapon"):
		weapon.shoot_next_weapon(scene)
