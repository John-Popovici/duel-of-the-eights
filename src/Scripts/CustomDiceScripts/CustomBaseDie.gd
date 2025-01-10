# Die.gd

extends RigidBody3D

# Exported start position so it can be set in the editor
@export var num_faces: int = 6 # Number of faces on the die (e.g., d6, d8, etc.)
@export var start_position: Vector3 = Vector3.ZERO
@export var start_rotation: Vector3 = Vector3.ZERO
@export var start_time: float
@export var impulse_range: int
@export var torque_range: int
# Thresholds to consider if the die is still rolling
@export var velocity_threshold: float  # Adjust this value based on your needs
@export var roll_time_limit: float     # Time limit to trigger function
var is_selected: bool = false          # Tracks if the die has been clicked/selected

# Threshold for detecting the "upward" ray
@export var up_threshold: float

@onready var raycastHolder = get_node("RayCastHolder")
@onready var face_rays = {} # Dictionary to associate raycast nodes with face values
@onready var dicefaceHolder = get_node("DiceFaceHolder")
@onready var dice_faces = {}
@onready var face_values = {}
var normalCustomTex = GlobalSettings.normalCustomDiceTex
var selectedCustomTex = GlobalSettings.selectedCustomDiceTex

func setup_faces() -> void:
	# Sets up raycast nodes for each face of the die
	var rayCount = 0
	for rayCast in raycastHolder.get_children():
		rayCount += 1
		face_rays[rayCount] = rayCast
		face_values[rayCount] = rayCount
	num_faces = rayCount
	var faceCount = 0
	for diceFace in dicefaceHolder.get_children():
		faceCount += 1
		dice_faces[faceCount] = diceFace
	setup_dice_specific_variables(num_faces)

func setup_dice_specific_variables(_faces: int) -> void:
	var diceDefaultSettings = GlobalSettings.diceDefaultSettingsRefs[_faces]
	start_time = diceDefaultSettings["start_time"]
	impulse_range = diceDefaultSettings["impulse_range"]
	torque_range = diceDefaultSettings["torque_range"]
	velocity_threshold = diceDefaultSettings["velocity_threshold"]
	roll_time_limit = diceDefaultSettings["roll_time_limit"]
	up_threshold = diceDefaultSettings["up_threshold"]
	reset_dice_tex()

# Applies random torque and force to simulate a roll
func roll() -> void:
	self.set_freeze_enabled(false)
	await get_tree().create_timer(start_time+0.5).timeout
	
	is_selected = false
	reset_dice_tex()

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
	var best_face_idx = -1
	var highest_dot = -1.0
	if !is_rolling:
		self.set_freeze_enabled(true)
	for face_idx in face_rays.keys():
		var raycast = face_rays[face_idx]
		var ray_direction = raycast.global_transform.basis.z.normalized()
		var dot_product = ray_direction.dot(Vector3.UP)
		
		if dot_product > highest_dot and dot_product > up_threshold:
			highest_dot = dot_product
			best_face_idx = face_idx
	if face_values.has(best_face_idx):
		return face_values[best_face_idx]
	else:
		return best_face_idx

func _mouse_enter() -> void:
	selected_dice_tex()
	

func _mouse_exit() -> void:
	if !is_selected:
		normal_dice_tex()

# Detects if the die was clicked and toggles its selected status
func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_toggle_selection_status()

func _toggle_selection_status() -> void:
	is_selected = !is_selected  # Toggle selection status
	print("Die selected status:", is_selected)
	print(self.name)
	print("Dice Face Value: ", get_face_value())
	reset_dice_tex()
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
	setup_faces()
	#_flipfaces()

var changenumber = true
func _flipfaces() -> void:
	while true:
		await get_tree().create_timer(4).timeout
		print("Flipping values")
		if changenumber:
			for i in range(1,7):
				change_face_value(i,7-i)
		else:
			for i in range(1,7):
				change_face_value(i,i)
		changenumber = !changenumber
		#break

func reset_dice_tex()->void:
	normalCustomTex = GlobalSettings.normalCustomDiceTex
	selectedCustomTex = GlobalSettings.selectedCustomDiceTex
	if !is_selected:
		normal_dice_tex()
	else:
		selected_dice_tex()

func normal_dice_tex()->void:
	for diceFaceKey in dice_faces.keys():
		var dictKey = "D "+str(num_faces)+"-"+str(face_values[diceFaceKey])
		dice_faces[diceFaceKey].set_surface_override_material(0,normalCustomTex[dictKey])

func selected_dice_tex()->void:
	for diceFaceKey in dice_faces.keys():
		var dictKey = "D "+str(num_faces)+"-"+str(face_values[diceFaceKey])
		dice_faces[diceFaceKey].set_surface_override_material(0,selectedCustomTex[dictKey])

func change_face_value(idx: int, value)->void:
	face_values[idx] = value
	reset_dice_tex()

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
