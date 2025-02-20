extends CanvasLayer

@onready var diceCustomization = get_node("BackPanel/Sections/DiceCustomization")
@onready var themeCustomization = get_node("BackPanel/Sections/ThemeCustomization")
@onready var camera = get_parent().get_node("DiceDisplay/CameraController/Camera3D")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_node("BackPanel/Sections/BackToHomeButton").connect("pressed",returnToIntro)
	diceCustomization.visible = true
	themeCustomization.visible = false
	_generate_dice_tex_options_buttons()


func _generate_dice_tex_options_buttons() -> void:
	for child in $BackPanel/Sections/DiceCustomization/MainDiceTextures.get_children():
		child.queue_free()
	for tex in GlobalSettings.allDiceTextures:
		var button = load("res://NodeScene/button.tscn").instantiate()
		button.text = str(tex)
		button.pressed.connect(_select_dice_tex.bind(GlobalSettings.allDiceTextures[tex],1))
		$BackPanel/Sections/DiceCustomization/MainDiceTextures.add_child(button)
	for child in $BackPanel/Sections/DiceCustomization/SelectedDiceTextures.get_children():
		child.queue_free()
	for tex in GlobalSettings.allDiceTextures:
		var button = load("res://NodeScene/button.tscn").instantiate()
		button.text = str(tex)
		button.pressed.connect(_select_dice_tex.bind(GlobalSettings.allDiceTextures[tex],2))
		$BackPanel/Sections/DiceCustomization/SelectedDiceTextures.add_child(button)
	for child in $BackPanel/Sections/DiceCustomization/DiceBaseTextures.get_children():
		child.queue_free()
	for tex in GlobalSettings.allDiceTextures:
		var button = load("res://NodeScene/button.tscn").instantiate()
		button.text = str(tex)
		button.pressed.connect(_select_dice_tex.bind(GlobalSettings.allDiceTextures[tex],3))
		$BackPanel/Sections/DiceCustomization/DiceBaseTextures.add_child(button)

func _select_dice_tex(_tex, _layer) -> void:
	match _layer:
		1:
			GlobalSettings.normalDiceTex = _tex
		2:
			GlobalSettings.selectedDiceTex = _tex
		3:
			GlobalSettings.dicebaseTex = _tex
	_reset_dice()

func _reset_dice()->void:
	get_parent().get_node("DiceDisplay/D6Display/Six_Dice").reset_dice_tex()
	get_parent().get_node("DiceDisplay/D8Display/EightDice").reset_dice_tex()
	get_parent().get_node("DiceDisplay/D4Display/FourDice").reset_dice_tex()
	get_parent().get_node("DiceDisplay/D12Display/TwelveDice").reset_dice_tex()

func changeTheme()->void:
	pass

func returnToIntro() -> void:
	get_parent().returnToIntro()
	#SceneSwitcher.returnToIntro()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_dice_pressed() -> void:
	diceCustomization.visible = true
	themeCustomization.visible = false


func _on_theme_pressed() -> void:
	diceCustomization.visible = false
	themeCustomization.visible = true


func _on_tavern_pressed() -> void:
	GlobalSettings.globalTheme = "Tavern"
	camera.get_node("Background_Movement/BackgroundObjects")._ready()


func _on_restaurant_pressed() -> void:
	GlobalSettings.globalTheme = "Restaurant"
	camera.get_node("Background_Movement/BackgroundObjects")._ready()
