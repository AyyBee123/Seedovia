extends Control

func _process(delta):
	$Logo.scale += delta * Vector2.ONE * 0.01

func _on_coming_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property($Coming, "modulate:a", 1, 1)

func _on_wishlist_timer_timeout():
	var tween = get_tree().create_tween()
	tween.tween_property($Wishlist, "modulate:a", 1, 1)
	tween.parallel().tween_property($"Steam Logo", "material:shader_parameter/fade", 1, 1)
