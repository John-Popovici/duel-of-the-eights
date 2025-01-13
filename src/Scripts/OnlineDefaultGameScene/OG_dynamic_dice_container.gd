extends Node3D

# Array to store references to all dice nodes
@export var dice_nodes: Array[RigidBody3D]

# Define starting positions for the dice (9 positions in total)
var start_positions := [
	Vector3(0, 10, 0), Vector3(4, 10, 0), Vector3(-4, 10, 0),
	Vector3(0, 10, 4), Vector3(4, 10, 4), Vector3(-4, 10, 4),
	Vector3(0, 10, -4), Vector3(4, 10, -4), Vector3(-4, 10, -4)
]

# Define positions for setting dice aside
var aside_positions := [
	Vector3(20, 1, -20), Vector3(20, 1, -10), Vector3(20, 1, 0),
	Vector3(20, 1, 10), Vector3(20, 1, 20)
]
# In cases of more than 5 dice we shift aside postions on x axis by this constant
var aside_row_gap := Vector3(10, 0, 0)



# Rolls all dice with random force and torque
func roll_dice() -> void:
	for die in dice_nodes:
		die.roll()  # Call the roll function on each die

# Rolls only selected dice
func roll_selected_dice() -> void:
	moveDiceAside(get_unselected_dice())
	for die in get_selected_dice():
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

func get_dice() -> Array[RigidBody3D]:
	return dice_nodes

# Returns a list of all selected dice
func get_selected_dice() -> Array:
	var selected_dice = []
	for die in dice_nodes:
		if die.get_selected_status():
			selected_dice.append(die)
	return selected_dice
	
func get_unselected_dice() -> Array:
	var unselected_dice = []
	for die in dice_nodes:
		if not die.get_selected_status():
			unselected_dice.append(die)
	return unselected_dice

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
		elif dice_type == 4:
			dice = preload("res://NodeScene/four_dice.tscn").instantiate()
		elif dice_type == 12:
			dice = preload("res://NodeScene/twelve_dice.tscn").instantiate()
		
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

func moveDiceAside(dice_to_move: Array) -> void:
	#move dice that are not being rerolled (i.e. not selected at time of reroll, when this is called)
	#to the side of the board (or other location, to not interfere with the rerolling dice)
	dice_to_move.sort_custom(func(a, b): return a.get_face_value() < b.get_face_value())
	var iterator = 0
	var current_row = 0
	var max_slots = aside_positions.size()
	for die in dice_to_move:
		die.setAsideProperties(aside_positions[iterator] + (aside_row_gap*current_row))
		die.moveToAsidePosition()
		iterator += 1
		if iterator >= max_slots:
			iterator = 0
			current_row += 1

func moveDiceInLine() -> void:
	#move dice once read to an organized display on the board
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
