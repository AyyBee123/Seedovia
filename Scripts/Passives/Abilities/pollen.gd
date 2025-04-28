extends Node

var source

func _ready():
	source = get_parent().get_parent()
	source.weapon_fired.connect(transfer_passive)

func _physics_process(delta):
	if source == Targets.get_player():
		return
	if "transferred_damage_multiplier" in source:
		source.transferred_damage_multiplier += 0.333 * delta
		source.transferred_size_multiplier += 0.05 * delta
		source.scale += Vector2.ONE * 0.05 * delta
	elif "DAMAGE" in source:
		source.DAMAGE += 1 * delta
		source.scale += Vector2.ONE * 0.05 * delta

func transfer_passive(weapon = null):
	if weapon == null:
		return
	if weapon.is_in_group("Weapon Effect"):
		return
	weapon.get_node("Passives").add_child(self.duplicate())
