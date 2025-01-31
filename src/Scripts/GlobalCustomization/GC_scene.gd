extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("DiceDisplay/CameraController").set_options_visible(true)

func returnToIntro() -> void:
	SceneSwitcher.returnToIntro()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
