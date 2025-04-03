extends Node3D

@export var movement_speed := 5.0
@export var mouse_sensitivity := 0.005
@export var zoom_speed := 2.0
@export var manual_control_enabled := true

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/Camera3D

var rotation_x := 0.0
var rotation_y := 0.0
var velocity := Vector3.ZERO

func _ready():
	if manual_control_enabled:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if not manual_control_enabled:
		return

	if event is InputEventMouseMotion:
		rotation_x -= event.relative.y * mouse_sensitivity
		rotation_y -= event.relative.x * mouse_sensitivity
		rotation_x = clamp(rotation_x, -1.5, 1.5)
		camera_pivot.rotation.x = rotation_x
		rotation.y = rotation_y

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.translate(Vector3(0, 0, -zoom_speed))
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.translate(Vector3(0, 0, zoom_speed))

	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#elif event.keycode == KEY_TAB:
		#	manual_control_enabled = !manual_control_enabled
		#	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if manual_control_enabled else Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	if not manual_control_enabled:
		return

	var input_vector := Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		input_vector -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		input_vector += transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_vector -= transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_vector += transform.basis.x
	if Input.is_action_pressed("move_up"):
		input_vector += transform.basis.y
	if Input.is_action_pressed("move_down"):
		input_vector -= transform.basis.y

	input_vector = input_vector.normalized()
	velocity = input_vector * movement_speed
	translate(velocity * delta)
