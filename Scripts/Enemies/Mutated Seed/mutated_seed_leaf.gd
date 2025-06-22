extends Sprite2D

var tween
var player
var damage = 1

func _ready():
	scale.x = 0
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale:x", 1, 0.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale:x", 0, 0.2).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)

func _on_bullet_hitbox_body_entered(body):
	_collide(body)

func _on_bullet_hitbox_area_entered(area):
	_collide(area)

func _collide(body):
	if body.is_in_group("Players"):
		player = body
		if not player.can_be_damaged:
			return
		player._player_stats.take_damage(damage)
