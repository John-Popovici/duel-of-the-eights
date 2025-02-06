extends Node3D

@onready var camera = get_parent().get_node("Camera3D")
@onready var cameraController = get_parent()
@onready var d6CamPos = get_parent().get_node("Positions/D6")
@onready var lerp_duration = 2
@onready var d8Display = get_parent().get_parent().get_node("D8Display")
@onready var d4Display = get_parent().get_parent().get_node("D4Display")
@onready var d12Display = get_parent().get_parent().get_node("D12Display")
@onready var cameraUIpanel = get_parent().get_node("CameraPosPanel")
@onready var start_transform = camera.global_transform

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("zoom_in")

func zoom_in():
	cameraController.set_options_disabled(true)
	cameraController.set_options_visible(true)
	d8Display.visible = false
	d4Display.visible = false
	d12Display.visible = false
	cameraController.lerp_camera_to_position(d6CamPos)
	await get_tree().create_timer(0.5).timeout
	var new_parent = camera  # Get the sibling node
	cameraController.set_options_disabled(false)
	d8Display.visible = true
	d4Display.visible = true
	d12Display.visible = true
	
	if new_parent:
		reparent(new_parent)  # Reparent this node under SiblingB
