extends Node2D

var transition_scene := false
var reward
var text

var reward_weight = {
	# index 0, 1, and 2 are equipment, consumable, and seed pools respectively
	0: 0.3,
	1: 0.5,
	2: 0.2,
}

func _ready():
	Global.RNG.randomize()

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
	LevelList.loaded_room_is_cleared = false
	LevelList.current_reward_given = false
	LevelList.items_on_ground.clear()
	LevelList.doors.clear()
	Global.save_room()
	LevelList.change_room.call_deferred(self)

func set_reward(reward_text: String = ""):
	match reward_text:
		"Talisman":
			reward = Pool.pools[0]
			text = reward.pool_name
			$"Background/Reward Text".text = "[center]Reward\n" + reward.pool_name
			return
		"Consumable":
			reward = Pool.pools[1]
			text = reward.pool_name
			$"Background/Reward Text".text = "[center]Reward\n" + reward.pool_name
			return
		"Seed":
			reward = Pool.pools[2]
			text = reward.pool_name
			$"Background/Reward Text".text = "[center]Reward\n" + reward.pool_name
			return
	if reward_text != "": # if the reward is set (i.e. passive room, boss room, etc.)
		$"Background/Reward Text".text = "[center]Reward\n" + reward_text
		text = reward_text
		return
	var roll: float = Global.RNG.randf_range(0.0, 1.0) # probability roll
	var reward_pool
	var index
	var acc_chance = 0.0 # accumulated chance
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
	text = reward.pool_name
	$"Background/Reward Text".text = "[center]Reward\n" + reward.pool_name
