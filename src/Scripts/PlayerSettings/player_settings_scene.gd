extends Node3D


func _ready() -> void:
	AudioManager.connect_buttons()

func returnToIntro() -> void:
	SceneSwitcher.returnToIntro()

func _process(delta: float) -> void:
	pass
