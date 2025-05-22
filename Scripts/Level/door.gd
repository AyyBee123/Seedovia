extends Node2D

var circle_transition
var _transitioned: bool
var transition_scene := false
var reward
var text

# all reward images
const TALISMAN = preload("res://Sprites/Reward Images/Talisman.png")
const DIE = preload("res://Sprites/Reward Images/Die.png")
const SEED = preload("res://Sprites/Inventory/Seed.png")
const GOLDEN_APPLE = preload("res://Sprites/Stat Ups/Golden Apple.png")
const COIN = preload("res://Sprites/Misc/Coin.png")
const MAX_HEALTH = preload("res://Sprites/Pickups/Max Health.png")
const LEAF_HEART = preload("res://Sprites/Pickups/Leaf Heart.png")
const APPLE = preload("res://Sprites/Consumables/Apple.png")

var reward_weight = {
	# index 0, 1, 2, 3, 4, 5, 6, and 7 are talisman, consumable, seed, money, stat up, 
	# health up, leaf heart, and heal pools respectively
	# all of these added up together must equal 1
	0: 0.04,
	1: 0.10,
	2: 0.04,
	3: 0.34,
	4: 0.34,
	5: 0.03,
	6: 0.04,
	7: 0.07
}

func _ready():
	circle_transition = get_tree().current_scene.get_node("%Circle Transition")
	Global.RNG.randomize()

func _physics_process(delta):
	if transition_scene:
		if LevelList.room_number == 12 and not _transitioned:
			circle_transition.material.set("shader_parameter/circle_position_y", 0.305)
			circle_transition.get_node("AnimationPlayer").play("Close")
			Targets.get_player().process_mode = Node.PROCESS_MODE_DISABLED
			_transitioned = true
		if not circle_transition.get_node("AnimationPlayer").is_playing():
			change_scene.call_deferred()

func _on_enter_radius_body_entered(body):
	if body.is_in_group("Players"):
		# prevents held item from being deleted when moving to a new room
		if body.get_node("Inventory").holding_item:
			PlayerInventory.add_item(body.get_node("Inventory").holding_item.item, body, self)
			body.get_node("Inventory").holding_item.queue_free()
			body.get_node("Inventory").holding_item = null
		transition_scene = true

func change_scene():
	Global.next_reward = reward
	LevelList.loaded_room_is_cleared = false
	LevelList.current_reward_given = false
	LevelList.shop_items_spawned = false
	LevelList.items_on_ground.clear()
	LevelList.shop_items_on_ground.clear()
	LevelList.pickup_items_on_ground.clear()
	LevelList.coins_on_ground.clear()
	LevelList.doors.clear()
	Global.save_run_room()
	LevelList.change_room.call_deferred(self)

func set_reward(reward_text: String = "", texture: Texture = null):
	# getting existing doors (from quitting and then continuing
	match reward_text:
		"Talisman":
			reward = Pool.pools[0]
			text = reward.pool_name
			%Image.texture = reward.texture
			%"Reward Text".text = "[center]" + reward.pool_name
			return
		"Die":
			reward = Pool.pools[1]
			text = reward.pool_name
			%Image.texture = reward.texture
			%"Reward Text".text = "[center]" + reward.pool_name
			return
		"Seed":
			reward = Pool.pools[2]
			text = reward.pool_name
			%Image.texture = reward.texture
			%"Reward Text".text = "[center]" + reward.pool_name
			return
		"Coins":
			reward = Pool.pools[3]
			text = reward.pool_name
			%Image.texture = reward.texture
			%"Reward Text".text = "[center]" + reward.pool_name
			return
		"Stat Up":
			reward = Pool.pools[4]
			text = reward.pool_name
			%Image.texture = reward.texture
			%"Reward Text".text = "[center]" + reward.pool_name
			return
		"Health Up":
			reward = Pool.pools[5]
			text = reward.pool_name
			%Image.texture = reward.texture
			%"Reward Text".text = "[center]" + reward.pool_name
			return
		"Leaf Heart":
			reward = Pool.pools[6]
			text = reward.pool_name
			%Image.texture = reward.texture
			%"Reward Text".text = "[center]" + reward.pool_name
			return
		"Heal":
			reward = Pool.pools[7]
			text = reward.pool_name
			%Image.texture = reward.texture
			%"Reward Text".text = "[center]" + reward.pool_name
			return
	# if the reward is set (i.e. passive room, boss room, etc.)
	# these specific rewards are set in the Level.gd script
	if reward_text != "":
		%Image.texture = texture
		%"Reward Text".text = "[center]" + reward_text
		text = reward_text
		return
	var roll: float = Global.RNG.randf_range(0.0, 1.0) # probability roll
	var reward_pool
	var index
	var acc_chance = 0.0 # accumulated chance
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
	%Image.texture = reward.texture
	if texture:
		%Image.texture = texture
	%"Reward Text".text = "[center]" + reward.pool_name
