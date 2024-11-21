extends Node3D

@export var move_mode: String = "lerp"  # Can be "lerp" or "snap"

@onready var camera = get_node("Camera3D")
@onready var positions_holder = get_node("Positions")
@onready var button_container = get_node("CameraPosPanel/ButtonHolder")
@onready var button_panel = get_node("CameraPosPanel")

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	populate_buttons()
	set_options_visible(false)
	self.visible = true

# Populates the VBoxContainer with buttons for each position node
func populate_buttons() -> void:
	for child in button_container.get_children():
		child.queue_free()
	for position_node in positions_holder.get_children():
		if position_node is Node3D:
			var button = Button.new()
			button.text = position_node.name
			#button.connect("pressed", self, "_on_position_button_pressed", [position_node])
			button.pressed.connect(_on_position_button_pressed.bind(position_node))
			button_container.add_child(button)

# Handles button presses to move the camera to a specific position node
func _on_position_button_pressed(position_node: Node3D) -> void:
	if move_mode == "snap":
		snap_camera_to_position(position_node)
	elif move_mode == "lerp":
		lerp_camera_to_position(position_node)

# Snaps the camera to the specified position and rotation
func snap_camera_to_position(target: Node3D) -> void:
	camera.global_transform = target.global_transform

# Lerps the camera to the specified position and rotation
func lerp_camera_to_position(target: Node3D) -> void:
	var start_transform = camera.global_transform
	var end_transform = target.global_transform
	var t = 0.0
	while t < 1.0:
		t += 0.05  # Lerp speed, adjust as needed
		camera.global_transform.origin = start_transform.origin.lerp(end_transform.origin, t)
		camera.global_transform.basis = start_transform.basis.slerp(end_transform.basis, t)
		await get_tree().process_frame  # Wait until the next frame

# Setter function for move_mode
func set_move_mode(mode: String) -> void:
	if mode in ["lerp", "snap"]:
		move_mode = mode

func set_options_visible(state: bool) -> void:
	button_panel.visible = state
