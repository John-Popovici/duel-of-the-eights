extends Node

@onready var normalDiceTex = load("res://Materials/DiceTextures/Red.tres")
@onready var selectedDiceTex = load("res://Materials/DiceTextures/Purple.tres")
@onready var dicebaseTex = load("res://Materials/DiceTextures/White.tres")

@export var allDiceTextures : Dictionary = {
	"Blue": load("res://Materials/DiceTextures/Blue.tres"),
	"Green": load("res://Materials/DiceTextures/Green.tres"),
	"Purple": load("res://Materials/DiceTextures/Purple.tres"),
	"Red": load("res://Materials/DiceTextures/Red.tres"),
	"White": load("res://Materials/DiceTextures/White.tres"),
	}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
