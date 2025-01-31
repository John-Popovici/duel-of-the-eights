extends Label
@export var duration: float = 5.0  # Time before disappearing
func set_message(message: String):
	print("Recieved toast message: ", message)
	self.text = message
	await get_tree().create_timer(duration).timeout
	queue_free()  # Remove from scene
