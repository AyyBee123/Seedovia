extends Node2D

var player_in_area = false
@export var item: inventory_item
var player = null

func _process(delta):
	if player_in_area:
		if Input.is_action_just_pressed("pick up"):
			pick_up()

func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		print("1")
		player_in_area = true
		player = body
		
func pick_up():
	player.pick_up_item(item)
	queue_free()
