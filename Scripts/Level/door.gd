extends Node2D

var transition_scene = false

func _ready():
	set_reward()

func _physics_process(delta):
	if transition_scene:
		change_scene()

func _on_enter_radius_body_entered(body):
	if body.is_in_group("Players"):
		transition_scene = true

func _on_enter_radius_body_exited(body):
	if body.is_in_group("Players"):
		transition_scene = false

func change_scene():
	Global.get_reward()
	LevelList.change_room()

func set_reward():
	var reward = Pool.pools.pick_random()
	Global.next_reward = reward
	if Global.rewards.has(reward): # retry function to attempt to get a different reward
		set_reward()
		return
	Global.rewards.append(reward)
	$"Background/Reward Text".text = "[center]Reward\n" + reward.pool_name
