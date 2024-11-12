extends Node
# score_calculator.gd
@onready var SinglesTotal = 0
signal BonusTriggered(_score:int)
var BonusThreshold: int
var BonusScore: int
var BonusUsed: bool
@onready var BonusExists: bool = false

# Main scoring function
func calculate_hand_score(hand_dict: Dictionary, dice_rolls: Array) -> int:
	var hand_type = hand_dict.get("hand_type")[0]  # e.g., "Singles", "Kind", "Straight"
	var hand_value1 = hand_dict.get("hand_type")[1]  # e.g., target value like 1, 2 for Singles; 3 for 3 of a Kind
	
	var scoring_rule = hand_dict.get("scoring_rule")  # Optional scoring rule string
	
	match hand_type:
		"Singles":
			return _calculate_singles_score(hand_value1, dice_rolls)
		"Kind":
			return _calculate_kind_score(hand_value1, dice_rolls)
		"Straight":
			return _calculate_straight_score(hand_value1, dice_rolls)
		"FullHouse":
			var hand_value2 = hand_dict.get("hand_type")[2]  # used for full houses
			return _calculate_full_house_score(hand_value1, hand_value2, dice_rolls)
		"Chance":
			return _calculate_chance_score(dice_rolls)
		_:
			print("Unknown hand type:", hand_type)
			return 0

func setupBonus(_bonusHand: Dictionary) -> void:
	#Add logic to read host input
	BonusExists = true
	BonusScore = 35
	BonusThreshold = 63
	BonusUsed = false

func initializeValues() -> void:
	BonusExists = false
	SinglesTotal = 0

# Calculates score for Singles (like Ones, Twos, etc.)
func _calculate_singles_score(target_value: int, dice_rolls: Array) -> int:
	var score = 0
	for roll in dice_rolls:
		if roll == target_value:
			score += roll
	SinglesTotal += score
	if BonusExists and SinglesTotal >= BonusThreshold and !BonusUsed:
		BonusTriggered.emit(BonusScore)
		BonusUsed = true
	return score

# Calculates score for Chance (Sum)
func _calculate_chance_score(dice_rolls: Array) -> int:
	var score = 0
	for roll in dice_rolls:
		score += roll
	return score

# Calculates score for Kind hands (like Three of a Kind, Four of a Kind)
func _calculate_kind_score(target_count: int, dice_rolls: Array) -> int:
	var roll_counts = {}
	for roll in dice_rolls:
		roll_counts[roll] = roll_counts.get(roll, 0) + 1
	# Check if any roll appears target_count times
	for number in roll_counts.keys():
		if roll_counts[number] >= target_count:
			return _calculate_chance_score(dice_rolls) # Sum all dice for scoring
	
	return 0  # No qualifying Kind found

# Helper function to remove duplicates from an array
func remove_duplicates(array: Array) -> Array:
	var unique_values = []
	for value in array:
		if value not in unique_values:
			unique_values.append(value)
	return unique_values

# Calculates score for Straights based on minimum length (target_count)
func _calculate_straight_score(target_length: int, dice_rolls: Array) -> int:
	var unique_rolls = dice_rolls.duplicate()
	unique_rolls.sort()
	unique_rolls = remove_duplicates(unique_rolls)
	var longest_straight = 1
	var current_straight = 1

	for i in range(1, unique_rolls.size()):
		if unique_rolls[i] == unique_rolls[i - 1] + 1:
			current_straight += 1
			longest_straight = max(longest_straight, current_straight)
		else:
			current_straight = 1
	
	if longest_straight >= target_length:
		return target_length * 10  # Example score based on length
	
	return 0

# Calculates score for Full House
func _calculate_full_house_score(setSize1: int, setSize2: int, dice_rolls: Array) -> int:
	var roll_counts = {}
	for roll in dice_rolls:
		roll_counts[roll] = roll_counts.get(roll, 0) + 1

	var has_smallSet = false
	var has_largeSet = false

	for count in roll_counts.values():
		if count >= setSize2:
			if has_largeSet:
				has_smallSet = true
			has_largeSet = true
		elif count >= setSize1:
			has_smallSet = true
	
	if has_smallSet and has_largeSet:
		return (setSize1+setSize2)*5  # Full House score
	
	return 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
