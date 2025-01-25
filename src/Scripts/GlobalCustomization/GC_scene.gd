extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("DiceDisplay/CanvasLayer/CameraController").set_options_visible(true)

func returnToIntro() -> void:
	var intro_scene = load("res://Scenes/IntroScene.tscn").instantiate()
	
	# Change scene to GameScene
	get_tree().root.add_child(intro_scene)
	queue_free()  # Free IntroScene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
