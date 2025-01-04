extends Node3D
# Use SceneSwitcher.returnToIntro("path to scene")
# Not in use currently
func _ready() -> void:
	pass

func returnToIntro() -> void:
	var current_scene = get_tree().current_scene

	# Only free the current scene if it's still valid
	if current_scene != null:
		current_scene.queue_free()
	else: # brute force clear of all nodes (in progress)
		var root = get_tree().root
		for child in root.get_children():
			child.queue_free()

	var intro_scene = load("res://Scenes/IntroScene.tscn").instantiate()

	get_tree().root.add_child(intro_scene)

	get_tree().current_scene = intro_scene

func _process(delta: float) -> void:
	pass
