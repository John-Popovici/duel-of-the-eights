extends "res://addons/gut/test.gd"

var dice_container
var six_die
var eight_die
var four_die
var twelve_die

func before_each():
	dice_container = partial_double(load("res://Scripts/OnlineDefaultGameScene/OG_dynamic_dice_container.gd")).new()
	dice_container._ready()
	six_die = load("res://NodeScene/six_dice.tscn")
	eight_die = load("res://NodeScene/eight_dice.tscn")
	four_die = load("res://NodeScene/four_dice.tscn")
	twelve_die = load("res://NodeScene/twelve_dice.tscn")

	var mock_die1 = partial_double(six_die).instantiate()
	var mock_die2 = partial_double(six_die).instantiate()
	stub(mock_die1, "roll").to_call(func():
		custom_roll(mock_die1)
	)
	stub(mock_die1, "get_face_value").to_return(1)
	stub(mock_die1, "_toggle_selection_status").to_call(func():
		custom_toggle_selection(mock_die1)
	)
	stub(mock_die2, "roll").to_call(func():
		custom_roll(mock_die2)
	)
	stub(mock_die2, "get_face_value").to_return(3)
	stub(mock_die2, "_toggle_selection_status").to_call(func():
		custom_toggle_selection(mock_die2)
	)
	var mock_die3 = partial_double(eight_die).instantiate()
	var mock_die4 = partial_double(eight_die).instantiate()
	stub(mock_die3, "roll").to_call(func():
		custom_roll(mock_die3)
	)
	stub(mock_die3, "get_face_value").to_return(4)
	stub(mock_die3, "_toggle_selection_status").to_call(func():
		custom_toggle_selection(mock_die3)
	)
	stub(mock_die4, "roll").to_call(func():
		custom_roll(mock_die4)
	)
	stub(mock_die4, "get_face_value").to_return(6)
	stub(mock_die4, "_toggle_selection_status").to_call(func():
		custom_toggle_selection(mock_die4)
	)
	var mock_die5 = partial_double(four_die).instantiate()
	var mock_die6 = partial_double(four_die).instantiate()
	stub(mock_die5, "roll").to_call(func():
		custom_roll(mock_die5)
	)
	stub(mock_die5, "get_face_value").to_return(1)
	stub(mock_die5, "_toggle_selection_status").to_call(func():
		custom_toggle_selection(mock_die5)
	)
	stub(mock_die6, "roll").to_call(func():
		custom_roll(mock_die6)
	)
	stub(mock_die6, "get_face_value").to_return(2)
	stub(mock_die6, "_toggle_selection_status").to_call(func():
		custom_toggle_selection(mock_die6)
	)
	var mock_die7 = partial_double(twelve_die).instantiate()
	var mock_die8 = partial_double(twelve_die).instantiate()
	stub(mock_die7, "roll").to_call(func():
		custom_roll(mock_die7)
	)
	stub(mock_die7, "get_face_value").to_return(9)
	stub(mock_die7, "_toggle_selection_status").to_call(func():
		custom_toggle_selection(mock_die7)
	)
	stub(mock_die8, "roll").to_call(func():
		custom_roll(mock_die8)
	)
	stub(mock_die8, "get_face_value").to_return(11)
	stub(mock_die8, "_toggle_selection_status").to_call(func():
		custom_toggle_selection(mock_die8)
	)
	
	dice_container.dice_nodes.append(mock_die1)
	dice_container.dice_nodes.append(mock_die2)
	dice_container.dice_nodes.append(mock_die3)
	dice_container.dice_nodes.append(mock_die4)
	dice_container.dice_nodes.append(mock_die5)
	dice_container.dice_nodes.append(mock_die6)
	dice_container.dice_nodes.append(mock_die7)
	dice_container.dice_nodes.append(mock_die8)
	
	stub(dice_container, "moveDiceAside").to_do_nothing()

func test_roll_dice():
	dice_container.roll_dice()
	for die in dice_container.dice_nodes:
		assert_true(die.getIsRolling(), "Each die should be rolling after roll_dice is called")

func test_roll_selected_dice():
	dice_container.dice_nodes[0]._toggle_selection_status()
	dice_container.roll_selected_dice()
	assert_true(dice_container.dice_nodes[0].getIsRolling(), "Selected die should be rolling after roll_selected_dice is called")
	for i in range(1, dice_container.dice_nodes.size()):
		assert_false(dice_container.dice_nodes[i].getIsRolling(), "Unselected dice should not be rolling after roll_selected_dice is called")

func test_invert_selection():
	dice_container.dice_nodes[0]._toggle_selection_status()
	dice_container.invert_selection()
	assert_false(dice_container.dice_nodes[0].get_selected_status(), "Previously selected die should be unselected after invert_selection is called")
	for i in range(1, dice_container.dice_nodes.size()):
		assert_true(dice_container.dice_nodes[i].get_selected_status(), "Previously unselected dice should be selected after invert_selection is called")

func test_get_dice_values():
	dice_container.roll_dice()
	var values = dice_container.get_dice_values()
	assert_eq(values.size(), 8, "There should be 6 values after rolling 8 dice")
	for value in values:
		assert_true(value in range(1, 12), "Each value should be between 1 and 12")

func test_toggle_dice_collisions():
	dice_container.toggleDiceCollisions(true)
	for die in dice_container.dice_nodes:
		assert_called(die, 'disableCollisions', [true])
	dice_container.toggleDiceCollisions(false)
	for die in dice_container.dice_nodes:
		assert_called(die, 'disableCollisions', [false])



# VVVVVVVVV custom functions for stubbing VVVVVVVVV

func custom_roll(mock_die) -> void:
	mock_die.is_rolling = true
	
func custom_toggle_selection(mock_die) -> void:
	mock_die.is_selected = !mock_die.is_selected
