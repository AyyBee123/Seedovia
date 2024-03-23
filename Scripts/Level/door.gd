extends Node2D

var transition_scene = false
var reward

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
	Global.next_reward = reward
	LevelList.change_room()

func set_reward():
	Pool.pools.shuffle()
	if Global.rewards.has(Pool.pools[0]): # retry function to attempt to get a different reward
		set_reward()
		return
	Global.rewards.append(Pool.pools[0])
	reward = Pool.pools[0]
	$"Background/Reward Text".text = "[center]Reward\n" + Pool.pools[0].pool_name
