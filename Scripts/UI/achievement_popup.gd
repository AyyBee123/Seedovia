extends Control

func destroy():
	SignalBus.ach_popup_finished.emit()
