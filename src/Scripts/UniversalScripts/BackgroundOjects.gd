extends Node3D

var _theme = "Tavern"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_theme = GlobalSettings.globalTheme
	#_theme = "Restaurant"
	if _theme == "Tavern":
		get_node("TavernDungeon").visible = true
		get_node("TavernDungeon/Characters/Bartender").set_hidden(false)
		get_node("Restaurant").visible = false
	elif _theme == "Restaurant":
		get_node("TavernDungeon").visible = false
		get_node("TavernDungeon/Characters/Bartender").set_hidden(true)
		get_node("Restaurant").visible = true
		
	pass # Replace with function body.

func reset() -> void:
	_ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
