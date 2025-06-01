extends Node

signal freeing_orphans

func free_orphaned_nodes():
	freeing_orphans.emit()
