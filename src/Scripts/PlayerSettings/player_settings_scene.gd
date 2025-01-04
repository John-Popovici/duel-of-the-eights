extends Node3D


func _ready() -> void:
	pass

func returnToIntro() -> void:
	var intro_scene = load("res://Scenes/IntroScene.tscn").instantiate()
	
	# Change scene to intro scene
	get_tree().root.add_child(intro_scene)
	queue_free()  # Free IntroScene

func _process(delta: float) -> void:
	pass
