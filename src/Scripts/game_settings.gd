extends CanvasLayer

signal game_settings_ready(game_settings,hand_settings)
@onready var start_game_button = $UIBox/Settings_Setup/Buttons/StartGame
@onready var advanced_settings_button = $UIBox/Settings_Setup/HandLimit/AdvancedSettingsButton
@onready var return_to_settings_button = $UIBox/Settings_Advanced/ReturnToSettings
@onready var save_advanced_settings_button = $UIBox/Settings_Advanced/SaveSettings
@onready var home_button = $UIBox/Settings_Setup/Buttons/BackToHomeButton

@onready var player1Name = $UIBox/Settings_Setup/PlayerNames/Player1Name
@onready var player2Name = $UIBox/Settings_Setup/PlayerNames/Player2Name
@onready var WinCondition = $UIBox/Settings_Setup/WinCondition/ConditionSelect
@onready var HealthPoints = $UIBox/Settings_Setup/HealthPoints/HealthPoints
@onready var HealthPointsBox = $UIBox/Settings_Setup/HealthPoints
@onready var Rounds = $UIBox/Settings_Setup/Rounds/Rounds
@onready var RoundRolls = $UIBox/Settings_Setup/Rounds/RoundRolls
@onready var DiceCountRef = $UIBox/Settings_Setup/Dice/DiceCount.get_line_edit()
@onready var DiceCountRange = $UIBox/Settings_Setup/Dice/DiceCount
@onready var DiceType = $UIBox/Settings_Setup/Dice/DiceType
@onready var opponent_roll_visible_button = $UIBox/Settings_Setup/HandLimit/OpponentRollVisible
@onready var advanced_settings_vbox = $UIBox/Settings_Advanced/ScrollContainer/advanced_settings_vbox

@onready var NetworkManager = get_node("../../NetworkManager")

var hand_settings_saved = false
@export var hand_settings_refs: Dictionary = {}
@export var hand_settings_vals: Dictionary = {}
# Capture the dice type and count
var dice_count: int
var dice_type: int
var win_cond: String
var show_opponent_rolls: bool = false

func _on_start_game_pressed():
	start_game_button.disabled = true
	home_button.disabled = true
	advanced_settings_button.disabled = true
	print("Passing ", show_opponent_rolls)
	var game_settings = {
		"player_names": [player1Name.text, player2Name.text],
		"win_condition": WinCondition.get_selected_id(),
		"health_points": int(HealthPoints.text),
		"rounds": int(Rounds.text),
		"round_rolls": int(RoundRolls.text),
		"dice_count": int(DiceCountRef.text),
		"dice_type": DiceType.get_selected_id(),  # e.g., 6-sided or 8-sided
		"show_rolls": show_opponent_rolls
	}
	if !hand_settings_saved:
		dice_count = int(DiceCountRef.text)
		dice_type = DiceType.get_selected_id()
		_populate_advanced_settings()
		await get_tree().create_timer(1.0).timeout
		save_advanced_settings()
	await get_tree().create_timer(1.0).timeout
	emit_signal("game_settings_ready", game_settings, hand_settings_vals)
	self.visible = false

func _win_condition_toggled(ID):
	print("Win Condition Toggled: ",ID)
	var win_cond = ID
	match win_cond:
		0: #score
			HealthPointsBox.visible = false
			win_cond = "Score"
		1: #healthpoints
			HealthPointsBox.visible = true
			win_cond = "Health"

func _on_advanced_settings_pressed() -> void:
	dice_count = int(DiceCountRef.text)
	dice_type = DiceType.get_selected_id()
	get_node("UIBox/Settings_Setup").visible = false
	_populate_advanced_settings()
	get_node("UIBox/Settings_Advanced").visible = true

# Populates the advanced settings based on dice count and type
func _populate_advanced_settings():
	# Clear current advanced settings to rebuild them
	hand_settings_refs.clear()
	hand_settings_vals.clear()
	for child in advanced_settings_vbox.get_children():
		child.queue_free()

	# Generate and add each hand to the VBoxContainer
	advanced_settings_vbox.add_child(_create_label("Single Numbers"))
	_generate_singles()
	
	advanced_settings_vbox.add_child(_create_label("Bonus"))
	_generate_bonus()
	
	advanced_settings_vbox.add_child(_create_label("Straights"))
	_generate_straights()
	
	advanced_settings_vbox.add_child(_create_label("Kinds"))
	_generate_kinds()
	
	advanced_settings_vbox.add_child(_create_label("Full Houses"))
	_generate_full_houses()
	
	advanced_settings_vbox.add_child(_create_label("All in"))
	_generate_chance()

func _create_label(_text: String) -> Label:
	var label = Label.new()
	label.text = _text
	return label

# Generate single-number hands (like Ones, Twos, ... up to dice_type)
func _generate_singles():
	for i in range(1, dice_type + 1):
		var hand_name = "Hand: %d's" % i
		var hand_type = ["Singles",i]
		var hand_option = _create_hand_option(hand_name, hand_type)
		advanced_settings_vbox.add_child(hand_option)

#Bonus
func _generate_bonus():
	var hand_name = "Bonus"
	var hand_type = ["Bonus",0]
	var hand_option = _create_hand_option(hand_name, hand_type)
	advanced_settings_vbox.add_child(hand_option)

#Chance
func _generate_chance():
	var hand_name = "Chance"
	var hand_type = ["Chance",0]
	var hand_option = _create_hand_option(hand_name, hand_type)
	advanced_settings_vbox.add_child(hand_option)

# Generate straights based on dice count
func _generate_straights():
	var min_straight = min(4, dice_count)
	for length in range(min_straight, dice_count + 1):
		var hand_name = "Straight of %d" % length
		var hand_type = ["Straight",length]
		var hand_option = _create_hand_option(hand_name, hand_type)
		advanced_settings_vbox.add_child(hand_option)
	#add code to state that can't do since low dice count

# Generate "Kinds" hands based on dice count
func _generate_kinds():
	# Start with "Three of a Kind" and go up to the maximum count (dice_count)
	for kind in range(3, dice_count + 1):
		var hand_name = "%d of a Kind" % kind
		var hand_type = ["Kind",kind]
		var hand_option = _create_hand_option(hand_name, hand_type)
		advanced_settings_vbox.add_child(hand_option)

# Generate full houses based on dice count
func _generate_full_houses():
	# This will create (min_set_size, remaining) combinations
	for n in range(4, dice_count + 1):
		for m in range(2, floor(n / 2) + 1):
			var hand_name = "Full House (%d, %d)" % [m, n-m]
			var hand_type = ["FullHouse",m,n-m]
			var hand_option = _create_hand_option(hand_name, hand_type)
			advanced_settings_vbox.add_child(hand_option)

# Helper function to create a UI option for each hand
func _create_hand_option(hand_name: String, hand_type: Array) -> HBoxContainer:
	var hand_hbox = HBoxContainer.new()

	# Label for the hand name
	var name_label = Label.new()
	name_label.text = hand_name
	hand_hbox.add_child(name_label)

	# Toggle for allowing the hand
	var allowed_checkbox = CheckBox.new()
	allowed_checkbox.text = "Allowed"
	allowed_checkbox.set_toggle_mode(true)
	allowed_checkbox.set_pressed(true)
	hand_hbox.add_child(allowed_checkbox)

	# Toggle for repeatable
	var repeatable_checkbox = CheckBox.new()
	repeatable_checkbox.text = "Repeatable"
	hand_hbox.add_child(repeatable_checkbox)

	# SpinBox for maximum plays allowed
	var max_plays = SpinBox.new()
	max_plays.min_value = 0
	max_plays.max_value = 99
	max_plays.value = 1
	max_plays.suffix = "Play"
	hand_hbox.add_child(max_plays)

	# TextField for custom scoring rule
	var scoring_input = LineEdit.new()
	scoring_input.placeholder_text = "Scoring rule"
	hand_hbox.add_child(scoring_input)

	# Save settings for this hand in hand_settings dictionary
	hand_settings_refs[hand_name] = {
		"hand_type": hand_type,
		"allowed": allowed_checkbox,
		"repeatable": repeatable_checkbox,
		"max_plays": max_plays,
		"scoring_rule": scoring_input
	}

	return hand_hbox

# Saves the hand settings and hides the advanced settings UI
func save_advanced_settings():
	hand_settings_vals.clear()
	# Loop through each hand in hand_settings and save current values
	for hand_name in hand_settings_refs.keys():
		var settings = hand_settings_refs[hand_name]
		hand_settings_vals[hand_name] = {
			"hand_type": settings["hand_type"],
			"allowed": settings["allowed"].is_pressed(),#is_checked()
			"repeatable": settings["repeatable"].is_pressed(),
			"max_plays": int(settings["max_plays"].value),
			"scoring_rule": settings["scoring_rule"].text
		}
	hand_settings_saved = true
	#print("Hand settings saved:", hand_settings)

func _on_return_to_settings_pressed() -> void:
	# Clear current advanced settings nodes
	for child in advanced_settings_vbox.get_children():
		child.queue_free()
	get_node("UIBox/Settings_Setup").visible = true
	get_node("UIBox/Settings_Advanced").visible = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	start_game_button.connect("pressed",self._on_start_game_pressed)
	advanced_settings_button.connect("pressed",self._on_advanced_settings_pressed)
	save_advanced_settings_button.connect("pressed",self.save_advanced_settings)
	return_to_settings_button.connect("pressed",self._on_return_to_settings_pressed)
	home_button.connect("pressed",self.on_home_pressed)
	WinCondition.set_toggle_mode(true)
	WinCondition.connect("item_selected", self._win_condition_toggled)
	HealthPointsBox.visible = false
	win_cond = "Score"
	opponent_roll_visible_button.set_toggle_mode(true)
	opponent_roll_visible_button.connect("toggled", self._on_roll_visible_toggled)
	show_opponent_rolls = false
	DiceType.set_toggle_mode(true)
	DiceType.connect("item_selected", self._dice_values_changed)
	DiceCountRange.connect("value_changed", self._dice_values_changed)

func _on_roll_visible_toggled(state) -> void:
	print("Was ", show_opponent_rolls)
	if show_opponent_rolls:
		show_opponent_rolls = false
	else:
		show_opponent_rolls = true
	print("Is ", show_opponent_rolls)

func _dice_values_changed(state) -> void:
	if hand_settings_saved:
		print("Hand Settings lost")
		hand_settings_saved = false
	#code to indicate

func collectInfo() -> void:
	self.visible = true
	if NetworkManager.getIsHost():
		get_node("UIBox/Settings_Setup").visible = true
		get_node("UIBox/Settings_Advanced").visible = false
		get_node("UIBox/Settings_Wait").visible = false
	else:
		get_node("UIBox/Settings_Setup").visible = false
		get_node("UIBox/Settings_Advanced").visible = false
		get_node("UIBox/Settings_Wait").visible = true

func on_home_pressed() -> void:
	#Add disconnect code here and network manager
	get_tree().get_root().get_node("OnlineGameScene").returnToIntro()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
