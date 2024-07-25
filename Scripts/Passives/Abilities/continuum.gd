extends Node

var source

func _ready():
	source = get_parent().get_parent()
	source.weapon_fired.connect(transfer_passive)
	if source.is_in_group("Weapon"):
		if source.get_node("Hitbox") != null:
			source.get_node("Hitbox").set_collision_mask_value(1, false) # 1 is the wall collision layer (being removed)

func _physics_process(delta):
	# top wall
	if source.global_position.y < -get_viewport().get_visible_rect().size.y / 2:
		source.global_position.y = get_viewport().get_visible_rect().size.y / 2
	# bottom wall
	if source.global_position.y > get_viewport().get_visible_rect().size.y / 2:
		source.global_position.y = -get_viewport().get_visible_rect().size.y / 2
	# left wall
	if source.global_position.x < -get_viewport().get_visible_rect().size.x / 2:
		source.global_position.x = get_viewport().get_visible_rect().size.x / 2
	# right wall
	if source.global_position.x > get_viewport().get_visible_rect().size.x / 2:
		source.global_position.x = -get_viewport().get_visible_rect().size.x / 2

# transfers this passive over from the initial source (the player) to the next weapon
# and from the next weapon to the following weapon, and so on...
func transfer_passive(weapon = null):
	if weapon == null or weapon.is_in_group("Weapon Effect"):
		return
	# make a new banana mine passive and add it as a child of the next weapon
	weapon.get_node("Passives").add_child(duplicate())
