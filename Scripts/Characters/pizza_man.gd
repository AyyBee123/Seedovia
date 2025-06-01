extends "res://Scripts/Player/player.gd"

func die():
	if is_dead:
		return
	velocity = Vector2.ZERO
	is_dead = true
	hand.visible = false
	_state_machine.set_state(_state_machine.states.die)
	$"Player Sprite".play("Die")
	Game.audio_manager.play(Game.audio_manager.bite)
	Global.save_data()
	Global.delete_run_data()

func _on_player_sprite_frame_changed():
	if $"Player Sprite".animation == "Die":
		match $"Player Sprite".frame:
			1:
				Game.audio_manager.play(Game.audio_manager.bite_2)
			2:
				Game.audio_manager.play(Game.audio_manager.bite_3)
			3:
				Game.audio_manager.play(Game.audio_manager.bite_4)
			4:
				Game.audio_manager.play(Game.audio_manager.bite_5)
			5:
				Game.audio_manager.play(Game.audio_manager.bite_6)
			6:
				Game.audio_manager.play(Game.audio_manager.bite_7)
			7:
				Game.audio_manager.play(Game.audio_manager.bite_8)
