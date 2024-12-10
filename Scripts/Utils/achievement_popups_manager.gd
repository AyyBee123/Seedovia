extends Node

var achievement_popup = preload("res://Scenes/UI/Achievement Popup.tscn")

var popup_queue := []
var can_display: bool = true

func _ready():
	SignalBus.achievement.connect(new_achievement)
	SignalBus.unlock.connect(new_unlock)
	SignalBus.ach_popup_finished.connect(finish_popup)

func _process(delta):
	if popup_queue.size() > 0 and can_display:
		display_popup(popup_queue[0])

func display_popup(_popup):
	can_display = false
	add_child(_popup)

func new_achievement(_ach):
	var popup = achievement_popup.instantiate()
	popup.get_node("%Sprite").texture = _ach.get_image()
	popup.get_node("%Name").text = "New Achievement Unlocked"
	popup.get_node("%Title").text = _ach.get_title()
	popup_queue.push_back(popup)

func new_unlock(_unlock):
	var popup = achievement_popup.instantiate()
	if _unlock is character_class:
		popup.get_node("%Sprite").texture = _unlock.get_texture()
		popup.get_node("%Name").text = "New Character Unlocked"
		popup.get_node("%Title").text = _unlock.character_name
	else:
		popup.get_node("%Sprite").texture = _unlock.get_texture()
		popup.get_node("%Name").text = "New %s Unlocked" % _unlock.category
		popup.get_node("%Title").text = _unlock.item_name
	popup_queue.push_back(popup)

func finish_popup():
	if popup_queue.size() > 0:
		popup_queue[0].queue_free()
		popup_queue.pop_front()
	can_display = true
