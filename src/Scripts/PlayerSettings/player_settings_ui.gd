extends CanvasLayer

@onready var back_button = $BackPanel/Sections/BackToHomeButton

func _ready() -> void:
	if back_button:
		Debugger.log("Back button found!")
		back_button.connect("pressed", _on_back_button_pressed)
	else:
		Debugger.log_error("Back button not found!")

func _on_back_button_pressed() -> void:
	Debugger.log("Back button pressed, switching to IntroScene...")
	SceneSwitcher.returnToIntro()

func _process(_delta: float) -> void:
	pass
