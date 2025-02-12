extends "res://addons/gut/test.gd"

var score_calculator = load("res://Scripts/OnlineDefaultGameScene/OG_score_calculator.gd")

# calculate_hand_score tester
func test_calculate_hand_score():
	var _score_calculator = score_calculator.new()
	_score_calculator._ready()
	
	var _calculate_singles_score_1 = _score_calculator._calculate_singles_score(5, [1,5,5,5,5,5], "2")
	assert_eq([50, 0], _calculate_singles_score_1)
