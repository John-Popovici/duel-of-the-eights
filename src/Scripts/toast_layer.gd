extends Control

@export var duration: float = 5.0  # Time before disappearing
@export var toast: PackedScene = preload("res://NodeScene/toast.tscn")

func set_message(message: String):
	var toast_instance = toast.instantiate()
	get_node("CanvasLayer/VBoxContainer").add_child(toast_instance)
	print("Sending toast message P2: ", message)
	toast_instance.set_message(message)
