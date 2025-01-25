# Die.gd

extends RigidBody3D

# Exported start position so it can be set in the editor
@export var num_faces: int
@export var start_position: Vector3 = Vector3.ZERO
@export var start_rotation: Vector3 = Vector3.ZERO
@export var aside_position: Vector3 = Vector3.ZERO
@export var aside_rotation: Vector3 = Vector3.ZERO
@export var move_aside_mode: String = "lerp"
@export var start_time: float
@export var impulse_range: int
@export var torque_range: int
# Thresholds to consider if the die is still rolling
@export var velocity_threshold: float  # Adjust this value based on your needs
@export var roll_time_limit: float     # Time limit to trigger function
var is_selected: bool = false          # Tracks if the die has been clicked/selected
@onready var dieMesh: MeshInstance3D = get_node("OuterMesh")
@onready var dieBase: MeshInstance3D = get_node("InnerMesh")

var normalTex = GlobalSettings.normalDiceTex
var selectedTex = GlobalSettings.selectedDiceTex
var diceBaseTex = GlobalSettings.dicebaseTex

# Threshold for detecting the "upward" ray
@export var up_threshold: float
# Dictionary to associate raycast nodes with face values
@onready var face_rays = {}

func setup_face_rays() -> void:
	# Sets up raycast nodes for each face of the die
	var raycastHolder = get_node("RayCastHolder")
	var rayCount = 0
	for rayCast in raycastHolder.get_children():
		rayCount += 1
		face_rays[rayCount] = rayCast
	num_faces = rayCount
	setup_dice_specific_variables(num_faces)

func setup_dice_specific_variables(_faces: int) -> void:
	var diceDefaultSettings = GlobalSettings.diceDefaultSettingsRefs[_faces]
	start_time = diceDefaultSettings["start_time"]
	impulse_range = diceDefaultSettings["impulse_range"]
	torque_range = diceDefaultSettings["torque_range"]
	velocity_threshold = diceDefaultSettings["velocity_threshold"]
	roll_time_limit = diceDefaultSettings["roll_time_limit"]
	up_threshold = diceDefaultSettings["up_threshold"]

# Applies random torque and force to simulate a roll
func roll() -> void:
	self.set_freeze_enabled(false)
	self.disableCollisions(false)
	await get_tree().create_timer(start_time+0.5).timeout
	
	is_selected = false
	dieMesh.set_surface_override_material(0,normalTex)

	# Reset linear and angular velocities
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	# Reset position and rotation to start values
	global_transform.origin = start_position
	rotation_degrees = start_rotation
	
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
	if !is_rolling:
		self.set_freeze_enabled(true)
	for face_value in face_rays.keys():
		var raycast = face_rays[face_value]
		var ray_direction = raycast.global_transform.basis.z.normalized()
		var dot_product = ray_direction.dot(Vector3.UP)
		
		if dot_product > highest_dot and dot_product > up_threshold:
			highest_dot = dot_product
			best_face = face_value
	return best_face

func _mouse_enter() -> void:
	dieMesh.set_surface_override_material(0,selectedTex)
	

func _mouse_exit() -> void:
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
	if dice_ui_element != null:
		dice_ui_element._toggle_texture()

var dice_ui_element
func _set_dice_ui(_ui_element) -> void:
	dice_ui_element = _ui_element

func _clear_dice_ui() ->void:
	dice_ui_element = null

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
	setup_face_rays()

func reset_dice_tex()->void:
	normalTex = GlobalSettings.normalDiceTex
	selectedTex = GlobalSettings.selectedDiceTex
	diceBaseTex = GlobalSettings.dicebaseTex
	if !is_selected:
		dieMesh.set_surface_override_material(0,normalTex)
	else:
		dieMesh.set_surface_override_material(0,selectedTex)
	dieBase.set_surface_override_material(0,diceBaseTex)

# Tracks if the die is currently rolling
var is_rolling: bool = false
var roll_start_time: float = -1.0  # Tracks when the die started rolling
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Update rolling status in _process

func getIsRolling() -> bool:
	return is_rolling


func setStartConditions(_pos: Vector3, _rot: Vector3, _time: float) -> void:
	start_position = _pos
	start_rotation = _rot
	start_time = _time
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	
func setAsideProperties(_pos: Vector3) -> void:
	aside_position = _pos
	aside_rotation = self.getStraightRotation()
	
func disableCollisions(_remove: bool) -> void:
	var collision_shape = $CollisionShape3D
	if collision_shape:
		collision_shape.disabled = _remove
	
func moveToAsidePosition() -> void:
	self.set_freeze_enabled(false)
	self.disableCollisions(true)
	if move_aside_mode == "snap":
		# instantly snap die to designated aside location while not being rolled
		global_transform.origin = self.aside_position
		rotation_degrees = self.aside_rotation
	elif move_aside_mode == "lerp":
		# smoothly lerp die to designated aside location while not being rolled
		var start_transform = global_transform
		var start_rotation = rotation_degrees
		var t = 0.0
		while t < 1.0:
			t += 0.05  # Lerp speed, adjust as needed
			global_transform.origin = start_position
			rotation_degrees = start_rotation
			global_transform.origin = start_transform.origin.lerp(self.aside_position, t)
			rotation_degrees = start_rotation.lerp(self.aside_rotation, t)
			await get_tree().process_frame  # Wait until the next frame
	self.set_freeze_enabled(true)
	
# Setter function for move_mode
func set_move_aside_mode(mode: String) -> void:
	if mode in ["lerp", "snap"]:
		move_aside_mode = mode

# Getter function to return the straigtened rotation vector for a particular die
func getStraightRotation() -> Vector3:
	return Vector3(rotation_degrees.x, 0, rotation_degrees.z)

# Getter function to get the x, y, or x component of a die's current position
func getAxisPos(axis: String) -> float:
	if axis in "xyzXYZ":
		return global_transform.origin[axis.to_lower()]
	else:
		return 0

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
				print("The die has been rolling for more than, ", roll_time_limit, " seconds.")
				roll_start_time = current_time  # Reset timer to prevent repeated calls
	else:
		is_rolling = false
