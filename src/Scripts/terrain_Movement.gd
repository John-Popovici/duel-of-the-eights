extends Node3D

# Current state
@export var target_position: Vector3 = Vector3(0,0,0)
var is_moving: bool = false
var move_start_time: float
@export var move_duration: float = 2
var start_position: Vector3

# Call this function to initiate movement
func move_to_position() -> void:
	start_position = global_transform.origin
	target_position = target_position * 50
	print(start_position)
	move_start_time = Time.get_ticks_msec() / 1000.0
	is_moving = true

# Smoothly updates the position each frame if movement is active
func _process(delta: float) -> void:
	if is_moving:
		var elapsed_time = (Time.get_ticks_msec() / 1000.0) - move_start_time
		var t = min(elapsed_time / move_duration, 1.0)  # Clamp t between 0 and 1
		global_transform.origin = start_position.lerp(target_position, t)
		
		# Stop movement when the target position is reached
		if t >= 1.0:
			is_moving = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
