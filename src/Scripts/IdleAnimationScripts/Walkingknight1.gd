extends Node3D

@onready var builtinAnimationPlayer = get_node("AnimationPlayer")
@onready var externalAnimationPlayer = get_node("ExternalAnimationPlayer")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.position = Vector3(-95,0,-200)
	start_animations()

func start_animations():
	externalAnimationPlayer.play("MovePath")
	builtinAnimationPlayer.play("Walking_A")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	builtinAnimationPlayer.queue("Walkin_A")
