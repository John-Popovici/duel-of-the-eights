extends Button

var toCall: Callable
var maxPlays: int
var settings: Dictionary
var disable: bool
@onready var plays: int = 0
var game_manager
var player
var scoreCalc

var baseName: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.connect("pressed",self.playHand)
	var game_managers = get_tree().get_nodes_in_group("SingleGameManager")
	if game_managers.size() > 0:
		game_manager = game_managers[0]
		player = game_manager.myPlayer
		scoreCalc = game_manager.scoreCalc
		connect("mouse_entered", _on_mouse_entered)
		connect("mouse_exited", _reset)
	pass # Replace with function body.

func playHand() -> void:
	plays += 1
	_reset()
	textChangeable = false
	prevState = ""
	
	var rolls = player.getRolls()
	if (plays >= maxPlays or (self.settings.get("hand_type")[0] == "Yahtzee" and scoreCalc.calculate_hand_score(settings,rolls)[0] == 0)):
		self.disabled = true
		disable = true
		
	toCall.call(settings, self)
	await get_tree().create_timer(1.0).timeout
	prevState = self.text
	textChangeable = true
	
	# handle yahtzee specific rules
	if (not disable) and (self.settings.get("hand_type")[0] == "Yahtzee"):
		scoreCalc.setYahtzeeCount(plays+1)
	

var textChangeable = true

func setText(_text: String):
	if textChangeable:
		self.text = _text

func setBaseName(_text: String):
	self.baseName = _text

func getDisable() ->bool:
	return disable

func setMaxPlays(_max: int) -> void:
	maxPlays = _max

func setSettings(_settings: Dictionary) -> void:
	settings = _settings

func setCallable(_call: Callable) -> void:
	toCall = _call

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

var prevState = "Select"

func _on_mouse_entered() -> void:
	#Debugger.log("Hover started","Testing")
	if player == null or self.disabled or !textChangeable:
		#Debugger.log("Returned on Hover","Testing")
		return
	var rolls = player.getRolls()
	Debugger.log(str(rolls))
	prevState = self.text
	Debugger.log("Prev State: " + prevState)
	var handScore = scoreCalc.calculate_hand_score(settings,rolls)
	Debugger.log("HandScore: " + str(handScore))
	if !(typeof(scoreCalc.calculate_hand_score(settings,rolls)) == typeof(0)):
		handScore = handScore[0]
	if prevState == "Select":
		setText(str(handScore))
	else:
		setText(str(int(prevState) + handScore))
	pass # Replace with function body.


func _reset() -> void:
	#Debugger.log("Resetting","Testing")
	if player == null or self.disabled or prevState == "":
		return
	setText(str(prevState))
	#prevState = "Select"
	pass # Replace with function body.
