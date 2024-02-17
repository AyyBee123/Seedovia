extends Control

func _ready():
	self.visible = false
	
func _process(delta):
	if Input.is_action_just_pressed("inventory"):
		# toggle inventory UI to open/close
		self.visible = !self.visible
