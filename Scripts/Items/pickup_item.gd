extends Node2D

var player
@export var item: pickup_item_class: set = set_item

const SPARKLE = preload("res://Scenes/Misc/Sparkle.tscn")

func _ready():
	for i in 8:
		spawn_sparkle(Color.WHITE)

func _physics_process(delta):
	if player != null:
		position += global_position.direction_to(player.global_position) * delta * 600

func set_item(new_item: pickup_item_class):
	item = new_item
	$Sprite.texture = new_item.get_texture()

func _on_pickable_area_body_entered(body):
	if body.is_in_group("Players"):
		player = body
		pick_up()

func _on_attract_area_body_entered(body):
	if body.is_in_group("Players"):
		player = body

func pick_up():
	item.on_pickup()
	visible = false
	SignalBus.pickup_item_recieved.emit(self)

func spawn_sparkle(color: Color):
	var sparkle = SPARKLE.instantiate()
	sparkle.modulate = color
	sparkle.direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	add_child(sparkle)
	sparkle.global_position = global_position + sparkle.direction * 20
