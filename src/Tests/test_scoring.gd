extends "res://addons/gut/test.gd"

var score_calculator

func before_each():
	score_calculator = preload("res://Scripts/OnlineDefaultGameScene/OG_score_calculator.gd").new()
	score_calculator._ready()

# Testing Singles Scoring
func test_singles_scoring():
	var _calculate_singles_score_1 = score_calculator._calculate_singles_score(5, [1,5,5,5,5,5], "2")
	assert_eq([50, 0], _calculate_singles_score_1)
	var _calculate_singles_score_2 = score_calculator._calculate_singles_score(1, [1,5,5,5,5,5], "2")
	assert_eq([2, 0], _calculate_singles_score_2)
	var _calculate_singles_score_3 = score_calculator._calculate_singles_score(5, [1,2,3], "2")
	assert_eq([0, 0], _calculate_singles_score_3)
	var _calculate_singles_score_4 = score_calculator._calculate_singles_score(5, [1,1,5,1,5,1], "1")
	assert_eq([10, 0], _calculate_singles_score_4)
	
# Testing Kind Scoring
func test_kind_scoring():
	var _calculate_kind_score_1 = score_calculator._calculate_kind_score(3, [1,5,5,5], "2")
	assert_eq(6, _calculate_kind_score_1)
	var _calculate_kind_score_2 = score_calculator._calculate_kind_score(4, [1,5,5,5,5], "3")
	assert_eq(12, _calculate_kind_score_2)
	var _calculate_kind_score_3 = score_calculator._calculate_kind_score(3, [1,2,3], "2")
	assert_eq(0, _calculate_kind_score_3)
	var _calculate_kind_score_4 = score_calculator._calculate_kind_score(4, [1,1,5,1,5,1], "")
	assert_eq(14, _calculate_kind_score_4)
	
# Testing Straight Scoring
func test_straight_scoring():
	var _calculate_straight_score_1 = score_calculator._calculate_straight_score(4, [1,5,2,4,3,1], "10")
	assert_eq(40, _calculate_straight_score_1)
	var _calculate_straight_score_2 = score_calculator._calculate_straight_score(4, [1,5,4,2,1], "3")
	assert_eq(0, _calculate_straight_score_2)
	var _calculate_straight_score_3 = score_calculator._calculate_straight_score(3, [1,2,2,1,3,5], "2")
	assert_eq(6, _calculate_straight_score_3)
	var _calculate_straight_score_4 = score_calculator._calculate_straight_score(3, [1,5,3,7,2,6], "10")
	assert_eq(30, _calculate_straight_score_4)
	
# Testing Full House Scoring
func test_full_house_scoring():
	var _calculate_full_house_score_1 = score_calculator._calculate_full_house_score(2,3, [1,3,3,1,3], "2")
	assert_eq(10, _calculate_full_house_score_1)
	var _calculate_full_house_score_2 = score_calculator._calculate_full_house_score(3,3, [2,2,4,4,2,4], "3")
	assert_eq(18, _calculate_full_house_score_2)
	var _calculate_full_house_score_3 = score_calculator._calculate_full_house_score(3,4, [1,2,2,1,1,2,2], "2")
	assert_eq(14, _calculate_full_house_score_3)
	var _calculate_full_house_score_4 = score_calculator._calculate_full_house_score(2,3, [1,5,1,4,4,4], "10")
	assert_eq(50, _calculate_full_house_score_4)
	
# Testing Chance Scoring
func test_chance_scoring():
	var _calculate_chance_score_1 = score_calculator._calculate_chance_score([1,1,1,1,1,1], "10")
	assert_eq(60, _calculate_chance_score_1)
	var _calculate_chance_score_2 = score_calculator._calculate_chance_score([1,2,4,3], "3")
	assert_eq(30, _calculate_chance_score_2)
	var _calculate_chance_score_3 = score_calculator._calculate_chance_score([1,2,1,3], "")
	assert_eq(7, _calculate_chance_score_3)
