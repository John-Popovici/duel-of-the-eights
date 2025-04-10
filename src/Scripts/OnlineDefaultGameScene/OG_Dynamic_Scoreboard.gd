extends CanvasLayer

@onready var vbox_container = $UIBox/SelfHandsSectionBox/ScrollContainer/HandsContainer

# Signal for when a hand is selected
signal hand_selected(hand: Dictionary)
var lastButton: Button
var BonusButton: Button
signal bonusExists(hand: Dictionary)
var AllButtons: Array[Button]
var AllButtonLabels: Array[Label]
@onready var TotalLabel = get_node("UIBox/SelfHandsSectionBox/Total")

const plays_mapping = { # note that these mappings are intentionally 1 number off from the expected mapping
	1 : "Double ",
	2 : "Triple ",
	3 : "Quadruple ",
	4 : "Quintuple "
}

# Called to populate the scoreboard with hands from hand_settings
func populate_scoreboard(hand_settings: Dictionary):
	self.visible = true
	for child in vbox_container.get_children():# Clear existing entries
		child.free()

	AllButtons.clear()
	
	for hand_name in hand_settings.keys():
		var settings = hand_settings[hand_name]
		if !settings["allowed"]:
			continue
		# Load the HandScoreEntry scene as a template
		var hand_entry = load("res://NodeScene/HandScoreEntry.tscn").instantiate()
		var hand_name_label = hand_entry.get_node("HandName")
		var select_button = hand_entry.get_node("Select")
		
		# Set up the hand display information
		hand_name_label.text = hand_name
		select_button.text = "Select"
		if hand_name == "Bonus":
			select_button.text = "0"
			select_button.disabled = true
			BonusButton = select_button
			bonusExists.emit(settings)
		else:
			AllButtons.append(select_button)
			AllButtonLabels.append(hand_name_label)
		select_button.setBaseName(hand_name)
		select_button.setMaxPlays(settings["max_plays"])
		select_button.setSettings(settings)
		#add code to set max number of presses per button
		
		# Connect the button to a function to handle the scoring
		var select_callable = Callable(self, "_on_hand_selected")
		select_button.setCallable(select_callable)
		#add signal connection to each button to disable/able when waiting
		
		# Add the hand entry to the VBoxContainer
		vbox_container.add_child(hand_entry)

# Callback for when a hand is selected
func _on_hand_selected(hand: Dictionary, button: Button):
	lastButton = button
	if hand.get("hand_type")[0] == "Yahtzee" and not button.disabled:
		var buttonIndex = AllButtons.find(button)
		if buttonIndex >= 0: #make sure button index is found
			# add the double or triple multiplier labels to hand name
			AllButtonLabels[buttonIndex].text = plays_mapping[AllButtons[buttonIndex].plays] + AllButtons[buttonIndex].baseName
	emit_signal("hand_selected", hand)

func updateButtonScore(_score: int):
	var _oldScore = TotalLabel.text.replace("Total: ", "")
	var newScore = int(_oldScore) + _score
	TotalLabel.text = "Total: " + str(newScore)
	if lastButton.text == "Select":
		lastButton.text = str(_score)
	else:
		var oldScore = int(lastButton.text)
		lastButton.text = str(oldScore + _score)

func updateBonusButtonScore(_score: int):
	var _oldScore = TotalLabel.text.replace("Total: ", "")
	var newScore = int(_oldScore) + _score
	TotalLabel.text = "Total: " + str(newScore)
	var oldScore = int(BonusButton.text)
	BonusButton.text = str(oldScore + _score)

func setAllButtonsDisable(state: bool) -> void:
	for _button in AllButtons:
		if !_button.getDisable():
			_button.disabled = state

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
