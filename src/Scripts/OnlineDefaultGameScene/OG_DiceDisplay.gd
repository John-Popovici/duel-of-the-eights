extends TextureRect
var die : RigidBody3D
var normal_tex
var selected_tex


func setDie (_die: RigidBody3D, _normal_tex, _selected_tex) -> void:
	die = _die
	die._set_dice_ui(self)
	normal_tex = _normal_tex
	selected_tex = _selected_tex
	_toggle_texture()

func clearDie () -> void:
	if die != null:
		die._clear_dice_ui()
	die = null

func _on_hover() -> void:
	if die != null and not die.get_selected_status():
		self.set_texture(selected_tex)
	
func _on_unhover() -> void:
	if die != null and not die.get_selected_status():
		self.set_texture(normal_tex)

# Function that handles the click event on the TextureRect
func _on_texture_rect_input_event(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Placeholder for the functionality to be executed
			Debugger.log("TextureRect clicked!")
			if die == null:
				Debugger.log_error("Dice not found")
				return
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				die._toggle_selection_status()
				#Change this UI texurerect
				_toggle_texture()
				

func _toggle_texture() -> void:
	if die.get_selected_status():
		self.set_texture(selected_tex)
	else:
		self.set_texture(normal_tex)
