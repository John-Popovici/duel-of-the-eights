extends Node3D

# Array to store references to all dice nodes
@export var dice_nodes: Array[RigidBody3D]

@export var scoreboard: VBoxContainer

# Define starting positions for the dice (9 positions in total)
var start_positions := [
	Vector3(0, 10, 0), Vector3(4, 10, 0), Vector3(-4, 10, 0),
	Vector3(0, 10, 4), Vector3(4, 10, 4), Vector3(-4, 10, 4),
	Vector3(0, 10, -4), Vector3(4, 10, -4), Vector3(-4, 10, -4)
]

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

func roll_rolling_or_invalid_dice() -> void:
	for die in dice_nodes:
		if die.getIsRolling() or (die.get_face_value() == -1):
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

# Returns a list of all selected dice
func get_rolling_dice() -> Array:
	var rolling_dice = []
	for die in dice_nodes:
		if die.getIsRolling():
			rolling_dice.append(die)
	return rolling_dice

func get_invalid_dice() -> Array:
	var invalid_dice = []
	for die in dice_nodes:
		if die.get_face_value() == -1:
			invalid_dice.append(die)
	return invalid_dice

func clear_dice() -> void:
	for child in get_children():
		child.queue_free()
	dice_nodes.clear()

func add_dice(dice_count: int, dice_type: int) -> void:
	clear_dice()
	for i in range(dice_count):
		var dice
		if dice_type == 6:
			dice = preload("res://NodeScene/six_dice.tscn").instantiate()
		elif dice_type == 8:
			dice = preload("res://NodeScene/eight_dice.tscn").instantiate()
		
		# Assign a starting position from the list, cycling if dice_count > 9
		var start_pos = start_positions[i % start_positions.size()]
		var start_time = (i / start_positions.size()) * 0.3
		
		# Generate a random rotation for added variation
		var start_rot = Vector3(randf() * TAU, randf() * TAU, randf() * TAU)
		
		# Set initial position and rotation using the function in Dice.gd
		dice.setStartConditions(start_pos, start_rot, start_time)
		dice.global_transform.origin = start_pos
		dice.rotation_degrees = Vector3.ZERO
		add_child(dice)
		dice_nodes.append(dice)
	roll_dice()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
