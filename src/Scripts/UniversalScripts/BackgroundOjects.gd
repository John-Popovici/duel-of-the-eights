extends Node3D

var _theme = "Tavern"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_theme = GlobalSettings.globalTheme
	#_theme = "Restaurant"
	if _theme == "Tavern":
		TavernState(true)
		RestaurantState(false)
	elif _theme == "Restaurant":
		TavernState(false)
		RestaurantState(true)
		
	pass # Replace with function body.

func TavernState(state: bool) -> void:
	get_node("TavernDungeon").visible = state
	get_node("TavernDungeon/Characters/Bartender").set_hidden(!state)
	get_node("TavernDungeon/Characters/Mage").set_hidden(!state)
	get_node("TavernDungeon/Characters/Rogue_Hooded").set_hidden(!state)

func RestaurantState(state: bool) -> void:
	get_node("Restaurant").visible = state

func reset() -> void:
	_ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
