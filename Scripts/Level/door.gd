extends Node2D

var transition_scene := false
var reward

var reward_weight = {
	# index 0, 1, and 2 are equipment, consumable, and seed pools respectively
	0: 0.3,
	1: 0.5,
	2: 0.2,
}

func _physics_process(delta):
	if transition_scene:
		change_scene.call_deferred()

func _on_enter_radius_body_entered(body):
	if body.is_in_group("Players"):
		# prevents held item from being deleted when moving to a new room
		if body.get_node("Inventory").holding_item:
			PlayerInventory.add_item(body.get_node("Inventory").holding_item.item, body, self)
			body.get_node("Inventory").holding_item.queue_free()
			body.get_node("Inventory").holding_item = null
		transition_scene = true

func _on_enter_radius_body_exited(body):
	if body.is_in_group("Players"):
		transition_scene = false

func change_scene():
	Global.next_reward = reward
	LevelList.change_room.call_deferred()

func set_reward(reward_text: String = ""):
	if reward_text != "": # if the reward is set (i.e. passive room, boss room, etc.)
		$"Background/Reward Text".text = "[center]Reward\n" + reward_text
		return
	# TODO: add RNG.randf_range(...)
	var roll: float = randf_range(0.0, 1.0)
	var reward_pool
	var index
	var acc_chance = 0.0
	# index 0, 1, and 2 are equipment, consumable, and seed pools respectively
	for i in reward_weight.size():
		acc_chance += reward_weight[i]
		if roll <= acc_chance:
			reward_pool = Pool.pools[i]
			index = i
			break
	if Global.rewards.has(Pool.pools[index]): # retry function to attempt to get a different reward
		set_reward()
		return
	Global.rewards.append(Pool.pools[index])
	reward = Pool.pools[index]
	$"Background/Reward Text".text = "[center]Reward\n" + reward.pool_name
