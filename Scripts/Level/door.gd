extends Node2D

var transition_scene := false
var reward

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
	if reward_text != "":
		$"Background/Reward Text".text = "[center]Reward\n" + reward_text
		return
	Pool.pools.shuffle()
	if Global.rewards.has(Pool.pools[0]): # retry function to attempt to get a different reward
		set_reward()
		return
	Global.rewards.append(Pool.pools[0])
	reward = Pool.pools[0]
	$"Background/Reward Text".text = "[center]Reward\n" + reward.pool_name
