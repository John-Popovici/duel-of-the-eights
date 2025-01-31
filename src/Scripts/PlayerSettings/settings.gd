extends Node

@onready var back_button = $VBoxContainer/BackButton

func _ready() -> void:
	back_button.pressed.connect(_on_backbutton_pressed)

# Function that is called when the back button is pressed
func _on_backbutton_pressed() -> void:
	SceneSwitcher.returnToIntro()
