extends Node
# score_calculator.gd
@onready var SinglesTotal = 0
var BonusThreshold: int
var BonusScore: int
var BonusUsed: bool
var bonusScoringRule
@onready var BonusExists: bool = false
var DiceType: int
var DiceCount: int
var straight_modifier: int
var full_house_modifier: int

# Main scoring function
func calculate_hand_score(hand_dict: Dictionary, dice_rolls: Array) -> Array[int]:
	var hand_type = hand_dict.get("hand_type")[0]  # e.g., "Singles", "Kind", "Straight"
	var hand_value1 = hand_dict.get("hand_type")[1]  # e.g., target value like 1, 2 for Singles; 3 for 3 of a Kind
	var scoring_rule = hand_dict.get("scoring_rule")
	
	match hand_type:
		"Singles":
			return _calculate_singles_score(hand_value1, dice_rolls, scoring_rule)
		"Kind":
			return [_calculate_kind_score(hand_value1, dice_rolls, scoring_rule),0] #Modify to include Yahtzee repetition rules
		"Straight":
			return [_calculate_straight_score(hand_value1, dice_rolls, scoring_rule),0]
		"FullHouse":
			var hand_value2 = hand_dict.get("hand_type")[2]  # used for full houses
			return [_calculate_full_house_score(hand_value1, hand_value2, dice_rolls, scoring_rule),0]
		"Chance":
			return [_calculate_chance_score(dice_rolls, scoring_rule),0]
		_:
			Debugger.log_error(str("Unknown hand type:", hand_type))
			return [0,0]

func setupBonus(_bonusHand: Dictionary) -> void:
	#Add logic to read host input
	bonusScoringRule = _bonusHand["scoring_rule"]
	if bonusScoringRule != "":
		BonusScore = int(bonusScoringRule)
	BonusExists = true

func initializeValues(_game_settings: Dictionary) -> void:
	BonusExists = false
	BonusUsed = false
	SinglesTotal = 0
	DiceCount = _game_settings["dice_count"]
	DiceType = int(_game_settings["dice_type"])
	straight_modifier = 10
	full_house_modifier = 5
	BonusScore = 35
	BonusThreshold = 63
	#Modify to use Dice type and number unless specified in scoring rule when scored
	#has to fit standard Yahtzee and Prof's 8 sided Yahtzee
	straight_modifier = roundi(-0.125*pow(DiceType,2) + 2.75*DiceType - 2)
	full_house_modifier = roundi(0.0114*pow(DiceType,2) + 0.5864*DiceType + 1.3636)
	BonusScore = roundi(-0.1563*pow(DiceType,3) + 3.4375*pow(DiceType,2) - 15*DiceType + 35)
	BonusThreshold = roundi(0.125*pow(DiceType,3) - 3.625*pow(DiceType,2) + 38.25*DiceType - 63)
	BonusThreshold = ((DiceType*(DiceType+1))/2) * DiceCount * 0.5625
	if DiceType == 8 and DiceCount == 8:
		BonusThreshold = 162
	if DiceType == 6 and DiceCount == 5:
		BonusThreshold = 63

# Calculates score for Singles (like Ones, Twos, etc.)
func _calculate_singles_score(target_value: int, dice_rolls: Array, _scoring_rule: String) -> Array[int]:
	var score = 0
	var bonus_send = 0
	var scoring_rule
	if _scoring_rule.is_empty():
		scoring_rule = 1
	else:
		scoring_rule = float(_scoring_rule)
	for roll in dice_rolls:
		if roll == target_value:
			score += roll
	SinglesTotal += int(score*scoring_rule)
	if BonusExists and SinglesTotal >= BonusThreshold and !BonusUsed:
		bonus_send = BonusScore
		BonusUsed = true
	return [int(score*scoring_rule), bonus_send]

# Calculates score for Chance (Sum)
func _calculate_chance_score(dice_rolls: Array, _scoring_rule: String) -> int:
	var score = 0
	var scoring_rule
	if _scoring_rule.is_empty():
		scoring_rule = 1
	else:
		scoring_rule = float(_scoring_rule)
	for roll in dice_rolls:
		score += roll
	return int(score*scoring_rule)

# Calculates score for Kind hands (like Three of a Kind, Four of a Kind)
func _calculate_kind_score(target_count: int, dice_rolls: Array, _scoring_rule: String) -> int:
	var roll_counts = {}
	for roll in dice_rolls:
		roll_counts[roll] = roll_counts.get(roll, 0) + 1
	# Check if any roll appears target_count times
	for number in roll_counts.keys():
		if (roll_counts[number] >= target_count) and !(_scoring_rule.is_empty()):
			return int(target_count * float(_scoring_rule)) #Use scroing rule to multiply
		if roll_counts[number] >= target_count:
			return _calculate_chance_score(dice_rolls,_scoring_rule) # Sum all dice for scoring
	
	return 0  # No qualifying Kind found

# Helper function to remove duplicates from an array
func remove_duplicates(array: Array) -> Array:
	var unique_values = []
	for value in array:
		if value not in unique_values:
			unique_values.append(value)
	return unique_values

# Calculates score for Straights based on minimum length (target_count)
func _calculate_straight_score(target_length: int, dice_rolls: Array, _scoring_rule: String) -> int:
	var unique_rolls = dice_rolls.duplicate()
	unique_rolls.sort()
	unique_rolls = remove_duplicates(unique_rolls)
	var longest_straight = 1
	var current_straight = 1
	var scoring_rule
	if _scoring_rule.is_empty():
		scoring_rule = straight_modifier
	else:
		scoring_rule = float(_scoring_rule)
	for i in range(1, unique_rolls.size()):
		if unique_rolls[i] == unique_rolls[i - 1] + 1:
			current_straight += 1
			longest_straight = max(longest_straight, current_straight)
		else:
			current_straight = 1
	
	if longest_straight >= target_length:
		if _scoring_rule.begins_with("="):
			return int(_scoring_rule.substr(1,-1))
		return int(target_length * scoring_rule)  # Example score based on length
	
	return 0

# Calculates score for Full House
func _calculate_full_house_score(setSize1: int, setSize2: int, dice_rolls: Array, _scoring_rule: String) -> int:
	var roll_counts = {}
	for roll in dice_rolls:
		roll_counts[roll] = roll_counts.get(roll, 0) + 1

	var has_smallSet = false
	var has_largeSet = false
	
	var scoring_rule
	if _scoring_rule.is_empty():
		scoring_rule = full_house_modifier
	else:
		scoring_rule = float(_scoring_rule)
	
	for count in roll_counts.values():
		if count >= setSize2:
			if has_largeSet:
				has_smallSet = true
			has_largeSet = true
		elif count >= setSize1:
			has_smallSet = true
	
	if has_smallSet and has_largeSet:
		if _scoring_rule.begins_with("="):
			return int(_scoring_rule.substr(1,-1))
		return int((setSize1+setSize2)*scoring_rule)  # Full House score
	
	return 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
