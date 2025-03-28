extends "res://Scripts/Passives/Classes/passive_chance.gd"

const VENOMOUS_DOSE_POOL = preload("res://Scenes/Passives/Effects/Venomous Dose Pool.tscn")

var source

func _ready():
	# first get_parent is the Passives node, second get_parent is the object node (player)
	super._ready()
	source = get_parent().get_parent()
	chance = 0.33
	source.weapon_fired.connect(transfer_passive)
	source.has_collided.connect(chance_to_trigger)

func trigger(collided_object = null):
	if source.is_in_group("Weapon Effect"):
		return
	var dose = VENOMOUS_DOSE_POOL.instantiate()
	dose.scale = 2.75 * Vector2.ONE
	if "SIZE" in source:
		dose.scale *= source.SIZE
	get_tree().current_scene.add_child.call_deferred(dose)
	if collided_object.is_in_group("Enemies") or collided_object.is_in_group("Obstacle"):
		if not "direction" in source:
			dose.global_position = source.global_position
		else:
			var line_direction = source.direction.normalized()
			var enemy_direction = collided_object.global_position - source.global_position
			var distance = line_direction.dot(enemy_direction)
			dose.global_position = distance * line_direction + source.global_position
	else:
		dose.global_position = source.global_position

func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	weapon.get_node("Passives").add_child(self.duplicate())
