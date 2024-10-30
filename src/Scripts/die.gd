# Die.gd

extends RigidBody3D

# Exported start position so it can be set in the editor
@export var start_position: Vector3 = Vector3.ZERO
@export var start_rotation: Vector3 = Vector3.ZERO
@export var impulse_range: int = 5
@export var torque_range: int = 5

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


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
