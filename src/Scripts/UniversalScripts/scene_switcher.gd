extends Node3D

@onready var currentScene
@export var introScene = preload("res://Scenes/IntroScene.tscn")

func _ready() -> void:
	currentScene = get_parent().get_node("IntroScene")
	#currentScene.print_tree_pretty()

func returnToIntro() -> void:
	# Only free the current scene if it's still valid
	if currentScene != null:
		var networkManagers = get_tree().get_nodes_in_group("NetworkHandlingNodes")
		if networkManagers.size() > 0:
			var network_manager = networkManagers[0]
			network_manager.broadcast_disconnect("ReturnToIntro")
			await get_tree().create_timer(1.0).timeout
		currentScene.queue_free()
	else: # brute force clear of all nodes (in progress)
		Debugger.log_warning("Do not have scene to free")

	currentScene = introScene.instantiate()
	get_tree().root.add_child(currentScene)
	#currentScene.print_tree_pretty()

func changeScene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Scene path does not exist: " + path)
		return
	
	if currentScene != null:
		currentScene.queue_free()
	else: # brute force clear of all nodes (in progress)
		Debugger.log_warning("Do not have scene to free")
	
	currentScene = load(path).instantiate()
	get_tree().root.add_child(currentScene)
	#currentScene.print_tree_pretty()

func _process(delta: float) -> void:
	pass
