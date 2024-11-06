# DiceContainer.gd
extends Node3D

# Array to store references to all dice nodes
@export var dice_nodes: Array[RigidBody3D]

@export var scoreboard: VBoxContainer

# Rolls all dice with random force and torque
func update_dice_values_board(values: Array[int]) -> void:
	scoreboard.update_dice_values(values)

# Rolls all dice with random force and torque
func roll_dice() -> void:
	for die in dice_nodes:
		die.roll()  # Call the roll function on each die

# Rolls only selected dice
func roll_selected_dice() -> void:
	for die in dice_nodes:
		if die.get_selected_status():  # Check if the die is selected
			die.roll()

# Retrieves the values of each die after rolling
func get_dice_values() -> Array[int]:
	var dice_values: Array[int] = []
	for die in dice_nodes:
		dice_values.append(die.get_face_value())  # Append the top-facing value
	return dice_values

# Returns a list of all selected dice
func get_selected_dice() -> Array:
	var selected_dice = []
	for die in dice_nodes:
		if die.get_selected_status():
			selected_dice.append(die)
	return selected_dice

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
