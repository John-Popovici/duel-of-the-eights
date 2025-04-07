extends Node3D

@export var move_mode: String = "lerp"  # Can be "lerp" or "snap"

@onready var camera = self
@onready var start_pos = camera.global_transform
@onready var positions_holder = get_parent().get_node("Positions")
@onready var positions =[]
@onready var positions_count = 0
@onready var currentPosCount = 0

signal posReached
# Called when the node enters the scene tree for the first time
func _ready() -> void:
	connect("posReached",goToNextPos)
	self.visible = true
	for position_node in positions_holder.get_children():
		if position_node is Node3D:
			positions_count += 1
			positions.append(position_node)
	goToNextPos()

func goToNextPos() -> void:
	currentPosCount = (currentPosCount + 1) % positions_count
	_on_position_button_pressed(positions[currentPosCount])

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
func lerp_camera_to_position(target: Node3D, lerp_speed: float = 0.005) -> void:
	var start_transform = camera.global_transform
	var end_transform = target.global_transform
	var t = 0.0
	while t < 1.0:
		t += lerp_speed  # Lerp speed, adjust as needed
		camera.global_transform.origin = start_transform.origin.lerp(end_transform.origin, t)
		camera.global_transform.basis = start_transform.basis.slerp(end_transform.basis, t)
		await get_tree().process_frame  # Wait until the next frame
	Debugger.log("Reached Lerp pos")
	posReached.emit()

# Setter function for move_mode
func set_move_mode(mode: String) -> void:
	if mode in ["lerp", "snap"]:
		move_mode = mode

func _process(delta):
	camera.rotation_degrees.y += sin(Time.get_ticks_msec() * 0.0001 * 5) * 0.005
