extends VBoxContainer

@onready var gameManager: Node # Reference to the Ones Button
@onready var dice_container: Node3D
@onready var ones_button = $OnesButton # Reference to the Ones Button
@onready var twos_button = $TwosButton # Reference to the Ones Button
@onready var threes_button = $ThreesButton # Reference to the Ones Button
@onready var fours_button = $FoursButton # Reference to the Ones Button
@onready var fives_button = $FivesButton # Reference to the Ones Button
@onready var sixes_button = $SixesButton # Reference to the Ones Button

@onready var triplet_button = $TripletButton # Reference to the Ones Button
@onready var quadruplet_button = $QuadrupletButton # Reference to the Ones Button
@onready var Yahtzee_button = $YahtzeeButton # Reference to the Ones Button
@onready var fullHouse_button = $FullHouseButton # Reference to the Ones Button
@onready var smStraight_button = $SmStraightButton # Reference to the Ones Button
@onready var laStraight_button = $LaStraightButton # Reference to the Ones Button
@onready var chance_button = $ChanceButton # Reference to the Ones Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gameManager = get_node("../../")
	dice_container = get_node("../../DiceContainer")
	ones_button.pressed.connect(calc_ones)
	twos_button.pressed.connect(calc_twos)
	threes_button.pressed.connect(calc_threes)
	fours_button.pressed.connect(calc_fours)
	fives_button.pressed.connect(calc_fives)
	sixes_button.pressed.connect(calc_sixes)
	
	triplet_button.pressed.connect(calc_triplet)
	quadruplet_button.pressed.connect(calc_quadruplet)
	Yahtzee_button.pressed.connect(calc_yahtzee)
	fullHouse_button.pressed.connect(calc_fullHouse)
	smStraight_button.pressed.connect(calc_smStraight)
	laStraight_button.pressed.connect(calc_laStraight)
	chance_button.pressed.connect(calc_chance)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ToggleVisibility() -> void:
	visible = !visible

func OnVisibility() -> void:
	visible = true

func OffVisibility() -> void:
	visible = false

func addScore(score: int) -> void:
	gameManager.update_scores(score)

# Helper function to remove duplicates from an array
func remove_duplicates(array: Array) -> Array:
	var unique_values = []
	for value in array:
		if value not in unique_values:
			unique_values.append(value)
	return unique_values


func calc_ones() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	for val in dice_values:
		if val == 1:
			score += val
	ones_button.disabled = true
	ones_button.text = str("Ones: %d" % score)
	addScore(score)

func calc_twos() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	for val in dice_values:
		if val == 2:
			score += val
	twos_button.disabled = true
	twos_button.text = str("Twos: %d" % score)
	addScore(score)

func calc_threes() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	for val in dice_values:
		if val == 3:
			score += val
	threes_button.disabled = true
	threes_button.text = str("Threes: %d" % score)
	addScore(score)

func calc_fours() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	for val in dice_values:
		if val == 4:
			score += val
	fours_button.disabled = true
	fours_button.text = str("Fours: %d" % score)
	addScore(score)

func calc_fives() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	for val in dice_values:
		if val == 5:
			score += val
	fives_button.disabled = true
	fives_button.text = str("Fives: %d" % score)
	addScore(score)

func calc_sixes() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	for val in dice_values:
		if val == 6:
			score += val
	sixes_button.disabled = true
	sixes_button.text = str("Sixes: %d" % score)
	addScore(score)

func calc_chance() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	for val in dice_values:
		score += val
	chance_button.disabled = true
	chance_button.text = str("Chance: %d" % score)
	addScore(score)

func calc_triplet() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	var counts: Array[int] = [0,0,0,0,0,0]
	var meetCrit = false
	for val in dice_values:
		score += val
		counts[val-1] +=1
		if counts[val-1]>=3:
			meetCrit = true
	if !meetCrit:
		score = 0
	triplet_button.disabled = true
	triplet_button.text = str("Three of a kind: %d" % score)
	addScore(score)

func calc_quadruplet() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	var counts: Array[int] = [0,0,0,0,0,0]
	var meetCrit = false
	for val in dice_values:
		score += val
		counts[val-1] +=1
		if counts[val-1]>=4:
			meetCrit = true
	if !meetCrit:
		score = 0
	quadruplet_button.disabled = true
	quadruplet_button.text = str("Four of a kind: %d" % score)
	addScore(score)

func calc_yahtzee() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	var counts: Array[int] = [0,0,0,0,0,0]
	var meetCrit = false
	for val in dice_values:
		counts[val-1] +=1
		if counts[val-1]>=5:
			meetCrit = true
	if meetCrit:
		score = 50
	Yahtzee_button.disabled = true
	Yahtzee_button.text = str("Yahtzee: %d" % score)
	addScore(score)

func calc_fullHouse() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	var counts: Array[int] = [0,0,0,0,0,0]
	var meetCrit = false
	for val in dice_values:
		counts[val-1] +=1
	
	var hasTwo = false
	var hasThree = false
	for count in counts:
		if count == 2:
			hasTwo = true
		elif count == 3:
			hasThree = true
	meetCrit = hasThree and hasTwo
	
	if meetCrit:
		score = 25
	fullHouse_button.disabled = true
	fullHouse_button.text = str("Full House: %d" % score)
	addScore(score)

func calc_smStraight() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	var meetCrit = false
	var sorted_unique_rolls = dice_values.duplicate()
	sorted_unique_rolls.sort()
	sorted_unique_rolls = remove_duplicates(sorted_unique_rolls)  # Remove duplicates
	if len(sorted_unique_rolls) >= 4:
		for i in range(len(sorted_unique_rolls) - 3):
			if sorted_unique_rolls[i] + 1 == sorted_unique_rolls[i + 1] and sorted_unique_rolls[i] + 2 == sorted_unique_rolls[i + 2] and sorted_unique_rolls[i] + 3 == sorted_unique_rolls[i + 3]:
				meetCrit = true  # Found a small straight
	
	if meetCrit:
		score = 30
	smStraight_button.disabled = true
	smStraight_button.text = str("Small Straight: %d" % score)
	addScore(score)

func calc_laStraight() -> void:
	var dice_values = dice_container.get_dice_values()
	var score: int = 0
	var meetCrit = false
	var sorted_unique_rolls = dice_values.duplicate()
	sorted_unique_rolls.sort()
	sorted_unique_rolls = remove_duplicates(sorted_unique_rolls)  # Remove duplicates
	if len(sorted_unique_rolls) == 5:
		if sorted_unique_rolls[0] + 1 == sorted_unique_rolls[1] and sorted_unique_rolls[1] + 1 == sorted_unique_rolls[2] and sorted_unique_rolls[2] + 1 == sorted_unique_rolls[3] and sorted_unique_rolls[3] + 1 == sorted_unique_rolls[4]:
			meetCrit = true  # Found a small straight
	
	if meetCrit:
		score = 40
	laStraight_button.disabled = true
	laStraight_button.text = str("Large Straight: %d" % score)
	addScore(score)
