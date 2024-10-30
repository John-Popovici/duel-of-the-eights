# DiceContainer.gd
extends Node3D

# Array to store references to all dice nodes
@export var dice_nodes: Array[RigidBody3D]

@export var roll_interval: float = 5.0       # Interval in seconds between rolls

var time_since_last_roll: float = 0.0        # Track time elapsed since last roll

@export var scoreboard: VBoxContainer

# Rolls all dice with random force and torque
func update_dice_values_board(values: Array[int]) -> void:
	scoreboard.update_dice_values(values)

# Rolls all dice with random force and torque
func roll_dice() -> void:
	for die in dice_nodes:
		die.roll()  # Call the roll function on each die

# Retrieves the values of each die after rolling
func get_dice_values() -> Array[int]:
	var dice_values: Array[int] = []
	for die in dice_nodes:
		dice_values.append(die.get_face_value())  # Append the top-facing value
	return dice_values


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#time_since_last_roll += delta            # Increment the timer by delta

	#if time_since_last_roll >= roll_interval:
		#update_dice_values_board(get_dice_values())
		#roll_dice()                          # Roll dice every 5 seconds
		#time_since_last_roll = 0.0           # Reset timer
	pass
