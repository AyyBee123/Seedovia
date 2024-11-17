extends "res://Scripts/Player/player.gd"

func _ready():
	if PlayerCharacter._is_starting: # when starting a new run
		PlayerCharacter._is_starting = false
		_player_stats.set_health(_player_stats.get_stat("Max_Health"))
		if PlayerPassives.starting_passives != null: # add starting passives to the player
			PlayerPassives.add_starting_passives()
		for stat in _player_stats.stats.keys():
			if stat == "Max_Health":
				_player_stats.stats[stat]["x"] = 1
				_player_stats.stats[stat]["+"] = 0
				continue
			_player_stats.stats[stat]["x"] = 1.0
			_player_stats.stats[stat]["+"] = 0.0
	else:
		PlayerPassives.set_passives()
		PlayerPassives.set_item_passives()
		PlayerStatStorage.set_stats()
		Global.load_data()
	_player_stats.set_health(PlayerStatStorage.current_health)
	controller_cursor.visible = false
	_player_stats.damaged.connect(took_damage)
	Global.save_data()
