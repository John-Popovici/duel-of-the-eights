# Die.gd

extends RigidBody3D

# Exported start position so it can be set in the editor
@export var start_position: Vector3 = Vector3.ZERO
@export var start_rotation: Vector3 = Vector3.ZERO
@export var impulse_range: int = 5
@export var torque_range: int = 5
@export var hover_height: float = 0.5  # Hover height in meters
var hover_toggle_position: Vector3
var is_selected: bool = false          # Tracks if the die has been clicked/selected
@onready var dieMesh: MeshInstance3D = $MeshInstance3D

var normalTex = preload('res://Materials/Dice_Base.tres')
var selectedTex = preload('res://Materials/Dice_Selected.tres')

# Dictionary mapping each die face direction to its value
var face_value_dict = {
	Vector3.UP: 1,
	Vector3.DOWN: 6,
	Vector3.RIGHT: 3,
	Vector3.LEFT: 4,
	Vector3.FORWARD: 2,
	Vector3.BACK: 5
}

# Applies random torque and force to simulate a roll
func roll() -> void:
	# Reset position and rotation to start values
	global_transform.origin = start_position
	global_transform.basis = Basis(start_rotation,0)
	
	is_selected = false
	
	# Reset linear and angular velocities
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
	# Apply random force for linear movement
	apply_impulse(Vector3.ZERO, Vector3(
		randf_range(-impulse_range, impulse_range),
		randf_range(impulse_range, impulse_range*2),
		randf_range(-impulse_range, impulse_range)
	))
	
	# Apply random torque for rotation
	apply_torque_impulse(Vector3(
		randf_range(-torque_range, torque_range),
		randf_range(-torque_range, torque_range),
		randf_range(-torque_range, torque_range)
	))

# Determines the top-facing die value after the roll
func get_face_value() -> int:
	# After the dice have settled, check which face is up
	var highest_face: Vector3 = Vector3.UP
	var highest_dot = -1.0
	
	# Loop through each face direction in the dictionary
	for face_dir in face_value_dict.keys():
		var dot = global_transform.basis.y.dot(face_dir)
		if dot > highest_dot:
			highest_dot = dot
			highest_face = face_dir
	
	return face_value_dict[highest_face]  # Return the value of the top face

func _mouse_enter() -> void:
	hover_toggle_position = global_transform.origin  # Save the starting position
	var new_position = hover_toggle_position + Vector3(0, hover_height, 0)
	global_transform.origin = new_position
	dieMesh.set_surface_override_material(0,selectedTex)

func _mouse_exit() -> void:
	hover_toggle_position = global_transform.origin  # Save the starting position
	var new_position = hover_toggle_position + Vector3(0, -hover_height, 0)
	global_transform.origin = new_position
	if !is_selected:
		dieMesh.set_surface_override_material(0,normalTex)

# Detects if the die was clicked and toggles its selected status
func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		is_selected = !is_selected  # Toggle selection status
		print("Die selected status:", is_selected)

# Returns whether the die is selected
func get_selected_status() -> bool:
	return is_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.mouse_entered.connect(_mouse_enter)
	self.mouse_exited.connect(_mouse_exit)
	self.input_event.connect(_on_input_event)
	dieMesh.set_surface_override_material(0,normalTex)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
