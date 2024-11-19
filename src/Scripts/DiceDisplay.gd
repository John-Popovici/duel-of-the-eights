extends TextureRect
var die : RigidBody3D

func setDie (_die: RigidBody3D) -> void:
	die = _die
	#print("Dice added to sprite with value: ",die.get_face_value())

func clearDie () -> void:
	#print("Dice removed")
	die = null

# Function that handles the click event on the TextureRect
func _on_texture_rect_input_event(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Placeholder for the functionality to be executed
			print("TextureRect clicked!")
			if die == null:
				print("Dice not found")
				return
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				die._toggle_selection_status()
				#Change this UI texurerect
