extends Node

# derived from https://gist.github.com/brettchalupa/1c68e37d2788a3d36f74222c354baac2
# Use SceneSwitcher.switch_scene("path to scene")

var current_scene = null

func _ready() -> void:
	var root = get_tree().root
	if root.get_child_count() > 0:
		current_scene = root.get_child(root.get_child_count() - 1)
	else:
		print("No scenes found in the root node")

func switch_scene(res_path: String) -> void:
	call_deferred("_deferred_switch_scene", res_path)

func _deferred_switch_scene(res_path: String) -> void:
	var scene = load(res_path)
	if scene == null:
		print_debug("Failed to load scene: ", res_path)
		return
	
	# Forcefull clear the root nodes
	var root = get_tree().root
	for child in root.get_children():
		child.queue_free()  
	
	current_scene = scene.instantiate()
	root.add_child(current_scene)
	get_tree().current_scene = current_scene
	print("Switched to new scene: ", current_scene.name)
