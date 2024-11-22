# Die.gd

extends RigidBody3D

# Exported start position so it can be set in the editor
@export var start_position: Vector3 = Vector3.ZERO
@export var start_rotation: Vector3 = Vector3.ZERO
@export var start_time: float = 0
@export var impulse_range: int = 5
@export var torque_range: int = 5
@export var hover_height: float = 0.5  # Hover height in meters
var hover_toggle_position: Vector3
@onready var move_last_time = -1.0
# Thresholds to consider if the die is still rolling
@export var velocity_threshold: float = 0.1  # Adjust this value based on your needs
@export var roll_time_limit: float = 3.0     # Time limit to trigger function
var is_selected: bool = false          # Tracks if the die has been clicked/selected
@onready var dieMesh: MeshInstance3D = get_node("OuterMesh")
@onready var dieBase: MeshInstance3D = get_node("InnerMesh")

var normalTex = GlobalSettings.normalDiceTex
var selectedTex = GlobalSettings.selectedDiceTex
var diceBaseTex = GlobalSettings.dicebaseTex

@export var face_threshold: float = 0.8  # Threshold for face orientation detection

# Threshold for detecting the "upward" ray
@export var up_threshold: float = 0.9
# Dictionary to associate raycast nodes with face values
@onready var face_rays = {
	1: $"RayCast3D_Face1",
	2: $"RayCast3D_Face2",
	3: $"RayCast3D_Face3",
	4: $"RayCast3D_Face4",
	5: $"RayCast3D_Face5",
	6: $"RayCast3D_Face6",
}

# Applies random torque and force to simulate a roll
func roll() -> void:
	self.set_freeze_enabled(false)
	await get_tree().create_timer(start_time).timeout
	# Reset position and rotation to start values
	global_transform.origin = start_position
	rotation_degrees = start_rotation
	#global_transform.basis = Basis(start_rotation,0)
	
	is_selected = false
	dieMesh.set_surface_override_material(0,normalTex)
	
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

# Determine which face is facing upward
func get_face_value() -> int:
	var best_face = -1
	var highest_dot = -1.0
	self.set_freeze_enabled(true)
	for face_value in face_rays.keys():
		var raycast = face_rays[face_value]
		var ray_direction = raycast.global_transform.basis.z.normalized()
		var dot_product = ray_direction.dot(Vector3.UP)
		
		if dot_product > highest_dot and dot_product > up_threshold:
			highest_dot = dot_product
			best_face = face_value
	return best_face
	
var move_start_time = Time.get_ticks_msec() / 1000.0
func _mouse_enter() -> void:
	move_start_time = Time.get_ticks_msec() / 1000.0
	if (move_last_time == -1.0 or move_start_time - move_last_time > 1.0) and !is_rolling:
		move_last_time = move_start_time
		hover()
	dieMesh.set_surface_override_material(0,selectedTex)

func reset_dice_tex()->void:
	normalTex = GlobalSettings.normalDiceTex
	selectedTex = GlobalSettings.selectedDiceTex
	diceBaseTex = GlobalSettings.dicebaseTex
	dieMesh.set_surface_override_material(0,normalTex)
	dieBase.set_surface_override_material(0,diceBaseTex)

func _mouse_exit() -> void:
	#hover_toggle_position = global_transform.origin  # Save the starting position
	#var new_position = hover_toggle_position + Vector3(0, -hover_height, 0)
	#global_transform.origin = new_position
	if !is_selected:
		dieMesh.set_surface_override_material(0,normalTex)

# Detects if the die was clicked and toggles its selected status
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_selection_status()

func _toggle_selection_status() -> void:
	is_selected = !is_selected  # Toggle selection status
	print("Die selected status:", is_selected)
	print(self.name)
	print("Dice Face Value: ", get_face_value())
	if !is_selected:
		dieMesh.set_surface_override_material(0,normalTex)
	else:
		dieMesh.set_surface_override_material(0,selectedTex)

# Returns whether the die is selected
func get_selected_status() -> bool:
	return is_selected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.mouse_entered.connect(_mouse_enter)
	self.mouse_exited.connect(_mouse_exit)
	self.input_event.connect(_on_input_event)
	dieMesh.set_surface_override_material(0,normalTex)
	dieBase.set_surface_override_material(0,diceBaseTex)

# Tracks if the die is currently rolling
var is_rolling: bool = false
var roll_start_time: float = -1.0  # Tracks when the die started rolling
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Update rolling status in _process

func getIsRolling() -> bool:
	return is_rolling

func hover():
	move_start_time = Time.get_ticks_msec() / 1000.0
	move_last_time = move_start_time
	hover_toggle_position = global_transform.origin  # Save the starting position
	var new_position = hover_toggle_position + Vector3(0, hover_height, 0)
	global_transform.origin = new_position

func setStartConditions(_pos: Vector3, _rot: Vector3, _time: float) -> void:
	start_position = _pos
	start_rotation = _rot
	start_time = _time
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO

func _process(_delta: float) -> void:
	# Calculate the speed by checking the length of the linear and angular velocities
	var speed = linear_velocity.length()
	var rotation_speed = angular_velocity.length()
	
	# Check if speed or rotation is above the threshold to determine if rolling
	if speed > velocity_threshold or rotation_speed > velocity_threshold:
		if !is_rolling:
			is_rolling = true
			roll_start_time = Time.get_ticks_msec() / 1000.0
		else:
			var current_time = Time.get_ticks_msec() / 1000.0
			if current_time - roll_start_time > roll_time_limit:
				print("The die has been rolling for more than 3 seconds.", roll_time_limit, " seconds.")
				hover()  # Call the function if the roll time limit is exceeded
				roll_start_time = current_time  # Reset timer to prevent repeated calls
	else:
		is_rolling = false
