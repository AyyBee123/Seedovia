extends Node


func _ready():
	for i in PlayerCharacter.starting_character.starting_talismans.size():
		PlayerInventory.talismans[i] = PlayerCharacter.starting_character.starting_talismans[i]
		PlayerCharacter.starting_character.starting_talismans[i].add_stats = true
	get_parent().remove_child(self)
	Global.save_run_data()
	queue_free.call_deferred()
