extends CanvasLayer

@onready var vbox_container = $UIBox/SelfHandsSectionBox/ScrollContainer/HandsContainer

# Signal for when a hand is selected
signal hand_selected(hand: Dictionary)
var lastButton: Button
var BonusButton: Button
signal bonusExists(hand: Dictionary)
var AllButtons: Array[Button]

# Called to populate the scoreboard with hands from hand_settings
func populate_scoreboard(hand_settings: Dictionary):
	self.visible = true
	for child in vbox_container.get_children():# Clear existing entries
		child.queue_free()

	for hand_name in hand_settings.keys():
		var settings = hand_settings[hand_name]
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
	emit_signal("hand_selected", hand)

func updateButtonScore(_score: int):
	if lastButton.text == "Select":
		lastButton.text = str(_score)
	else:
		var oldScore = int(lastButton.text)
		lastButton.text = str(oldScore + _score)

func updateBonusButtonScore(_score: int):
	BonusButton.text = str(_score)

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
